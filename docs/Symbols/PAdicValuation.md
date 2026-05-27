---
Template: Symbol
Name: PAdicValuation
Context: Wolfram`PAdic`
Paclet: Wolfram/PAdic
URI: Wolfram/PAdic/ref/PAdicValuation
Keywords: [p-adic, valuation, divisibility, ultrametric, number theory]
SeeAlso: [PAdicNorm, PAdicDigits, HenselLift, IntegerExponent, Mod, Divisors]
RelatedGuides: [PAdic]
---

## Usage

<code>[PAdicValuation]()[$x$, $p$]</code> gives the p-adic valuation $v_p(x)$: the largest integer $n$ such that $p^n$ divides $x$, extended to $\mathbb{Q}$ by $v_p(a/b) = v_p(a) - v_p(b)$.

## Details & Options

- $x$ may be any [Integer]() or [Rational](); $p$ must be a prime $\ge 2$.
- $v_p(0) = +\infty$ by convention - this is what makes the *ultrametric inequality* $v_p(x + y) \ge \min(v_p(x), v_p(y))$ hold without exceptions.
- For integers, `PAdicValuation` is exactly [IntegerExponent](); for rationals, the kernel splits numerator and denominator.
- The valuation is multiplicative: $v_p(xy) = v_p(x) + v_p(y)$.

## Basic Examples

The 7-adic valuation of $98 = 2 \cdot 7^2$:

```wl
PAdicValuation[98, 7]
```

<!-- => 2 -->

The 5-adic valuation of a rational that has a factor of $5$ in the denominator:

```wl
PAdicValuation[3/25, 5]
```

<!-- => -2 -->

## Scope

The valuation at $x = 0$ is the symbol `Infinity`:

```wl
PAdicValuation[0, 7]
```

<!-- => Infinity -->

Different primes give different valuations of the same integer:

```wl
{PAdicValuation[2520, 2], PAdicValuation[2520, 3], PAdicValuation[2520, 5], PAdicValuation[2520, 7]}
```

<!-- => {3, 2, 1, 1} -->

## Properties and Relations

The valuation is *non-archimedean*: it satisfies the strong triangle inequality

$$ v_p(x + y) \ge \min(v_p(x), v_p(y)) $$

with equality when $v_p(x) \ne v_p(y)$:

```wl
{PAdicValuation[7 + 49, 7], Min[PAdicValuation[7, 7], PAdicValuation[49, 7]]}
```

<!-- => {1, 1} -->

The valuation is multiplicative under products:

```wl
With[{x = 21, y = 35, p = 7},
    PAdicValuation[x y, p] === PAdicValuation[x, p] + PAdicValuation[y, p]]
```

<!-- => True -->

## Possible Issues

`PAdicValuation` does not check that $p$ is prime. For composite $p$ the value computed is still well-defined (the largest $n$ with $p^n \mid x$), but it stops being a *valuation* in the algebraic sense:

```wl
PAdicValuation[36, 6]
```

<!-- => 2 -->

## Neat Examples

A table of valuations gives a quick read on the prime-factor structure of an integer:

```wl
Block[{n = 2520},
    AssociationMap[PAdicValuation[n, #] &, Select[Range[2, 20], PrimeQ]]]
```

<!-- => <|2 -> 3, 3 -> 2, 5 -> 1, 7 -> 1, 11 -> 0, 13 -> 0, 17 -> 0, 19 -> 0|> -->
