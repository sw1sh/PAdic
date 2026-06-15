(* :Title: PAdic *)
(* :Context: Wolfram`PAdic` *)
(* :Summary:
    Utilities for p-adic numbers: the valuation v_p, the absolute value
    |x|_p, base-p digit expansions of integers and rationals (extending
    RealDigits with little-endian, negative-power-of-p indices for
    Q_p \ Z_p elements), Hensel lifting (the p-adic Newton iteration),
    a computable PAdicNumber object whose UpValues route Plus / Times /
    Power / Norm through Z_p arithmetic, and a handful of visualisations
    (digit bar chart, p-adic tree, Kummer/Sierpinski-style valuation
    array).

    The kernel is dependency-free and works on Integer / Rational
    inputs. Each public symbol's usage line names its math notation;
    the docs in docs/Symbols/ spell out the same notation inline so the
    reader can match the formula in the page to the kernel function.
*)

BeginPackage["Wolfram`PAdic`"]

PAdicValuation::usage = "PAdicValuation[x, p] gives the p-adic valuation v_p(x): the largest integer n with p^n dividing x, taking value Infinity at x = 0 and extending to rationals as v_p(a/b) = v_p(a) - v_p(b)."

PAdicNorm::usage = "PAdicNorm[x, p] gives the p-adic absolute value |x|_p = p^(-v_p(x)), with |0|_p = 0."

PAdicDigits::usage = "PAdicDigits[x, p] gives {{a_0, a_1, ..., a_{k-1}}, j} for x = sum_{i=0..k-1} a_i p^(i+j), the little-endian base-p expansion of x in Q_p shifted so the first digit sits at position p^j. PAdicDigits[x, p, n] truncates to n digits after the leading one. Negative j means x has factors of p in its denominator (x in Q_p but not Z_p)."

HenselLift::usage = "HenselLift[f, a, p, n] returns the unique a' in Z/p^n with f(a') = 0 mod p^n and a' = a mod p, computed by the p-adic Newton iteration a := a - f(a) / f'(a) (mod p^k) doubling the precision each step. Requires f(a) = 0 mod p and f'(a) != 0 mod p (Hensel's hypothesis); returns $Failed when the derivative vanishes mod p."

PAdicNumber::usage = "PAdicNumber[p, x, n] represents the p-adic integer x mod p^n - an element of Z/p^n Z viewed as an approximation to a p-adic integer with precision n. PAdicNumber[p, x] uses the default precision Infinity, storing an Integer or Rational value exactly. PAdicNumber[p, f] with f a pure function k :-> (residue mod p^k) represents a *lazy* element of Z_p - a coherent residue sequence - for genuinely irrational p-adics (e.g. the 10-adic idempotents) that have no closed form; arithmetic composes generators and precision is pulled by Mod / PAdicDigits / truncation. The object carries UpValues for Plus, Times, Subtract, Power, Equal, Mod, Abs, and Norm, so Z_p arithmetic compose naturally: PAdicNumber[7, 3, 4] + PAdicNumber[7, 5, 4] -> PAdicNumber[7, 8, 4]. Mixed-arity Integer or Rational operands are auto-coerced. Negative input is reduced to a positive residue via x mod p^n (so PAdicNumber[7, -1, 4] is the canonical 7^4 - 1)."

PAdicNumberQ::usage = "PAdicNumberQ[x] tests whether x is a normalised PAdicNumber expression."

PAdicDigitPlot::usage = "PAdicDigitPlot[x, p, n] renders the first n base-p digits of x as a labelled bar chart, the digit value on the y-axis against the power-of-p position on the x-axis. The bar at position k has height a_k where x = sum a_i p^(i+j); the chart annotation reports the leading shift j."

PAdicTree::usage = "PAdicTree[p, depth] returns the tree whose leaves are the residues mod p^depth, with each internal node at level k representing the disk of p-adic integers congruent mod p^k. The graph layout makes the ultrametric structure visible: the closer two leaves are in the tree, the closer they are p-adically."

PAdicValuationArray::usage = "PAdicValuationArray[p, n] returns the n x n ArrayPlot whose (i, j) cell is colored by the p-adic valuation v_p(binomial(i+j, j)). By Kummer's theorem this is the number of carries when adding j to i in base p, and the picture is the Sierpinski-style fractal that is the canonical visualisation of p-adic structure inside the integers."

Begin["`Private`"]


(* === valuation === *)

PAdicValuation[0, _Integer ? Positive] := Infinity

