---
Template: Symbol
Name: HilbertSymbol
Context: Wolfram`PAdic`
Paclet: Wolfram/PAdic
URI: Wolfram/PAdic/ref/HilbertSymbol
Keywords: [Hilbert symbol, quadratic form, local-global, reciprocity, p-adic, norm]
SeeAlso: [PAdicSquareQ, PAdicSqrt, PAdicNorm, PAdicValuation, JacobiSymbol]
RelatedGuides: [PAdic]
---

## Usage

<code>[HilbertSymbol]()[$a$, $b$, $p$]</code> gives the Hilbert symbol $(a, b)_p \in \{1, -1\}$: it is $+1$ when $z^2 = a x^2 + b y^2$ has a nontrivial solution in $\mathbb{Q}_p$, and $-1$ otherwise. $p$ is a prime or [Infinity]() (the real place).

## Details & Options

- Equivalently, $(a, b)_p = 1$ iff $a$ is a norm from the extension $\mathbb{Q}_p(\sqrt b)$.
- For $p = \infty$ the symbol is $-1$ exactly when both $a$ and $b$ are negative.
- For odd $p$, writing $a = p^\alpha u$ and $b = p^\beta v$ with units $u, v$, $$(a,b)_p = (-1)^{\alpha\beta\,\varepsilon(p)} \left(\tfrac{u}{p}\right)^{\beta} \left(\tfrac{v}{p}\right)^{\alpha},$$ where $\varepsilon(p) = (p-1)/2$ and $(\tfrac{\cdot}{p})$ is the Legendre symbol. For $p = 2$ the analogous formula uses $\varepsilon(n) = (n-1)/2$ and $\omega(n) = (n^2-1)/8$ mod $2$.
- The symbol is *symmetric*, $(a, b)_p = (b, a)_p$, and *bimultiplicative*, $(a a', b)_p = (a, b)_p (a', b)_p$.
- It depends only on $a$ and $b$ modulo squares, so it is a pairing on $\mathbb{Q}_p^\times / (\mathbb{Q}_p^\times)^2$.
- **Hilbert reciprocity**: for fixed $a, b$ the symbol is $+1$ for all but finitely many places, and the product over *all* places (every prime and $\infty$) is $1$. This is the engine of the local-global principle for quadratic forms.

## Basic Examples

The form $z^2 = -x^2 - y^2$ has no nontrivial real solution, so the symbol at the real place is $-1$:

```wl
HilbertSymbol[-1, -1, Infinity]
```

<!-- => -1 -->

The same form over $\mathbb{Q}_2$ is also anisotropic, but over $\mathbb{Q}_3$ it has a solution:

```wl
{HilbertSymbol[-1, -1, 2], HilbertSymbol[-1, -1, 3]}
```

<!-- => {-1, 1} -->

## Scope

For an odd prime $p$ and a unit $u$, the symbol $(u, p)_p$ reduces to the Legendre symbol $\left(\tfrac{u}{p}\right)$ - the obstruction is whether $u$ is a quadratic residue:

```wl
{HilbertSymbol[2, 7, 7], HilbertSymbol[5, 7, 7]}
```

<!-- => {1, -1}  (2 is a QR mod 7, 5 is not) -->

## Properties and Relations

The symbol is symmetric:

```wl
With[{a = 6, b = 35}, HilbertSymbol[a, b, 7] == HilbertSymbol[b, a, 7]]
```

<!-- => True -->

Hilbert reciprocity - the product over all places is $1$ - is a deep theorem and a strong self-check. For $a = -15$, $b = 21$ the relevant places are $\{2, 3, 5, 7, \infty\}$:

```wl
With[{places = {2, 3, 5, 7, Infinity}},
    {HilbertSymbol[-15, 21, #] & /@ places, Times @@ (HilbertSymbol[-15, 21, #] & /@ places)}]
```

<!-- => {{1, -1, 1, -1, 1}, 1} -->

[PAdicSquareQ]() is the degenerate case $b = $ a square: $(a, b)_p = 1$ automatically when $b$ is a square in $\mathbb{Q}_p$.

## Neat Examples

The Hasse-Minkowski theorem says a quadratic form over $\mathbb{Q}$ represents $0$ nontrivially iff it does so over $\mathbb{R}$ and over every $\mathbb{Q}_p$. For a ternary form $\langle a, b, -1\rangle$ that local condition at $p$ is exactly $(a, b)_p = 1$, so scanning the symbol across places decides global solvability. The form $z^2 = 2 x^2 + 7 y^2$ is solvable everywhere - hence over $\mathbb{Q}$:

```wl
HilbertSymbol[2, 7, #] & /@ {2, 3, 5, 7, Infinity}
```

<!-- => {1, 1, 1, 1, 1} -->

But $z^2 = 2 x^2 + 3 y^2$ fails locally at $2$ and $3$, so it has no rational solution:

```wl
HilbertSymbol[2, 3, #] & /@ {2, 3, 5, 7, Infinity}
```

<!-- => {-1, -1, 1, 1, 1} -->
