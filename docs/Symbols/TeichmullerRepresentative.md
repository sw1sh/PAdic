---
Template: Symbol
Name: TeichmullerRepresentative
Context: Wolfram`PAdic`
Paclet: Wolfram/PAdic
URI: Wolfram/PAdic/ref/TeichmullerRepresentative
Keywords: [Teichmuller, root of unity, Hensel, character, p-adic]
SeeAlso: [HenselLift, PAdicSqrt, PAdicNumber, PAdicDigits, RootOfUnity]
RelatedGuides: [PAdic]
---

## Usage

<code>[TeichmullerRepresentative]()[$a$, $p$, $n$]</code> gives the residue mod $p^n$ of the Teichmuller representative of $a$: the unique $(p-1)$-th root of unity in $\mathbb{Z}_p$ congruent to $a$ mod $p$ (and $0$ when $a \equiv 0$).

## Details & Options

- The map $a \mapsto \omega(a)$ is the *Teichmuller character*: a multiplicative section of the reduction $\mathbb{Z}_p^\times \to \mathbb{F}_p^\times$, so $\omega(a)$ and $a$ have the same residue mod $p$ but $\omega(a)$ is an exact root of unity.
- It is computed as a [HenselLift]() of $x^{p-1} - 1$ from the seed $a$: since $a^{p-1} \equiv 1 \pmod p$ and the derivative $(p-1)x^{p-2}$ is a unit, Hensel's hypothesis holds and the lift is unique.
- The $p - 1$ Teichmuller representatives are exactly the $(p-1)$-th roots of unity in $\mathbb{Z}_p$ - the canonical lift of $\mathbb{F}_p^\times$.
- $\omega(a) = a$ whenever $a$ is already a root of unity (e.g. $a = 1$); $\omega(p\,k) = 0$.

## Basic Examples

The Teichmuller representative of $3$ in $\mathbb{Z}_7$ to precision $7^4$:

```wl
TeichmullerRepresentative[3, 7, 4]
```

<!-- => 1354 -->

It is a $6$th root of unity and reduces to $3$ mod $7$:

```wl
With[{w = TeichmullerRepresentative[3, 7, 4]}, {Mod[w^6, 7^4], Mod[w, 7]}]
```

<!-- => {1, 3} -->

## Scope

The class of $a \equiv 0$ maps to $0$:

```wl
TeichmullerRepresentative[7, 7, 4]
```

<!-- => 0 -->

The four units of $\mathbb{F}_5$ lift to the four $4$th roots of unity in $\mathbb{Z}_5$ - note $57^2 \equiv -1$:

```wl
Table[TeichmullerRepresentative[a, 5, 3], {a, 1, 4}]
```

<!-- => {1, 57, 68, 124}  (124 = -1, 57 and 68 = -57 are the square roots of -1) -->

## Properties and Relations

Every representative satisfies $\omega^{p-1} = 1$:

```wl
Table[Mod[TeichmullerRepresentative[a, 5, 3]^4, 5^3], {a, 1, 4}]
```

<!-- => {1, 1, 1, 1} -->

The character is multiplicative: $\omega(a)\,\omega(b) \equiv \omega(a b)$:

```wl
With[{p = 7, n = 4},
    Mod[TeichmullerRepresentative[2, p, n] TeichmullerRepresentative[3, p, n]
        - TeichmullerRepresentative[6, p, n], p^n]]
```

<!-- => 0 -->

The representatives are a fixed point of repeated $p$-th powering - the dynamical view of "keep raising to the $p$": $\omega(a) \equiv a^{p^k}$ for large $k$. They are also the digits used in the Teichmuller (multiplicative) expansion of a $p$-adic number, the companion to the additive [PAdicDigits]() expansion.
