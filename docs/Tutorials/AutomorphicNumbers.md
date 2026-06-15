---
Template: TechNote
Name: AutomorphicNumbers
Title: Automorphic Numbers and the Idempotents of the 10-adics
Context: Wolfram`PAdic`
Paclet: Wolfram/PAdic
URI: Wolfram/PAdic/tutorial/AutomorphicNumbers
Keywords: [automorphic numbers, idempotent, 10-adic, Chinese remainder, Newton iteration]
RelatedGuides: [PAdic]
RelatedTutorials: [IntroductionToPAdics, HenselsLemma]
---

## A number whose square ends in itself

Square $5$ and you get $25$; square $25$ and you get $625$; square $625$ and you get $390625$. Each result *ends in the number you started with*. Numbers with this property - $n^2$ ending in the digits of $n$ - are called **automorphic numbers**, and below $1000$ there are only a handful:

```wl
Select[Range[1, 1000], Mod[#^2, 10^IntegerLength[#]] == # &]
```

<!-- => {1, 5, 6, 25, 76, 376, 625} -->

Two infinite families are hiding here. One ends in $5$ ($5, 25, 625, 90625, 890625, \ldots$); the other ends in $6$ ($6, 76, 376, 9376, 109376, \ldots$). Each family adds one stable digit at a time and never stops. Read off the digits and you get two numbers with *infinitely many* digits to the left:

$$ P = \ldots 918212890625, \qquad Q = \ldots 081787109376 $$

These are not integers - but they are perfectly good **10-adic integers** $\mathbb{Z}_{10}$, and they satisfy the cleanest equation a number can:

$$ P^2 = P, \qquad Q^2 = Q. $$

A number equal to its own square is an **idempotent**. This tutorial is about where $P$ and $Q$ come from, why there are exactly two of them, and how to compute them.

## Why the ordinary p-adics have no such numbers

The equation $x^2 = x$ factors as $x(x - 1) = 0$. In any number system with *no zero divisors* - the real numbers, the rationals, or the field $\mathbb{Q}_p$ of [p-adic numbers](paclet:Wolfram/PAdic/tutorial/IntroductionToPAdics) for a **prime** $p$ - a product is zero only if a factor is zero, so the only solutions are the trivial $x = 0$ and $x = 1$. There is nothing interesting to find.

The base $10$ is different because $10 = 2 \cdot 5$ is **composite**. The ring $\mathbb{Z}_{10}$ has zero divisors, and that is exactly the room a nontrivial idempotent needs. The 10-adics are *not* a field (the [Introduction](paclet:Wolfram/PAdic/tutorial/IntroductionToPAdics) flags this when deriving $\ldots 9999 = -1$), and $P$, $Q$ are the most vivid symptom of it.

## The two-prime decomposition

The Chinese Remainder Theorem splits arithmetic mod $10^n$ into arithmetic mod $2^n$ and mod $5^n$ independently:

$$ \mathbb{Z}/10^n\mathbb{Z} \;\cong\; \mathbb{Z}/2^n\mathbb{Z} \times \mathbb{Z}/5^n\mathbb{Z}, $$

and in the limit $\mathbb{Z}_{10} \cong \mathbb{Z}_2 \times \mathbb{Z}_5$. Under this splitting a number is recorded as a *pair* of residues. An idempotent must be idempotent in each coordinate, and in each of $\mathbb{Z}_2$, $\mathbb{Z}_5$ the only idempotents are $0$ and $1$. So $\mathbb{Z}_{10}$ has exactly **four** idempotents - the four pairs:

| pair | meaning | idempotent |
|---|---|---|
| $(0, 0)$ | $0 \bmod 2$, $0 \bmod 5$ | $0$ |
| $(1, 1)$ | $1 \bmod 2$, $1 \bmod 5$ | $1$ |
| $(1, 0)$ | $1 \bmod 2$, $0 \bmod 5$ | $P$ |
| $(0, 1)$ | $0 \bmod 2$, $1 \bmod 5$ | $Q$ |

A direct search mod $10^6$ confirms there are precisely four, and names the two nontrivial ones:

```wl
Select[Range[0, 10^6 - 1], Mod[#^2, 10^6] == # &]
```

<!-- => {0, 1, 109376, 890625} -->

$P$ is the pair $(1, 0)$: odd (hence $\equiv 1 \bmod 2^n$) and divisible by $5^n$ - so it ends in $5$. $Q$ is the mirror image $(0, 1)$: even and $\equiv 1 \bmod 5^n$ - so it ends in $6$. `ChineseRemainder` builds each one to any precision we like:

```wl
n = 12;
{P, Q} = {ChineseRemainder[{1, 0}, {2^n, 5^n}], ChineseRemainder[{0, 1}, {2^n, 5^n}]}
```

