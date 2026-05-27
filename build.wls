#!/usr/bin/env wolframscript
(* Build the PAdic paclet documentation from the structured markdown in
   docs/, writing each notebook into the standard paclet layout under
   Documentation/English/. Example outputs are cached with the built-in
   persistence framework. Also builds the paclet-repository submission
   notebook (ResourceDefinition). *)

print[args___] := WriteString["stdout", StringJoin[ToString /@ {args}], "\n"]

pacletDir = DirectoryName[$InputFileName]
Get[FileNameJoin[{pacletDir, "..", "..", "MarkdownToNotebook.wl"}]]

(* load the paclet so example cells resolve its symbols during evaluation *)
PacletDirectoryLoad[pacletDir]
Needs["Wolfram`PAdic`"]

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
    info = MarkdownToNotebook[srcFile, "Association"];
    tmpl = info["Template"];
    baseName = FileBaseName[srcFile];
    dir = FileNameJoin[Prepend[subdir[tmpl], pacletDir]];
    Quiet @ CreateDirectory[dir, CreateIntermediateDirectories -> True];
    out = FileNameJoin[{dir, baseName <> ".nb"}];
    MarkdownToNotebook[srcFile, out];
    print["  ", FileNameTake[srcFile], " -> Documentation/English/", Last[subdir[tmpl]], "/", baseName, ".nb"]
]

print["building PAdic documentation"]
Scan[buildDoc, Sort @ FileNames["*.md", FileNameJoin[{pacletDir, "docs"}], Infinity]]

(* paclet-repository submission notebook at the paclet root *)
rd = FileNameJoin[{pacletDir, "ResourceDefinition.md"}]
If[ FileExistsQ[rd],
    MarkdownToNotebook[rd, FileNameJoin[{pacletDir, "ResourceDefinition.nb"}]];
    print["  ResourceDefinition.md -> ResourceDefinition.nb"]
]

print["done"]
