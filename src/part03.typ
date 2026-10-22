#import "lib.typ": *

#let Sa = R("Sailors")
#let Re = R("Reserves")
#let Bo = R("Boats")

#part(3, "Joins, self-joins, set operations and negative queries", blurb: [
  *What this part fixes.* The three set operators and union compatibility in practice; the
  self-join as a device for comparing two rows; and the "never / without / except" family,
  which is always a set difference on *keys*. Every question in this part uses the
  Sailors–Boats–Reserves schema of §1.2A.
])

#heading(level: 2)[3.1 Set operations in practice]

#q[3.1][Find the names of sailors who have reserved a red boat *or* a green boat.][
#ans[ $ pi_("sname")(#Sa bowtie #Re bowtie sigma_("color" = #C("red") or "color" = #C("green"))(#Bo)) $ ]
#schem[Result schema: $("sname")$, a set.]
#why[ The condition is on a *single* boat's colour, so it is one selection with a
disjunction — not a union of two queries. The corresponding union form,
$pi_("sname")(#Sa bowtie #Re bowtie sigma_("color" = #C("red"))(#Bo)) union pi_("sname")(dots)$,
is also correct and returns the same set, but it is longer and does more work. ]
#trap[ Do not write $sigma_("color" = #C("red"))(#Bo) union sigma_("color" = #C("green"))(#Bo)$
and then project `sname`: those are two sets of *boat* tuples, and `sname` is not in their
schema. Also, "or" over the *same* tuple is `or`; "or" over *different* tuples needs union. ]
]

#q[3.2][Find the names of sailors who have reserved *both* a red boat and a green boat.][
#ans[ Let $R("Red") = pi_("sid")(#Re bowtie sigma_("color" = #C("red"))(#Bo))$ and
$R("Green") = pi_("sid")(#Re bowtie sigma_("color" = #C("green"))(#Bo))$. Then
$ pi_("sname")(#Sa bowtie (R("Red") inter R("Green"))) $ ]
#schem[$R("Red")$ and $R("Green")$ both have schema $("sid")$, so they are union compatible
and the intersection is legal. Result: $("sname")$.]
#why[ "Both" is two *independent existences*: there must be one reservation witnessing red
and another witnessing green. Because each are computed separately and then intersected on
`sid`, the two witnesses are allowed to be different reservations. This is the crucial
difference from Q6.32's "same reservation" variant. ]
#trap[ `sname` is not a key, so intersecting on names loses sailors who share a name — and
$R("Red") inter R("Green")$ with names also *gains* a false positive when two different
sailors with the same name witness the two colours. Intersect on `sid`; join to `Sailors`
afterwards. ]
]

#q[3.3][Find the names of sailors who have reserved a red boat but *not* a green boat.][
#ans[ $ pi_("sname")(#Sa bowtie (pi_("sid")(#Re bowtie sigma_("color" = #C("red"))(#Bo)) - pi_("sid")(#Re bowtie sigma_("color" = #C("green"))(#Bo)))) $ ]
#schem[Both operands of the difference are $("sid")$, hence union compatible; the join with
`Sailors` restores `sname`.]
#why[ "A but not B" is the set difference of the *key* sets of A and B (pattern 4). The
difference must be taken *before* joining to `Sailors`, because after the join the schema is
wider and the subtraction would no longer be a statement about sailors. ]
#trap[ $pi_("sname")("Red") - pi_("sname")("Green")$ is the name-set error of Q2.12 again.
Also, this query is *not* "sailors who reserved only red boats" — a sailor who reserved red
and blue qualifies here but not there. That is Q6.31. ]
]

