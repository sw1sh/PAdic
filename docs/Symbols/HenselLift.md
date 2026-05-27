---
Template: Symbol
Name: HenselLift
Context: Wolfram`PAdic`
Paclet: Wolfram/PAdic
URI: Wolfram/PAdic/ref/HenselLift
Keywords: [p-adic, Hensel, Newton iteration, lifting, root finding]
SeeAlso: [PAdicValuation, PAdicNorm, PAdicDigits, PowerMod, FindRoot]
RelatedGuides: [PAdic]
---

## Usage

<code>[HenselLift]()[$f$, $a$, $p$, $n$]</code> returns the unique integer $\tilde a \in \mathbb{Z}/p^n\mathbb{Z}$ with $f(\tilde a) \equiv 0 \pmod{p^n}$ and $\tilde a \equiv a \pmod p$, when $a$ is a *simple* root mod $p$ (i.e. $f'(a) \not\equiv 0 \pmod p$).

## Details & Options

- The lift is computed by the **p-adic Newton iteration**:

  $$ a_{k+1} = a_k - \frac{f(a_k)}{f'(a_k)} \pmod{p^{2k}} $$

  The precision exactly *doubles* each step, so reaching precision $p^n$ takes $\lceil \log_2 n \rceil$ iterations.
- *Hensel's hypothesis*: $f(a) \equiv 0 \pmod p$ and $f'(a) \not\equiv 0 \pmod p$. When the derivative vanishes mod $p$ the lift is not unique (or may not exist), and `HenselLift` returns `$Failed`.
- $f$ may be any callable expression (a [Function](), a pure-polynomial `Function[x, x^2 - 2]`, a `Function[x, x^3 + x + 1]`, ...); the derivative is taken with [D]().

## Basic Examples

A square root of $2$ in $\mathbb{Z}_7$ exists because $3^2 = 9 \equiv 2 \pmod 7$. Lift to precision $7^4 = 2401$:

```wl
HenselLift[#^2 - 2 &, 3, 7, 4]
```

<!-- => 2166 -->

Verify the lift satisfies $f(\tilde a) \equiv 0 \pmod{p^n}$:

```wl
Mod[2166^2 - 2, 7^4]
```

<!-- => 0 -->

The *other* root of $x^2 - 2$ in $\mathbb{Z}_7$ lifts from $a = 4$ (since $4 \equiv -3 \pmod 7$):

```wl
HenselLift[#^2 - 2 &, 4, 7, 4]
```

<!-- => 235 -->

(And $235 + 2166 = 2401 = 7^4$, the two roots are negatives of each other in $\mathbb{Z}/7^4\mathbb{Z}$.)

## Scope

Hensel's lemma fails when the derivative vanishes mod $p$ - the lift is then not unique:

```wl
HenselLift[#^2 - 1 &, 0, 2, 4]
```

<!-- => $Failed (f'(0) = 0 in F_2) -->

Polynomials with higher-degree roots work the same way. The real cube root of 2 lifts in $\mathbb{Z}_5$ from $a = 3$:

```wl
HenselLift[#^3 - 2 &, 3, 5, 5]
```

<!-- => 2178 -->

## Properties and Relations

The lift agrees with the initial approximation mod $p$:

```wl
With[{a = 3, p = 7, n = 4},
    Mod[HenselLift[#^2 - 2 &, a, p, n], p] === Mod[a, p]]
```

<!-- => True -->

Compared to a built-in modular root finder, the Hensel lift is *constructive* - it builds the answer by doubling precision rather than searching:

```wl
With[{n = 4, target = 7^4},
    {HenselLift[#^2 - 2 &, 3, 7, n], First @ Select[Range[target], Mod[#^2, target] === 2 &]}]
```

<!-- => {2166, 235} -->

## Possible Issues

The iteration uses [PowerMod]() to invert $f'(a_k)$ mod $p^k$. If the inverse does not exist at some intermediate step (which only happens when $f'(a_k) \equiv 0 \pmod p$, i.e. Hensel's hypothesis fails), the lift returns `$Failed`.

## Neat Examples

Lifting a square root of $-1$ in $\mathbb{Z}_5$ (since $2^2 = 4 \equiv -1 \pmod 5$):

```wl
With[{lifted = HenselLift[#^2 + 1 &, 2, 5, 10]},
    {lifted, Mod[lifted^2 + 1, 5^10]}]
```

<!-- => {6139557, 0} -->
