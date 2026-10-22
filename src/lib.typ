// Shared macros for the Relational Algebra question bank

// ---------- palette ----------
#let ink    = rgb("#1a1a1a")
#let accent = rgb("#12456b")
#let accent2= rgb("#8a3b12")
#let l3     = rgb("#6b6b6b")
#let l4     = rgb("#c9c9c9")
#let notebg = rgb("#eef4fa")
#let warnbg = rgb("#fdf2e3")
#let redbg  = rgb("#fbecec")
#let greenbg= rgb("#edf7ee")
#let codebg = rgb("#f4f4f4")
#let rule   = rgb("#b9c6d2")

// ---------- math shorthand ----------
#let R(x) = math.italic(x)          // relation / alias name (call as #R("Sailors") inside math)
#let A(x) = math.upright(x)          // attribute name
#let C(x) = text(fill: rgb("#0b6b3a"), weight: "bold", x)  // string constant
#let w(x) = math.upright(x)         // keyword inside math (max, avg, ...)

// ---------- structural helpers ----------
#let part(num, title, blurb: none) = {
  heading(level: 1)[Part #num — #title]
  if blurb != none {
    block(fill: notebg, inset: 9pt, radius: 2pt, width: 100%)[
      #set text(size: 9.2pt)
      #blurb
    ]
    v(4pt)
  }
}

// question wrapper:  #q[6.4][statement][solution body]
#let q(id, stmt, body) = block(
  breakable: true, width: 100%, above: 13pt, below: 7pt,
  inset: (left: 10pt, top: 3pt), stroke: (left: 2.4pt + accent),
)[
  #text(fill: accent, weight: "bold", size: 10.2pt)[Q#id] #h(3pt) #text(weight: "bold")[#stmt]
  #v(2.5pt)
  #body
]

// answer line
#let ans(body) = block(above: 4pt, below: 3pt)[
  #text(weight: "bold", fill: accent)[Answer.] #body
]

// centred display maths that may break, with a little breathing room
#let eq(body) = block(width: 100%, above: 8pt, below: 8pt)[
  #align(center)[#body]
]

#let steps(..) = block(above: 3pt, below: 2pt)[
  #text(weight: "bold", size: 9.3pt)[Steps.]
]
#let lbl(x) = text(weight: "bold", fill: accent2, x)

#let trap(body) = block(
  fill: warnbg, inset: (x: 8pt, y: 6pt), radius: 2.5pt, width: 100%,
  above: 6pt, below: 4pt,
)[
  #set text(size: 9.1pt)
  #text(weight: "bold", fill: accent2)[Trap / common mistake.] #body
]

#let note(body) = block(
  fill: notebg, inset: (x: 8pt, y: 6pt), radius: 2.5pt, width: 100%,
  above: 6pt, below: 4pt,
)[
  #set text(size: 9.1pt)
  #body
]

#let nex(body) = block(
  fill: redbg, inset: (x: 8pt, y: 6pt), radius: 2.5pt, width: 100%,
  above: 6pt, below: 4pt,
)[
  #set text(size: 9.1pt)
  #text(weight: "bold", fill: rgb("#8d1f1f"))[Not expressible in classical relational algebra.] #body
]

#let ok(body) = block(
  fill: greenbg, inset: (x: 8pt, y: 6pt), radius: 2.5pt, width: 100%,
  above: 6pt, below: 4pt,
)[
  #set text(size: 9.1pt)
  #text(weight: "bold", fill: rgb("#145c2c"))[Expressible.] #body
]

#let keybox(body) = block(
  fill: rgb("#f7f7f2"), stroke: (left: 2pt + accent2), inset: (x: 9pt, y: 8pt),
  width: 100%, above: 8pt, below: 6pt,
)[
  #set text(size: 9.2pt)
  #body
]

// compact table helper:  #tab2((w1, w2), [h1],[h2], [a], [b], ...)
#let tab(cols, ..cells) = {
  let c = cells.pos()
  table(
    columns: cols, stroke: 0.4pt + l4, inset: (x: 5pt, y: 3.6pt),
    align: left, ..c,
  )
}

// small inline "schema" chip
#let sch(x) = box(fill: codebg, inset: (x: 3.2pt, y: 1.2pt), radius: 2pt, text(size: 8.6pt, font: "DejaVu Sans Mono", x))

#let why(body) = block(above: 2pt, below: 2pt)[
  #text(weight: "bold", size: 9.2pt, fill: accent2)[Why.] #body
]
#let schem(body) = block(above: 3pt, below: 1pt)[
  #text(size: 8.8pt, fill: rgb("#4a5a68"))[#body]
]
#let mini(body) = text(size: 8.9pt, fill: l3, body)


#let correct(body) = block(
  fill: greenbg, stroke: (left: 2pt + rgb("#145c2c")), inset: (x: 8pt, y: 6pt),
  width: 100%, above: 5pt, below: 3pt,
)[
  #set text(size: 9.1pt)
  #text(weight: "bold", fill: rgb("#145c2c"))[Correct form.] #body
]

#let aside(body) = block(
  stroke: (left: 1.6pt + l4), inset: (x: 8pt, y: 4pt), width: 100%,
  above: 5pt, below: 3pt,
)[
  #set text(size: 9.1pt)
  #body
]

// question with no solution (practice paper)
#let qq(id, stmt) = block(
  breakable: true, width: 100%, above: 11pt, below: 5pt,
  inset: (left: 10pt, top: 2pt), stroke: (left: 2pt + l4),
)[
  #text(fill: accent, weight: "bold", size: 10pt)[#id] #h(3pt) #stmt
]

// answer-key item
#let ki(label, body) = block(
  breakable: true, above: 7pt, below: 3pt, width: 100%,
  stroke: (left: 1.6pt + rule), inset: (left: 9pt, top: 1pt),
)[
  #text(weight: "bold", fill: accent, size: 9.6pt)[#label] #h(5pt) #body
]
