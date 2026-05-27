(* :Title: PAdic *)
(* :Context: Wolfram`PAdic` *)
(* :Summary:
    Utilities for p-adic numbers: the valuation v_p, the absolute value
    |x|_p, base-p digit expansions of integers and rationals (extending
    RealDigits with little-endian, negative-power-of-p indices for
    Q_p \ Z_p elements), and Hensel lifting (the p-adic Newton iteration
    that promotes a root mod p to a root mod p^n).

    The kernel is dependency-free and works on Integer / Rational inputs.
    Each public symbol's usage line names its math notation; the docs in
    docs/Symbols/ then spell out the same notation inline so the reader
    can match the formula in the page to the kernel function.
*)

BeginPackage["Wolfram`PAdic`"]

PAdicValuation::usage = "PAdicValuation[x, p] gives the p-adic valuation v_p(x): the largest integer n with p^n dividing x, taking value Infinity at x = 0 and extending to rationals as v_p(a/b) = v_p(a) - v_p(b)."

PAdicNorm::usage = "PAdicNorm[x, p] gives the p-adic absolute value |x|_p = p^(-v_p(x)), with |0|_p = 0."

PAdicDigits::usage = "PAdicDigits[x, p] gives {{a_0, a_1, ..., a_{k-1}}, j} for x = sum_{i=0..k-1} a_i p^(i+j), the little-endian base-p expansion of x in Q_p shifted so the first digit sits at position p^j. PAdicDigits[x, p, n] truncates to n digits after the leading one. Negative j means x has factors of p in its denominator (x in Q_p but not Z_p)."

HenselLift::usage = "HenselLift[f, a, p, n] returns the unique a' in Z/p^n with f(a') = 0 mod p^n and a' = a mod p, computed by the p-adic Newton iteration a := a - f(a) / f'(a) (mod p^k) doubling the precision each step. Requires f(a) = 0 mod p and f'(a) != 0 mod p (Hensel's hypothesis); returns $Failed when the derivative vanishes mod p."

Begin["`Private`"]


(* === valuation === *)

(* p-adic valuation of an integer: the largest e with p^e | x. IntegerExponent
   is the built-in for exactly this; we just route through it and handle the
   x = 0 case (v_p(0) = +Infinity, the convention that makes the ultrametric
   inequality and the |0|_p = 0 case fall out cleanly). *)

PAdicValuation[0, _Integer ? Positive] := Infinity

PAdicValuation[x_Integer, p_Integer ? Positive] /; p >= 2 :=
    IntegerExponent[x, p]

(* Rational case: v_p(a/b) = v_p(a) - v_p(b). The Integer rule above already
   handles each numerator / denominator individually. *)

PAdicValuation[x_Rational, p_Integer ? Positive] /; p >= 2 :=
    PAdicValuation[Numerator[x], p] - PAdicValuation[Denominator[x], p]


(* === norm === *)

(* |x|_p = p^(-v_p(x)), with |0|_p = 0 (the limit of p^(-n) as n -> +Inf). *)

PAdicNorm[0, _Integer ? Positive] := 0

PAdicNorm[x_ ? NumericQ, p_Integer ? Positive] /; p >= 2 :=
    p ^ (- PAdicValuation[x, p])


(* === digits === *)

(* Default digit count: enough to represent the input exactly when x is an
   Integer, and a reasonable truncation for rationals. *)
$defaultDigits = 20

(* Little-endian p-adic digits for a NON-NEGATIVE integer, returning a list
   of length exactly n (zero-padded on the right). IntegerDigits is the
   built-in but returns big-endian and minimum-width, so we reverse and pad. *)

intDigitsLittleEndian[x_Integer ? NonNegative, p_, n_] :=
    PadRight[Reverse @ IntegerDigits[x, p], n]

