---
Template: Symbol
Name: PAdicSquareQ
Context: Wolfram`PAdic`
Paclet: Wolfram/PAdic
URI: Wolfram/PAdic/ref/PAdicSquareQ
Keywords: [p-adic, square, quadratic residue, Hensel, unit]
SeeAlso: [PAdicSqrt, HilbertSymbol, PAdicValuation, HenselLift, JacobiSymbol]
RelatedGuides: [PAdic]
---

## Usage

<code>[PAdicSquareQ]()[$x$, $p$]</code> gives [True]() if the rational $x$ is a square in $\mathbb{Q}_p$.

## Details & Options

- Write $x = p^{v} u$ with $u$ a $p$-adic unit. Then $x$ is a square iff $v$ is even **and** the unit $u$ is a square.
- For odd $p$, the unit $u$ is a square iff it is a quadratic residue mod $p$ (the Legendre symbol is $+1$) - the higher digits then lift uniquely by Hensel's lemma.
- For $p = 2$, the unit $u$ is a square iff $u \equiv 1 \pmod 8$.
- For $p = $ [Infinity]() (the real place), $x$ is a "square" iff $x > 0$.
- $0$ is a square at every place.
- `PAdicSquareQ[x, p]` is the predicate behind [PAdicSqrt](): the root exists exactly when this returns [True]() (and, for [PAdicSqrt](), $x$ is a $p$-adic integer).

## Basic Examples

$2$ is a square in $\mathbb{Q}_7$ but $3$ is not:

```wl
{PAdicSquareQ[2, 7], PAdicSquareQ[3, 7]}
```

<!-- => {True, False} -->

An odd valuation can never be a square - $7$ has valuation $1$ in $\mathbb{Q}_7$:

```wl
PAdicSquareQ[7, 7]
```

<!-- => False -->

## Scope

The $2$-adic rule is the "$1$ mod $8$" condition. $17 \equiv 1 \pmod 8$ is a square; $-1 \equiv 7$ is not:

```wl
{PAdicSquareQ[17, 2], PAdicSquareQ[-1, 2]}
```

<!-- => {True, False} -->

At the real place, being a square is just being positive:

```wl
{PAdicSquareQ[4, Infinity], PAdicSquareQ[-4, Infinity]}
```

<!-- => {True, False} -->

## Properties and Relations

`PAdicSquareQ` agrees with the existence of a [PAdicSqrt]() for $p$-adic integers:

```wl
AllTrue[Range[1, 50], PAdicSquareQ[#, 7] == (PAdicSqrt[#, 7, 4] =!= $Failed) &]
```

<!-- => True -->

Squareness in $\mathbb{Q}_p$ is the $b = $ square specialisation of the [HilbertSymbol](): $(a, b)_p = 1$ whenever $b$ is a square. It is the local input to the Hasse-Minkowski local-global principle: a rational is a square iff it is a square in $\mathbb{R}$ and in every $\mathbb{Q}_p$.

```wl
{PAdicSquareQ[9, Infinity], AllTrue[{2, 3, 5, 7, 11, 13}, PAdicSquareQ[9, #] &]}
```

<!-- => {True, True}  (9 = 3^2 is a square everywhere) -->