#q[3.4][Find the names of sailors who have reserved a red boat but *not* a boat of any other
colour. In other words: sailors all of whose reservations are of red boats, and who have at
least one reservation.][
#ans[ Let $R("Bad") = pi_("sid")(#Re bowtie sigma_("color" != #C("red"))(#Bo))$. Then
$ pi_("sname")(#Sa bowtie (pi_("sid")(#Re) - R("Bad"))) $ ]
#schem[$R("Bad")$: $("sid")$. $pi_("sid")(#Re)$: $("sid")$. Difference: $("sid")$. Result:
$("sname")$.]
#why[ This is pattern 5 ("only X"): *all* $-$ *any non-X*. Note that
$pi_("sid")(#Re) - R("Bad")$ also enforces "at least one reservation" automatically, because
a sailor with no reservations is not in $pi_("sid")(#Re)$ in the first place. ]
#note[ If the question were "sailors who reserved only red boats" *including* sailors with no
reservations at all (a pedantic but real reading), the answer would be
$pi_("sname")(#Sa) - pi_("sname")(#Sa bowtie R("Bad"))$. Always state which reading you are
using — examiners accept either *if* it is stated. ]
#trap[ Writing $pi_("sid")(sigma_("color" = #C("red"))(#Bo) bowtie #Re)$ alone gives "has a
red reservation", not "only red". The word *only* needs the negation of the complement. ]
]

#q[3.5][Find the names of sailors who have never reserved a red boat.][
#ans[ $ pi_("sname")(#Sa bowtie (pi_("sid")(#Sa) - pi_("sid")(#Re bowtie sigma_("color" = #C("red"))(#Bo)))) $ ]
#schem[Inner difference: $("sid")$ on both sides. Result: $("sname")$.]
#why[ "Never P" is *all sailors* minus *sailors who P* (pattern 2). The subtraction must be on
`sid`, and only afterwards is the name looked up. The join with the difference is equivalent
to a set intersection on `sid`, since $pi_("sid")(#Sa)$ is the key set. ]
#trap[ $pi_("sname")(#Sa) - pi_("sname")(#Sa bowtie #Re bowtie sigma_("color" = #C("red"))(#Bo))$
returns the right answer *only if names are unique*. It is the answer most students write and
it is worth partial credit, but the key version is the correct one. ]
]

#q[3.6][Find the boats that have never been reserved.][
#ans[ $ pi_("bid")(#Bo) - pi_("bid")(#Re)$ ]
#schem[Both operands $("bid")$ — union compatible. Result: $("bid")$.]
#why[ The simplest negative query in the subject. Add
$pi_("bname", "color")(#Bo bowtie (dots))$ if boat names are wanted; the *difference* itself
must stay on the key. ]
#trap[ $#Bo - pi_("sid", "bid", "day")(#Re)$ is not union compatible (3 attributes versus 3,
but `bid`, `bname`, `color` against `sid`, `bid`, `day` — different domains in positions 1 and
2). Project both sides to `bid`. ]
]

#q[3.7][Find the sailors who have never made a reservation.][
#ans[ $ pi_("sid")(#Sa) - pi_("sid")(#Re) $ ]
#schem[$("sid")$ on both sides. Result: $("sid")$.]
#why[ Pattern 2 with no join at all: the relationship `Reserves` is consulted directly. To
return names instead, join the result back to `Sailors`. ]
#trap[ Do not use $pi_("sid", "sname")(#Sa) - pi_("sid")(#Re)$: two attributes against one.
This is the most frequently penalised expression in the whole course. ]
]

#q[3.8][Find the names of sailors who reserved *at least two different boats*.][
#ans[ Let $R("P") = pi_("sid", "bid")(#Re)$. Then
$ pi_("sname")(#Sa bowtie pi_("P1.sid")(sigma_("P1.bid" != "P2.bid")(rho_("P1")(R("P")) times rho_("P2")(R("P"))))) $ ]
#schem[$R("P")$: $("sid", "bid")$. The product: $("P1.sid", "P1.bid", "P2.sid", "P2.bid")$.
After $sigma$ and $pi$: $("sid")$ — the sailors for whom two *different* boats exist. ]
#why[ "At least two" is a self-join of the relationship with a $!=$ condition on the second
identifier and an equality on the first. The projection to `(sid, bid)` first is essential:
otherwise a sailor who reserved one boat on two days would count as two. ]
#trap[ Forgetting $pi_("sid", "bid")$ gives "at least two *reservations*", which is a
different question (Q6.21). Also, the inequality must be between the *boat* attributes, not
between the sid attributes. ]
]

