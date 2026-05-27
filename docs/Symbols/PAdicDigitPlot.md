---
Template: Symbol
Name: PAdicDigitPlot
Context: Wolfram`PAdic`
Paclet: Wolfram/PAdic
URI: Wolfram/PAdic/ref/PAdicDigitPlot
Keywords: [p-adic, digit, visualisation, bar chart, base-p]
SeeAlso: [PAdicDigits, PAdicTree, PAdicValuationArray, BarChart, IntegerDigits]
RelatedGuides: [PAdic]
---

## Usage

<code>[PAdicDigitPlot]()[$x$, $p$, $n$]</code> renders the first $n$ base-$p$ digits of $x$ as a labelled bar chart: bar $k$ has height $a_k$ where $x = \sum_{i = 0}^{n-1} a_i p^{i + j}$, with the leading position $p^j$ reported in the plot label.

<code>[PAdicDigitPlot]()[$x_{p}$]</code> where $x_p$ is a [PAdicNumber]() infers $p$ and $n$ from the object itself.

## Details & Options

- Digits are *little-endian*: the lowest power of $p$ is the leftmost bar, the natural reading order for the p-adic completion.
- The y-axis is fixed at $[0, p - 1]$, the full range of possible base-$p$ digits.
- The plot label includes the *leading shift* $j$, which is the p-adic valuation. A negative $j$ flags an element of $\mathbb{Q}_p$ outside $\mathbb{Z}_p$.
- Output is a plain [Graphics]() (a [BarChart]() under the hood), so it composes with [Show](), [GraphicsRow](), and the rest of the visualisation toolchain.

## Basic Examples

Show the first five 7-adic digits of $100 = 2 + 2 \cdot 49$:

```wl
PAdicDigitPlot[100, 7, 5]
```

<!-- => bar chart with bars at positions 0 and 2 of height 2, others 0 -->

The 7-adic expansion of $-1$ is $\ldots 6\,6\,6\,6$ - every bar reaches the maximum:

```wl
PAdicDigitPlot[-1, 7, 6]
```

<!-- => bar chart with all six bars at height 6 -->

A [PAdicNumber]() can be plotted directly without restating $p$ and $n$:

```wl
PAdicDigitPlot[PAdicNumber[7, 100, 5]]
```

<!-- => same bar chart as PAdicDigitPlot[100, 7, 5] -->

## Scope

A rational with $p$ in the denominator shifts the leading position into negative territory, and the plot label reports the shift:

```wl
PAdicDigitPlot[1/7, 7, 5]
```

<!-- => bar chart with leading bar of height 1; the label notes position p^-1 -->

A rational with a periodic expansion gives a constant bar - the 7-adic expansion of $1/3$ has digit $5$ followed by all $4$s:

```wl
PAdicDigitPlot[1/3, 7, 8]
```

<!-- => first bar at 5, the remaining seven at 4 -->

## Properties and Relations

`PAdicDigitPlot` is the visualisation companion to [PAdicDigits](): the heights of the bars are exactly the first list returned by `PAdicDigits`:

```wl
PAdicDigits[100, 7, 5]
```

<!-- => {{2, 0, 2, 0, 0}, 0} -->

## Neat Examples

Lay out the digit charts of the first few powers of $1/p$ in a row to see the "shifting" structure of $\mathbb{Q}_p$ outside $\mathbb{Z}_p$:

```wl
GraphicsRow[Table[PAdicDigitPlot[1/7^k, 7, 6], {k, 0, 2}], ImageSize -> 700]
```

<!-- => three bar charts of increasing leading-shift |j| -->
