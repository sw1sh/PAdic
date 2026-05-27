---
Template: Symbol
Name: PAdicValuationArray
Context: Wolfram`PAdic`
Paclet: Wolfram/PAdic
URI: Wolfram/PAdic/ref/PAdicValuationArray
Keywords: [p-adic, Kummer, Sierpinski, fractal, Pascal triangle, visualisation, valuation]
SeeAlso: [PAdicValuation, PAdicTree, PAdicDigitPlot, ArrayPlot, Binomial]
RelatedGuides: [PAdic]
---

## Usage

<code>[PAdicValuationArray]()[$p$, $n$]</code> returns an $n \times n$ [ArrayPlot]() whose $(i, j)$ cell is coloured by $v_p\binom{i + j}{j}$ - the $p$-adic valuation of the corresponding binomial coefficient.

## Details & Options

- *Kummer's theorem* says $v_p\binom{i + j}{j}$ equals the number of *carries* when adding $j$ to $i$ in base $p$. The resulting picture is the canonical Sierpinski-style fractal visualisation of $p$-adic structure inside the integers.
- For $p = 2$ the picture is the classical Sierpinski triangle (the parity of Pascal's triangle, flipped upside-down because cells with valuation $> 0$ are the "even" ones).
- For $p = 3$ it's a Pascal-triangle-shaped Sierpinski gasket with three-fold structure, and so on.
- The colouring uses the `"SunsetColors"` palette; deeper colour means a higher valuation, i.e. a binomial coefficient divisible by a higher power of $p$.
- Output is plain [Graphics](); [Show]() / [GraphicsGrid]() / [Manipulate]() compose freely.

## Basic Examples

A $32 \times 32$ window on the 2-adic Pascal triangle - the Sierpinski triangle, rotated and recoloured:

```wl
PAdicValuationArray[2, 32]
```

<!-- => ArrayPlot showing the Sierpinski-triangle fractal -->

The same construction in base $3$ shows a Pascal triangle modulo $3$ - a different fractal but the same kind of self-similar pattern:

```wl
PAdicValuationArray[3, 27]
```

<!-- => ArrayPlot with three-fold Sierpinski-like structure -->

## Scope

A $1 \times 1$ array shows the trivial fact $v_p\binom{0}{0} = v_p(1) = 0$:

```wl
PAdicValuationArray[7, 1]
```

<!-- => single-cell ArrayPlot at value 0 -->

For odd $p \ge 5$ the fractal scale is set by $p$: the self-similar tiles have side $p$, so a window of size $p^k$ captures $k$ levels of nesting:

```wl
PAdicValuationArray[5, 25]
```

<!-- => 25x25 array showing two levels of base-5 nesting -->

## Properties and Relations

The array is symmetric in $(i, j)$ because $\binom{i + j}{j} = \binom{i + j}{i}$:

```wl
With[{p = 5, n = 12, tbl = Table[PAdicValuation[Binomial[i + j, j], p], {i, 0, 11}, {j, 0, 11}]},
    tbl === Transpose[tbl]]
```

<!-- => True -->

The first row is identically zero because $\binom{j}{j} = 1$ for all $j$, and similarly the first column:

```wl
With[{p = 7, n = 10},
    {Table[PAdicValuation[Binomial[j, j], p], {j, 0, n - 1}],
     Table[PAdicValuation[Binomial[i, 0], p], {i, 0, n - 1}]}]
```

<!-- => {{0, 0, ..., 0}, {0, 0, ..., 0}} -->

## Neat Examples

The same window at successive primes makes the dependence on $p$ vivid - the scale of the self-similar tiles grows with the prime:

```wl
GraphicsRow[Table[PAdicValuationArray[p, p^3], {p, {2, 3, 5}}], ImageSize -> 700]
```

<!-- => three Sierpinski-style fractals at the three smallest primes -->