#q[3.9][Find the names of sailors who have reserved a boat on at least two different dates.][
#ans[ $ pi_("sname")(#Sa bowtie pi_("R1.sid")(sigma_("R1.sid" = "R2.sid" and "R1.day" != "R2.day")(rho_("R1")(#Re) times rho_("R2")(#Re)))) $ ]
#schem[Product schema: 6 attributes, $("R1.sid", "R1.bid", "R1.day", "R2.sid", "R2.bid", "R2.day")$.
After $sigma$ and $pi$: $("sid")$. ]
#why[ "At least two different dates" is a self-join, so the *same* relation appears twice
under two names. Because $times$ pairs everything with everything, the equality on `sid`
(same sailor) and the inequality on `day` (different dates) must both be written explicitly
in the $sigma$. ]
#trap[ Do *not* use $rho_("R1")(#Re) bowtie rho_("R2")(#Re)$: a natural join equates *all
three* shared attributes, forcing the two reservations to be the same tuple, and the
subsequent $sigma$ on `day` then returns nothing. General rule: *for a self-join with an
inequality, use $times$ plus an explicit $sigma$; reserve $bowtie$ for equality on all
shared attributes.* ]
]

#q[3.10][Find the sids of sailors who reserved boat 101 and also reserved boat 103.][
#ans[ $ pi_("sid")(sigma_("bid" = 101)(#Re)) inter pi_("sid")(sigma_("bid" = 103)(#Re)) $ ]
#schem[Both operands $("sid")$, union compatible. Alternatively, a self-join:
$pi_("R1.sid")(sigma_("R1.bid" = 101 and "R2.bid" = 103 and "R1.sid" = "R2.sid")(rho_("R1")(#Re) times rho_("R2")(#Re)))$.]
#why[ Two independent existences on the same key set. Intersection is shorter and shows the
intent; the self-join is what you must write if the question forbids $inter$. ]
#trap[ $pi_("sid")(sigma_("bid" = 101 and "bid" = 103)(#Re))$ is empty: one tuple cannot
satisfy both. That is the "$and$ on one tuple" trap again. ]
]

#q[3.11][Find the names of sailors who have reserved a boat that is either red or green, but
have never reserved a blue boat.][
#ans[ $ pi_("sname")(#Sa bowtie (R("RG") - R("Blue")))$ where
$R("RG") = pi_("sid")(#Re bowtie sigma_("color" = #C("red") or "color" = #C("green"))(#Bo))$
and $R("Blue") = pi_("sid")(#Re bowtie sigma_("color" = #C("blue"))(#Bo))$. ]
#schem[$R("RG")$ and $R("Blue")$ are both $("sid")$. Result: $("sname")$.]
#why[ The two requirements have different quantifiers: an *existential* one over red-or-green
and a *negative* one over blue. Each is computed as a key set, and only then combined. ]
#trap[ Do not try to express this with a single $sigma$ over a three-way join: the positive
and negative conditions range over *different tuples*, so no tuple-local condition can
capture it. ]
]

#q[3.12][Under what conditions is $R("R") - R("S")$ equal to $R("S") - R("R")$? Give an
example with the sailors schema.][
#ans[ Only when the two operands contain the same set of tuples, i.e. $R("R") = R("S")$;
then both differences are empty. In every other case set difference is *not* commutative. ]
#schem[Both differences are defined only when the operands are union compatible.]
#why[ $R("R") - R("S")$ removes from $R("R")$ those tuples also in $R("S")$. Swapping them
changes which side is being reduced. Example: $T("A") = {1, 2}$, $T("B") = {2, 3}$ gives
$T("A") - T("B") = {1}$ but $T("B") - T("A") = {3}$. ]
#trap[ $union$ and $inter$ *are* commutative and associative; $-$ is neither associative nor
commutative. This is a standard 2-mark theory question. ]
]

#q[3.13][Show that $R("R") inter R("S")$ can be written with $-$ alone, and verify the
identity on small relations.][
#ans[ $ R("R") inter R("S") = R("R") - (R("R") - R("S")) $ ]
#schem[All three expressions have the schema of $R("R")$.]
#why[ $R("R") - R("S")$ is the part of $R("R")$ that is *not* in $R("S")$. Removing that part
from $R("R")$ leaves exactly the part that *is* in $R("S")$ — the intersection. Verify with
$T("A") = {1,2,3}$, $T("B") = {2,3,4}$: $T("A") - T("B") = {1}$, and
$T("A") - {1} = {2,3} = T("A") inter T("B")$. ]
#trap[ The asymmetric-looking form $R("R") - (R("R") - R("S"))$ cannot be simplified to
$R("S") - (R("S") - R("R"))$ unless you also swap the roles; both are correct, but
$R("R") - (R("S") - R("R"))$ is *wrong* — it returns $R("R")$, because
$R("S") - R("R")$ is disjoint from $R("R")$. ]
]

