#import "lib.typ": *

#let Sa = R("Sailors")
#let Re = R("Reserves")
#let Bo = R("Boats")

#part(11, "Practice paper — questions only", blurb: [
  *How to use it.* Close the book. Time yourself. This paper is modelled on the MANIT Bhopal
  end-semester pattern (one compulsory section of short answers, plus a choice of long
  questions), but the *wording* is new — no question is copied verbatim from a previous paper.
  The answer key starts on the page referenced in Part 12.
])

#heading(level: 2)[Instructions]

#tab((auto, 1fr),
  [*Paper*], [Relational Algebra and Relational Calculus — Section B],
  [*Time*], [3 hours],
  [*Maximum marks*], [80],
  [*Schemas*], [Sailors–Boats–Reserves, Library (full schema), Hospital–Prescription. All are as defined in Part 1.2 and restated at the head of each question.],
  [*Marks*], [Section I: 10 × 2 = 20. Section II: 4 × 5 = 20. Section III: 2 × 10 = 20 (internal choice). Section IV: 1 × 20 = 20 (case study, internal choice).],
  [*Rules*], [Classical relational algebra only. No SQL. No aggregate functions. State the schema of the answer, and of each named intermediate relation. Marks are awarded for the schema even when the expression is imperfect.],
)
#v(6pt)

#heading(level: 2)[Section I — short answers (2 marks each, all compulsory)]

#qq[A1][Define union compatibility. State precisely why it is required by $union$, $inter$ and
$-$ but not by $times$.]

#qq[A2][Give the relational algebra expression for "the names of sailors who have reserved boat
103", and state the schema of the intermediate relation after the join.]

#qq[A3][Is $pi_("sname")(#Sa) - pi_("sname")(sigma_("rating" < 8)(#Sa))$ a correct way to find
the names of sailors with rating at least 8? Justify your answer in two sentences.]

#qq[A4][Write the division $#Re div pi_("bid")(#Bo)$ and state its result schema. Explain in one
sentence what it computes, and why that is not "sailors who reserved all boats".]

#qq[A5][Using the hospital schema, explain why `Patient` and `Doctor` cannot be joined with a
natural join in the query "patients whose primary doctor is John Smith".]

#qq[A6][State whether "the medicine prescribed in the largest total number of units" is
expressible in classical relational algebra. Name the operator that would be required.]

#qq[A7][Give two different expressions, one using $div$ and one not, for "sailors who reserved
every boat".]

#qq[A8][What is the result of $pi_("color")(#Bo)$ when sixty boats are red and forty are blue?
Explain in terms of set semantics.]

#qq[A9][Write the expression for "the boat(s) most recently reserved" — or state why it needs a
maximum over a date and give the expression for the latest date alone.]

#qq[A10][Define the semijoin and the antijoin, say whether either is part of the classical
algebra, and give the classical expression for each.]

#heading(level: 2)[Section II — short problems (5 marks each, attempt any four)]

#qq[B1][*(Sailors)* Find the names of sailors who have reserved a red boat but have never
reserved a green boat. Give the expression, the schema at each step, and the edge case of a
sailor with no reservations.]

#qq[B2][*(Sailors)* Find the sids of sailors whose rating is the second-highest rating in the
relation. Preserve ties in the rating value, and explain why "second-highest rating" and
"rating of the second sailor" differ.]

#qq[B3][*(Library)* Find the members who have borrowed every book written by any author whose
name is "Navathe". State the dividend and divisor schemas explicitly.]

#qq[B4][*(Hospital)* Find the names of patients who have received at least one medicine from
every generic category, where `Medicine.GenericFlag = 'Y'` marks a generic medicine, and each
such medicine is treated as its own category. Does the question even make sense? If not, repair
it and answer the repaired question.]

#qq[B5][*(Sailors)* Find the pairs of sailors who have reserved exactly the same set of boats.
Give the expression in the two-directional form and explain why one direction alone is
insufficient.]

