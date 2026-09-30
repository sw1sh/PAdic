---
Template: Symbol
Name: PAdicSqrt
Context: Wolfram`PAdic`
Paclet: Wolfram/PAdic
URI: Wolfram/PAdic/ref/PAdicSqrt
Keywords: [p-adic, square root, Hensel, Newton, 2-adic]
SeeAlso: [PAdicSquareQ, HenselLift, TeichmullerRepresentative, HilbertSymbol, PAdicNumber]
RelatedGuides: [PAdic]
---

## Usage

<code>[PAdicSqrt]()[$x$, $p$, $n$]</code> gives a residue $r$ mod $p^n$ with $r^2 \equiv x \pmod{p^n}$ - a square root of the $p$-adic integer $x$ in $\mathbb{Z}_p$ to precision $n$ - or [$Failed]() if $x$ is not a square in $\mathbb{Z}_p$.

## Details & Options

- A square root in $\mathbb{Z}_p$ exists iff [PAdicSquareQ]()$[x, p]$ is [True]() and the valuation $v_p(x)$ is non-negative (so the root is itself a $p$-adic integer).
- For odd $p$, `PAdicSqrt` finds a root of $x$ in the residue field and lifts it with the quadratic Newton iteration of [HenselLift]() - the precision doubles each step.
- For $p = 2$, the derivative $2t$ of $t^2 - x$ vanishes mod $2$, so Hensel's hypothesis fails; `PAdicSqrt` instead lifts the root one bit at a time, which is why the $2$-adic condition is the stricter $u \equiv 1 \pmod 8$.
- Both roots are present: if $r$ is returned, $p^n - r$ is the other.
- For a rational unit $x$, the identity $r^2 \equiv x$ holds *$p$-adically*; verify it as $\operatorname{Mod}[\,\text{den}(x)\, r^2 - \text{num}(x), p^n] = 0$ rather than by reducing $x$ as a real number.

## Basic Examples

A square root of $2$ in $\mathbb{Z}_7$, to precision $7^5$:

```wl
PAdicSqrt[2, 7, 5]
```

<!-- => 4567 -->

It really squares to $2$:

```wl
Mod[PAdicSqrt[2, 7, 5]^2 - 2, 7^5]
```

<!-- => 0 -->

A non-residue has no root:

```wl
PAdicSqrt[3, 7, 5]
```

<!-- => $Failed -->

## Scope

The $2$-adic lift handles the failure of Hensel's hypothesis at $p = 2$. Since $17 \equiv 1 \pmod 8$ it has a $2$-adic square root:

```wl
With[{r = PAdicSqrt[17, 2, 8]}, {r, Mod[r^2 - 17, 2^8]}]
```

<!-- => {105, 0} -->

But $5 \not\equiv 1 \pmod 8$, so $5$ is not a square in $\mathbb{Q}_2$ at any precision:

```wl
PAdicSqrt[5, 2, 6]
```

<!-- => $Failed -->

## Properties and Relations

The two square roots sum to $p^n$:

```wl
With[{r = PAdicSqrt[2, 7, 5]}, {r, 7^5 - r, Mod[(7^5 - r)^2 - 2, 7^5]}]
```

<!-- => {4567, 12240, 0} -->

`PAdicSqrt` is the special case $f(t) = t^2 - x$ of [HenselLift]() for odd $p$; the result wraps directly into a [PAdicNumber]():

```wl
With[{r = PAdicSqrt[2, 7, 5]}, PAdicNumber[7, r, 5]^2]
```

<!-- => PAdicNumber[7, 2, 5] -->

A root exists exactly when [PAdicSquareQ]() says so:

```wl
{PAdicSqrt[2, 7, 4] =!= $Failed, PAdicSquareQ[2, 7]}
```

<!-- => {True, True} -->
