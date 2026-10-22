#import "lib.typ": *

#let Sa = R("Sailors")
#let Re = R("Reserves")
#let Bo = R("Boats")

#part(4, "Division, \"all\", \"every\", \"only\" and universal conditions", blurb: [
  *What this part fixes.* Division is the only classical operator that expresses $forall$.
  This part gives the definition, the derivation from $pi, times, -$, the three schema
  discipline rules, the empty-divisor edge case, and twenty-two questions that separate
  "all", "only", "every", "at least one" and "no". Schema: Sailors–Boats–Reserves unless a
  question says otherwise.
])

#heading(level: 2)[4.1 The definition, once and properly]

Let $R("R")(X, Y)$ and $R("S")(Y)$, with $"attr"(R("S")) = Y subset.eq "attr"(R("R"))$. Then

#eq[$ R("R") div R("S") = { t in pi_X (R("R")) : forall s in R("S") space [(t, s) in R("R")] } $]

Three consequences that decide most exam answers:

+ The *result schema* is $X = "attr"(R("R")) - "attr"(R("S"))$. Nothing else survives.
+ The divisor must be *exactly* the set you are quantifying over. "All boats" is
  $pi_("bid")(#Bo)$; "all boats that are red" is $pi_("bid")(sigma_("color" = #C("red"))(#Bo))$;
  "all boats reserved by sailor 22" is $pi_("bid")(sigma_("sid" = 22)(#Re))$.
+ The dividend must be *projected* to $X union Y$ before dividing. If it carries an extra
  attribute — the classic mistake of dividing `Reserves` itself — the extra attribute joins
  $X$ and the answer has the wrong schema, even if the tuples look plausible.

#heading(level: 2)[4.2 Deriving division from the five primitive operators]

#keybox[
*Claim.* $R("R") div R("S") = pi_X (R("R")) - pi_X ( (pi_X (R("R")) times R("S")) - R("R") )$,
where $X = "attr"(R("R")) - "attr"(R("S"))$.

*Proof.*
+ $pi_X (R("R"))$ is the set of *candidate* answers — every $t$ that is attached to at least
  one $s$ in $R("R")$.
+ $pi_X (R("R")) times R("S")$ is the set of *all pairs* $(t, s)$ that a perfect answer would
  have to contain.
+ Subtracting $R("R")$ leaves precisely the pairs $(t, s)$ that are *missing* from $R("R")$.
+ Projecting to $X$ gives the set of candidates $t$ that are missing at least one $s$, i.e.
  the candidates that fail the $forall$.
+ Subtracting that from the candidates leaves exactly the $t$ for which no $s$ is missing.
  That is the definition of division. $square$
]

#q[4.1][Find the sids of sailors who have reserved *all* boats.][
#ans[ $ pi_("sid", "bid")(#Re) div pi_("bid")(#Bo) $ ]
#schem[Dividend: $("sid", "bid")$. Divisor: $("bid")$. Result: $("sid")$.]
#why[ The dividend has been projected to $("answer", "quantified") = ("sid", "bid")$. The divisor
is the full set of boats. Any extra attribute in the dividend — `day` in particular — would
end up in the result schema and change the meaning. ]
#trap[ $#Re div pi_("bid")(#Bo)$ is *not* equivalent: `Reserves` has schema
$("sid", "bid", "day")$, so $"attr"(R) - "attr"(S) = ("sid", "day")$ and the "answer" is a set
of (sailor, day) pairs — a sailor who reserved *all* boats on one single day. Silently
different, and a classic lost mark. ]
]

#q[4.2][Find the names of sailors who have reserved all boats.][
#ans[ $ pi_("sname")(#Sa bowtie (pi_("sid", "bid")(#Re) div pi_("bid")(#Bo))) $ ]
#schem[Division result $("sid")$; join with `Sailors` on `sid`; project $("sname")$.]
#why[ Compute the key set first — division on keys only — then look up descriptive
attributes. This "divide, then join" habit prevents almost every name-related error. ]
#trap[ Do not attempt to divide a relation that contains `sname`. If you need names, join
*after* the division. ]
]

