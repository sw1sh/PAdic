---
Template: Paclet
ResourceType: Paclet
Name: Wolfram/PAdic
Context: Wolfram`PAdic`
Paclet: Wolfram/PAdic
Description: p-adic numbers, valuations, digit expansions, and Hensel lifting for the Wolfram Language
ContributedBy: Nikolay Murzin, Claude (Anthropic)
Keywords: [p-adic, valuation, norm, ultrametric, Hensel lifting, number theory]
MainGuide: Documentation/English/Guides/PAdic.nb
License: MIT
WolframVersion: 14.0+
Categories: [Higher Mathematical Computation]
Sources: ["Neal Koblitz, *p-adic Numbers, p-adic Analysis, and Zeta-Functions*, Springer GTM 58, 2nd ed., 1984"]
SourceControlURL: https://github.com/sw1sh/PAdic
Links: ["[p-adic number (Wikipedia)](https://en.wikipedia.org/wiki/P-adic_number)", "[Hensel's lemma (Wikipedia)](https://en.wikipedia.org/wiki/Hensel%27s_lemma)"]
---

## Details & Options

- The paclet works on [Integer]() and [Rational]() inputs; the prime $p$ is any prime $\ge 2$.
- The p-adic *valuation* $v_p$, the *absolute value* $|x|_p = p^{-v_p(x)}$, and the *digit expansion* form a self-contained model of $\mathbb{Q}_p$ - the field of p-adic numbers, the non-archimedean completion of $\mathbb{Q}$.
- *Hensel's lemma* (the p-adic Newton iteration) lifts a simple root of a polynomial mod $p$ to a root mod $p^n$, with the precision doubling each step.

## Usage

The package provides [PAdicValuation](), [PAdicNorm](), [PAdicDigits](), and [HenselLift]().

## Basic Examples

The 7-adic valuation of $98 = 2 \cdot 7^2$:

```wl
PAdicValuation[98, 7]
```
<!-- => 2 -->

---

The 7-adic absolute value of the same integer:

```wl
PAdicNorm[98, 7]
```
<!-- => 1/49 -->

---

The 7-adic digit expansion of $1/3$ (a periodic sequence in $\mathbb{Z}_7^\times$):

```wl
PAdicDigits[1/3, 7, 6]
```
<!-- => {{5, 4, 4, 4, 4, 4}, 0} -->

---

Lift the approximation $3$ to a square root of $2$ in $\mathbb{Z}_7$ at precision $7^4$:

```wl
HenselLift[#^2 - 2 &, 3, 7, 4]
```
<!-- => 2166 -->

## Author Notes

This paclet was authored with substantial help from an AI assistant
(Claude Opus 4.7, Anthropic). The implementation, documentation, and
worked examples were drafted by the model and reviewed / edited by the
human contributor. The math content (p-adic valuation, ultrametric
inequality, Hensel's lemma, Newton iteration with quadratic precision
doubling) follows Koblitz's *p-adic Numbers, p-adic Analysis, and
Zeta-Functions* (2nd ed., Springer GTM 58, 1984).

## Hero Image

Kummer's theorem: the 2-adic valuation of $\binom{n}{k}$ is the number of carries when adding $k$ to $n - k$ in base 2. Coloring a $64 \times 64$ patch of Pascal's triangle by this valuation traces a Sierpinski-like fractal - the canonical visualisation of p-adic structure inside the integers:

```wl
ArrayPlot[
    Table[PAdicValuation[Binomial[n, k], 2], {n, 0, 63}, {k, 0, 63}],
    ColorFunction -> "SunsetColors",
    Frame -> False,
    ImageSize -> 600,
    PlotRangePadding -> None
]
```
