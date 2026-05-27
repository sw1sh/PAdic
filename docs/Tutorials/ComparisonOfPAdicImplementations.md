---
Template: TechNote
Name: ComparisonOfPAdicImplementations
Title: How `Wolfram/PAdic` Compares to Other p-adic Implementations
Context: Wolfram`PAdic`
Paclet: Wolfram/PAdic
URI: Wolfram/PAdic/tutorial/ComparisonOfPAdicImplementations
Keywords: [p-adic, comparison, SageMath, PARI, Magma, SymPy, FiniteField]
RelatedGuides: [PAdic]
RelatedTutorials: [IntroductionToPAdics, HenselsLemma]
---

## Why this note exists

The Wolfram Language has long shipped first-class support for the *other* algebraic completions of $\mathbb{Q}$ - the real and complex numbers, finite fields $\mathbb{F}_{p^k}$ via [FiniteField](), modular integers via [Mod]() and [PowerMod]() - but $\mathbb{Q}_p$ and $\mathbb{Z}_p$ have remained absent. Several other mathematical systems treat the p-adics as first-class citizens, and the design choices they make are instructive. This note records what each does, where `Wolfram/PAdic` follows their lead, and where the design intentionally diverges.

## The landscape

### SageMath

[SageMath](https://www.sagemath.org/) has the most elaborate p-adic stack of any open-source system. The constructors [Zp](https://doc.sagemath.org/html/en/reference/padics/sage/rings/padics/factory.html) and `Qp` produce rings (parents) parameterised by the prime $p$ and a working precision; their elements know their precision, support full arithmetic, and have lazy / fixed-modulus / capped-relative *representation modes* that trade off speed for precision tracking. Element formatting is `3 + 2*7 + 7^3 + O(7^5)`. Hensel lifting is a method on polynomials; the digit expansion is `.expansion()`.

`Wolfram/PAdic` borrows the *element-carries-precision* idea. The `Min` rule for precision propagation is the standard Sage "capped-relative" semantics. The default rendering ("$x + O(p^n)$" in the compact view) follows Sage's notation directly. Sage's multiple representation modes are deliberately not modelled - we keep one canonical form (`PAdicNumber[p, x, n]`) and let `Infinity` precision serve the role of "exact / lazy".

### PARI / GP

[PARI/GP](https://pari.math.u-bordeaux.fr/) has p-adics as a first-class *type* (`t_PADIC`) with native syntax: write `3 + O(7^5)` and PARI parses it as a p-adic number. Operations like `padicappr` find roots of polynomials over $\mathbb{Q}_p$; `valuation` returns $v_p(x)$. PARI's precision tracking is fully automatic - an arithmetic operation on two p-adic inputs returns a p-adic with the appropriate precision *and* the result is itself a p-adic, not a residue + tag.

`Wolfram/PAdic` cannot match PARI's syntactic integration (the Wolfram parser does not have a literal p-adic form), but the *semantics* of `PAdicNumber[p, x, n] + k` mirror what `3 + O(7^5) + 2` does in PARI. PARI's automatic precision matching - the result keeps the lower precision - is exactly the `Min[n, m]` rule.

### Magma

[Magma](http://magma.maths.usyd.edu.au/) has `pAdicField(p, n)` and `pAdicQuotientRing(p, n)`. Like Sage, it makes a sharp distinction between a *parent* (the ring/field) and an *element*. Magma supports both fixed and capped precision, polynomial factorisation over $\mathbb{Q}_p$, and Newton-polygon-based root finding. The big difference with Sage: Magma is closed-source, so the implementation choices are observed externally rather than read.

`Wolfram/PAdic` does *not* build a parent ring object. Elements carry the prime and precision directly, in the spirit of how Wolfram's [FiniteField]() does *not* require you to construct $\mathbb{F}_p$ before mentioning an element of it. The cost is that there is no place to hang parent-level operations (a discrete logarithm in $\mathbb{Z}_p^\times$ is not naturally "a method on $\mathbb{Z}_p$"); the win is a leaner API.

### SymPy

[SymPy](https://www.sympy.org/) does not have a dedicated p-adic type. There is some related machinery in `sympy.polys.galoistools` for polynomials over $\mathbb{F}_p$, and the rational module supports arbitrary modular arithmetic, but constructing a p-adic number requires writing helper functions yourself. Hensel lifting is implemented internally for some factorisation routines (`hensel_lift` in `sympy.polys.factortools`) but is not exposed as a general user-facing tool.

`Wolfram/PAdic` is closer to "SymPy with first-class p-adic support" than to "Sage". The kernel is a single ~300-line `.wl` file; Sage's p-adic library is tens of thousands of lines of Cython. The trade-off is deliberate: we cover the *concepts* (valuation, norm, digits, Hensel lifting, ultrametric arithmetic) at high quality, and stop short of the optimised low-level integer kernels Sage / PARI carry.

### Maple

[Maple](https://www.maplesoft.com/)'s [padic](https://www.maplesoft.com/support/help/Maple/view.aspx?path=padic) package provides p-adic series, Hensel lifting, and root-finding over $\mathbb{Q}_p$. Maple's notation is the "expanded" form $\ldots + a_2 p^2 + a_1 p + a_0$, which reads right-to-left like the textbook digit display - the opposite of the little-endian convention Sage / `Wolfram/PAdic` use. Both are valid; the choice is purely cosmetic.

## A short cross-reference table

| Concept                     | `Wolfram/PAdic`                                                  | SageMath                            | PARI/GP                  | Magma                          | SymPy                                 |
|----------------------------|------------------------------------------------------------------|-------------------------------------|--------------------------|--------------------------------|---------------------------------------|
| Valuation $v_p(x)$         | `PAdicValuation[x, p]`                                           | `x.valuation()`                     | `valuation(x, p)`        | `Valuation(x, p)`              | `sympy.ntheory.padic_valuation`       |
| Norm $|x|_p$               | `PAdicNorm[x, p]`                                                | `x.abs()` (in $\mathbb{Q}_p$)       | -                        | `Abs(x)`                       | (helper)                              |
| Digit expansion            | `PAdicDigits[x, p, n]`                                           | `x.expansion()`                     | (via `O(p^n)` truncation)| `padicExpansion`               | -                                     |
| Hensel lift                | `HenselLift[f, a, p, n]`                                         | `f.hensel_lift(...)`                | `padicappr`              | `HenselLift`                   | `hensel_lift` (internal)              |
| Element type               | `PAdicNumber[p, x, n]`                                           | `Zp(p)(x)`                          | `t_PADIC`                | `pAdicQuotientRing(p, n)!x`    | -                                     |
| Exact / lazy precision     | `PAdicNumber[p, x]` / `PAdicNumber[p, x, Infinity]`              | "lazy" model in some variants       | -                        | (limited)                      | -                                     |
| Native syntax              | -                                                                | -                                   | `3 + O(7^5)`             | -                              | -                                     |
| Parent ring object         | none (elements self-describe)                                    | `Zp(p)`, `Qp(p)`                    | implicit                 | `pAdicField(p)`                | -                                     |

## What `Wolfram/PAdic` deliberately does *not* do

A short list of design decisions worth being explicit about, because every system above does at least one of these and we don't:

- **No parent ring object.** There is no `PAdicIntegers[7]` or `PAdicField[7]` to manipulate. Elements are self-describing. The motivation is the same as [FiniteField]()'s: keep the Wolfram surface minimal.
- **No $\mathbb{Q}_p$ outside $\mathbb{Z}_p$.** The constructor rejects rationals with $p$ in the denominator. The valuation function still accepts them (returning a negative integer) and the digit function still works (using a negative leading shift), but the computable `PAdicNumber` object is currently a $\mathbb{Z}_p$ thing only. Lifting this restriction is a candidate for a future version.
- **No polynomial factorisation over $\mathbb{Q}_p$.** Sage and PARI both have this; we don't. The Hensel lift is provided as a stand-alone tool for simple roots, which covers the bread-and-butter use case (square roots, cube roots, $n$-th roots, $\zeta_{p-1}$ in $\mathbb{Z}_p^\times$).
- **No teichmüller / multiplicative-group structure functions.** Discrete logarithm in $\mathbb{Z}_p^\times$, Teichmüller representatives - these are real workhorses in p-adic number theory and a natural follow-up, but not in v1.
- **One representation, not several.** Sage has fixed-mod, capped-rel, capped-abs, lazy. We have *finite precision* and *exact* (`Infinity` precision), and that's it. The rationale: 90 % of the value is in the basic concept; the additional modes are warranted only when you're doing serious p-adic computation that the present paclet does not yet target.

## What we do that others mostly don't

- **Plain Wolfram-style summary boxes.** A `PAdicNumber` renders as a Wolfram-native summary box with prime / precision / residue / digit shape, like [FiniteField](), [Quantity](), or [GeoPosition](). Sage's element printing is text-only; PARI's is text-only; Maple's is text-only. The summary-box convention is a Wolfram idiom and it slots `PAdicNumber` in among the familiar computable-object types.
- **Visualisations.** [PAdicDigitPlot](), [PAdicTree](), and [PAdicValuationArray]() are companion visualisations of the digit expansion, the ultrametric tree, and the Kummer/Sierpinski fractal. Other systems leave these to the user. The visualisations are quick to draw because Wolfram's graphics primitives are at hand.
- **Default Infinity precision.** `PAdicNumber[p, x]` keeps the value exact and uses ordinary [Rational]() arithmetic, only truncating to a finite precision when an explicit `Mod` or precision-coercion is requested. SageMath has a "lazy" mode that does something analogous; PARI / Magma / Maple do not.

## A worked example

The same calculation in three notations - the square root of $2$ in $\mathbb{Z}_7$ at precision $4$.

`Wolfram/PAdic`:

```wl
HenselLift[#^2 - 2 &, 3, 7, 4]
```

<!-- => 2166 -->

The same in (paraphrased) SageMath would read

```python
R = Zp(7, 4); R(3).square_root()
```

and in PARI

```
sqrt(2 + O(7^4))
```

The point is that the structure is shared - prime, precision, starting approximation - and the surface differs.

## Pointers

- SageMath p-adic reference manual: <https://doc.sagemath.org/html/en/reference/padics/>
- PARI/GP user's manual, section on `t_PADIC`: <https://pari.math.u-bordeaux.fr/dochtml/html/Vectors_matrices_linear_algebra_and_sets.html> (search "t_PADIC")
- Magma online help, section "p-adic Rings and their Extensions"
- Maple `padic` package help
- F. Q. Gouvêa, *p-adic Numbers: An Introduction* - the standard textbook all of the above implement against
