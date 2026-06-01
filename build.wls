#!/usr/bin/env wolframscript
(* Build the PAdic paclet documentation from the structured markdown in
   docs/, writing each notebook into the standard paclet layout under
   Documentation/English/. Example outputs are cached with the built-in
   persistence framework. Also builds the paclet-repository submission
   notebook (ResourceDefinition). *)

pacletDir = DirectoryName[$InputFileName]

(* Register the in-repo WolframParser BEFORE loading MTN: MTN's own
   Needs["Wolfram`Parser`"] then finds it locally instead of trying to download
   it. Its LaTeXMathParse (context Wolfram`Parser`, not Wolfram`Parser`LaTeX`)
   is what MTN routes TeX through; without this the build silently falls back to
   ImportString and loses all the parser's \frac / \mathbb / big-operator work. *)
PacletDirectoryLoad[FileNameJoin[{pacletDir, "..", "WolframParser"}]]
Get[FileNameJoin[{pacletDir, "..", "..", "MarkdownToNotebook.wl"}]]
Quiet @ Check[Needs["Wolfram`Parser`"], Null]

(* load the paclet so example cells resolve its symbols during evaluation *)
PacletDirectoryLoad[pacletDir]
Needs["Wolfram`PAdic`"]

(* Render LaTeX math in Computer Modern when an installed CM font allows it;
   fall back to the front end's native math font otherwise so the build still
   succeeds.  Prefer Latin Modern *Math* (its italics are the cmmi letterforms
   LaTeX uses; MarkdownToNotebook's applyMathFont remaps to them and pulls
   \mathbb into MSBM10), then Latin Modern Roman, then CMU Serif.  Passed via
   the "MathFont" option. *)
$fontDirs = {
    FileNameJoin[{$HomeDirectory, "Library", "Fonts"}],
    "/Library/Fonts", "/System/Library/Fonts"}
$mathFont = Which[
    FileNames["latinmodern-math*" | "lmmath*", $fontDirs] =!= {}, "Latin Modern Math",
    FileNames["lmroman*" | "latinmodern*", $fontDirs] =!= {}, "Latin Modern Roman",
    FileNames["cmun*", $fontDirs] =!= {}, "CMU Serif",
    True, Automatic]
Print["  math font: ", $mathFont]

subdir["Symbol"] = {"Documentation", "English", "ReferencePages", "Symbols"}
subdir["Guide"] = {"Documentation", "English", "Guides"}
(* Overview shares the tutorial/ URI namespace with TechNotes
   (DocumentationTools` PreCreateNewPageDialog["Overview"] writes its files
   to $TutorialDirectory), so they coexist in Documentation/English/Tutorials/. *)
subdir["TechNote"] = {"Documentation", "English", "Tutorials"}
subdir["Overview"] = {"Documentation", "English", "Tutorials"}

(* The output file basename is the SOURCE basename - it must match the last
   segment of the URI (DocumentationBuild builds the URI from the file path).
   Symbol / Guide / TechNote pages happen to have the same display "Name:"
   and basename, but an Overview is the case they can differ - its
   frontmatter Name: is the rendered title ("PAdic"), while the URI tail
   and file basename are "Overview". *)
buildDoc[srcFile_String] := Block[{info, tmpl, baseName, dir, out},
    info = MarkdownToNotebook[srcFile, "Association", "MathFont" -> $mathFont];
    tmpl = info["Template"];
    baseName = FileBaseName[srcFile];
    dir = FileNameJoin[Prepend[subdir[tmpl], pacletDir]];
    Quiet @ CreateDirectory[dir, CreateIntermediateDirectories -> True];
    out = FileNameJoin[{dir, baseName <> ".nb"}];
    MarkdownToNotebook[srcFile, out, "MathFont" -> $mathFont];
    Print["  ", FileNameTake[srcFile], " -> Documentation/English/", Last[subdir[tmpl]], "/", baseName, ".nb"]
]

Print["building PAdic documentation"]
Scan[buildDoc, Sort @ FileNames["*.md", FileNameJoin[{pacletDir, "docs"}], Infinity]]

(* paclet-repository submission notebook at the paclet root *)
rd = FileNameJoin[{pacletDir, "ResourceDefinition.md"}]
If[ FileExistsQ[rd],
    MarkdownToNotebook[rd, FileNameJoin[{pacletDir, "ResourceDefinition.nb"}], "MathFont" -> $mathFont];
    Print["  ResourceDefinition.md -> ResourceDefinition.nb"]
]

Print["done"]
