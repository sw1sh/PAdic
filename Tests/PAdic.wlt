(* :Title: tests.wlt - PAdic test suite *)
(* :Context: Wolfram`PAdic` *)
(* :Summary:
    VerificationTest entries covering every documented behavior of the
    Wolfram`PAdic` paclet. Run via run-tests.wls (TestReport-based).
    Each test has a TestID with the shape "Symbol: behavior".
*)


(* === PAdicValuation === *)

VerificationTest[
    PAdicValuation[98, 7],
    2,
    TestID -> "PAdicValuation: 98 = 2 * 7^2 has 7-adic valuation 2"
]

VerificationTest[
    PAdicValuation[3/25, 5],
    -2,
    TestID -> "PAdicValuation: rational with p in denominator -> negative"
]

VerificationTest[
    PAdicValuation[0, 7],
    Infinity,
    TestID -> "PAdicValuation: v_p(0) = Infinity"
]

VerificationTest[
    {
        PAdicValuation[2520, 2], PAdicValuation[2520, 3],
        PAdicValuation[2520, 5], PAdicValuation[2520, 7]
    },
    {3, 2, 1, 1},
    TestID -> "PAdicValuation: different primes of 2520"
]

VerificationTest[
    PAdicValuation[7 + 49, 7],
    1,
    TestID -> "PAdicValuation: ultrametric strict equality case"
]

VerificationTest[
    With[{x = 21, y = 35, p = 7},
        PAdicValuation[x y, p] === PAdicValuation[x, p] + PAdicValuation[y, p]
    ],
    True,
    TestID -> "PAdicValuation: multiplicativity"
]


(* === PAdicNorm === *)

VerificationTest[
    PAdicNorm[49, 7],
    1/49,
    TestID -> "PAdicNorm: high power of p has small norm"
]

VerificationTest[
    PAdicNorm[1/7, 7],
    7,
    TestID -> "PAdicNorm: p in denominator has large norm"
]

VerificationTest[
    PAdicNorm[0, 7],
    0,
    TestID -> "PAdicNorm: |0|_p = 0"
]

VerificationTest[
    PAdicNorm[42, 5],
    1,
    TestID -> "PAdicNorm: p-adic unit has norm 1"
]

VerificationTest[
    With[{x = 7^2, y = 7^3, p = 7},
        PAdicNorm[x + y, p] <= Max[PAdicNorm[x, p], PAdicNorm[y, p]]
    ],
    True,
    TestID -> "PAdicNorm: ultrametric inequality"
]

VerificationTest[
    With[{x = 14, y = 21, p = 7},
        PAdicNorm[x y, p] === PAdicNorm[x, p] PAdicNorm[y, p]
    ],
    True,
    TestID -> "PAdicNorm: multiplicativity"
]

VerificationTest[
    With[{p = 7, n = 10},
        PAdicNorm[Sum[p^k, {k, 0, n}] - (-1/6), p]
    ],
    1/7^11,
    TestID -> "PAdicNorm: geometric series convergence (-1/6 limit)"
]


(* === PAdicDigits === *)

VerificationTest[
    PAdicDigits[100, 7, 5],
    {{2, 0, 2, 0, 0}, 0},
    TestID -> "PAdicDigits: 100 in base 7 (first 5 digits)"
]

VerificationTest[
    PAdicDigits[1/7, 7, 5],
    {{1, 0, 0, 0, 0}, -1},
    TestID -> "PAdicDigits: 1/7 starts at position p^-1"
]

VerificationTest[
    PAdicDigits[-1, 7, 6],
    {{6, 6, 6, 6, 6, 6}, 0},
    TestID -> "PAdicDigits: -1 is the infinite ...666"
]

VerificationTest[
    PAdicDigits[0, 7, 5],
    {{0, 0, 0, 0, 0}, 0},
    TestID -> "PAdicDigits: 0 is all zeros"
]

VerificationTest[
    PAdicDigits[1/3, 7, 6],
    {{5, 4, 4, 4, 4, 4}, 0},
    TestID -> "PAdicDigits: 1/3 periodic"
]

VerificationTest[
    With[{x = 1/3, p = 7, n = 20},
        Block[{ds = PAdicDigits[x, p, n]},
            PAdicValuation[Total[First[ds] p^(Range[0, n - 1] + Last[ds])] - x, p] >= n
        ]
    ],
    True,
    TestID -> "PAdicDigits: reconstruction to precision n"
]


(* === HenselLift === *)