PAdicValuation[x_Integer, p_Integer ? Positive] /; p >= 2 :=
    IntegerExponent[x, p]

PAdicValuation[x_Rational, p_Integer ? Positive] /; p >= 2 :=
    PAdicValuation[Numerator[x], p] - PAdicValuation[Denominator[x], p]

(* PAdicNumber objects answer the valuation question against their precision -
   the valuation is at most n - 1 (the residue is in [0, p^n) so the most
   factors of p it can carry is the residue itself). *)
PAdicValuation[PAdicNumber[p_, x_, _], p_] /; numQ[x] := If[x === 0, Infinity, IntegerExponent[x, p]]
(* lazy: read the valuation off enough forced digits (the count of leading
   zero digits); all-zero to that depth reports Infinity. *)
PAdicValuation[PAdicNumber[p_, f_Function, _], p_] :=
    With[{r = Mod[f[$lazyEqualDigits], p^$lazyEqualDigits]},
        If[r === 0, Infinity, IntegerExponent[r, p]]
    ]


(* === norm === *)

PAdicNorm[0, _Integer ? Positive] := 0

PAdicNorm[x_ ? NumericQ, p_Integer ? Positive] /; p >= 2 :=
    p ^ (- PAdicValuation[x, p])

PAdicNorm[pa_PAdicNumber, p_Integer] := p ^ (- PAdicValuation[pa, p])


(* === digits === *)

$defaultDigits = 20

intDigitsLittleEndian[x_Integer ? NonNegative, p_, n_] :=
    PadRight[Reverse @ IntegerDigits[x, p], n]

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
        shifted = p^n - unit;
        {intDigitsLittleEndian[shifted, p, n], v}
    ]

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
        residue = Mod[unitNum * PowerMod[unitDen, -1, p^n], p^n];
        {intDigitsLittleEndian[residue, p, n], vn - vd}
    ]

PAdicDigits[x_ ? NumericQ, p_Integer ? Positive] :=
    PAdicDigits[x, p, $defaultDigits]

(* Digits of a PAdicNumber go through residueAt, so the same code serves a
   finite residue, an exact rational, and a lazy generator. With an explicit
   count k the value is forced to k digits; without one a finite-precision
   object uses its precision and an exact / lazy one uses $defaultDigits. *)
PAdicDigits[PAdicNumber[p_, v_, _], q_Integer, k_Integer ? Positive] :=
    {intDigitsLittleEndian[residueAt[v, p, k], p, k], 0}
PAdicDigits[pn : PAdicNumber[p_, _, prec_]] :=
    PAdicDigits[pn, p, If[IntegerQ[prec], prec, $defaultDigits]]
PAdicDigits[pn : PAdicNumber[p_, _, _], p_] := PAdicDigits[pn]


(* === Hensel lifting === *)

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