#qq[B6][*(Mixed)* A student writes
$pi_("sname")(sigma_("color" = #C("red"))(#Sa bowtie #Re bowtie #Bo))$.
Identify every error, in the order in which an evaluator would encounter them, and write the
corrected expression.]

#heading(level: 2)[Section III — long answers (10 marks each, attempt any two)]

#qq[C1][*(Sailors)* For each of the following, write the expression and say in one line which
pattern (§1.14) you used. (a) sailors who have reserved all red boats; (b) sailors who have
reserved no red boat; (c) sailors who have reserved only red boats; (d) sailors who have
reserved at least one red boat and at least one green boat. Then explain, in a short paragraph,
why (b) and (c) are not complements of each other.]

#qq[C2][*(Hospital)* Using the hospital schema: (a) list the names of doctors who have prescribed
for patients they are not the primary doctor of; (b) list the names of patients all of whose
prescriptions were written by their primary doctor; (c) explain, with a case table, the
difference between (b) and "patients with no prescriptions by other doctors". State which
reading your expression implements.]

#qq[C3][*(Library)* The librarian wants "the most borrowed book". (a) Show that this is not
expressible in classical relational algebra and say exactly which operator is missing. (b) Write
the extended-algebra expression that answers it. (c) Write the classical expression for the
closely related query "the book borrowed by the largest number of *distinct* members" and say
whether it is expressible. (d) Write the classical expression for "the book with the highest
price" (assume a `Price` attribute on `Book`) and explain why *that* one is expressible.]

#qq[C4][*(Sailors)* Prove or disprove each statement, with a counter-example where it fails.
(a) $R div (S_1 union S_2) = (R div S_1) union (R div S_2)$.
(b) $sigma_theta(R bowtie S) = sigma_theta(R) bowtie sigma_theta(S)$.
(c) $pi_("sid")(#Re) - pi_("sid")(#Sa) = emptyset$ for every instance of the sailors schema.
(d) $R inter S = R - (R - S)$.]

#heading(level: 2)[Section IV — case study (20 marks, attempt any one)]

#qq[D1][*Hospital, integrated.* A hospital quality report needs the following five answers.
Write all five expressions, name each intermediate relation with its schema, and state for each
whether it is expressible in classical relational algebra.
#v(3pt)
#list(
  indent: 1.2em,
  [The names of patients who have seen (i.e. have a prescription from) more than three distinct
   doctors, together with the number of such doctors — *the count is optional*; if it is not
   expressible, say so and give what is.],
  [The names of doctors who have prescribed at least one medicine to every patient for whom they
   are the primary doctor.],
  [The names of patients who have been prescribed at least one medicine that their primary
   doctor has never prescribed to anyone.],
  [The trade names of medicines that have been prescribed by every doctor who has prescribed
   anything.],
  [The names of the patient(s) whose most recent prescription is the most recent prescription in
   the hospital.],
)]

#qq[D2][*Sailors, integrated.* Answer the following, naming each intermediate relation and its
schema, and flag any part that is not expressible.
#v(3pt)
#list(
  indent: 1.2em,
  [The names of sailors who have reserved every boat reserved by any sailor with a rating lower
   than their own.],
  [The sids of sailors who have reserved at least one boat on every date on which boat 103 was
   reserved.],
  [The boat(s) with the highest number of reservations — expressible or not?],
  [The names of sailors who have never reserved a boat that is older than their own rating —
   note that this question contains a domain error; identify it and answer the repaired
   question.],
  [Using only $pi$, $sigma$ and $times$, express "sailors who have reserved all boats".],
)]

#heading(level: 2)[Marking scheme, in one paragraph]

Section I rewards precision: a correct expression with no schema statement typically loses one
of the two marks. Section II rewards the *edge cases* — the empty divisor, the sailor with no
reservations, the tie. Section III expects every intermediate relation to be named, and expects
you to say which reading of an ambiguous sentence you are implementing. Section IV is where the
"not expressible" discussion earns its marks: a bare "cannot be done" without the name of the
missing operator scores at most a third of the part.

#v(10pt)
#note[
  *Diagnostic.* If you can do Section I in 20 minutes and Section II in 40, your notation is
  sound. If Section III(C3) or Section IV(D1.1) still feels uncertain, re-read §1.11 and §10.6
  — the *expressibility frontier* is where most students lose the largest single block of marks,
  because they answer a counting question with an extreme-value pattern.
]