#q[3.14][A student writes
$pi_("sid")(#Sa) - pi_("sid")(sigma_("rating" < 8)(#Re))$.
Explain two independent reasons why this is wrong, and repair it.][
#ans[ Correct version: $pi_("sid")(#Sa) - pi_("sid")(sigma_("rating" < 8)(#Sa))$. ]
#schem[The student's second operand is $("sid")$ — the *types* match, so the error is not
caught by union compatibility. That is what makes it a good exam question.]
#why[ Reason 1: `Reserves` has no `rating` attribute, so the inner selection is not even
well-formed. Reason 2 (the deeper one): rating belongs to `Sailors`, so a condition on rating
must be evaluated on `Sailors`, not on the reservation relation. ]
#trap[ Even after repairing the schema, resist the urge to project `sname` before the
subtraction — see Q2.12. ]
]

#heading(level: 2)[3.2 Self-joins: comparing two rows]

#q[3.15][Find the pairs of sailors who have the same rating. Return sids, and do not report a
pair twice.][
#ans[ $ pi_("S1.sid", "S2.sid")(sigma_("S1.rating" = "S2.rating" and "S1.sid" < "S2.sid")(rho_("S1")(#Sa) times rho_("S2")(#Sa))) $ ]
#schem[Product schema: $("S1.sid", "S1.sname", "S1.rating", "S1.age", "S2.sid", "S2.sname", "S2.rating", "S2.age")$.
Result: $("S1.sid", "S2.sid")$.]
#why[ Two rows of the same relation are needed, so the relation must appear twice under
different names. The condition $A("S1.sid") < A("S2.sid")$ does three jobs: it removes pairs
of a sailor with himself, and it removes the mirror image $(y, x)$ of every pair $(x, y)$. ]
#trap[ Using $!=$ instead of $<$ returns each unordered pair twice and includes
self-pairs removed — actually $!=$ removes self-pairs but keeps both orders. Using no
inequality at all includes every sailor paired with himself. Read the question: "pairs"
almost always means *unordered*, distinct pairs. ]
]

#q[3.16][Find the sids of sailors who have the same rating as another sailor, but a different
sid.][
#ans[ $ pi_("S1.sid")(sigma_("S1.rating" = "S2.rating" and "S1.sid" != "S2.sid")(rho_("S1")(#Sa) times rho_("S2")(#Sa))) $ ]
#schem[Result: $("sid")$ — note that a projection to one attribute is enough, because the
question asks *which* sailors, not which pairs.]
#why[ This is Q3.15 with the pair collapsed to a single sailor. Projecting only $A("S1.sid")$
and letting $pi$ remove duplicates is what turns "pairs" into "sailors". ]
#trap[ Because $pi$ removes duplicates, you do *not* need to add
$A("S1.sid") < A("S2.sid")$ here: each qualifying sailor appears in the result exactly once
either way. Adding it is harmless but shows you understand *why* it was needed in Q3.15. ]
]

#q[3.17][Find the names of sailors who are older than some other sailor with the same rating.][
#ans[ $ pi_("S1.sname")(sigma_("S1.rating" = "S2.rating" and "S1.age" > "S2.age")(rho_("S1")(#Sa) times rho_("S2")(#Sa))) $ ]
#schem[Result: $("sname")$.]
#why[ Two comparisons are needed on the *same* pair of tuples: equality on the grouping
attribute, inequality on the compared attribute. This is the prototype of every "per-group"
query in Part 5. ]
#trap[ $pi_("sname")(sigma_("age" > "age")(#Sa))$ is always empty — the two `age` references
are the *same* attribute of the *same* tuple. You need two tuple variables before you can
compare a value with another value. ]
]