HenselLift[f_, a_Integer, p_Integer ? Positive, n_Integer ? Positive] /; p >= 2 :=
    Block[{a0 = Mod[a, p], deriv, lifted, target = p^n},
        deriv = Mod[henselDerivative[f, a0], p];
        If[ deriv === 0,
            $Failed,
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


(* === PAdicNumber: a computable Z_p element ===
   Stored canonically as PAdicNumber[p, residue, n]. For finite precision n,
   the residue is an integer in [0, p^n). For PRECISION = Infinity, the
   residue is the exact Integer or Rational input - the constructor stores
   it verbatim and arithmetic is exact. Truncate to a finite precision via
   `PAdicNumber[p, paInfinity, n]` or `Mod[paInfinity, p^n]`.

   The UpValues below route Plus / Times / Subtract / Power / Equal / Mod /
   Abs / Norm through Z/p^n arithmetic (or exact rational arithmetic at
   Infinity precision). Operations on two PAdicNumbers with the same prime
   take the Min of their precisions - the right loss-of-precision rule
   because a sum of two p-adic numbers known to precision n and m is known
   to precision Min[n, m]; Min[Infinity, n] = n leaves the finite-precision
   side governing.

   Mixed arithmetic with plain Integer / Rational works by coercing the
   non-PAdic operand into a PAdicNumber at the existing precision. *)

$defaultPrecision = Infinity

PAdicNumberQ[PAdicNumber[_Integer, _Integer | _Rational, _Integer | Infinity]] := True
(* A lazy element carries a coherent generator (a Function) in the value
   slot and is always at Infinity precision - see the lazy section below. *)
PAdicNumberQ[PAdicNumber[_Integer, _Function, Infinity]] := True
PAdicNumberQ[_] := False

(* Infinity-precision constructor: the canonical form for an exact Z_p value
   is PAdicNumber[p, x, Infinity] with x an Integer or a Rational with no p
   in its denominator. We only emit a *rewrite* rule for the *invalid* case
   (rational with p in the denominator), so the valid canonical form is
   inert and does not loop. *)
PAdicNumber[p_Integer ? Positive, x_Rational, Infinity] /;
    p >= 2 && IntegerExponent[Denominator[x], p] > 0 :=
        (Message[PAdicNumber::nzp, x, p]; $Failed)

(* Truncating an Infinity-precision number to finite precision: route through
   the finite-precision constructor on the exact value. *)
PAdicNumber[p_Integer ? Positive, PAdicNumber[p_, x_, Infinity], n_Integer ? Positive] :=
    PAdicNumber[p, x, n]

(* Canonicalise finite-precision integer residues into [0, p^n). *)
PAdicNumber[p_Integer ? Positive, x_Integer, n_Integer ? Positive] /;
    p >= 2 && ! (0 <= x < p^n) := PAdicNumber[p, Mod[x, p^n], n]

PAdicNumber[p_Integer ? Positive, x_Rational, n_Integer ? Positive] /; p >= 2 :=
    Block[{num = Numerator[x], den = Denominator[x], vd, residue},
        vd = IntegerExponent[den, p];
        If[ vd > 0,
            Message[PAdicNumber::nzp, x, p];
            $Failed,
            residue = Mod[num * PowerMod[den, -1, p^n], p^n];
            PAdicNumber[p, residue, n]
        ]
    ]

(* Default precision: Infinity, so PAdicNumber[7, 3] is the exact 3 in Z_7. *)
PAdicNumber[p_Integer ? Positive, x_ ? NumericQ] /; p >= 2 :=
    PAdicNumber[p, x, $defaultPrecision]

(* === lazy (generator-valued) Z_p elements ===

   A genuinely irrational p-adic integer - the 10-adic idempotents, a
   Teichmuller representative, any non-eventually-periodic digit stream -
   has no closed-form value to store. We encode it the way Z_p is *defined*,
   as the inverse limit lim Z/p^n: a coherent generator, a pure function
   gen: k |-> (residue mod p^k) with gen[k + 1] = gen[k] (mod p^k). Such a
   Function may sit in the value slot of an Infinity-precision PAdicNumber.
   Arithmetic composes generators lazily and precision is *pulled* - by
   truncation, Mod, or PAdicDigits - never pushed; nothing is forced until
   a concrete digit count is asked for.

   PAdicNumber[p, f] with f a Function is the canonical lazy element; giving
   it a finite precision forces f to that many digits. *)
PAdicNumber[p_Integer ? Positive, f_Function] /; p >= 2 := PAdicNumber[p, f, Infinity]
PAdicNumber[p_Integer ? Positive, f_Function, n_Integer ? Positive] /; p >= 2 :=
    PAdicNumber[p, Mod[f[n], p^n], n]

(* Tests for the two value shapes a PAdicNumber can carry. *)
numQ[x_] := MatchQ[x, _Integer | _Rational]
genQ[x_] := MatchQ[x, _Function]

(* residueAt is the single primitive every lazy operation forces through:
   the residue of a stored value at precision k. The k_Integer constraint is
   load-bearing - it keeps residueAt *inert* on a symbolic / Slot argument,
   so composing generators below never applies anything until a real digit
   count arrives. *)
residueAt[x_Integer, p_, k_Integer] := Mod[x, p^k]
residueAt[x_Rational, p_, k_Integer] := Mod[Numerator[x] PowerMod[Denominator[x], -1, p^k], p^k]
residueAt[f_Function, p_, k_Integer] := Mod[f[k], p^k]

(* Compose stored values into a new generator. Slot form is safe because
   residueAt stays unevaluated until the result is applied to an Integer, and
   any operand that is itself a Function shields its own slots. *)
lazyBinary[op_, p_, a_, b_] := Function[Mod[op[residueAt[a, p, #], residueAt[b, p, #]], p^#]]
lazyPower[p_, a_, k_Integer ? Positive] := Function[Mod[residueAt[a, p, #]^k, p^#]]
lazyPower[p_, a_, k_Integer ? Negative] := Function[PowerMod[residueAt[a, p, #], k, p^#]]

(* Equality involving a lazy value cannot be decided exactly (no finite
   number of digits proves two coherent sequences equal); we check the first
   $lazyEqualDigits digits and document the limitation. *)
$lazyEqualDigits = 64

(* Mod[lazy, m]: a p-adic integer maps to Z/mZ only when m divides some p^k;
   force to the least such k. (For m built from other primes the value is
   not determined - we force a generous default rather than loop.) *)
lazyModPrec[_, 1] := 1
lazyModPrec[p_, m_Integer] :=
    If[ SubsetQ[FactorInteger[p][[All, 1]], FactorInteger[m][[All, 1]]],
        Max[Ceiling[#[[2]] / IntegerExponent[p, #[[1]]]] & /@ FactorInteger[m]],
        $lazyEqualDigits
    ]

PAdicNumber::nzp = "The rational `1` has the prime `2` in its denominator and so is not in Z_p; PAdicNumber currently models only Z_p elements."

(* Coerce a non-PAdic numeric operand into a PAdicNumber sharing the
   prime / precision of the other side. *)
coerceTo[k_Integer | k_Rational, p_, n_] := PAdicNumber[p, k, n]
coerceTo[x_PAdicNumber, _, _] := x

(* Reduce a residue mod p^n - or pass through unchanged when n is Infinity. *)
reduceMod[x_, _, DirectedInfinity[1]] := x
reduceMod[x_, p_, n_Integer] := Mod[x, p^n]

(* Plus / Subtract: add residues, take Min of precisions. *)
PAdicNumber /: Plus[PAdicNumber[p_, a_, n_], PAdicNumber[p_, b_, m_]] /; numQ[a] && numQ[b] :=
    PAdicNumber[p, a + b, Min[n, m]]
(* lazy companion: if either side is a generator, compose lazily when both
   are exact (Min precision Infinity), else force both to the finite Min. *)
PAdicNumber /: Plus[PAdicNumber[p_, a_, n_], PAdicNumber[p_, b_, m_]] /; genQ[a] || genQ[b] :=
    With[{k = Min[n, m]},
        If[ k === Infinity,
            PAdicNumber[p, lazyBinary[Plus, p, a, b], Infinity],
            PAdicNumber[p, Mod[residueAt[a, p, k] + residueAt[b, p, k], p^k], k]
        ]
    ]
PAdicNumber /: Plus[pa : PAdicNumber[p_, _, n_], k : (_Integer | _Rational)] :=
    pa + coerceTo[k, p, n]

(* Times: same. *)
PAdicNumber /: Times[PAdicNumber[p_, a_, n_], PAdicNumber[p_, b_, m_]] /; numQ[a] && numQ[b] :=
    PAdicNumber[p, a * b, Min[n, m]]
PAdicNumber /: Times[PAdicNumber[p_, a_, n_], PAdicNumber[p_, b_, m_]] /; genQ[a] || genQ[b] :=
    With[{k = Min[n, m]},
        If[ k === Infinity,
            PAdicNumber[p, lazyBinary[Times, p, a, b], Infinity],
            PAdicNumber[p, Mod[residueAt[a, p, k] * residueAt[b, p, k], p^k], k]
        ]
    ]
PAdicNumber /: Times[pa : PAdicNumber[p_, _, n_], k : (_Integer | _Rational)] :=
    pa * coerceTo[k, p, n]
PAdicNumber /: Times[-1, PAdicNumber[p_, a_, n_]] /; numQ[a] := PAdicNumber[p, -a, n]

(* Power: integer exponent. Finite precision uses PowerMod for speed; infinite
   precision falls back to ordinary Power (the result is an exact Rational /
   Integer in Z_p whenever the base is a unit, and Power of the residue
   otherwise - which is correct because exact arithmetic in Z_p is just
   ordinary Rational arithmetic when no factor of p is in any denominator).
   Negative exponent requires the residue to be a p-adic unit. *)
PAdicNumber /: Power[PAdicNumber[p_, a_, DirectedInfinity[1]], k_Integer] /; numQ[a] :=
    PAdicNumber[p, a^k, Infinity]
(* lazy companion: a generator raised to an integer power is a generator. *)
PAdicNumber /: Power[PAdicNumber[p_, f_, DirectedInfinity[1]], k_Integer] /; genQ[f] && k != 0 :=
    PAdicNumber[p, lazyPower[p, f, k], Infinity]
PAdicNumber /: Power[PAdicNumber[p_, a_, n_Integer], k_Integer] /; k > 0 :=
    PAdicNumber[p, PowerMod[a, k, p^n], n]
PAdicNumber /: Power[PAdicNumber[p_, a_, n_Integer], -1] /; CoprimeQ[a, p] :=
    PAdicNumber[p, PowerMod[a, -1, p^n], n]
PAdicNumber /: Power[PAdicNumber[p_, a_, n_Integer], k_Integer] /; k < 0 && CoprimeQ[a, p] :=
    PAdicNumber[p, PowerMod[a, k, p^n], n]

(* Equality: same prime, same residue at the lower precision. *)
PAdicNumber /: Equal[PAdicNumber[p_, a_, n_], PAdicNumber[p_, b_, m_]] /; numQ[a] && numQ[b] :=
    With[{prec = Min[n, m]},
        If[ prec === Infinity, a === b, Mod[a - b, p^prec] === 0 ]
    ]
(* lazy companion: with a generator on either side, exact equality is not
   decidable - compare the first $lazyEqualDigits digits (or the finite Min
   precision, if one side is a truncation). *)
PAdicNumber /: Equal[PAdicNumber[p_, a_, n_], PAdicNumber[p_, b_, m_]] /; genQ[a] || genQ[b] :=
    With[{prec = Min[n, m] /. Infinity -> $lazyEqualDigits},
        Mod[residueAt[a, p, prec] - residueAt[b, p, prec], p^prec] === 0
    ]
PAdicNumber /: Equal[pa : PAdicNumber[p_, _, n_], k : (_Integer | _Rational)] :=
    pa == coerceTo[k, p, n]

(* Abs / Norm route through PAdicNorm so the same |.|_p convention is used
   everywhere. *)
PAdicNumber /: Abs[pa : PAdicNumber[p_, _, _]] := PAdicNorm[pa, p]
PAdicNumber /: Norm[pa_PAdicNumber] := Abs[pa]

(* Mod[PAdicNumber, m] returns the residue as an Integer - the "lift back
   to Z" operation. Accepts any positive Integer; works at both finite and
   infinite precision. *)
PAdicNumber /: Mod[PAdicNumber[_, a_Integer, _], m_Integer ? Positive] := Mod[a, m]
PAdicNumber /: Mod[PAdicNumber[p_, a_Rational, _], m_Integer ? Positive] :=
    Block[{num = Numerator[a], den = Denominator[a]},
        Mod[num * PowerMod[den, -1, m], m]
    ]
(* lazy: force the generator just deep enough that m divides p^k. *)
PAdicNumber /: Mod[PAdicNumber[p_, f_Function, _], m_Integer ? Positive] :=
    Mod[f[lazyModPrec[p, m]], m]

(* Format: a SummaryBox following the FiniteFieldElement convention, with
   Prime / Precision in the always-visible row and an expanded view showing
   the residue and its base-p digit shape. The icon is a tiny 4x4 swatch
   of the p-adic valuation array - a recognisable Sierpinski-style cue. *)

padicIcon[p_] := With[{n = 4},
    Graphics[
        Raster @ Table[
            ColorData["SunsetColors"][Min[1., PAdicValuation[Binomial[i + j, j], p] / 3.]],
            {i, 0, n - 1}, {j, 0, n - 1}
        ],
        ImageSize -> {Automatic, Dynamic[3.5 CurrentValue["FontCapHeight"] / AbsoluteCurrentValue[Magnification]]},
        PlotRangePadding -> None,
        Frame -> True, FrameTicks -> None,
        FrameStyle -> Directive[Opacity[0.5], Thickness[Tiny], RGBColor[0.36, 0.51, 0.71]]
    ]
]

padicResidueLabel[p_, a_, n_] := With[
    {digits = If[ n === Infinity, $Failed, First @ PAdicDigits[a, p, Min[n, 8]] ]},
    If[ digits === $Failed,
        ToString[a, StandardForm],
        Row[{a, " = ", Row[Riffle[Reverse[digits], "\:2009"]], If[n > 8, " \[Ellipsis]", ""], " (base ", p, ")"}]
    ]
]

PAdicNumber /: MakeBoxes[pa : PAdicNumber[p_Integer, a_, n_], form : (StandardForm | TraditionalForm)] /; numQ[a] :=
    BoxForm`ArrangeSummaryBox[
        PAdicNumber,
        pa,
        padicIcon[p],
        {
            BoxForm`SummaryItem[{"Prime: ", p}],
            BoxForm`SummaryItem[{"Precision: ", n}]
        },
        {
            BoxForm`SummaryItem[{"Residue: ", padicResidueLabel[p, a, n]}],
            BoxForm`SummaryItem[{"Compact form: ",
                Row[{a, " + O(", Superscript[p, n], ")"}]
            }]
        },
        form
    ]

(* A lazy element shows its first forced digits and flags the precision as
   infinite-on-demand rather than a stored residue. *)
(* MakeBoxes is HoldAllComplete, so match the evaluated DirectedInfinity[1]
   rather than the held symbol Infinity (which would never match). *)
PAdicNumber /: MakeBoxes[pa : PAdicNumber[p_Integer, f_Function, DirectedInfinity[1]], form : (StandardForm | TraditionalForm)] :=
    With[{digits = Reverse @ First @ PAdicDigits[pa, p, 8]},
        BoxForm`ArrangeSummaryBox[
            PAdicNumber,
            pa,
            padicIcon[p],
            {
                BoxForm`SummaryItem[{"Prime: ", p}],
                BoxForm`SummaryItem[{"Precision: ", Row[{"\[Infinity]", " (lazy)"}]}]
            },
            {
                BoxForm`SummaryItem[{"Digits: ", Row[{"\[Ellipsis]\:2009", Row[Riffle[digits, "\:2009"]], " (base ", p, ")"}]}],
                BoxForm`SummaryItem[{"Form: ", "coherent residue sequence"}]
            },
            form
        ]
    ]


(* === Visualisations === *)

(* PAdicDigitPlot: a labelled bar chart of the first n base-p digits of x.
   Bar k has height a_k; the y-axis runs 0..p-1; the chart annotation
   reports the leading shift j. *)
PAdicDigitPlot[x_, p_Integer ? Positive, n_Integer ? Positive] /; p >= 2 :=
    Block[{ds = PAdicDigits[x, p, n], digits, j},
        digits = First[ds]; j = Last[ds];
        BarChart[digits,
            ChartLabels -> Range[0, n - 1] + j,
            PlotRange -> {Automatic, {0, p - 1}},
            PlotLabel -> Row[{"first ", n, " base-", p, " digits of ", x, " starting at position p^", j}],
            AxesLabel -> {"position", "digit"},
            ChartStyle -> "Pastel"
        ]
    ]

PAdicDigitPlot[pa_PAdicNumber] :=
    Block[{p = pa[[1]], n = pa[[3]]}, PAdicDigitPlot[Mod[pa[[2]], p^n], p, n]]

(* PAdicTree: a graph whose leaves are residues mod p^depth and whose
   internal nodes are residues mod p^k for k < depth. Two leaves share an
   ancestor at level k iff they agree mod p^k - exactly the ultrametric
   neighbourhood structure of Z_p. Edges connect each node at level k to
   the p children obtained by appending one more digit. *)
PAdicTree[p_Integer ? Positive, depth_Integer ? NonNegative] /; p >= 2 :=
    Block[{nodes, edges},
        nodes = Catenate @ Table[Table[{k, r}, {r, 0, p^k - 1}], {k, 0, depth}];
        edges = Catenate @ Table[
            With[{r = Last[node], k = First[node]},
                Table[node -> {k + 1, r + d p^k}, {d, 0, p - 1}]
            ],
            {node, Select[nodes, First[#] < depth &]}
        ];
        Graph[nodes, edges,
            GraphLayout -> "LayeredEmbedding",
            VertexLabels -> Placed[Automatic, Tooltip],
            VertexStyle -> Directive[PointSize[Medium], LightDarkSwitched[Black, White]],
            EdgeStyle -> Directive[Opacity[0.4], LightDarkSwitched[Gray, LightGray]]
        ]
    ]

(* PAdicValuationArray: the Kummer/Sierpinski fractal - an n x n array
   coloured by v_p(binomial(i+j, j)), the number of carries when adding j
   to i in base p. The pattern is the canonical visualisation of p-adic
   structure inside the integers. *)
PAdicValuationArray[p_Integer ? Positive, n_Integer ? Positive] /; p >= 2 :=
    ArrayPlot[
        Table[PAdicValuation[Binomial[i + j, j], p], {i, 0, n - 1}, {j, 0, n - 1}],
        ColorFunction -> "SunsetColors",
        Frame -> False,
        PlotRangePadding -> None,
        PlotLabel -> Row[{p, "-adic valuations of ", n, "\[Times]", n, " Pascal triangle (Kummer / Sierpinski)"}]
    ]


End[]

EndPackage[]
