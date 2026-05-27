---
Template: Symbol
Name: PAdicNumber
Context: Wolfram`PAdic`
Paclet: Wolfram/PAdic
URI: Wolfram/PAdic/ref/PAdicNumber
Keywords: [p-adic, computable, UpValues, arithmetic, Z_p]
SeeAlso: [PAdicNumberQ, PAdicValuation, PAdicNorm, PAdicDigits, HenselLift, FiniteField]
RelatedGuides: [PAdic]
---

## Usage

<code>[PAdicNumber]()[$p$, $x$, $n$]</code> represents the p-adic integer $x \bmod p^n$ - an element of $\mathbb{Z}/p^n\mathbb{Z}$ viewed as a precision-$n$ approximation to a p-adic integer in $\mathbb{Z}_p$.

<code>[PAdicNumber]()[$p$, $x$]</code> uses the default precision [Infinity](), which stores the value *exactly* as an Integer or Rational and propagates exact arithmetic.

## Details & Options

- The object carries [UpValues]() for [Plus](), [Times](), [Subtract](), [Power](), [Equal](), [Mod](), [Abs](), and [Norm](), so $\mathbb{Z}_p$ arithmetic composes naturally without an explicit "evaluate" step.
- *Precision* $n$ may be a positive [Integer]() (the residue is stored mod $p^n$ in $[0, p^n)$) or [Infinity]() (the value is stored exactly).
- Binary operations on two `PAdicNumber` objects with the same prime take the *minimum* of the two precisions. This is the right rule: a sum of p-adic numbers known to precision $n$ and $m$ is known to precision $\min(n, m)$. $\min(\infty, n) = n$, so mixing an exact and a precision-$n$ value yields the precision-$n$ truncation.
- Mixed-arity [Integer]() or [Rational]() operands are coerced into a `PAdicNumber` at the existing precision. A rational with the prime in its denominator is rejected with [Message]().
- Negative input or input outside $[0, p^n)$ is reduced to a positive residue via $x \bmod p^n$.
- The default rendering is a Wolfram-style **summary box** showing the prime, the precision, and (in the expanded view) the residue with its first base-$p$ digits and the textbook "$x + O(p^n)$" form.

## Basic Examples

Build a 7-adic integer at the default (exact) precision:

```wl
PAdicNumber[7, 3]
```

<!-- => PAdicNumber[7, 3, Infinity] -->

The same value truncated to precision $4$:

```wl
PAdicNumber[7, 3, 4]
```

<!-- => PAdicNumber[7, 3, 4] -->

The constructor normalises out-of-range residues at finite precision. The 7-adic integer $-1$ at precision $4$ is the canonical residue $7^4 - 1 = 2400$:

```wl
PAdicNumber[7, -1, 4]
```

<!-- => PAdicNumber[7, 2400, 4] -->

Arithmetic composes through UpValues:

```wl
PAdicNumber[7, 3, 4] + PAdicNumber[7, 5, 4]
```

<!-- => PAdicNumber[7, 8, 4] -->

---

```wl
PAdicNumber[7, 3, 4] * PAdicNumber[7, 5, 4]
```

<!-- => PAdicNumber[7, 15, 4] -->

The multiplicative inverse exists for units (residues coprime to $p$):

```wl
PAdicNumber[7, 3, 4]^-1
```

<!-- => PAdicNumber[7, 1601, 4] -->

(check: $3 \cdot 1601 = 4803 \equiv 1 \pmod{7^4}$.)

## Scope

Exact arithmetic at the default precision keeps the answer as a closed-form [Rational](). The inverse of $3$ in $\mathbb{Z}_7$ is exactly $1/3$:

```wl
PAdicNumber[7, 3]^-1
```

<!-- => PAdicNumber[7, 1/3, Infinity] -->

A rational with no factor of $p$ in the denominator coerces straight into $\mathbb{Z}_p$. The 7-adic representation of $1/6$ at precision $6$:

```wl
PAdicNumber[7, 1/6, 6]
```

<!-- => PAdicNumber[7, 98041, 6] -->

(check: $6 \cdot 98041 = 588246 \equiv 1 \pmod{7^6}$.)

Mixed-arity arithmetic auto-coerces the plain integer / rational into the existing prime and precision:

```wl
PAdicNumber[7, 3, 4] + 5
```

<!-- => PAdicNumber[7, 8, 4] -->

---

```wl
PAdicNumber[7, 3, 4] * (1/3)
```

<!-- => PAdicNumber[7, 1, 4] -->

## Properties and Relations

[PAdicNumberQ]() recognises normalised `PAdicNumber` expressions, useful for guarding pattern-matched code:

```wl
{PAdicNumberQ[PAdicNumber[7, 3, 4]], PAdicNumberQ[42]}
```

<!-- => {True, False} -->

[Abs]() routes through [PAdicNorm]() so the same $|\cdot|_p$ convention is in force everywhere:

```wl
{Abs[PAdicNumber[7, 49, 4]], PAdicNorm[49, 7]}
```

<!-- => {1/49, 1/49} -->

[Equal]() compares residues at the *minimum* precision of the two operands, which is what "equal as a p-adic approximation" should mean:

```wl
PAdicNumber[7, 100, 4] == 100
```

<!-- => True -->

[Mod]() lifts back to $\mathbb{Z}$ - useful for extracting an explicit residue at coarser precision:

```wl
Mod[PAdicNumber[7, 100, 4], 7^2]
```

<!-- => 2 -->

The Hensel lift fits naturally into the framework: a precision-$n$ root of $f$ in $\mathbb{Z}_p$ wraps directly into a `PAdicNumber`:

```wl
With[{lift = HenselLift[#^2 - 2 &, 3, 7, 6]},
    PAdicNumber[7, lift, 6]^2 - 2]
```

<!-- => PAdicNumber[7, 0, 6] -->

## Possible Issues

A rational whose denominator carries a factor of $p$ is not in $\mathbb{Z}_p$, and `PAdicNumber` does not currently model $\mathbb{Q}_p \setminus \mathbb{Z}_p$. The constructor refuses to build such an object:

```wl
PAdicNumber[7, 1/7, 4]
```

<!-- => $Failed (and a PAdicNumber::nzp message) -->

Negative-exponent powers require the residue to be a unit. The constructor does not preemptively check coprimality; the [Power]() UpValue does, and a non-unit base returns unevaluated:

```wl
PAdicNumber[7, 14, 4]^-1
```

<!-- => PAdicNumber[7, 14, 4]^-1 (no inverse, the residue is divisible by 7) -->

## Neat Examples

The constructor + UpValues let you compute the 7-adic expansion of a recurring "real" identity. The series $\sum_{k=0}^N 7^k$ converges 7-adically to $-1/6 \in \mathbb{Z}_7$, so building the partial sum at high precision and comparing to the coerced limit is a one-liner:

```wl
With[{p = 7, n = 10},
    Total[Table[PAdicNumber[p, p^k, n + 1], {k, 0, n}]] == PAdicNumber[p, -1/6, n + 1]]
```

<!-- => True -->
