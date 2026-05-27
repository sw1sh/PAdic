---
Template: Symbol
Name: PAdicNorm
Context: Wolfram`PAdic`
Paclet: Wolfram/PAdic
URI: Wolfram/PAdic/ref/PAdicNorm
Keywords: [p-adic, norm, absolute value, ultrametric, non-archimedean]
SeeAlso: [PAdicValuation, PAdicDigits, HenselLift, Abs]
RelatedGuides: [PAdic]
---

## Usage

<code>[PAdicNorm]()[$x$, $p$]</code> gives the p-adic absolute value $|x|_p = p^{-v_p(x)}$, with $|0|_p = 0$.

## Details & Options

- The norm is defined for any [Integer]() or [Rational](); $p$ must be a prime $\ge 2$.
- $|x|_p$ is *small* when $x$ has many factors of $p$ (the closer to $0$ in the p-adic topology) - the *opposite* of the usual real-line intuition.
- The norm satisfies the **ultrametric inequality**: $|x + y|_p \le \max(|x|_p, |y|_p)$, strictly stronger than the usual triangle inequality.
- *Multiplicativity*: $|xy|_p = |x|_p \cdot |y|_p$.

## Basic Examples

A number divisible by a high power of $p$ has small p-adic norm:

```wl
PAdicNorm[49, 7]
```

<!-- => 1/49 -->

A rational with $p$ in the denominator has *large* p-adic norm:

```wl
PAdicNorm[1/7, 7]
```

<!-- => 7 -->

## Scope

The norm of $0$ is $0$ (the only element with norm $0$):

```wl
PAdicNorm[0, 7]
```

<!-- => 0 -->

An integer coprime to $p$ is a *p-adic unit* and has norm $1$:

```wl
PAdicNorm[42, 5]
```

<!-- => 1 -->

## Properties and Relations

The ultrametric inequality - the defining feature of a non-archimedean norm:

```wl
With[{x = 7^2, y = 7^3, p = 7},
    PAdicNorm[x + y, p] <= Max[PAdicNorm[x, p], PAdicNorm[y, p]]]
```

<!-- => True -->

Multiplicativity:

```wl
With[{x = 14, y = 21, p = 7},
    PAdicNorm[x y, p] === PAdicNorm[x, p] PAdicNorm[y, p]]
```

<!-- => True -->

## Neat Examples

The geometric series for $|x|_p < 1$ converges in the p-adic topology to $1/(1-x)$. For $x = p = 7$:

```wl
With[{x = 7, p = 7, n = 10},
    {N @ PAdicNorm[Sum[x^k, {k, 0, n}] - 1/(1 - x), p], "should -> 0 as n increases"}]
```

<!-- => {1/2.8247524900000003*^8, "should -> 0 as n increases"} -->