#q[4.3][Find the sids of sailors who have reserved all *red* boats.][
#ans[ $ pi_("sid", "bid")(#Re) div pi_("bid")(sigma_("color" = #C("red"))(#Bo)) $ ]
#schem[Result $("sid")$.]
#why[ The quantified set is "red boats", so the colour filter belongs inside the *divisor*. ]
#trap[ $pi_("sid", "bid")(sigma_("color" = #C("red"))(#Re bowtie #Bo)) div pi_("bid")(#Bo)$
asks a completely different question — it removes non-red reservations from the dividend and
then requires all boats, which can never succeed unless every boat is red. Filters belong on
the divisor when they define the quantified set, and on the dividend only when they restrict
the witness set. ]
]

#q[4.4][Find the sids of sailors who have reserved every boat that sailor 22 has reserved.][
#ans[ $ pi_("sid", "bid")(#Re) div pi_("bid")(sigma_("sid" = 22)(#Re)) $ ]
#schem[Result $("sid")$.]
#why[ The quantified set is *whatever 22 reserved*, which is computed as a projection of a
selection. Sailor 22 appears in his own answer (he did reserve all of them) — decide from the
wording whether to exclude him with a further difference. ]
#trap[ If 22 has reserved nothing, the divisor is empty and division returns *every* sid in
$pi_("sid")(#Re)$. That is the vacuous-truth edge case; see Q4.19. ]
]

#q[4.5][Find the sids of sailors who have reserved every boat on 2019-10-01, and explain why
the schema makes this question ambiguous.][
#ans[ Two readings, and the schema decides which is expressible:
*(a) "for each boat, there is a reservation by this sailor on that date"* —
$ pi_("sid", "bid")(sigma_("day" = #C("2019-10-01"))(#Re)) div pi_("bid")(#Bo) $;
*(b) "this sailor's reservations on that date cover all boats"* — exactly the same expression,
because the dividend is already restricted to that date.
The *diagonal* reading — "there is one day on which he reserved all boats" — is
$ pi_("sid", "day")(#Re) - pi_("sid", "day")( (pi_("sid", "day")(#Re) times pi_("bid")(#Bo)) - pi_("sid", "bid", "day")(#Re) )$,
i.e. a division whose result keeps `day`. ]
#schem[(a)/(b) return $("sid")$; the diagonal reading returns $("sid", "day")$.]
#why[ The word "on" attaches either to the reservation (readings a and b) or to the
quantification (the diagonal reading). Classical relational algebra can express all three, but
*which schema the answer must have* tells you which one is wanted. Say which reading you are
using. ]
#trap[ Reading (b) is *not* the same as (a) when the schema allowed a sailor to reserve the
same boat twice on the same day — it does not, by the key — but they *are* different from the
diagonal reading, which is the one most students accidentally write by dividing
$(pi_("sid", "day", "bid"))$. ]
]

#q[4.6][Find the names of sailors who have reserved all boats of colour red *or* all boats of
colour green.][
#ans[ $ pi_("sname")(#Sa bowtie ( R("AllRed") union R("AllGreen") )) $ where
$R("AllRed") = pi_("sid", "bid")(#Re) div pi_("bid")(sigma_("color" = #C("red"))(#Bo))$ and
$R("AllGreen") = pi_("sid", "bid")(#Re) div pi_("bid")(sigma_("color" = #C("green"))(#Bo))$. ]
#schem[Both division results are $("sid")$, so the union is legal. Result $("sname")$.]
#why[ "All red or all green" is a disjunction of two *complete* universal conditions. Each
universal condition is one division; the disjunction is union. Compare with Q4.7, where the
disjunction is *inside* the quantifier and the answer is different. ]
#trap[ Do *not* distribute union into division: $R div (S_1 union S_2) != (R div S_1) union (R div S_2)$
in general. Dividing by a larger set is *harder*; the right-hand side is easier for each term.
This non-distributivity is a standard 2-mark theory question. ]
]