#q[3.18][Find the pairs of sailors who have reserved the same boat.][
#ans[ $ pi_("R1.sid", "R2.sid")(sigma_("R1.bid" = "R2.bid" and "R1.sid" < "R2.sid")(rho_("R1")(#Re) times rho_("R2")(#Re))) $ ]
#schem[Result: $("R1.sid", "R2.sid")$.]
#why[ The relationship is `Reserves`, so the self-join is over `Reserves`, not over
`Sailors`. The $<$ condition makes the pairs unordered and distinct. ]
#trap[ Note that the two sailors need not have reserved the boat on the same day — the
equality is only on `bid`. That distinction is Q3.19. ]
]

#q[3.19][Find the pairs of sailors who reserved the same boat on the same day.][
#ans[ $ pi_("R1.sid", "R2.sid")(sigma_("R1.bid" = "R2.bid" and "R1.day" = "R2.day" and "R1.sid" < "R2.sid")(rho_("R1")(#Re) times rho_("R2")(#Re))) $ ]
#schem[Result: $("R1.sid", "R2.sid")$.]
#why[ One more conjunct, one more attribute in the equality. This is the general recipe for
"same X as": self-product plus equality on X, plus inequality on the identifier if the pairs
must be distinct and unordered. ]
#trap[ Do not use $rho_("R1")(#Re) bowtie rho_("R2")(#Re)$ — the natural join equates all
three attributes at once (same sailor, same boat, same day), which defeats the purpose. Use
$times$ and write the equalities you actually want. ]
]

#q[3.20][Find the names of sailors who have reserved a boat with a *higher* bid than every boat
reserved by sailor 22.][
#ans[ Let $R("S22") = pi_("bid")(sigma_("sid" = 22)(#Re))$ and
$R("Low") = pi_("R1.sid")(sigma_("R1.bid" <= "R2.bid")(rho_("R1")(#Re) times rho_("R2")(R("S22"))))$.
Then $ pi_("sname")(#Sa bowtie (pi_("sid")(#Re) - R("Low"))) $. ]
#schem[$R("S22")$: $("bid")$. The product: $("R1.sid", "R1.bid", "R1.day", "bid")$.
$R("Low")$: $("sid")$. ]
#why[ "$>$ every" is "$not$ ($<=$ some)": find the sailors who have at least one reservation
that is not higher than *some* boat of sailor 22, and remove them. This is the counter-example
method, and it is the only method that works when the comparison is with a *set* rather than
a single value. ]
#trap[ If sailor 22 has no reservations, $R("S22")$ is empty, the product is empty, and
*every* sailor with a reservation is returned. That is vacuously correct ("higher than every
boat reserved by 22" is true when there is no such boat) — and examiners like you to say so. ]
]

#heading(level: 2)[3.3 Negative queries: the complete family]

#note[
  Every "no", "never", "without", "except" question has the same skeleton:

  #align(center)[$ "Answer" = pi_("key")(R("Universe")) - pi_("key")(R("Witness")) $]

  The only two decisions are (a) what the *universe* is — all sailors, all boats, all
  patients — and (b) what counts as a *witness* — one join chain that exhibits the forbidden
  property. Get those two right and the query writes itself.
]

#q[3.21][Find the names of sailors who have not reserved any boat on 2019-10-01.][
#ans[ $ pi_("sname")(#Sa bowtie (pi_("sid")(#Sa) - pi_("sid")(sigma_("day" = #C("2019-10-01"))(#Re)))) $ ]
#schem[Inner difference: $("sid")$. Result: $("sname")$.]
#why[ The witness is "reserved something on that day". The universe is all sailors, so
sailors with no reservations at all are correctly included. ]
#trap[ If the universe were $pi_("sid")(#Re)$ — sailors who have *some* reservation — the
answer would exclude sailors with no reservations, which is the opposite of what "have not
reserved any boat on that day" means for them. Choosing the universe is the whole question. ]
]

