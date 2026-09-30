---
Template: Symbol
Name: PAdicDiskPlot3D
Context: Wolfram`PAdic`
Paclet: Wolfram/PAdic
URI: Wolfram/PAdic/ref/PAdicDiskPlot3D
Keywords: [p-adic, visualisation, disk, coins, Sierpinski, ultrametric, 3D]
SeeAlso: [PAdicTree, PAdicValuationArray, PAdicDigitPlot, PAdicDigits, Graphics3D]
RelatedGuides: [PAdic]
---

## Usage

<code>[PAdicDiskPlot3D]()[$p$, depth]</code> renders the $p$-adic integers $\mathbb{Z}_p$, truncated to the given depth, as a self-similar stack of 3D coins: $p$ coins (labelled $0, \ldots, p-1$) sit at the vertices of a regular $p$-gon to form a cluster, $p$ clusters sit at the vertices of a larger $p$-gon, and so on.

<code>[PAdicDiskPlot3D]()[$p$]</code> uses depth $3$.

## Details & Options

- The plot contains $p^{\text{depth}}$ coins - one per residue mod $p^{\text{depth}}$, i.e. one per leaf of the depth-$\text{depth}$ tree [PAdicTree]() draws.
- Two residues sit in the same sub-cluster exactly when they agree to that many base-$p$ digits. So physical nesting *is* $p$-adic closeness: the deeper the shared cluster, the smaller the $p$-adic distance. This is the geometric "circles within circles" picture of $\mathbb{Z}_p$, and the coin-stack companion to the graph-based [PAdicTree]().
- Each coin is labelled by its base-$p$ digit at the *finest* level (the last digit that distinguishes it from its cluster siblings). Labels are shown only when there are at most $81$ coins, so the figure stays readable.
- Sub-clusters shrink by a factor just inside the "kissing" ratio $\sin(\pi/p)/(1+\sin(\pi/p))$, so siblings keep a small visible gap.
- The result is an ordinary [Graphics3D]() with a dark background, warm lighting, and a front-on viewpoint; any of these can be overridden with [Show]().

## Basic Examples

The $3$-adic integers to depth $3$ - the Sierpinski-triangle stack of coins, three digits per cluster, nested three deep:

```wl
PAdicDiskPlot3D[3, 3]
```

The construction works for any base. The $5$-adic integers to depth $2$ are a pentagon of pentagons:

```wl
PAdicDiskPlot3D[5, 2]
```

## Scope

The default depth is $3$:

```wl
PAdicDiskPlot3D[3]
```

At depth $0$ the whole of $\mathbb{Z}_p$ is a single coin:

```wl
Count[PAdicDiskPlot3D[7, 0], _Cylinder, Infinity]
```

<!-- => 1 -->

There is exactly one coin per residue mod $p^{\text{depth}}$:

```wl
Count[PAdicDiskPlot3D[3, 3], _Cylinder, Infinity]
```

<!-- => 27 -->

## Properties and Relations

`PAdicDiskPlot3D` and [PAdicTree]() draw the *same* combinatorial object - the depth-$d$ tree of $\mathbb{Z}_p$ - one as a coin stack, the other as a graph. The coin count equals the tree's leaf count:

```wl
With[{p = 2, d = 4},
    {Count[PAdicDiskPlot3D[p, d], _Cylinder, Infinity],
     Count[VertexList[PAdicTree[p, d]], {d, _}]}]
```

<!-- => {16, 16} -->

The flat fractal that [PAdicValuationArray]() produces, the tree of [PAdicTree](), and this coin stack are three views of one structure: the nested, ultrametric self-similarity of the $p$-adic integers.

## Neat Examples

The $2$-adic integers, deep enough that the labels drop away and only the Cantor-set self-similarity remains:

```wl
PAdicDiskPlot3D[2, 6]
```

The same picture underlies the [automorphic numbers](paclet:Wolfram/PAdic/tutorial/AutomorphicNumbers): "keep squaring" walks down one branch of the $10$-adic coin stack toward an idempotent.
