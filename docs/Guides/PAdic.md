---
Template: Guide
Name: PAdic
Title: p-adic Numbers
Context: Wolfram`PAdic`
Paclet: Wolfram/PAdic
URI: Wolfram/PAdic/guide/PAdic
Description: p-adic valuations, norms, digit expansions, and Hensel lifting for the Wolfram Language.
Keywords: [p-adic, valuation, norm, ultrametric, Hensel lifting, number theory]
RelatedGuides: [NumberTheoreticFunctions]
Links: ["[p-adic number (Wikipedia)](https://en.wikipedia.org/wiki/P-adic_number)", "[Hensel's lemma (Wikipedia)](https://en.wikipedia.org/wiki/Hensel%27s_lemma)"]
---

## Abstract

The `PAdic` paclet adds the layer the Wolfram Language does not ship: for each prime $p$, a *p-adic valuation* $v_p$ and its derived *p-adic absolute value* $|x|_p = p^{-v_p(x)}$, the base-$p$ digit expansion of any element of $\mathbb{Q}_p$ (extending `IntegerDigits` and `RealDigits` to elements with infinitely many digits to the left and finitely many to the right of the "decimal" point), and the Hensel lift that promotes a root of a polynomial mod $p$ to a root mod $p^n$ via Newton iteration. The valuation alone is enough to recover the *ultrametric inequality* $|x + y|_p \le \max(|x|_p, |y|_p)$ that makes $\mathbb{Q}_p$ a strikingly different completion of $\mathbb{Q}$ from the familiar $\mathbb{R}$.

## Functions

### Valuation and norm
- `PAdicValuation` the p-adic valuation $v_p(x)$
- `PAdicNorm` the p-adic absolute value $|x|_p = p^{-v_p(x)}$

### Digit expansion
- `PAdicDigits` the base-$p$ digit expansion in $\mathbb{Q}_p$ (extends [RealDigits]() to the p-adic completion)

### Hensel lifting
- `HenselLift` the p-adic Newton iteration that lifts $f(a) \equiv 0 \pmod p$ to $f(\tilde a) \equiv 0 \pmod{p^n}$

### A computable p-adic integer
- `PAdicNumber` a [Z_p]() element carrying [UpValues]() for [Plus](), [Times](), [Power](), [Equal](), etc.
- `PAdicNumberQ` predicate for normalised `PAdicNumber` expressions

### Visualisations
- `PAdicDigitPlot` bar chart of the first $n$ base-$p$ digits of $x$
- `PAdicTree` the Cayley tree of residues mod $p^k$ - the ultrametric neighbourhood structure of $\mathbb{Z}_p$
- `PAdicValuationArray` the Kummer / Sierpinski fractal $v_p\binom{i+j}{j}$ as an [ArrayPlot]()