#q[3.22][Find the names of sailors who have reserved every boat that sailor 22 has reserved.
(Do it without division, then with division.)][
#ans[ *Without division:*
$ pi_("sname")(#Sa bowtie (pi_("sid")(#Sa) - pi_("sid")( pi_("sid")(#Sa) times pi_("bid")(sigma_("sid" = 22)(#Re)) - #Re ))) $
*With division:*
$ pi_("sname")(#Sa bowtie ( pi_("sid", "bid")(#Re) div pi_("bid")(sigma_("sid" = 22)(#Re)) )) $ ]
#schem[Both inner expressions return $("sid")$. Result: $("sname")$.]
#why[ The counter-example method: all sailors, minus those for whom *some* boat of sailor 22
is missing from their reservations. The middle expression
$pi_("sid")(#Sa) times pi_("bid")(dots) - #Re$ is exactly the set of missing (sailor, boat)
pairs; projecting its `sid` gives the disqualified sailors. ]
#trap[ The dividend must be $pi_("sid", "bid")(#Re)$ — *not* `Reserves`, whose schema includes
`day`. With `day` present, the divisor's schema is not a subset in the right way and the
division silently asks a different (and meaningless) question. ]
]

#q[3.23][Find the names of sailors who have reserved all boats, and explain the two equivalent
formulations.][
#ans[ $ pi_("sname")(#Sa bowtie ( pi_("sid", "bid")(#Re) div pi_("bid")(#Bo) )) $
$ = pi_("sname")(#Sa bowtie ( pi_("sid")(#Sa) - pi_("sid")( pi_("sid")(#Sa) times pi_("bid")(#Bo) - pi_("sid", "bid")(#Re) ) )) $ ]
#schem[The division returns $("sid")$; the subtraction form also returns $("sid")$. ]
#why[ Division is the direct statement of $forall$; the second form is its definition, and
writing both is the safest exam strategy because it shows the marker you know *why* they are
equal. The middle term $pi_("sid")(#Sa) times pi_("bid")(#Bo) - pi_("sid", "bid")(#Re)$ is the
set of "missing reservations" that a perfect sailor would have. ]
#trap[ Check the sailor with *no* reservations in both forms. *Division:* he is absent from
$pi_("sid")(#Re)$, so he is not a candidate and is not returned — correct, since "reserved all
boats" is false for him. *Subtraction form:* his every (sailor, boat) pair is missing, so he
lands in the disqualified set and is removed — also correct. The two forms agree, which is
exactly why they are worth writing side by side. ]
]

#q[3.24][Find the sailors who have reserved at least one boat but not all boats.][
#ans[ $ pi_("sid")(#Re) - ( pi_("sid", "bid")(#Re) div pi_("bid")(#Bo) ) $ ]
#schem[Both operands $("sid")$. Result: $("sid")$.]
#why[ "At least one" gives the universe; "all" is subtracted. This is the *complement within
the reservers*, not within all sailors — the question says "at least one", so a sailor with
no reservations must not appear. ]
#trap[ $pi_("sid")(#Sa) - (pi_("sid", "bid")(#Re) div pi_("bid")(#Bo))$ answers "did not
reserve all boats", which includes sailors with no reservations. Both readings appear in
papers; the wording "at least one but not all" forces the first. ]
]

#q[3.25][Find the boats that have been reserved by at least one sailor but not by all
sailors.][
#ans[ $ pi_("bid")(#Re) - ( pi_("bid", "sid")(#Re) div pi_("sid")(#Sa) ) $ ]
#schem[Both operands $("bid")$. ]
#why[ The roles are swapped: now the "answer attribute" is `bid` and the quantified attribute
is `sid`. Note the dividend has schema $("bid", "sid")$; attribute order in the projection is
irrelevant to division, only the *set* matters. ]
#trap[ Using $pi_("bid", "day")(#Re)$ as the dividend would quantify over days, not sailors,
and answer a completely different question. ]
]

#q[3.26][Find the names of sailors who have reserved only boats that are red.][
#ans[ $ pi_("sname")(#Sa bowtie (pi_("sid")(#Re) - pi_("sid")(#Re bowtie sigma_("color" != #C("red"))(#Bo)))) $ ]
#schem[The subtracted term is $("sid")$; the difference is $("sid")$. ]
#why[ "Only red" = "has reservations" minus "has a non-red reservation". This is pattern 5
and it is the same expression as Q3.4. ]
#trap[ "$!=$ red" versus "$=$ not-red": in the presence of NULL colours these differ. In this
book colours are non-null, so $sigma_("color" != #C("red"))$ is the complement of
$sigma_("color" = #C("red"))$ and both are fine. State the assumption if the paper mentions
NULLs. ]
]
