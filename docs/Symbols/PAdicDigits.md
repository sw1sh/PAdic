---
Template: Symbol
Name: PAdicDigits
Context: Wolfram`PAdic`
Paclet: Wolfram/PAdic
URI: Wolfram/PAdic/ref/PAdicDigits
Keywords: [p-adic, digits, base-p expansion, digit, RealDigits]
SeeAlso: [PAdicValuation, PAdicNorm, HenselLift, IntegerDigits, RealDigits]
RelatedGuides: [PAdic]
---

## Usage

<code>[PAdicDigits]()[$x$, $p$]</code> gives $\{\{a_0, a_1, \ldots, a_{n-1}\}, j\}$ where $x = \sum_{i=0}^{n-1} a_i p^{i+j}$ is the base-$p$ expansion truncated to $n$ digits, with the first digit at position $p^j$.

<code>[PAdicDigits]()[$x$, $p$, $n$]</code> uses exactly $n$ digits.

## Details & Options

- Digits are *little-endian*: the lowest power of $p$ comes first. This is the natural order for the p-adic completion, where the "infinite" direction is toward higher powers.
- The shift $j$ is the p-adic valuation $v_p(x)$, so $j \ge 0$ iff $x \in \mathbb{Z}_p$ (a p-adic integer). A negative $j$ flags $x \in \mathbb{Q}_p \setminus \mathbb{Z}_p$ (factors of $p$ in the denominator).
- Negative integers have an *infinite* expansion with digits all eventually equal to $p - 1$, the p-adic analogue of "$\ldots 999$" being a representation of $-1$ in base 10.
- $n$ defaults to 20 - enough to see the structure of any rational.
- Rationals: the kernel computes the digits of $(\mathrm{num} \cdot \mathrm{den}^{-1}) \bmod p^n$ via [PowerMod]() on the unit part of the denominator.

## Basic Examples

The first five 7-adic digits of $100 = 2 + 2 \cdot 49$:

```wl
PAdicDigits[100, 7, 5]
```

<!-- => {{2, 0, 2, 0, 0}, 0} -->

The 7-adic expansion of $1/7$ starts at position $p^{-1}$:

```wl
PAdicDigits[1/7, 7, 5]
```

<!-- => {{1, 0, 0, 0, 0}, -1} -->

The 7-adic expansion of $-1$ is $\ldots 6\,6\,6\,6\,6\,6$:

```wl
PAdicDigits[-1, 7, 6]
```

<!-- => {{6, 6, 6, 6, 6, 6}, 0} -->

## Scope

The digits of $0$ are all zero, with shift $0$:

```wl
PAdicDigits[0, 7, 5]
```

<!-- => {{0, 0, 0, 0, 0}, 0} -->

A rational with no factor of $p$ in the denominator has shift $0$ and a periodic digit sequence:

```wl
PAdicDigits[1/3, 7, 6]
```

<!-- => {{5, 4, 4, 4, 4, 4}, 0} -->

## Properties and Relations

The reconstruction $\sum_i a_i p^{i+j}$ recovers $x$ when there are enough digits:

```wl
With[{x = 1/3, p = 7, n = 20},
    Block[{ds = PAdicDigits[x, p, n]},
        Mod[Total[First[ds] p^Range[0, n - 1]] - x p^(-Last[ds]), p^(n - 1)]]]
```

<!-- => 0 -->

`PAdicDigits` is to $\mathbb{Q}_p$ what [RealDigits]() is to $\mathbb{R}$:

```wl
{PAdicDigits[100, 7, 5], RealDigits[100, 7, 5]}
```

<!-- => {{{2, 0, 2, 0, 0}, 0}, {{2, 0, 2, 0, 0}, 3}} -->

## Possible Issues

The expansion of a *negative* integer is **infinite** in the p-adic sense - any finite truncation is the residue mod $p^n$, not the integer itself:

```wl
PAdicDigits[-1, 7, 4]
```

<!-- => {{6, 6, 6, 6}, 0} -->

(Read: $-1 \equiv 6 + 6 \cdot 7 + 6 \cdot 49 + 6 \cdot 343 = 2400 = 7^4 - 1 \pmod{7^4}$.)

## Neat Examples

A small table compares the base-$p$ representations of consecutive rationals:

```wl
Block[{p = 7}, AssociationMap[PAdicDigits[#, p, 5] &, {1, 1/2, 1/3, 1/7, 1/49, -1}]]
```

<!-- => an association from each rational to its p-adic digit shape -->
