# PAdic

A Wolfram Language paclet for the p-adic numbers $\mathbb{Q}_p$:
valuations $v_p$, the non-archimedean absolute value $|x|_p$, digit
expansions in $\mathbb{Q}_p$ (extending `RealDigits` to the p-adic
completion), and the Hensel lift.

| Symbol | Math |
|---|---|
| `PAdicValuation[x, p]` | $v_p(x)$ |
| `PAdicNorm[x, p]` | $|x|_p = p^{-v_p(x)}$ |
| `PAdicDigits[x, p, n]` | $\{a_0, a_1, \ldots, a_{n-1}\}$ with $x = \sum a_i p^{i+j}$ |
| `HenselLift[f, a, p, n]` | the unique $\tilde a \in \mathbb{Z}/p^n$ with $f(\tilde a) \equiv 0 \pmod{p^n}$ and $\tilde a \equiv a \pmod p$ |

## Layout

```
PAdic/
|-- PacletInfo.wl
|-- Kernel/PAdic.wl
|-- docs/
|   |-- Guides/PAdic.md
|   |-- Symbols/
|   |   |-- PAdicValuation.md
|   |   |-- PAdicNorm.md
|   |   |-- PAdicDigits.md
|   |   `-- HenselLift.md
|   `-- Tutorials/
|       |-- IntroductionToPAdics.md
|       |-- HenselsLemma.md
|       `-- Overview.md
|-- ResourceDefinition.md
|-- build.wls
`-- README.md
```

## Build

```bash
wolframscript -f build.wls          # writes Documentation/English/.../*.nb
```

This walks `docs/**/*.md`, runs `MarkdownToNotebook` on each, and writes
the produced `.nb` under the paclet's standard `Documentation/English/`
layout. `ResourceDefinition.md` is built into the paclet-repository
submission notebook at the paclet root.

## What this paclet exercises in MarkdownToNotebook

- Greek + blackboard-bold: $\mathbb{Z}_p$, $\mathbb{Q}_p$
- Subscripts with the p-adic absolute value $|x|_p$
- Congruence notation $a \equiv b \pmod{p^n}$
- Display math with `$$ … $$` and `\frac{}{}`
- Math inside `<code>` Usage signatures: `<code>[HenselLift]()[$f$, $a$, $p$, $n$]</code>`
- Backticked symbol auto-linking (`PAdicNorm`, `IntegerDigits`, `PowerMod`)
- Inferred links to other paclet symbols and tutorials
- Heading text with markup ("$\sqrt{2}$ in $\mathbb{Z}_7$")
- The `Overview` template with TOC headings + clickable leaf links
