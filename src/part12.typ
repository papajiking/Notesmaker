#import "lib.typ": *

#let Sa = R("Sailors")
#let Re = R("Reserves")
#let Bo = R("Boats")

#part(12, "Answer key, marking scheme and coverage checklist", blurb: [
  *Purpose.* Compact answers to the practice paper (Part 11), followed by the coverage
  checklist that proves every category required by the brief has been covered, with a pointer
  to where. Use the checklist as a revision index, not as a list of topics to memorise
  separately.
])

#heading(level: 2)[12.1 Answer key — Section I]

#ki[A1][$R$ and $S$ are union compatible when they have the same number of attributes and the
$i$-th attribute of $R$ has the same domain as the $i$-th of $S$, for every $i$; names need not
match, and the result takes the names of the left operand. $times$ needs no such condition
because it produces *all* combinations and merges no attribute: its result schema is the union
of the two attribute sets, and it is defined for any pair of relations with disjoint attribute
names.]

#ki[A2][$pi_("sname")(#Sa bowtie sigma_("bid" = 103)(#Re))$. Intermediate schema after the join:
$("sid", "sname", "rating", "age", "bid", "day")$.]

#ki[A3][No. `sname` is not a key: a sailor with rating 7 and the same name as a sailor with
rating 9 appears on both sides and cancels. The correct form subtracts on `sid`.]

#ki[A4][Result schema $("sid", "day")$ — "reserved every boat on one single day". It is not
"sailors who reserved all boats" because `day` is retained: the quantification is per day.]

#ki[A5][`Patient` and `Doctor` share `SSN`, `FirstName` and `LastName`. A natural join equates
all three, i.e. it looks for patients who *are* the doctor. The intended join is
`Patient.PrimaryDoctor_SSN = Doctor.SSN`, an equijoin on differently-named attributes.]

#ki[A6][Not expressible. It requires the aggregation operator $gamma$ with `sum`.]

#ki[A7][With division: $pi_("sid", "bid")(#Re) div pi_("bid")(#Bo)$. Without:
$pi_("sid")(#Sa) - pi_("sid")(pi_("sid")(#Sa) times pi_("bid")(#Bo) - pi_("sid", "bid")(#Re))$.]

#ki[A8][Two rows: one for `red`, one for `blue`. $pi$ returns a *set*, so the 60 red boats
collapse to a single `red` tuple.]

#ki[A9][The latest date is
$pi_("day")(#Re) - pi_("R1.day")(sigma_("R1.day" < "R2.day")(rho_("R1")(#Re) times rho_("R2")(#Re)))$.
The boat(s) associated with it are found by joining that value back to `Reserves`; if several
boats share the latest date, all are returned.]
#ki[A10][Semijoin $R bowtie.l S = pi_("attr"(R))(R bowtie S)$; antijoin
$R arrow.l S = R - pi_("attr"(R))(R bowtie S)$. Neither is classical; both are shorthands to
be expanded in a classical-RA answer.]

#heading(level: 2)[12.2 Answer key — Section II]

#ki[B1][$ pi_("sname")(#Sa bowtie (pi_("sid")(#Re bowtie sigma_("color" = #C("red"))(#Bo)) - pi_("sid")(#Re bowtie sigma_("color" = #C("green"))(#Bo)))) $.
Steps: `Red` $= pi_("sid")(#Re bowtie sigma_("color" = #C("red"))(#Bo))$, schema $("sid")$;
`Green` likewise; difference $("sid")$; natural join with `Sailors` on `sid`; result $("sname")$.
A sailor with no reservations is in neither `Red` nor `Green`, so he is *not* returned — which is
correct for "reserved a red boat but not a green one".]

#ki[B2][Let `M` be the maximum rating (Q5.1) and `Rest` $= pi_("rating")(#Sa) - "M"$. The
second-highest is the maximum of `Rest`, i.e.
$"Rest" - pi_("R1.rating")(sigma_("R1.rating" < "R2.rating")(rho_("R1")("Rest") times rho_("R2")("Rest")))$.
"Second-highest rating" is a *value*; "rating of the second sailor" needs an ordering of rows,
which relations do not have.]

#ki[B3][Dividend $pi_("MemberID", "BookID")(#R("Borrow"))$. Divisor
$pi_("BookID")(#R("WrittenBy") bowtie_(#A("AuthorID") = #A("A.AuthorID")) sigma_("A.AuthorName" = #C("Navathe"))(rho_("A")(#R("Author"))))$.
Result $("MemberID")$.]