(* Digit expansion of an Integer. v_p(x) factors of p sit at the bottom of
   the expansion (so x = p^v_p(x) * unit), and the unit's digits are what we
   actually return. Negative integers: the p-adic expansion of -1 in base p
   is the infinite digit string {(p-1), (p-1), (p-1), ...}, so a negative x
   is x + p^n for large enough n (digit-wise the same as taking the
   two's-complement representation in the corresponding base). *)

PAdicDigits[0, p_Integer ? Positive, n_Integer ? Positive] /; p >= 2 :=
    {ConstantArray[0, n], 0}

PAdicDigits[x_Integer ? Positive, p_Integer ? Positive, n_Integer ? Positive] /; p >= 2 :=
    Block[{v = IntegerExponent[x, p], unit},
        unit = x / p^v;
        {intDigitsLittleEndian[unit, p, n], v}
    ]

PAdicDigits[x_Integer ? Negative, p_Integer ? Positive, n_Integer ? Positive] /; p >= 2 :=
    Block[{v = IntegerExponent[-x, p], unit, shifted},
        unit = (-x) / p^v;
        (* x' = p^n - unit shifts -unit to a positive representative mod p^n
           whose little-endian digits are the p-adic expansion of -unit. *)
        shifted = p^n - unit;
        {intDigitsLittleEndian[shifted, p, n], v}
    ]

(* Rational case: separate numerator from denominator factors of p, then
   compute the digits of (numerator * inverse(denominator) mod p^n). The
   trailing shift j is negative iff the denominator carried factors of p
   (x not in Z_p). *)

PAdicDigits[x_Rational, p_Integer ? Positive, n_Integer ? Positive] /; p >= 2 :=
    Block[
        {
            num = Numerator[x],
            den = Denominator[x],
            vn, vd, unitNum, unitDen, residue
        },
        vn = IntegerExponent[num, p];
        vd = IntegerExponent[den, p];
        unitNum = num / p^vn;
        unitDen = den / p^vd;
        (* unitDen is coprime to p by construction, so its inverse mod p^n
           exists and PowerMod returns it. The residue lives in [0, p^n). *)
        residue = Mod[unitNum * PowerMod[unitDen, -1, p^n], p^n];
        {intDigitsLittleEndian[residue, p, n], vn - vd}
    ]

(* Default n: 20 digits, enough for a comfortable look at any rational. *)

PAdicDigits[x_ ? NumericQ, p_Integer ? Positive] :=
    PAdicDigits[x, p, $defaultDigits]


(* === Hensel lifting === *)

(* The p-adic Newton iteration: given f(a) = 0 (mod p) and f'(a) != 0 (mod p),
   set a_{k+1} = a_k - f(a_k) / f'(a_k) (mod p^{2k}). The precision exactly
   doubles each step (classical Newton convergence), so reaching precision
   p^n takes ceil(log_2 n) iterations. We work polynomial-symbolically with
   f as a function, evaluate at a Mod[a, p^k] integer, and use PowerMod for
   the modular inverse of f'(a).

   The function f is anything callable with one numeric argument (a Function,
   a pure-polynomial Function[x, ...], an InterpretationBox sym, ...);
   D[f[x], x] /. x -> a gives the derivative. *)

henselDerivative[f_, a_] := Block[{x},
    D[f[x], x] /. x -> a
]

henselStep[f_, a_, p_, prec_] := Block[{fa, fpa, inv},
    fa = Mod[f[a], prec];
    fpa = Mod[henselDerivative[f, a], prec];
    inv = PowerMod[fpa, -1, prec];
    If[ MatchQ[inv, _PowerMod],
        $Failed,
        Mod[a - fa * inv, prec]
    ]
]

(* Drive Newton until the precision reaches p^n, doubling each iteration.
   Returns $Failed when the derivative vanishes mod p (Hensel's hypothesis
   fails) or when a step's modular inverse does not exist. *)

HenselLift[f_, a_Integer, p_Integer ? Positive, n_Integer ? Positive] /; p >= 2 :=
    Block[{a0 = Mod[a, p], deriv, lifted, target = p^n},
        deriv = Mod[henselDerivative[f, a0], p];
        If[ deriv === 0,
            $Failed,
            (* NestWhile threads (current approx, current precision) until
               precision meets target. Each step doubles precision (capped
               at target) so we never overshoot the requested modulus. *)
            lifted = NestWhile[
                Block[{newPrec = Min[target, #[[2]]^2]},
                    {henselStep[f, #[[1]], p, newPrec], newPrec}
                ] &,
                {a0, p},
                Last[#] < target &
            ];
            If[ MatchQ[First[lifted], $Failed], $Failed, First[lifted] ]
        ]
    ]


End[]

EndPackage[]
