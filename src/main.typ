// =====================================================================
//  RELATIONAL ALGEBRA — COMPLETE SOLVED QUESTION BANK
//  B.Tech CSE (MANIT Bhopal pattern)
//  Build:  python -c "import typst; typst.compile('main.typ', root='.')"
// =====================================================================

#import "lib.typ": *

#set document(title: "Relational Algebra — Complete Solved Question Bank", author: "DBMS Course Notes")

// ---------- title page ----------
#page(numbering: none)[
  #v(2.2cm)
  #align(center)[
    #text(size: 9.5pt, fill: l3, tracking: 2pt)[B.TECH CSE · DATABASE MANAGEMENT SYSTEMS]
    #v(0.5cm)
    #line(length: 45%, stroke: 0.8pt + accent)
    #v(0.5cm)
    #text(size: 27pt, weight: "bold", fill: accent)[Relational Algebra]
    #v(0.15cm)
    #text(size: 20pt, weight: "bold", fill: accent)[Complete Solved Question Bank]
    #v(0.45cm)
    #line(length: 45%, stroke: 0.8pt + accent)
    #v(0.7cm)
    #text(size: 11pt, style: "italic")[
      Classical relational algebra only — selection, projection, rename, union,
      intersection, difference, Cartesian product, join and division. No SQL. No
      aggregates. Every expression derived, every schema stated.
    ]
    #v(1.1cm)
    #block(width: 78%, fill: notebg, inset: 12pt, radius: 3pt)[
      #set text(size: 9pt)
      #set par(justify: true)
      #text(weight: "bold")[Coverage.] 12 parts · 3 mandatory schemas (Sailors–Boats,
      Library, Hospital–Prescription) · 240+ solved questions · pattern catalogue ·
      "not expressible" proofs · error clinic · practice paper with answer key ·
      coverage checklist. Modelled on *Database System Concepts* (Silberschatz, Korth,
      Sudarshan), *Fundamentals of Database Systems* (Elmasri & Navathe) and
      *Database Management Systems* (Ramakrishnan & Gehrke).
    ]
    #v(1.4cm)
    #text(size: 9pt, fill: l3)[Compiled for university examination preparation · MANIT Bhopal pattern]
  ]
]

// ---------- front matter ----------
#heading(level: 1, outlined: false)[How to use this book]

#set par(justify: false, leading: 0.66em)
This book is a *question bank*, not a textbook. It is organised the way an examiner
thinks: one *logical pattern* per family of questions, then every surface form of that
pattern, then the traps that separate a 6-mark answer from a 10-mark answer.

*The one idea that carries the whole subject.* Nearly every "hard" relational algebra
question is one of exactly five shapes:

#grid(columns: (1fr, 1fr), gutter: 10pt,
  block(fill: notebg, inset: 8pt, radius: 2pt)[
    *1. Existence* ("at least one", "some", "a") \
    #text(size: 9pt)[→ join, then project.]
  ],
  block(fill: notebg, inset: 8pt, radius: 2pt)[
    *2. Non-existence* ("none", "never", "not") \
    #text(size: 9pt)[→ `π(R) − π(matches)`.]
  ],
  block(fill: notebg, inset: 8pt, radius: 2pt)[
    *3. Universality* ("all", "every", "each") \
    #text(size: 9pt)[→ division, or `π(R) − π(counter-example)`.]
  ],
  block(fill: notebg, inset: 8pt, radius: 2pt)[
    *4. Extremum* ("highest", "oldest", "latest") \
    #text(size: 9pt)[→ `R − π(σ_{R1.a < R2.a}(ρ_{R1}R × ρ_{R2}R))`.]
  ],
  block(fill: notebg, inset: 8pt, radius: 2pt)[
    *5. Comparison of two records* ("same", "more than", "pairs") \
    #text(size: 9pt)[→ self-join with `ρ` plus an explicit `θ` predicate.]
  ],
  block(fill: redbg, inset: 8pt, radius: 2pt)[
    *6. Counting / summing* ("exactly 3", "more than 20", "total") \
    #text(size: 9pt)[→ *not expressible* in classical RA. Say so, then give the
    extended-algebra form.]
  ],
)

*Conventions used throughout.*
- Relations are written in italics: $T("Sailors")$, $T("Reserves")$. Attribute names are
  upright: $A("sid")$, $A("sname")$.
- String constants are green: $sigma_(A("color") = #C("red"))$.
- *Set semantics* is assumed everywhere. A relation is a *set* of tuples; $pi$ and
  every other operator remove duplicates. This is the classical definition and it is what
  university answer scripts are marked against.
- Schema of a relation $T("R")$ is written $T("R")(A_1, A_2, dots, A_n)$.
- $#C("⊥")$ denotes the distinguished *no-value* marker used when a textbook schema has a
  NULL-able column (for example `ReturnDate`). Classical relational algebra has no NULLs;
  we model "unknown" by an explicit constant or by an explicit extra relation, and we say
  which one we are using.
- Every solution states (i) the expression, (ii) the intermediate relations *with their
  schemas*, (iii) why it is correct, (iv) the trap.

*On attributing questions.* Questions marked *(SKS §4.3 pattern)*, *(EN Ch. 6 pattern)* or
*(RG §4.2 pattern)* follow the standard pattern of that chapter; they are
*textbook-standard*, not verbatim quotations. Only questions whose wording is genuinely
canonical (for example "find sailors who have reserved all boats") are described as
classic. No question in this book claims to be a verbatim reproduction of a printed
exercise.

#heading(level: 2, outlined: false)[The twelve parts, and what each one fixes in your head]

#tab((auto, 1fr), stroke: 0.4pt + l4, inset: 5pt,
  [*Part*], [*Purpose*],
  [1], [Short notes, operator reference, schema of every operator, the 20-pattern catalogue],
  [2], [Basic university-level questions: selection, projection, rename, one-relation and two-relation queries],
  [3], [Joins, self-joins, set operations, negative ("never / without / except") queries],
  [4], [Division and universal quantification; deriving division from the five primitive operators],
  [5], [Maximum, minimum, ranking, ties, group-wise extremes, k-th highest],
  [6], [Sailors & Boats: the full 37-question classical bank],
  [7], [Books, Authors and Borrowing: full and simplified schema, 33 questions],
  [8], [Hospital & Prescription: the five original exam questions plus 22 more],
  [9], [Advanced mixed questions that combine three or more techniques],
  [10], [Query equivalence, wrong expressions, counterexamples, error clinic],
  [11], [Practice paper — questions only, exam timing],
  [12], [Answer key, marking scheme, coverage checklist],
)

#v(6pt)
#note[
  *A warning about the phrase "write the relational algebra".* Marks are lost far more
  often for an ill-typed expression than for a wrong idea. Before you write anything,
  write down the *schema you want* (which attributes must the answer have?) and the
  *schema you have*. Every operator in this book is accompanied by its schema rule for
  exactly this reason — see Part 1.3.
]

#outline(title: [Contents], depth: 1, indent: auto)

// ---------- body ----------
#include "part01.typ"
#include "part02.typ"
#include "part03.typ"
#include "part04.typ"
#include "part05.typ"
#include "part06.typ"
#include "part07.typ"
#include "part08.typ"
#include "part09.typ"
#include "part10.typ"
#include "part11.typ"
#include "part12.typ"
