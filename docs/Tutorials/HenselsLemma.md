---
Template: TechNote
Name: HenselsLemma
Title: Hensel's Lemma and the p-adic Newton Iteration
Context: Wolfram`PAdic`
Paclet: Wolfram/PAdic
URI: Wolfram/PAdic/tutorial/HenselsLemma
Keywords: [Hensel, Newton, root finding, p-adic, lifting]
RelatedGuides: [PAdic]
RelatedTutorials: [IntroductionToPAdics]
---

## The statement

Let $f \in \mathbb{Z}[x]$ and $p$ a prime, and suppose $a_0 \in \mathbb{Z}$ satisfies

$$ f(a_0) \equiv 0 \pmod p, \qquad f'(a_0) \not\equiv 0 \pmod p. $$

Then there is a *unique* $\tilde a \in \mathbb{Z}_p$ with $f(\tilde a) = 0$ and $\tilde a \equiv a_0 \pmod p$.

The second condition - the derivative does not vanish mod $p$ - is *Hensel's hypothesis*. Geometrically it says $a_0$ is a *simple* root of $f$ mod $p$: the tangent line is not horizontal. When it fails, the root may or may not lift, and if it does, the lift is not unique.

## The p-adic Newton iteration

The proof of Hensel's lemma is constructive - it builds $\tilde a$ as the limit of the p-adic Newton iteration

$$ a_{k+1} = a_k - \frac{f(a_k)}{f'(a_k)} $$

Two facts about this iteration in $\mathbb{Z}_p$ make it different from the real-number Newton's method:

1. *Convergence is quadratic and certain*. If $v_p(f(a_k)) \ge k$ at one step, then $v_p(f(a_{k+1})) \ge 2k$ at the next - the precision **doubles** each step. There is no "did Newton converge?" question; the iteration always converges, and the rate is built into the arithmetic.
2. *The division is exact mod $p^k$*. Because $f'(a_k)$ is a unit mod $p$ (Hensel's hypothesis), it has a multiplicative inverse mod $p^k$, which [PowerMod]() finds. No floating-point round-off, no precision loss.

The `HenselLift` function in this paclet drives this iteration until the precision reaches the requested $p^n$.

## A worked example: $\sqrt{2}$ in $\mathbb{Z}_7$

Does $2$ have a square root in $\mathbb{Z}_7$? Take $f(x) = x^2 - 2$. The initial approximations are the roots of $f$ mod $7$: solve $x^2 \equiv 2 \pmod 7$. By Euler's criterion / direct search, $x = 3$ works ($3^2 = 9 = 7 + 2$), and so does $x = 4 = -3 \pmod 7$. Both are *simple* roots: $f'(3) = 6 \not\equiv 0 \pmod 7$. So Hensel's lemma applies to both, and $\sqrt{2}$ exists in $\mathbb{Z}_7$ - in fact, both branches.

A single Newton step refines $a_0 = 3$ to precision $7^2 = 49$:

$$ a_1 = a_0 - \frac{a_0^2 - 2}{2 a_0} = 3 - \frac{7}{6} \equiv 3 - 7 \cdot 6^{-1} \pmod{49} $$

The modular inverse $6^{-1} \pmod{49}$ is $41$ (since $6 \cdot 41 = 246 = 5 \cdot 49 + 1$), so $a_1 = 3 - 7 \cdot 41 = 3 - 287 \equiv -284 \equiv 10 \pmod{49}$. Check: $10^2 = 100 = 2 + 2 \cdot 49 \equiv 2 \pmod{49}$. The next step jumps to $7^4 = 2401$:

```wl
HenselLift[#^2 - 2 &, 3, 7, 4]
```

```wl
Mod[2166^2 - 2, 7^4]
```

The lift at the *other* root starts from $a_0 = 4$:

```wl
HenselLift[#^2 - 2 &, 4, 7, 4]
```

And, indeed, $2166 + 235 = 2401 = 7^4$ - the two roots are negatives of each other in $\mathbb{Z}/7^4\mathbb{Z}$, as $\sqrt{2}$ and $-\sqrt{2}$ should be.

## When Hensel's lemma fails

Take $f(x) = x^2 - 1$ over $\mathbb{F}_2$. Both $a = 0$ and $a = 1$ have $f(a) \equiv 0 \pmod 2$, but $f'(x) = 2x$ is identically $0$ mod $2$. Hensel's hypothesis fails - and indeed the lift is not unique: $x^2 \equiv 1 \pmod 4$ has roots $\{1, 3\}$, while mod $8$ it has *four* roots $\{1, 3, 5, 7\}$. The number of square roots of $1$ mod $2^n$ grows with $n$, in contradiction with the uniqueness Hensel would guarantee.

`HenselLift` reports this failure mode:

```wl
HenselLift[#^2 - 1 &, 0, 2, 4]
```

## Why the iteration works

The classical proof is short. Suppose $f(a_k) \equiv 0 \pmod {p^k}$. Write $a_{k+1} = a_k + p^k t$ for an undetermined $t \in \mathbb{Z}/p\mathbb{Z}$, and expand $f$ in a finite Taylor series:

$$ f(a_{k+1}) = f(a_k) + p^k t \cdot f'(a_k) + p^{2k} \cdot (\text{higher order}). $$

Mod $p^{k+1}$ the higher-order terms vanish (since $2k \ge k + 1$ as soon as $k \ge 1$), so

$$ f(a_{k+1}) \equiv f(a_k) + p^k t \cdot f'(a_k) \pmod{p^{k+1}}. $$

Choose $t = - \frac{f(a_k) / p^k}{f'(a_k)} \pmod p$, which is well-defined exactly because $f'(a_k)$ is a unit mod $p$ (Hensel's hypothesis). The right-hand side is then $\equiv 0 \pmod{p^{k+1}}$, so $a_{k+1}$ is a lift of $a_k$ to one more digit of p-adic precision.

The `HenselLift` implementation in this paclet performs the *quadratic* version of the same step: each step squares the current precision instead of adding one. The same calculation goes through with $p^{k+1}$ replaced by $p^{2k}$.

## Beyond polynomials

Hensel's lemma is the engine behind a great deal of p-adic analysis: lifts of factorizations, *Teichmuller representatives* (the unique $(p-1)$-th roots of unity in $\mathbb{Z}_p$), and the implicit function theorem in the p-adic setting. The simplest illustration of a Teichmuller rep is the lift of a non-zero residue $a \pmod p$ to the unique p-adic integer $\omega \in \mathbb{Z}_p^\times$ with $\omega^{p-1} = 1$ and $\omega \equiv a \pmod p$ - exactly a Hensel lift of $x^{p-1} - 1$ from $x = a$:

```wl
With[{p = 7},
    Table[HenselLift[#^(p - 1) - 1 &, a, p, 4], {a, 1, p - 1}]]
```

Each of these is the unique 7-adic 6th root of unity congruent to its index mod $7$ - the p-adic analogue of the complex 6th roots of unity.
