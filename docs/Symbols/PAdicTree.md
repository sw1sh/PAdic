---
Template: Symbol
Name: PAdicTree
Context: Wolfram`PAdic`
Paclet: Wolfram/PAdic
URI: Wolfram/PAdic/ref/PAdicTree
Keywords: [p-adic, tree, visualisation, ultrametric, disk, neighbourhood]
SeeAlso: [PAdicDigitPlot, PAdicValuationArray, PAdicValuation, Graph, TreeGraph]
RelatedGuides: [PAdic]
---

## Usage

<code>[PAdicTree]()[$p$, depth]</code> returns the [Graph]() whose leaves are the residues mod $p^{\text{depth}}$ and whose internal node at level $k$ represents the disk of $p$-adic integers congruent mod $p^k$.

## Details & Options

- The tree has $1 + p + p^2 + \cdots + p^{\text{depth}}$ vertices and $p + p^2 + \cdots + p^{\text{depth}}$ edges.
- Two leaves share an ancestor at level $k$ iff they agree mod $p^k$ - exactly the ultrametric neighbourhood structure of $\mathbb{Z}_p$. The graph is the standard "Cayley tree" picture of $\mathbb{Z}_p$ that appears in every introductory text on p-adic analysis.
- Each vertex is a pair $\{k, r\}$ where $k$ is the level (depth from the root) and $r \in \{0, 1, \ldots, p^k - 1\}$ is the residue mod $p^k$.
- The graph uses a layered embedding so the depth direction is geometrically meaningful; vertices carry their $\{k, r\}$ label as a [Tooltip]().

## Basic Examples

The 2-adic tree of depth $4$ has the familiar binary-tree shape:

```wl
PAdicTree[2, 4]
```

<!-- => Graph with 31 vertices (1 + 2 + 4 + 8 + 16), 30 edges -->

The 3-adic tree of depth $3$ branches three ways at every level:

```wl
PAdicTree[3, 3]
```

<!-- => Graph with 40 vertices (1 + 3 + 9 + 27), 39 edges -->

## Scope

The trivial cases work as expected. At depth $0$ the tree is a single root:

```wl
PAdicTree[7, 0]
```

<!-- => Graph with 1 vertex, 0 edges -->

At depth $1$ the root has $p$ direct children (the $p$ residue classes mod $p$):

```wl
PAdicTree[5, 1]
```

<!-- => Graph with 6 vertices, 5 edges -->

## Properties and Relations

The number of vertices and edges follow the geometric series. For depth $d$ and prime $p$:

```wl
With[{p = 3, d = 3, g = PAdicTree[3, 3]},
    {VertexCount[g], Sum[p^k, {k, 0, d}], EdgeCount[g], Sum[p^k, {k, 1, d}]}]
```

<!-- => {40, 40, 39, 39} -->

The leaves at depth $d$ are exactly the integers $0, 1, \ldots, p^d - 1$ (each tagged with its level):

```wl
With[{p = 2, d = 3},
    Sort @ Select[VertexList[PAdicTree[p, d]], First[#] == d &]]
```

<!-- => {{3, 0}, {3, 1}, {3, 2}, {3, 3}, {3, 4}, {3, 5}, {3, 6}, {3, 7}} -->

## Neat Examples

The tree makes the ultrametric inequality visible. Two leaves are *close* when their tree-distance from a common ancestor is small - this is what "close mod a high power of $p$" looks like geometrically:

```wl
PAdicTree[3, 4]
```

<!-- => the depth-4 ternary Cayley tree of Z_3 -->