#q[4.7][Find the sids of sailors who have reserved all boats that are red *or* green.][
#ans[ $ pi_("sid", "bid")(#Re) div pi_("bid")(sigma_("color" = #C("red") or "color" = #C("green"))(#Bo)) $ ]
#schem[Result $("sid")$.]
#why[ Here the disjunction defines the *quantified set*: every boat whose colour is red or
green. It is one division, not a union of two divisions. The distinction from Q4.6 is the
whole point of the pair: compare "all red or all green" (union of divisions) with "all
red-or-green" (division by a union). ]
#trap[ Neither expression implies the other. A sailor who reserved all red boats and no green
boats satisfies Q4.6 but not Q4.7. ]
]

#q[4.8][Find the sids of sailors who have reserved all boats, *and* whose rating is at least
8.][
#ans[ $ ( pi_("sid", "bid")(#Re) div pi_("bid")(#Bo) ) inter pi_("sid")(sigma_("rating" >= 8)(#Sa)) $ ]
#schem[Both operands $("sid")$. Result $("sid")$.]
#why[ Two independent conditions on a sailor, each computed on the key, then intersected.
Mixing a universal condition (division) with a tuple-local one (selection) is always done this
way — never by trying to push the selection into the division. ]
#trap[ Restricting the dividend instead — $pi_("sid", "bid")(sigma_("rating" >= 8)(#Sa) bowtie #Re) div dots$ —
also works here because the join preserves the pair, but it is fragile: it silently changes
the meaning if the restriction is on an attribute that does not survive the join. The
intersection form is safer and easier to mark. ]
]

#q[4.9][Find the sids of sailors who have reserved at least one boat but *not* all boats.][
#ans[ $ pi_("sid")(#Re) - ( pi_("sid", "bid")(#Re) div pi_("bid")(#Bo) ) $ ]
#schem[Both $("sid")$. ]
#why[ "At least one" is the universe, "all" is subtracted. The order matters: subtracting in
the other direction is meaningless but still well-typed, so no error will warn you. ]
#trap[ See Q3.24 for the difference between this and its complement over *all* sailors. ]
]

#q[4.10][Find the boats that have been reserved by all sailors with rating 10.][
#ans[ $ pi_("bid", "sid")(#Re) div pi_("sid")(sigma_("rating" = 10)(#Sa)) $ ]
#schem[Result $("bid")$. Note the dividend's attribute order is irrelevant to division; what
matters is that its schema is exactly (answer attributes $union$ divisor attributes).]
#why[ The direction of the question is reversed: the answer attribute is `bid` and the
quantified attribute is `sid`. Division does not care which attribute is which. ]
#trap[ Using $pi_("bid", "sid")(sigma_("bid" = 101)(#Re))$ as the dividend restricts the boats
considered, which is a different (usually easier) question. ]
]

#q[4.11][Find the names of sailors who have reserved every boat that has been reserved by
*every* sailor with rating 10.][
#ans[ Let $R("B10") = pi_("bid", "sid")(#Re) div pi_("sid")(sigma_("rating" = 10)(#Sa))$ —
the boats reserved by all rating-10 sailors. Then
$ pi_("sname")(#Sa bowtie ( pi_("sid", "bid")(#Re) div R("B10") )) $. ]
#schem[$R("B10")$: $("bid")$. The second division returns $("sid")$. Result $("sname")$.]
#why[ Nested universals compose naturally when the inner one produces exactly the set the
outer one quantifies over. Read inside-out: first find the set of boats, then divide by it. ]
#note[ If $R("B10")$ is empty — no boat was reserved by every rating-10 sailor, which happens
whenever a rating-10 sailor reserved nothing — the outer division returns *every* sailor.
Vacuous truth again; state it. ]
#trap[ Do not try to flatten the two divisions into one. $(R div S) div T$ is not a
meaningful expression here because the schemas do not line up. ]
]

#q[4.12][Find the sids of sailors who have reserved every boat that is *not* red.][
#ans[ $ pi_("sid", "bid")(#Re) div pi_("bid")(#Bo - pi_("bid", "color")(#Bo) bowtie_("color" != "red") dots) $
— written correctly:
$ pi_("sid", "bid")(#Re) div pi_("bid")(#Bo - sigma_("color" = #C("red"))(#Bo)) $ ]
#schem[The divisor is $pi_("bid")(#Bo - sigma_("color" = #C("red"))(#Bo))$, a set of bids.
Result $("sid")$. ]
#why[ The quantified set is defined by a *difference* on `Boats`, and only then projected to
`bid`. The order — filter first, project second — is what keeps the domain of the divisor
right. ]
#trap[ $pi_("bid")(#Bo) - pi_("bid")(sigma_("color" = #C("red"))(#Bo))$ is equivalent and
also correct. But $pi_("bid")(#Bo) - pi_("bid", "color")(#Bo)$ would be a type error. ]
]

