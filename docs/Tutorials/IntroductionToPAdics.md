---
Template: TechNote
Name: IntroductionToPAdics
Title: An Introduction to p-adic Numbers
Context: Wolfram`PAdic`
Paclet: Wolfram/PAdic
URI: Wolfram/PAdic/tutorial/IntroductionToPAdics
Keywords: [p-adic, valuation, ultrametric, completion]
RelatedGuides: [PAdic]
RelatedTutorials: [HenselsLemma]
---

## What completion of $\mathbb{Q}$ to choose?

The familiar real numbers $\mathbb{R}$ are the completion of the rationals $\mathbb{Q}$ with respect to the usual absolute value $|x|$. *Ostrowski's theorem* says that, up to equivalence, this is one of only two kinds of absolute value $\mathbb{Q}$ admits: the usual archimedean one, and, for every prime $p$, the *p-adic* absolute value $|x|_p$. The corresponding completion is the field $\mathbb{Q}_p$ of **p-adic numbers** - a strikingly different number system, and the subject of this paclet.

## The p-adic valuation

Fix a prime $p$. The **p-adic valuation** $v_p \colon \mathbb{Q}^\times \to \mathbb{Z}$ sends a non-zero rational to

$$ v_p(a/b) = v_p(a) - v_p(b), \qquad v_p(n) = \max\{e \ge 0 : p^e \mid n\} $$

with $v_p(0) = +\infty$ by convention. Walking the three corner cases:

The 7-adic valuation of an integer divisible by $7^2$:

```wl
PAdicValuation[98, 7]
```

<!-- => 2 -->

---

The valuation of a reciprocal - negative, because $1/49 = 1/7^2$:

```wl
PAdicValuation[1/49, 7]
```

<!-- => -2 -->

---

And the conventional value at $0$, which makes the ultrametric inequality unconditional:

```wl
PAdicValuation[0, 7]
```

<!-- => Infinity -->

Multiplicativity $v_p(xy) = v_p(x) + v_p(y)$ is immediate from the definition.

## The p-adic absolute value

From the valuation we derive the **p-adic absolute value** $|x|_p = p^{-v_p(x)}$, with $|0|_p = 0$. Numbers divisible by *higher* powers of $p$ are p-adically *smaller*:

```wl
Table[{p^k, PAdicNorm[p^k, p]}, {k, -2, 4}] /. p -> 7
```

The familiar triangle inequality $|x + y| \le |x| + |y|$ holds, but a much stronger one is also true - the **ultrametric inequality**:

$$ |x + y|_p \le \max(|x|_p, |y|_p) $$

This is what makes $\mathbb{Q}_p$ a *non-archimedean* field. Every triangle in $\mathbb{Q}_p$ is isoceles: if $|x|_p \ne |y|_p$ then $|x + y|_p$ equals the larger of the two. Pictorially, two p-adic numbers are *close* when they agree mod a high power of $p$ - the analogue, but emphatically not the same, as two real numbers agreeing in many decimal places.

```wl
With[{p = 7},
    {PAdicNorm[7 + 49, p], Max[PAdicNorm[7, p], PAdicNorm[49, p]]}]
```

## $\mathbb{Z}_p$ vs $\mathbb{Q}_p$

The p-adic *integers* $\mathbb{Z}_p$ are the elements of $\mathbb{Q}_p$ with $v_p(x) \ge 0$, equivalently $|x|_p \le 1$. They are the natural completion of the integers $\mathbb{Z}$ in the p-adic metric. The full field $\mathbb{Q}_p$ adds elements with poles - finitely many factors of $p$ in the denominator.

For an integer $n \ge 0$, the p-adic digits are just the *reverse* of the usual base-$p$ digits (p-adic ordering puts the lowest power of $p$ first - this is the "little-endian" convention every p-adic textbook uses):

```wl
{PAdicDigits[100, 7, 4], IntegerDigits[100, 7]}
```

For $1/7$, the only "digit" sits at the position $7^{-1}$:

```wl
PAdicDigits[1/7, 7, 4]
```

## $\ldots 9999 = -1$ in $\mathbb{Q}_{10}$ (well, kind of)

The 10-adics $\mathbb{Q}_{10}$ are not a field (10 is not prime), but the **digit construction** still works and gives the famous identity that $-1$ has the "infinite" decimal expansion $\ldots 9999$. With a real prime in place of $10$ the same identity holds: the 7-adic expansion of $-1$ is $\ldots 6666666$:

```wl
PAdicDigits[-1, 7, 8]
```

Algebraically: $\sum_{i=0}^{\infty} (p - 1) p^i = (p - 1) \cdot \frac{1}{1 - p} = -1$, and the partial sum truncates to $p^n - 1 \equiv -1 \pmod{p^n}$.

## A geometric series that converges p-adically but not over $\mathbb{R}$

In the real numbers, the series $\sum_{k \ge 0} 7^k = 1 + 7 + 49 + 343 + \ldots$ diverges. In $\mathbb{Q}_7$, the *general* term $7^k$ has p-adic norm $7^{-k} \to 0$, so the series *does* converge - to $1/(1 - 7) = -1/6$. The 7-adic distance between the partial sum and the closed-form limit drops by one factor of $7$ each step:

```wl
Table[N @ PAdicNorm[Sum[7^k, {k, 0, n}] - (-1/6), 7], {n, 1, 8}]
```

<!-- => {0.0204, 0.00292, 0.000416, 5.95e-5, 8.50e-6, 1.21e-6, 1.73e-7, 2.48e-8} (each ~ 1/7 of the previous) -->

And the limit $-1/6$ itself sits in $\mathbb{Z}_7$ as a periodic expansion - every digit is $1$, because $-1/6 = 1 + 7 + 49 + \ldots$:

```wl
PAdicDigits[-1/6, 7, 10]
```

<!-- => {{1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, 0} -->

## Where this is going

The next tutorial - [HenselsLemma](paclet:Wolfram/PAdic/tutorial/HenselsLemma) - shows how, once you have the field $\mathbb{Q}_p$, *polynomial equations* become easy to solve mod $p^n$ for arbitrarily large $n$. The classical statement is **Hensel's lemma**, and the algorithm behind it is the p-adic Newton iteration that `HenselLift` implements.