#ki[B4][As stated it does not make sense: "every generic category" treats each medicine as a
category of its own, so the query degenerates to "received every generic medicine", which *is*
answerable. Repaired: dividend $pi_("Patient_SSN", "TradeName")(#R("Prescription") bowtie_(#A("Id") = #A("Prescription_Id")) #R("Prescription_Medicine"))$,
divisor $pi_("TradeName")(sigma_("GenericFlag" = #C("Y"))(#R("Medicine")))$, result
$("Patient_SSN")$. The lesson: a division question is only well posed when the divisor
describes a genuine finite set.]

#ki[B5][Two-directional coverage (Q7.33 / Q9.6). One direction alone returns pairs $(a, b)$ where
$b$ has borrowed everything $a$ did — a *superset* relation, not equality. Both directions are
needed because set equality is a conjunction of two inclusions.]

#ki[B6][The errors, in evaluation order: (i) `Sailors` has no `color`, so the selection is not
bound to the right relation — it must be applied to `Boats`; (ii) as written the selection is
applied *after* the joins, which is legal but then `color` is unqualified and ambiguous in
principle — qualify it; (iii) the projection after the join is fine, so the repaired expression
is $pi_("sname")(#Sa bowtie #Re bowtie sigma_("color" = #C("red"))(#Bo))$, or equivalently
$pi_("sname")(sigma_("Boats.color" = #C("red"))(#Sa bowtie #Re bowtie #Bo))$. A third,
subtler issue: if the intent was "reserved *only* red boats", the expression answers the wrong
quantifier.]
#heading(level: 2)[12.3 Answer key — Section III]

#ki[C1][(a) $pi_("sname")(#Sa bowtie (pi_("sid", "bid")(#Re) div pi_("bid")(sigma_("color" = #C("red"))(#Bo))))$ — pattern 6.
(b) $pi_("sname")(#Sa bowtie (pi_("sid")(#Sa) - pi_("sid")(#Re bowtie sigma_("color" = #C("red"))(#Bo))))$ — pattern 2.
(c) $pi_("sname")(#Sa bowtie (pi_("sid")(#Re) - pi_("sid")(#Re bowtie sigma_("color" != #C("red"))(#Bo))))$ — pattern 5.
(d) $pi_("sname")(#Sa bowtie (pi_("sid")(#Re bowtie sigma_("color" = #C("red"))(#Bo)) inter pi_("sid")(#Re bowtie sigma_("color" = #C("green"))(#Bo))))$ — pattern 3.
(b) and (c) are not complements: a sailor with no reservations satisfies *neither* "reserved a
red boat" nor "reserved a red boat but not a green one"; and a sailor with red *and* blue
satisfies neither (b) nor (c) either — he is excluded from (c) by the blue boat, and from (b)
because he *did* reserve red. The two sets overlap, so they cannot be complements.]

#ki[C2][(a) $pi_("D.FirstName", "D.LastName")(rho_("D")(#R("Doctor")) bowtie_(#A("D.SSN") = #A("Doctor_SSN")) sigma_("PrimaryDoctor_SSN" != "Doctor_SSN")(#R("Prescription") bowtie_(#A("Patient_SSN") = #A("P.SSN")) rho_("P")(#R("Patient"))))$.
(b) patients minus patients having a prescription by a non-primary doctor (Q8.4). (c) the case
table of Q8.4: (b) as literally worded returns A $union$ B; the stricter "has prescriptions,
all by the primary doctor" returns B only. State the reading.]

#ki[C3][(a) Not expressible; missing operator $gamma$ (grouping with `count`).
(b) $gamma_("BookID"; "count"("MemberID") arrow.l n)(#R("Borrow"))$, then the maximum-of-`n`
pattern, then join to `Book` for the title.
(c) "Borrowed by the largest number of distinct members" is also a count of distinct entities,
so also not expressible — a common trap, because "distinct" sounds like a set operation but the
*comparison* is still between counts.
(d) With a `Price` attribute, $#R("Book") - pi_("B1.BookID", "B1.Title", "B1.Publisher", "B1.Category", "B1.Price")(sigma_("B1.Price" < "B2.Price")(rho_("B1")(#R("Book")) times rho_("B2")(#R("Book"))))$ —
expressible because price is a *stored value*, so it can be compared with $<$ directly.]

#ki[C4][(a) False (Q4.15). (b) False in general: if $theta$ mentions attributes of both $R$ and
$S$, $sigma_theta(R) bowtie sigma_theta(S)$ is ill-typed or empty while the left side is not;
the identity holds only when $theta$ is a conjunction of an $R$-part and an $S$-part.
(c) True: every reserving `sid` is a sailor's `sid` (referential integrity), so the difference is
always empty — a good check on foreign keys. (d) True: $R - (R - S) = R inter S$ (§1.10).]
#heading(level: 2)[12.4 Answer key — Section IV (outline)]

#ki[D1][(1) "More than three distinct doctors" is *expressible* (four tuple variables, Q8.22);
the accompanying *count* is not — say so and give the four-variable expression.
(2) Expressibility is subtle: "every patient for whom they are the primary doctor" is a
quantified set derived from `Patient`; if a doctor has *no* primary patients, the condition is
vacuously true. The expression is a difference against a violation set, exactly as in Q8.14.
(3) Two nested differences: medicines of the patient minus medicines of the primary doctor.
(4) $pi_("Doctor_SSN", "TradeName")(#R("Prescription") bowtie #R("Prescription_Medicine")) div pi_("Doctor_SSN")(#R("Prescription"))$ —
a clean division with a derived dividend.
(5) Maximum over `Date` (Q5.13), then join back: expressible.]

#ki[D2][(1) A division whose divisor varies per sailor — not directly expressible as one
division; use the counter-example method with a *three-variable* device (Q9.6), subtracting the
"sailor x has a boat of a lower-rated sailor that x lacks" pairs.
(2) $pi_("sid", "day")(#Re) div pi_("day")(sigma_("bid" = 103)(#Re))$ — a clean division.
(3) Not expressible (count of reservations per boat).
(4) Domain error: `age` and `rating` are different domains, and "a boat that is older than a
rating" is a category mistake. The repaired question is presumably "sailors who have never
reserved a boat whose *bid* is lower than their rating" — still a domain error; the meaningful
repair is "…a boat that any sailor with a lower rating has reserved" (Q9.5).
(5) $pi_("sid")(#Sa) - pi_("sid")(pi_("sid")(#Sa) times pi_("bid")(#Bo) - pi_("sid", "bid")(#Re))$.]
#heading(level: 2)[12.5 Coverage checklist]

Every row of the brief is listed with the questions that discharge it. Tick the box when you can
reproduce the *pattern* from memory, not the example.

#table(
  columns: (auto, 1.55fr, 1fr, auto),
  stroke: 0.4pt + l4, inset: (x: 5pt, y: 3.6pt), align: (left, left, left, center),
  table.header([*Ref*], [*Required category*], [*Where covered*], [*Done*]),
  [C1], [Selection and projection], [§1.4–1.5; Q2.1–Q2.12; Q6.1–Q6.8], [☐],
  [C2], [Rename and aliasing], [§1.6; Q2.13–Q2.14], [☐],
  [C3], [Union, intersection, difference; union compatibility], [§1.7; Q3.1–Q3.14; Q6.9–Q6.14], [☐],
  [C4], [Cartesian product and theta join], [§1.8; Q2.15–Q2.20], [☐],
  [C5], [Equijoin and natural join], [§1.8; Q2.17–Q2.18], [☐],
  [C6], [Multi-relation joins], [Q2.18; Q6.4; Q7.4; Q8.9], [☐],
  [C7], [Self-joins], [Q3.15–Q3.20; Q6.15–Q6.22], [☐],
  [C8], [At least one / at least two / exactly one / none], [Q3.8–Q3.10; Q5.17–Q5.19; Q5.23–Q5.27], [☐],
  [C9], [NOT, NEVER, WITHOUT, ONLY, EXCEPT], [Q3.3–3.7, 3.21–3.26; Q6.11–6.14, 6.26, 6.31, 6.33, 6.35], [☐],
  [C10], [ALL, EVERY, EACH; universal quantification], [Part 4 in full; Q6.23–Q6.27, Q6.34, Q6.37], [☐],
  [C11], [Division and equivalent formulations], [§1.9–1.10, §4.2; Q4.1–Q4.22], [☐],
  [C12], [Same versus different records], [Q3.15–3.19; Q6.15–6.22; Q7.33; Q8.21], [☐],
  [C13], [Date comparisons], [Q2.8; Q3.9, 3.21; Q5.13; Q7.25–7.26; Q8.24], [☐],
  [C14], [Conditional and group-wise maximum/minimum], [Q5.8, 5.12–5.16; Q8.24], [☐],
  [C15], [Nested expressions], [Q9.1–Q9.14], [☐],
  [C16], [Query equivalence], [§10.1; Q10.19–Q10.23; C4 of the practice paper], [☐],
  [C17], [Error detection], [§10.3, Q10.1–Q10.18; B6 of the practice paper], [☐],
  [C18], [Union compatibility and schema matching], [§1.7; Q10.3, Q10.10, Q10.18], [☐],
  [C19], [Expression simplification], [§10.4–10.5; Q10.19–Q10.23], [☐],
  [C20], [Fixed-cardinality conditions without aggregates], [§10.6; Q5.17–Q5.19; Q8.22], [☐],
  [C21], [Queries not expressible under the restrictions], [§10.7; Q5.9–5.10, 5.16, 5.19, 5.27→; Q7.24; Q8.3, 8.27; Q9.8, 9.13], [☐],
  [C22], [Maximum / minimum attribute values], [§5.1; Q5.1–5.4, 5.11], [☐],
  [C23], [Records with maximum / minimum], [Q5.3–5.4, 5.6, 5.11], [☐],
  [C24], [Second-highest, third-highest, k-th highest], [Q5.5–5.7, 5.22, 6.30, 9.9], [☐],
  [C25], [Tied maxima and minima], [Q5.3, 5.6, 5.14; Q6.28], [☐],
  [C26], [Global versus group-wise maximum], [Q5.8, 5.13, 5.15; Q8.24; §10.2 pair 8], [☐],
  [C27], [Most expensive treatment per doctor / cheapest per patient], [Q5.8, 5.11, 5.13; Q8.16, 8.20, 8.24], [☐],
  [C28], [Highest salary per department], [Q5.8, 5.23], [☐],
  [C29], [Latest and earliest dates], [Q3.9, 3.21; Q5.13; Q7.25–7.26; Q8.24], [☐],
  [C30], [Maximum after a selection / after removing records], [Q5.12, 5.21; Q9.7, 9.9], [☐],
  [C31], [The eleven confusable sentence pairs], [§10.2, pairs 1–11], [☐],
  [C32], [Sailors and Boats: all 37 required queries], [Part 6, Q6.1–Q6.37], [☐],
  [C33], [Library: full and simplified schema, 33 queries], [Part 7, Q7.1–Q7.33], [☐],
  [C34], [Hospital: the five exam questions], [Q8.1–Q8.5], [☐],
  [C35], [Hospital: 20+ additional queries], [Q8.6–Q8.27], [☐],
  [C36], [Assumptions on keys and NULLs], [§1.16; Q7.30; Q8.4], [☐],
  [C37], [When aggregation or extensions are required], [§1.11, §10.6–10.7; Q5.9, 5.16, 5.27; Q7.24; Q8.3], [☐],
)

#heading(level: 2)[12.6 Known traps, in one page — the last thing to read before the exam]

#keybox[
+ *The universe is part of the question.* "Never reserved a red boat" must start from
  $pi_("sid")(#Sa)$, not from $pi_("sid")(#Re)$.
+ *Set operations go on keys.* `sname` and `Title` are not keys; subtracting names deletes
  innocent rows and keeps wrong ones.
+ *Both sides of $-, union, inter$ must have the same attribute list.* Write it out before you
  write the operator.
+ *A selection cannot see another tuple.* Comparisons between two rows need $rho$ plus $times$.
+ *For self-joins with $!=$ use $times$.* A natural join of a relation with its renamed copy
  equates everything.
+ *Divide only after projecting.* The dividend is exactly (answer attributes $union$ divisor
  attributes).
+ *The divisor is the set you quantify over* — filter *inside* it, not around it.
+ *Extremes: value first, then join.* That is what preserves ties.
+ *Standardise the projection list to the target's schema order* whenever you subtract whole
  tuples.
+ *Counts, sums, averages, "more than $n$", "same number as", "most" are not classical.* Say so,
  name $gamma$, and then — if the question allows — give the extended expression.
+ *Bracket everything.* There is no universal precedence.
+ *State your assumptions* about ties, NULLs, keys and the empty case. Examiners award marks for
  each one you name, and they cannot award marks for what you did not write.
]

#v(12pt)
#align(center)[
  #line(length: 40%, stroke: 0.5pt + l4)
  #v(5pt)
  #text(size: 9pt, fill: l3, style: "italic")[
    End of the question bank. \
    Every expression in this book is classical relational algebra: $pi$, $sigma$, $rho$,
    $union$, $-$, $times$, and the derived $inter$, $bowtie$, $div$. No SQL, no aggregates,
    no shortcuts that cannot be expanded.
  ]

]