#heading(level: 2)[4.3 The schema discipline of division: three worked diagnostics]

#note[
  The three checks below catch essentially every division error in an exam script. Do them in
  this order before writing anything.

  #tab((auto, 1fr),
    [*Check*], [*How to verify*],
    [1. Divisor schema], [List the attributes of the divisor. Say aloud what set they describe ("the set of all bids", "the set of bids of red boats"). If you cannot name the set in one phrase, the divisor is wrong.],
    [2. Dividend schema], [It must be exactly $X union Y$ — answer attributes plus divisor attributes, nothing else. If `day` or `sname` is in there and you did not intend it, the division answers a different question.],
    [3. Result schema], [It must be exactly $X$. Say aloud what a tuple of the result means ("a sailor such that…"). If you cannot finish the sentence with "for all", you did not need division.],
  )
]

#q[4.13][A student writes $#Re div pi_("bid")(#Bo)$ for "sailors who reserved all boats".
Diagnose the error, state the schema the student's expression actually has, and repair it.][
#ans[ Correct: $pi_("sid", "bid")(#Re) div pi_("bid")(#Bo)$. ]
#schem[Student's result: $"attr"(#Re) - "attr"(pi_("bid")(#Bo)) = ("sid", "bid", "day") - ("bid") = ("sid", "day")$.
The repaired expression has result $("sid")$. ]
#why[ The student's expression is *well-typed and non-empty*: it returns (sailor, day) pairs
such that, on that single day, the sailor reserved every boat. That is a real query — just not
the one asked. This is the most instructive error in the whole subject, because nothing about
the syntax is wrong. ]
#trap[ The habit that prevents it: always write the dividend as
$pi_("sid", "bid")$ — i.e. *project to exactly the two attributes you are relating* — before
dividing. ]
]

#q[4.14][What does $pi_("sid", "bid")(#Re) div pi_("bid", "day")(#Re)$ mean? Is it the same as
Q4.1?][
#ans[ It is *not* Q4.1. The divisor is a set of (bid, day) pairs; the dividend's schema is
$("sid", "bid")$, which does not contain `day`, so the divisor's schema is not a subset of the
dividend's — the expression is *ill-formed*. ]
#schem[Undefined: division requires $"attr"(R("S")) subset.eq "attr"(R("R"))$.]
#why[ Division quantifies over *tuples of the divisor*, and those tuples must be able to
combine with candidate tuples to form tuples of the dividend. If the divisor mentions an
attribute the dividend does not have, the concatenation is impossible. ]
#note[ To ask "sailors who reserved every (boat, day) pair that occurs", the dividend must
include `day`: $pi_("sid", "bid", "day")(#Re) div pi_("bid", "day")(#Re)$, whose result is
$("sid")$ and whose meaning is exactly that. This is a genuinely different query from Q4.1
and much harder to satisfy. ]
]

#q[4.15][Prove that $R div (S_1 union S_2) subset.eq (R div S_1) inter (R div S_2)$, and give an
example showing the inclusion is strict.][
#note[
  Careful: the natural expectation is the opposite direction. Work it out.
  If $t$ has all pairs with every element of $S_1 union S_2$, it certainly has all pairs with
  every element of $S_1$ — so $t in R div S_1$, and likewise for $S_2$. Hence
  $R div (S_1 union S_2) subset.eq (R div S_1) inter (R div S_2)$.
]
#ans[ The inclusion is in that direction and is generally strict. Example: $R("R")$ relates
sailor 1 to boats 101 and 102, and sailor 2 to boat 101 only. $R("S_1") = {101}$,
$R("S_2") = {102}$. Then $R("R") div R("S_1") = {1, 2}$ and $R("R") div R("S_2") = {1}$, whose
intersection is ${1}$; and $R("R") div (R("S_1") union R("S_2")) = {1}$. Equality here. ]
#why[ To see strictness, add a third sailor who has all of $R("S_1")$ and all of $R("S_2")$ but
not their union — impossible, because the union is just the two elements. Strictness arises
only when the elements of $R("S_1")$ and $R("S_2")$ are *pairs* whose combinations are
missing: let $R("S_1") = {(101, "a")}$, $R("S_2") = {(102, "b")}$, and let $t$ have exactly
those two pairs but not $(101, "b")$ or $(102, "a")$. Then $t$ is in both quotients but not
in $R("R") div (R("S_1") union R("S_2"))$. ]
#trap[ Many textbooks state $R div (S_1 union S_2) = (R div S_1) inter (R div S_2)$ in
exercises that *assume* one-attribute divisors, where the identity does hold. Always check the
arity of the divisor before quoting an identity. ]
]