VerificationTest[
    HenselLift[#^2 - 2 &, 3, 7, 4],
    2166,
    TestID -> "HenselLift: sqrt(2) in Z_7 from a=3, precision 4"
]

VerificationTest[
    Mod[2166^2 - 2, 7^4],
    0,
    TestID -> "HenselLift: lift verifies f(a) = 0 mod p^n"
]

VerificationTest[
    HenselLift[#^2 - 2 &, 4, 7, 4],
    235,
    TestID -> "HenselLift: other sqrt(2) root from a=4"
]

VerificationTest[
    HenselLift[#^2 - 1 &, 0, 2, 4],
    $Failed,
    TestID -> "HenselLift: failure when derivative vanishes mod p"
]

VerificationTest[
    HenselLift[#^3 - 2 &, 3, 5, 5],
    2178,
    TestID -> "HenselLift: cube root of 2 in Z_5"
]

VerificationTest[
    With[{a = 3, p = 7, n = 4},
        Mod[HenselLift[#^2 - 2 &, a, p, n], p] === Mod[a, p]
    ],
    True,
    TestID -> "HenselLift: agrees with seed mod p"
]


(* === PAdicNumber: constructors & equality === *)

VerificationTest[
    PAdicNumber[7, 3],
    PAdicNumber[7, 3, Infinity],
    TestID -> "PAdicNumber: default precision is Infinity"
]

VerificationTest[
    PAdicNumber[7, 3, 4],
    PAdicNumber[7, 3, 4],
    TestID -> "PAdicNumber: explicit precision construction"
]

VerificationTest[
    PAdicNumber[7, -1, 4],
    PAdicNumber[7, 2400, 4],
    TestID -> "PAdicNumber: negative reduces to positive residue"
]

VerificationTest[
    PAdicNumber[7, 1/6, 6],
    PAdicNumber[7, 98041, 6],
    TestID -> "PAdicNumber: rational coercion"
]

VerificationTest[
    PAdicNumber[7, 3, 4] == 3,
    True,
    TestID -> "PAdicNumber: equality with integer"
]

VerificationTest[
    PAdicNumber[7, 3, 4] == PAdicNumber[7, 5, 4],
    False,
    TestID -> "PAdicNumber: equality - different values"
]


(* === PAdicNumber: arithmetic === *)

VerificationTest[
    PAdicNumber[7, 3, 4] + PAdicNumber[7, 5, 4],
    PAdicNumber[7, 8, 4],
    TestID -> "PAdicNumber: Plus"
]

VerificationTest[
    PAdicNumber[7, 3, 4] * PAdicNumber[7, 5, 4],
    PAdicNumber[7, 15, 4],
    TestID -> "PAdicNumber: Times"
]

VerificationTest[
    PAdicNumber[7, 3, 4] + 5,
    PAdicNumber[7, 8, 4],
    TestID -> "PAdicNumber: mixed Plus with Integer"
]

VerificationTest[
    PAdicNumber[7, 3, 4] * (1/3),
    PAdicNumber[7, 1, 4],
    TestID -> "PAdicNumber: mixed Times with Rational"
]

VerificationTest[
    PAdicNumber[7, 3, 4]^-1,
    PAdicNumber[7, 1601, 4],
    TestID -> "PAdicNumber: inverse of a unit (finite precision)"
]

VerificationTest[
    PAdicNumber[7, 3]^-1,
    PAdicNumber[7, 1/3, Infinity],
    TestID -> "PAdicNumber: inverse at Infinity precision is exact"
]

VerificationTest[
    Abs[PAdicNumber[7, 49, 4]],
    1/49,
    TestID -> "PAdicNumber: Abs routes through PAdicNorm"
]

VerificationTest[
    PAdicValuation[PAdicNumber[7, 49, 4], 7],
    2,
    TestID -> "PAdicNumber: PAdicValuation accepts PC argument"
]

VerificationTest[
    Mod[PAdicNumber[7, 100, 4], 7^2],
    2,
    TestID -> "PAdicNumber: Mod lifts back to Integer"
]

VerificationTest[
    Mod[PAdicNumber[7, 1/3], 7^4],
    1601,
    TestID -> "PAdicNumber: Mod on Infinity-precision rational"
]


(* === PAdicNumber: Infinity-precision arithmetic === *)

VerificationTest[
    PAdicNumber[7, 3] + PAdicNumber[7, 5],
    PAdicNumber[7, 8, Infinity],
    TestID -> "PAdicNumber: Infinity-precision Plus stays exact"
]

VerificationTest[
    PAdicNumber[7, 3] * PAdicNumber[7, 5],
    PAdicNumber[7, 15, Infinity],
    TestID -> "PAdicNumber: Infinity-precision Times stays exact"
]

VerificationTest[
    PAdicNumber[7, PAdicNumber[7, -1], 4],
    PAdicNumber[7, 2400, 4],
    TestID -> "PAdicNumber: truncate Infinity to finite precision"
]

VerificationTest[
    PAdicNumber[7, 3] + PAdicNumber[7, 5, 4],
    PAdicNumber[7, 8, 4],
    TestID -> "PAdicNumber: mixed precision takes Min"
]

VerificationTest[
    With[{p = 7, n = 10},
        Total[Table[PAdicNumber[p, p^k, n + 1], {k, 0, n}]] == PAdicNumber[p, -1/6, n + 1]
    ],
    True,
    TestID -> "PAdicNumber: geometric series equals -1/6 in Z_7"
]


(* === PAdicNumberQ === *)

VerificationTest[
    PAdicNumberQ[PAdicNumber[7, 3, 4]],
    True,
    TestID -> "PAdicNumberQ: True for valid PC"
]

VerificationTest[
    PAdicNumberQ[PAdicNumber[7, 3]],
    True,
    TestID -> "PAdicNumberQ: True for Infinity precision"
]

VerificationTest[
    PAdicNumberQ[42],
    False,
    TestID -> "PAdicNumberQ: False for non-PC"
]


(* === PAdicNumber: lazy (generator-valued) Z_p elements ===
   The two nontrivial idempotents of Z_10 are genuinely irrational p-adics
   (no closed form), so they are encoded as coherent generators
   k :-> residue mod 10^k. P ends in 5, Q ends in 6, P + Q = 1, P Q = 0. *)

VerificationTest[
    PAdicNumberQ[PAdicNumber[10, Function[k, ChineseRemainder[{1, 0}, {2^k, 5^k}]]]],
    True,
    TestID -> "PAdicNumber lazy: PAdicNumberQ recognises a generator"
]

VerificationTest[
    With[{P = PAdicNumber[10, Function[k, ChineseRemainder[{1, 0}, {2^k, 5^k}]]]},
        P^2 == P],
    True,
    TestID -> "PAdicNumber lazy: idempotent P^2 == P"
]

VerificationTest[
    With[{Q = PAdicNumber[10, Function[k, ChineseRemainder[{0, 1}, {2^k, 5^k}]]]},
        Q^2 == Q],
    True,
    TestID -> "PAdicNumber lazy: idempotent Q^2 == Q"
]

VerificationTest[
    With[
        {
            P = PAdicNumber[10, Function[k, ChineseRemainder[{1, 0}, {2^k, 5^k}]]],
            Q = PAdicNumber[10, Function[k, ChineseRemainder[{0, 1}, {2^k, 5^k}]]]
        },
        {P + Q == 1, P*Q == 0}],
    {True, True},
    TestID -> "PAdicNumber lazy: complementary orthogonal idempotents"
]

VerificationTest[
    With[{P = PAdicNumber[10, Function[k, ChineseRemainder[{1, 0}, {2^k, 5^k}]]]},
        Mod[P, 10^12]],
    918212890625,
    TestID -> "PAdicNumber lazy: Mod forces the generator (P mod 10^12)"
]

VerificationTest[
    With[{P = PAdicNumber[10, Function[k, ChineseRemainder[{1, 0}, {2^k, 5^k}]]]},
        First @ PAdicDigits[P, 10, 6]],
    {5, 2, 6, 0, 9, 8},
    TestID -> "PAdicNumber lazy: PAdicDigits forces little-endian digits"
]

VerificationTest[
    With[{P = PAdicNumber[10, Function[k, ChineseRemainder[{1, 0}, {2^k, 5^k}]]]},
        PAdicNumber[10, P, 6]],
    PAdicNumber[10, 890625, 6],
    TestID -> "PAdicNumber lazy: truncation to finite precision evaluates"
]

VerificationTest[
    With[
        {
            P = PAdicNumber[10, Function[k, ChineseRemainder[{1, 0}, {2^k, 5^k}]]],
            Q = PAdicNumber[10, Function[k, ChineseRemainder[{0, 1}, {2^k, 5^k}]]]
        },
        P == Q],
    False,
    TestID -> "PAdicNumber lazy: distinct idempotents compare unequal"
]

VerificationTest[
    With[{P = PAdicNumber[10, Function[k, ChineseRemainder[{1, 0}, {2^k, 5^k}]]]},
        Abs[P]],
    1,
    TestID -> "PAdicNumber lazy: Abs of a unit idempotent is 1"
]

(* A lazy element can also wrap a Hensel lift: the precision-on-demand
   square root of 2 in Z_7. *)
VerificationTest[
    With[{s = PAdicNumber[7, Function[k, HenselLift[#^2 - 2 &, 3, 7, k]]]},
        s^2 == 2],
    True,
    TestID -> "PAdicNumber lazy: Hensel-lift generator is a square root of 2"
]


(* === Visualisations (smoke - check head only) === *)

VerificationTest[
    Head @ PAdicDigitPlot[100, 7, 5],
    Graphics,
    TestID -> "PAdicDigitPlot: returns Graphics"
]

VerificationTest[
    Head @ PAdicTree[3, 3],
    Graph,
    TestID -> "PAdicTree: returns Graph"
]

VerificationTest[
    VertexCount @ PAdicTree[2, 4],
    31,
    TestID -> "PAdicTree: vertex count = 1 + 2 + 4 + 8 + 16"
]

VerificationTest[
    Head @ PAdicValuationArray[2, 32],
    Graphics,
    TestID -> "PAdicValuationArray: returns Graphics"
]

VerificationTest[
    With[{p = 5, n = 12,
          tbl = Table[PAdicValuation[Binomial[i + j, j], p], {i, 0, 11}, {j, 0, 11}]
    },
        tbl === Transpose[tbl]
    ],
    True,
    TestID -> "PAdicValuationArray: symmetric (Binomial[i+j, j] = Binomial[i+j, i])"
]