<!-- => {918212890625, 81787109376} -->

These are the trailing digits of $P$ and $Q$ ($Q$ printed without its leading zero). Their little-endian 10-adic digit expansions, read right-to-left, are the two automorphic families:

```wl
{PAdicDigits[P, 10, 12], PAdicDigits[Q, 10, 12]}
```

<!-- => {{{5,2,6,0,9,8,2,1,2,8,1,9}, 0}, {{6,7,3,9,0,1,7,8,7,1,8,0}, 0}} -->

## Complementary idempotents: $P + Q = 1$, $PQ = 0$

The pairs $(1, 0)$ and $(0, 1)$ are complementary - they add to $(1, 1) = 1$ and multiply to $(0, 0) = 0$. So $P$ and $Q$ are **orthogonal idempotents** that partition $\mathbb{Z}_{10}$:

$$ P + Q = 1, \qquad P \cdot Q = 0. $$

The paclet's [PAdicNumber](paclet:Wolfram/PAdic/ref/PAdicNumber) carries the right arithmetic upvalues, so $\mathbb{Z}_{10}$ algebra composes directly - no manual `Mod` needed:

```wl
{p, q} = {PAdicNumber[10, P, n], PAdicNumber[10, Q, n]};
{p^2 == p, q^2 == q, p + q, p*q}
```

<!-- => {True, True, PAdicNumber[10, 1, 12], PAdicNumber[10, 0, 12]} -->

This is the algebraic shadow of $\mathbb{Z}_{10} \cong \mathbb{Z}_2 \times \mathbb{Z}_5$: multiplying by $P$ projects onto the $\mathbb{Z}_2$ factor, multiplying by $Q$ onto the $\mathbb{Z}_5$ factor, and the two projections are complementary.

## The automorphic numbers are the truncations

Now the opening puzzle resolves itself. Because $P^2 = P$ holds in $\mathbb{Z}_{10}$, it holds modulo every power $10^k$:

$$ \left(P \bmod 10^k\right)^2 \equiv P \bmod 10^k. $$

So *every* $k$-digit truncation of $P$ is a number whose square ends in those same $k$ digits - an automorphic number. The "$5$" family is just $P$ revealed one digit at a time; the "$6$" family is $Q$:

```wl
Table[Mod[P, 10^k], {k, 1, n}]
```

<!-- => {5, 25, 625, 625, 90625, 890625, 2890625, 12890625, 212890625, 8212890625, 18212890625, 918212890625} -->

```wl
With[{trunc = Table[Mod[P, 10^k], {k, 1, n}]},
    Mod[#^2, 10^IntegerLength[#]] == # & /@ trunc]
```

<!-- => all True -->

## Computing them by a self-correcting iteration

`ChineseRemainder` is the slick route, but there is a more p-adic one that mirrors the [Newton iteration behind Hensel's lemma](paclet:Wolfram/PAdic/tutorial/HenselsLemma). The map

$$ e \;\longmapsto\; 3e^2 - 2e^3 $$

is an *idempotent-doubling* step: if $e$ is idempotent mod $10^k$, then $3e^2 - 2e^3$ is idempotent mod $10^{2k}$ - the number of correct digits **doubles** each step, just like the quadratic convergence of the p-adic Newton method. Seed it with the one-digit idempotents $5$ and $6$ and it locks onto $P$ and $Q$:

```wl
lift[e_] := Mod[3 e^2 - 2 e^3, 10^n];
{NestList[lift, 5, 4], NestList[lift, 6, 4]}
```

<!-- => {..., 918212890625} and {..., 81787109376} -->

After four steps from a single digit the iteration is already exact to all twelve - and it is *self-correcting*: a wrong low-order digit anywhere along the way is washed out, because the only fixed points the map can converge to are the four idempotents.

## What this says about $\mathbb{Z}_{10}$

Idempotents are the algebraic fingerprint of a *product* decomposition: a ring splits as a direct product exactly when it carries a pair of complementary idempotents like $P$ and $Q$. Finding them by squaring digits, by the Chinese Remainder Theorem, or by Newton iteration are three views of the single fact $\mathbb{Z}_{10} \cong \mathbb{Z}_2 \times \mathbb{Z}_5$.

For a *prime* base $p$ the ring $\mathbb{Z}_p$ is a domain - it does not factor, has no zero divisors, and so has no automorphic numbers beyond $0$ and $1$. The whole phenomenon lives on the fact that $10$ is composite. To go back to the prime case and the field $\mathbb{Q}_p$, see [An Introduction to p-adic Numbers](paclet:Wolfram/PAdic/tutorial/IntroductionToPAdics); for the Newton iteration that powers the idempotent lift, see [Hensel's Lemma and the p-adic Newton Iteration](paclet:Wolfram/PAdic/tutorial/HenselsLemma).