#q[4.16][Express "sailors who have reserved all boats" *without* using division, then expand
your expression into the five primitive operators only.][
#ans[ $ pi_("sid")(#Sa) - pi_("sid")( pi_("sid")(#Sa) times pi_("bid")(#Bo) - pi_("sid", "bid")(#Re) ) $
This uses only $pi$, $times$, $-$ — already primitive. ]
#schem[Inner: $("sid", "bid")$ on both sides of the difference; after $pi$: $("sid")$.]
#why[ The middle term is the *missing-pairs* relation. A sailor is disqualified exactly when
he is attached to at least one missing pair. This is the definition of division written out,
and it is the answer an examiner wants when division is disallowed. ]
#trap[ Note the universe: $pi_("sid")(#Sa)$, *not* $pi_("sid")(#Re)$. With the latter, sailors
with no reservations would be excluded from consideration and would *wrongly* be counted as
having reserved all boats. Subtle, and worth a mark. ]
]

#q[4.17][Use the definition to evaluate $R("R") div R("S")$ for the small relations
$R("R") = {(1, "a"), (1, "b"), (2, "a")}$ and $R("S") = {("a"), ("b")}$.][
#ans[ $R("R") div R("S") = {(1)}$. ]
#schem[Result schema is the single attribute of $R("R")$ that is not in $R("S")$, i.e. the id. ]
#why[ Candidate answers are ${1, 2}$. Pairs required for a perfect answer:
$(1,"a"), (1,"b"), (2,"a"), (2,"b")$. Present pairs: all but $(2,"b")$. Missing pairs:
${(2,"b")}$, whose projection is ${2}$. Candidates minus ${2}$ is ${1}$. ]
#trap[ If $R("S")$ were empty, the answer would be all candidates ${1, 2}$; if $R("R")$ were
empty, then candidates ${}$ is empty and so is the answer. Both are consistent with the
definition, and both look wrong to a first-time reader. ]
]

#q[4.18][State the correct dividend and divisor schema for each of the following, without
writing the full expression. (a) sailors who reserved all boats; (b) boats reserved by all
sailors; (c) sailors who reserved all red boats; (d) sailors who reserved all boats reserved
by 22; (e) pairs (sailor, day) such that the sailor reserved all boats on that day.][
#ans[ #tab((auto, auto, auto, auto),
  [*(a)*], [dividend $("sid", "bid")$], [divisor $("bid")$], [result $("sid")$],
  [*(b)*], [dividend $("bid", "sid")$], [divisor $("sid")$], [result $("bid")$],
  [*(c)*], [dividend $("sid", "bid")$], [divisor $("bid")$ of red boats only], [result $("sid")$],
  [*(d)*], [dividend $("sid", "bid")$], [divisor $("bid")$ of 22's boats], [result $("sid")$],
  [*(e)*], [dividend $("sid", "day", "bid")$], [divisor $("bid")$], [result $("sid", "day")$],
) ]
#why[ In (e) the answer schema itself contains `day`, so `day` must be part of the dividend's
non-quantified attributes. This is exactly the expression a student writes by accident in
Q4.13 — here it is the *correct* answer to a different question. ]
#trap[ In (b) the dividend is $pi_("bid", "sid")$, not $pi_("sid", "bid")$: the *set* of
attributes is what matters, but writing them in answer-first order prevents mistakes when you
read the expression back. ]
]

#heading(level: 2)[4.4 Edge cases: empty divisor, empty dividend, ties]

#q[4.19][Explain the vacuous-truth case: what does $pi_("sid", "bid")(#Re) div pi_("bid")(sigma_("color" = #C("yellow"))(#Bo))$
return when there are no yellow boats?][
#ans[ It returns *every* sailor who appears in $pi_("sid", "bid")(#Re)$ — i.e. every sailor
with at least one reservation. ]
#schem[Result $("sid")$.]
#why[ $forall s in emptyset : P(s)$ is true for every $t$; there is no counter-example to find.
So every candidate passes. ]
#trap[ The candidate set is $pi_("sid")$ of the *dividend*, so sailors with no reservations
are still excluded. Students often claim "all sailors"; the precise answer is "all sailors who
have made at least one reservation". Also state whether the question intends the vacuous
reading — the mathematically correct one — or the colloquial "must have reserved something
yellow". ]
]

#q[4.20][Give an expression for "sailors who have reserved at least one yellow boat *and* all
red boats" and explain why the two conditions do not interact.][
#ans[ $ (pi_("sid", "bid")(#Re) div pi_("bid")(sigma_("color" = #C("red"))(#Bo))) inter pi_("sid")(#Re bowtie sigma_("color" = #C("yellow"))(#Bo)) $ ]
#schem[Both operands $("sid")$.]
#why[ The universal condition and the existential condition are evaluated independently on
`sid` sets and combined by intersection. The intersections' operands need not be disjoint or
related — set operators do not care about the provenance of tuples. ]
#trap[ The existential part must use a join with $sigma$; the *division* alone would not
require any yellow boat to exist — see Q4.19. ]
]

#q[4.21][Can classical relational algebra express "sailors who have reserved all boats
reserved by *more than three* sailors"? Explain.][
#note[
  Not in the classical algebra: "more than three sailors" is a *cardinality* condition on a
  group, which needs counting. With the extended operator $gamma$ one writes
  $gamma_("bid"; "count"("sid") arrow.l n)(pi_("bid", "sid")(#Re))$ and then selects
  $sigma_(n > 3)$, but $gamma$ is not part of the classical algebra of $pi, sigma, rho, union,
  -, times$.
]
#ans[ The query *as stated* is not expressible in classical relational algebra. It becomes
expressible if the threshold is a *fixed numeral* and the schema makes the count first-order
definable — for "reserved by more than three sailors" it is not, because "more than three"
compares a numeral to the size of a set of arbitrary tuples. ]
]

#q[4.22][Using only division and set operations, decide for each pair whether it is expressible:
(a) sailors who reserved all boats; (b) sailors who reserved exactly 3 boats; (c) sailors who
reserved all boats of the same colour; (d) sailors who reserved all boats that are red or blue
but not both.][
#ans[ *(a)* Expressible — Q4.1. *(b)* Not expressible ("exactly 3" is a cardinality
condition when 3 is a numeral only in the fixed-arity sense; see §10.6 — for a *fixed
numeral* such as 3, a finite disjunction of "at least $k$" conditions is expressible, but it
requires the identity of the boats and becomes impractically large; the clean answer is that
it needs counting). *(c)* Expressible with one division per colour value, but not uniformly
in the schema: with a fixed, finite set of colours $c_1, c_2, dots$ it is a finite union of
divisions. *(d)* Expressible — the inner condition is a plain set expression inside the
divisor. ]
#why[ The dividing line is *fixed versus computed* cardinality (§1.11). Anything that can be
written as a finite Boolean combination of existentials and universals over the stored
relations is expressible; anything that must *count an unbounded number of tuples* is not. ]
#trap[ (b) catches students who answer "expressible" because 3 is a constant. For a fixed
numeral $k$ the statement "there exist $k$ distinct boats reserved by $s$" is expressible, and
for $k = 3$ that is a finite expression (§10.6 shows the pattern). What is *not* expressible is
"exactly $k$" where $k$ is read from an attribute, or "more than 3" as a comparative count.
Examiners usually want "not expressible" for (b) with the reason "requires counting"; if you
add the fixed-numeral caveat you will get the benefit of the doubt. ]
]
