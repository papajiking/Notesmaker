#import "lib.typ": *

#let Sa = R("Sailors")
#let Re = R("Reserves")
#let Bo = R("Boats")

#part(6, "Sailors and Boats — complete solved question bank", blurb: [
  *What this part fixes.* The complete classical bank on the *Database System Concepts* running
  example, in the order in which it is normally taught: basic queries, set operations,
  self-joins, division, then the advanced queries (extremes, "only", "all", "exactly one").
  Every question states the schema it uses. Questions marked *(SKS pattern)* follow the
  standard shape of Chapter 4 exercises; they are not verbatim reproductions.
])

#heading(level: 2)[6.0 Sample instance]

All answers below can be checked against this small instance. It is used only to *illustrate*;
the expressions are correct for every instance.

#grid(columns: (1fr, 1fr, 1fr), gutter: 8pt,
  [#table(columns: 4, stroke: 0.4pt + l4, inset: 3.5pt,
    table.header([*sid*], [*sname*], [*rating*], [*age*]),
    [22], [Dustin], [7], [45.0],
    [29], [Brutus], [1], [33.0],
    [31], [Lubber], [8], [55.5],
    [32], [Andy], [8], [25.5],
    [58], [Rusty], [10], [35.0],
    [64], [Horatio], [7], [35.0],
    [71], [Zorba], [10], [16.0],
    [74], [Horatio], [9], [35.0],
  )],
  [#table(columns: 3, stroke: 0.4pt + l4, inset: 3.5pt,
    table.header([*bid*], [*bname*], [*color*]),
    [101], [Interlake], [blue],
    [102], [Interlake], [red],
    [103], [Clipper], [green],
    [104], [Marine], [red],
  )],
  [#table(columns: 3, stroke: 0.4pt + l4, inset: 3.5pt,
    table.header([*sid*], [*bid*], [*day*]),
    [22], [101], [2019-10-01],
    [22], [102], [2019-10-01],
    [22], [103], [2019-10-01],
    [22], [104], [2019-10-01],
    [31], [102], [2019-10-03],
    [31], [103], [2019-10-05],
    [64], [101], [2019-10-07],
    [64], [102], [2019-10-07],
    [74], [103], [2019-10-09],
  )],
)
#v(3pt)
#mini[Note the deliberate features: two sailors share the name "Horatio" (sids 64 and 74), two share rating 8 (31 and 32), and two share rating 10 (58 and 71). These are the ties that make the difference between "on keys" and "on names" visible.]

#heading(level: 2)[6.1 Basic queries]

#q[6.1][Find the names of all sailors.][
#ans[ $ pi_("sname")(#Sa) $ ]
#schem[$("sname")$; one row per distinct name, so "Horatio" appears once even though two sailors bear it. ]
#why[ Pure projection: no condition, and the requested attribute is `sname`. ]
#trap[ If the question wants one row per sailor, project the key as well
($pi_("sid", "sname")(#Sa)$) and say why. ]
]

#q[6.2][Find the sailors whose rating is 8.][
#ans[ $ sigma_("rating" = 8)(#Sa) $ ]
#schem[Schema of `Sailors`. ]
#why[ Tuple-local condition on a stored attribute. ]
#trap[ "Rating 8" is one condition, not a join. Do not add `Reserves` unless a reservation is
mentioned. ]
]

#q[6.3][Find the names of sailors older than 35.][
#ans[ $ pi_("sname")(sigma_("age" > 35)(#Sa)) $ ]
#schem[$("sname")$. ]
#why[ Select then project — the order matters because `age` must survive until the selection. ]
#trap[ $sigma_("age" > 35)(pi_("sname")(#Sa))$ is a type error. With the sample instance the
answer is empty (no one is strictly older than 35), which is the right answer, not a mistake. ]
]

#q[6.4][Find the names of sailors who have reserved a red boat. *(classic)*][
#ans[ $ pi_("sname")(#Sa bowtie #Re bowtie sigma_("color" = #C("red"))(#Bo)) $ ]
#schem[Join chain schema is the union of the three; the result is $("sname")$. ]
#why[ Existential: there is a reservation linking the sailor to a red boat. With the sample
instance, Dustin (22), Lubber (31), Horatio (64) are returned — Horatio appears once although
the name matches two sids. ]
#trap[ Projecting after the joins gives names; projecting before would lose the link. ]
]

#q[6.5][Find the sids of sailors who have reserved boat 103.][
#ans[ $ pi_("sid")(sigma_("bid" = 103)(#Re)) $ ]
#schem[$("sid")$. ]
#why[ `Reserves` already contains both attributes needed; no join is required. ]
#trap[ Do not join with `Sailors` — that only adds attributes which are then projected away. ]
]

#q[6.6][Find the bid and bname of boats reserved on 2019-10-03.][
#ans[ $ pi_("bid", "bname")(sigma_("day" = #C("2019-10-03"))(#Re) bowtie #Bo) $ ]
#schem[$("bid", "bname")$. ]
#why[ The date is in `Reserves`; the name is in `Boats`; the shared attribute is `bid`. ]
#trap[ Using $pi_("bid", "bname")(#Bo)$ restricted by the date is impossible — `Boats` has no
`day`. ]
]

#q[6.7][Find the names of sailors who have reserved a boat of colour blue or green.][
#ans[ $ pi_("sname")(#Sa bowtie #Re bowtie sigma_("color" = #C("blue") or "color" = #C("green"))(#Bo)) $ ]
#schem[$("sname")$. ]
#why[ One selection with a disjunction over a single boat tuple. ]
#trap[ The *union* form is also correct, but it must be a union of two *complete queries*:
$pi_("sname")(#Sa bowtie #Re bowtie sigma_("color" = #C("blue"))(#Bo)) union pi_("sname")(#Sa bowtie #Re bowtie sigma_("color" = #C("green"))(#Bo))$,
never a union of two `Boats` relations followed by a projection — the projection would have no
`sname` to project. ]
]

#q[6.8][Find the names of sailors above rating 7 who have reserved a red boat.][
#ans[ $ pi_("sname")(sigma_("rating" > 7)(#Sa) bowtie #Re bowtie sigma_("color" = #C("red"))(#Bo)) $ ]
#schem[$("sname")$. ]
#why[ Two independent restrictions, both pushed to their leaves. ]
#trap[ $sigma_("rating" > 7)(pi_("sname")(#Sa) bowtie #Re bowtie sigma_("color" = #C("red"))(#Bo))$
is *legal* here because `rating` survives the join — but only by accident of schema. Pushing
selections down is always safe; pulling them up is safe only when the attribute survives. ]
]

#heading(level: 2)[6.2 Union, intersection, difference]

#q[6.9][Find the names of sailors who have reserved a red boat or a green boat.][
#ans[ $ pi_("sname")(#Sa bowtie #Re bowtie sigma_("color" = #C("red") or "color" = #C("green"))(#Bo)) $ ]
#schem[$("sname")$, a set. ]
#why[ "Or" over the same boat tuple. With the sample instance: Dustin, Lubber, Horatio. ]
#trap[ Compare Q6.10: adding "both" changes the expression from $or$ to an intersection of two
$exists$ conditions. The English word "or" is inclusive here; exclusive-or is a different
(and rarely asked) question. ]
]

#q[6.10][Find the names of sailors who have reserved both a red boat and a green boat. *(classic)*][
#ans[ $ pi_("sname")(#Sa bowtie ( pi_("sid")(#Re bowtie sigma_("color" = #C("red"))(#Bo)) inter pi_("sid")(#Re bowtie sigma_("color" = #C("green"))(#Bo)) )) $ ]
#schem[Both intersected operands are $("sid")$. ]
#why[ Two independent existences, intersected on the key. With the sample instance: Dustin
(reserved 102 red and 103 green), Lubber (102 red, 103 green), Horatio 64 (102 red only) — no;
Horatio 64 is excluded, Horatio 74 excluded. So {Dustin, Lubber}. ]
#trap[ The whole-tuple intersection
$sigma_("color" = #C("red"))(#Bo) inter sigma_("color" = #C("green"))(#Bo)$ is *empty*: a boat
cannot be two colours. Intersections of existential conditions must be taken *after*
projecting to the key that the existence is about. ]
]

#q[6.11][Find the names of sailors who have reserved a red boat but never a green boat.][
#ans[ $ pi_("sname")(#Sa bowtie ( pi_("sid")(#Re bowtie sigma_("color" = #C("red"))(#Bo)) - pi_("sid")(#Re bowtie sigma_("color" = #C("green"))(#Bo)) )) $ ]
#schem[$("sid")$ on both sides of the difference. ]
#why[ Difference of key sets, then look up names. Same shape as Q3.3. ]
#trap[ $pi_("sname")(#Sa bowtie #Re bowtie sigma_("color" = #C("red"))(#Bo)) - pi_("sname")(#Sa bowtie #Re bowtie sigma_("color" = #C("green"))(#Bo))$ is the (incorrect) name-set
version — two different sailors called Horatio would cancel each other out. ]
]

#q[6.12][Find the names of sailors who have never reserved a red boat.][
#ans[ $ pi_("sname")(#Sa bowtie ( pi_("sid")(#Sa) - pi_("sid")(#Re bowtie sigma_("color" = #C("red"))(#Bo)) )) $ ]
#schem[$("sid")$. ]
#why[ Universe = all sailors; witness = red reservation. ]
#trap[ Omitting the $pi_("sid")(#Sa)$ universe and using $pi_("sid")(#Re)$ instead silently
excludes sailors with no reservations — who certainly never reserved a red boat. ]
]

#q[6.13][Find the boats that have never been reserved. *(classic)*][
#ans[ $ pi_("bid")(#Bo) - pi_("bid")(#Re) $ ]
#schem[$("bid")$. ]
#why[ Pattern 2 with the universe `Boats`. ]
#trap[ To print names, join afterwards:
$pi_("bname")(#Bo bowtie (pi_("bid")(#Bo) - pi_("bid")(#Re)))$. ]
]

#q[6.14][Find the sids and names of sailors who have never made a reservation.][
#ans[ $ pi_("sid", "sname")(#Sa bowtie (pi_("sid")(#Sa) - pi_("sid")(#Re))) $ ]
#schem[$("sid", "sname", "rating", "age")$ if the whole tuple is returned; project
$("sid", "sname")$ to match the question. ]
#why[ The difference is on `sid`; the join restores the descriptive attributes. ]
#trap[ $pi_("sid", "sname")(#Sa) - pi_("sid")(#Re)$ is not union compatible: two attributes
against one. This exact error is worth a mark in almost every paper. ]
]

#heading(level: 2)[6.3 Self-joins and comparisons]

#q[6.15][Find the pairs of sailors with the same rating. Report each unordered pair once.][
#ans[ $ pi_("S1.sid", "S2.sid")(sigma_("S1.rating" = "S2.rating" and "S1.sid" < "S2.sid")(rho_("S1")(#Sa) times rho_("S2")(#Sa))) $ ]
#schem[$("S1.sid", "S2.sid")$. ]
#why["Same rating" is an equality between two tuple variables; $<$ on the keys makes each pair
appear once and removes self-pairs. ]
#trap[ With the sample instance, ratings 8 (31,32), 7 (22,64) and 10 (58,71) each produce one
pair; rating 9 and rating 1 produce none. If you forget the $<$ condition you get 6 ordered
pairs plus 8 self-pairs. ]
]

#q[6.16][Find the sids of sailors who share their rating with at least one other sailor with a
different sid.][
#ans[ $ pi_("S1.sid")(sigma_("S1.rating" = "S2.rating" and "S1.sid" != "S2.sid")(rho_("S1")(#Sa) times rho_("S2")(#Sa))) $ ]
#schem[$("sid")$. ]
#why[ Same join, but the answer is a set of sailors, and $pi$ removes the duplicate witnesses. ]
#trap[ Using $<$ here returns only the smaller sid of each pair (31, not 32). Because the
question asks *which sailors*, both members are wanted, so $!=$ is correct and $<$ is not. ]
]

#q[6.17][Find the pairs (older, younger) of sailors with the same rating.][
#ans[ $ pi_("S1.sid", "S2.sid")(sigma_("S1.rating" = "S2.rating" and "S1.age" > "S2.age")(rho_("S1")(#Sa) times rho_("S2")(#Sa))) $ ]
#schem[$("S1.sid", "S2.sid")$, ordered by the roles older/younger. ]
#why[ Here the inequality is on the *compared* attribute, not on the key, because the pair is
ordered by age. This is the difference from Q6.15. ]
#trap[ If two sailors have the same rating *and* the same age, the pair appears in neither
direction — that is correct for an "older/younger" question but would be wrong for a "same
age" question, which needs $= $. ]
]

#q[6.18][Find the pairs of sailors who have reserved the same boat.][
#ans[ $ pi_("R1.sid", "R2.sid")(sigma_("R1.bid" = "R2.bid" and "R1.sid" < "R2.sid")(rho_("R1")(#Re) times rho_("R2")(#Re))) $ ]
#schem[$("R1.sid", "R2.sid")$. ]
#why[ The self-join is on `Reserves`, because that is where "reserved" lives. ]
#trap[ Do not put the self-join on `Sailors`: sailors do not carry boats. ]
]

#q[6.19][Find the pairs of sailors who reserved the same boat on the same day.][
#ans[ $ pi_("R1.sid", "R2.sid")(sigma_("R1.bid" = "R2.bid" and "R1.day" = "R2.day" and "R1.sid" < "R2.sid")(rho_("R1")(#Re) times rho_("R2")(#Re))) $ ]
#schem[$("R1.sid", "R2.sid")$. ]
#why[ Two equalities on the relationship, one inequality on the key. ]
#trap[ The natural join $rho_("R1")(#Re) bowtie rho_("R2")(#Re)$ equates all three attributes,
so it can only find a sailor paired with himself — use $times$. ]
]

#q[6.20][Find the names of sailors who have reserved a boat with a higher bid than every boat
reserved by sailor 22.][
#ans[ Let $R("B22") = pi_("bid")(sigma_("sid" = 22)(#Re))$ and
$R("Low") = pi_("R1.sid")(sigma_("R1.bid" <= "R2.bid")(rho_("R1")(#Re) times rho_("R2")(R("B22"))))$.
Then $ pi_("sname")(#Sa bowtie (pi_("sid")(#Re) - R("Low"))) $. ]
#schem[$R("B22")$: $("bid")$. $R("Low")$: $("sid")$. ]
#why[ The counter-example method: a sailor fails if *some* of his boats is not higher than
*some* boat of 22. With the sample: 22 has 101–104, so a higher boat does not exist and the
answer is empty. ]
#trap[ The naive answer "bid > max(bid of 22)" would require an extra extreme query and breaks
on the empty case. ]
]

#q[6.21][Find the names of sailors who have made at least two reservations — and contrast with
"at least two different boats".][
#ans[ *At least two reservations:*
$ pi_("sname")(#Sa bowtie pi_("R1.sid")(sigma_("R1.sid" = "R2.sid" and "R1.bid" != "R2.bid")(rho_("R1")(#Re) times rho_("R2")(#Re)))) $
*At least two different boats:* same expression with the projection
$pi_("sid", "bid")$ applied to `Reserves` before the self-join. ]
#schem[Both results: $("sid")$ before the join with `Sailors`. ]
#why[ Because the key of `Reserves` is (sid, bid, day), two reservations of the *same* boat on
different days are two reservations but one boat. The sample instance has no such case, so
invent one to test: adding (64, 101, 2019-10-08) makes 64 a two-reservation sailor without
changing the boat count. ]
#trap[ Questions that say "at least two" usually mean two *distinct entities*; read the noun
after "two". This pair of queries is the standard test of that reading. ]
]

#q[6.22][Find the sailors who share the same name but have different sids.][
#ans[ $ pi_("S1.sid", "S2.sid")(sigma_("S1.sname" = "S2.sname" and "S1.sid" < "S2.sid")(rho_("S1")(#Sa) times rho_("S2")(#Sa))) $ ]
#schem[$("S1.sid", "S2.sid")$. ]
#why[ The comparison attribute is `sname`, which is *not* a key — that is the whole point. ]
#trap[ A common wrong answer is $pi_("sname")(#Sa) - pi_("sname")(sigma_("sname" = "X")(#Sa))$ style
set arithmetic on names; it cannot detect duplicates because projection has already removed
them. Duplicate detection needs a self-join. ]
]

#heading(level: 2)[6.4 Division and universal quantification]

#q[6.23][Find the sids of sailors who have reserved every boat. *(classic)*][
#ans[ $ pi_("sid", "bid")(#Re) div pi_("bid")(#Bo) $ ]
#schem[$("sid")$. ]
#why[ Dividend restricted to the two attributes of interest; divisor is the full boat set. ]
#trap[ Dividing `Reserves` directly returns (sid, day) pairs — see Q4.13. ]
]

#q[6.24][Find the names of sailors who have reserved every red boat.][
#ans[ $ pi_("sname")(#Sa bowtie ( pi_("sid", "bid")(#Re) div pi_("bid")(sigma_("color" = #C("red"))(#Bo)) )) $ ]
#schem[$("sname")$. ]
#why[ The quantified set is *red* boats, so the colour condition is inside the divisor. ]
#trap[ With the sample instance there are two red boats (102, 104); no sailor reserved both,
so the answer is empty. Empty answers are common in division queries — do not "fix" them. ]
]

#q[6.25][Find the names of sailors who have reserved every boat that sailor 22 has reserved.][
#ans[ $ pi_("sname")(#Sa bowtie ( pi_("sid", "bid")(#Re) div pi_("bid")(sigma_("sid" = 22)(#Re)) )) $ ]
#schem[$("sname")$. ]
#why[ The divisor is whatever 22 reserved; Dustin himself is included, as he reserved all of
them. ]
#trap[ If 22 had no reservations the divisor would be empty and *every* sailor returned —
vacuous truth. Say so. ]
]

#q[6.26][Find the sids of sailors who have reserved all boats of colour red.][
#ans[ $ pi_("sid", "bid")(#Re) div pi_("bid")(sigma_("color" = #C("red"))(#Bo)) $ ]
#schem[$("sid")$. ]
#why[ This is Q4.3, restated as part of the complete bank. ]
#trap[ "All red boats" and "all boats, which happen to be red" are different queries when
non-red boats exist. Only the first is asked here. ]
]

#q[6.27][Explain how division solves "for all" questions, and derive the equivalent expression
that uses only $pi$, $times$ and $-$.][
#ans[ See §4.1–4.2 for the full derivation. The identity is
$R("R") div R("S") = pi_X (R("R")) - pi_X ( (pi_X (R("R")) times R("S")) - R("R") )$ with
$X = "attr"(R("R")) - "attr"(R("S"))$. ]
#why[ The English sentence "for every boat, the sailor reserved it" has the form
$forall b in R("Boats"), exists r in R("Reserves")$ with matching attributes. Division is
exactly the operator whose definition contains that $forall$. The primitive form of the same
statement is "there is no boat that is missing", and "missing boats" is a set difference
against a product. ]
#trap[ The double quantifier "$forall b exists r$" is *not* the same as "$exists r forall b$".
The second is division when $r$ ranges over a single sailor; the first allows a different
reservation per boat, which is precisely what division computes. Mixing them up produces the
"same day" variant of Q4.5. ]
]

#heading(level: 2)[6.5 Advanced queries]

#q[6.28][Find the sailor(s) with the highest rating.][
#ans[ $ #Sa bowtie ( pi_("rating")(#Sa) - pi_("S1.rating")(sigma_("S1.rating" < "S2.rating")(rho_("S1")(#Sa) times rho_("S2")(#Sa))) ) $ ]
#schem[Schema of `Sailors`. ]
#why[ Value, then join (Q5.3). With the sample instance: Zorba (71) and Rusty (58), both
rating 10. ]
#trap[ Returning only one of them loses the tie mark. The natural join preserves both
automatically — that is why the value-then-join form is preferred over tuple subtraction here. ]
]

#q[6.29][Find the oldest sailor(s).][
#ans[ $ #Sa bowtie ( pi_("age")(#Sa) - pi_("S1.age")(sigma_("S1.age" < "S2.age")(rho_("S1")(#Sa) times rho_("S2")(#Sa))) ) $ ]
#schem[Schema of `Sailors`. ]
#why[ Same pattern with `age`. With the sample instance: Lubber (31) at 55.5. ]
#trap[ If ages were stored as strings (e.g. "45.0"), comparison would still work for these
values but not in general for unequal digit counts; assume numeric. ]
]

#q[6.30][Find the second-highest distinct rating.][
#ans[ Let $R("MaxR") = pi_("rating")(#Sa) - pi_("S1.rating")(sigma_("S1.rating" < "S2.rating")(rho_("S1")(#Sa) times rho_("S2")(#Sa)))$
and $R("Rest") = pi_("rating")(#Sa) - R("MaxR")$. Then
$ R("Rest") - pi_("R1.rating")(sigma_("R1.rating" < "R2.rating")(rho_("R1")(R("Rest")) times rho_("R2")(R("Rest")))) $ ]
#schem[$("rating")$ throughout. ]
#why[ Remove the maximum, then take the maximum of the remainder — Q5.5. With the sample
instance: ratings are {1, 7, 8, 9, 10}; removing 10 leaves {1,7,8,9} whose maximum is 9. ]
#trap[ "Second-highest rating" is 9 (Horatio 74), even though two sailors hold rating 10. Ties
are collapsed because we are ranking *values*. ]
]

#q[6.31][Find the names of sailors who have reserved only red boats.][
#ans[ $ pi_("sname")(#Sa bowtie ( pi_("sid")(#Re) - pi_("sid")(#Re bowtie sigma_("color" != #C("red"))(#Bo)) )) $ ]
#schem[$("sid")$. ]
#why[ Pattern 5: at least one reservation, minus any non-red reservation. ]
#trap[ A sailor with no reservations is not returned, because he is not in
$pi_("sid")(#Re)$. If the question intends "vacuously only red", use
$pi_("sname")(#Sa) - pi_("sname")(#Sa bowtie pi_("sid")(#Re bowtie sigma_("color" != #C("red"))(#Bo)))$
and say so. ]
]

#q[6.32][Find the names of sailors who reserved a red boat and a green boat *in the same
reservation*.][
#nex[ Under this schema the query is *not meaningful*, and the mark is for saying so. ]
#ans[ A row of `Reserves` records *one* boat on *one* day: the schema is
(sid, bid, day), so "one reservation" can never contain two boats. The question becomes
answerable only under a different schema — a `Reservation(ResId, sid, day)` relation plus
`Reservation_Item(ResId, bid)`. It is then a self-join on `ResId`:
$ pi_("sid")(#R("Reservation") bowtie pi_("ResId")( sigma_("b1.color" = #C("red") and "b2.color" = #C("green"))( rho_("b1")(#R("Reservation_Item") bowtie #Bo) times rho_("b2")(#R("Reservation_Item") bowtie #Bo) ) ) ) $ ]
#schem[Under the standard schema: not expressible / not meaningful. Under the multi-item
schema: $("sid")$. ]
#why[ This is the *reason* the standard schema is called "Sailors, Boats, Reserves" rather
than "reservations with items": it cannot model a multi-boat reservation, and therefore the
"same reservation" variant of the red-and-green question has no answer in it. ]
#aside[ If the examiner's intended reading is "on the same *day*", that *is* expressible:
$ pi_("sname")(#Sa bowtie pi_("R1.sid")( sigma_("R1.sid" = "R2.sid" and "R1.day" = "R2.day")( rho_("R1")(#Re bowtie sigma_("color" = #C("red"))(#Bo)) times rho_("R2")(#Re bowtie sigma_("color" = #C("green"))(#Bo)) ) )) $. ]
#trap[ A student who writes the "same day" expression without noticing the schema limitation
usually still gets most of the marks, but not the mark awarded for identifying that a single
reservation row holds a single boat. Say both. ]
]

#q[6.33][Find the names of sailors who have reserved red boats but no other colours.][
#ans[ $ pi_("sname")(#Sa bowtie ( pi_("sid")(#Re bowtie sigma_("color" = #C("red"))(#Bo)) - pi_("sid")(#Re bowtie sigma_("color" != #C("red"))(#Bo)) )) $ ]
#schem[$("sid")$ on both sides. ]
#why[ "At least one red" gives the universe; "any non-red" is removed. This differs from Q6.31
only in how the universe is written: Q6.31 uses *all* reservations, which forces the sailor to
have at least one reservation of any kind; Q6.33 forces at least one *red* one. For a sailor
with no reservations the two agree (both exclude him); for a sailor with a blue boat only,
both exclude him. The expressions differ if the table could contain a reservation with a NULL
colour. ]
#trap[ $sigma_("color" != #C("red"))$ is the complement of $sigma_("color" = #C("red"))$ only
when `color` is never NULL. State the assumption. ]
]

#q[6.34][Find the boats that have been reserved by every sailor in the set {22, 31}.][
#ans[ $ pi_("bid", "sid")(#Re) div pi_("sid")(sigma_("sid" = 22 or "sid" = 31)(#Sa)) $ ]
#schem[Divisor: $("sid")$. Result: $("bid")$. ]
#why[ The divisor is a *constant relation* built by selection over `Sailors`. This is the
standard way to quantify over a named finite set of stored entities: encode the set as a
selection, then divide. ]
#trap[ If the set is supplied as a literal relation that is not in the database — say
$R("S") = {(22), (31)}$ — division still works, because the divisor need not be a stored
relation. Write the constant relation explicitly and say that you are doing so. ]
]

#q[6.35][Find the names of sailors whose every reservation satisfies the condition "the boat is
red".][
#ans[ $ pi_("sname")(#Sa bowtie (pi_("sid")(#Re) - pi_("sid")(#Re bowtie sigma_("color" != #C("red"))(#Bo)))) $ ]
#schem[$("sid")$. ]
#why[ A universally quantified condition over a sailor's reservations is pattern 5: all rows
minus the violating rows. This is the same shape as Q6.31, which shows that "only X" and
"every reservation is X" are the same query in disguise. ]
#trap[ Note that this expression *also* requires at least one reservation. The purely
universal reading would include sailors with no reservations (vacuous truth). Both readings
must be labelled. ]
]

#q[6.36][Find the ordered pairs of sailors (x, y) such that every boat reserved by x has a
higher bid than every boat reserved by y.][
#ans[ Let $R("X") = pi_("sid", "bid")(#Re)$ and
$R("Bad") = pi_("x.sid", "y.sid")( sigma_("x.bid" <= "y.bid")( rho_("x")(R("X")) times rho_("y")(R("X")) ) )$.
Then $ (pi_("sid")(#Re) times pi_("sid")(#Re)) - R("Bad") $ ]
#schem[$R("Bad")$: $("x.sid", "y.sid")$. The product of the two sid sets is union compatible
with it, so the difference is legal. Result: $("sid", "sid")$ — ordered pairs. ]
#why[ "$>$ every boat of y" is "$not$ ($<=$ some boat of y)". The product of *all* sailors
pairs with itself gives every candidate pair; the $sigma$ finds the pairs with at least one
violating comparison; the difference leaves the good pairs. This is the counter-example method
applied to a *pair* of tuple variables. ]
#trap[ The pairs where x has no reservations or y has no reservations are *vacuously*
satisfying and are returned. If the question means non-vacuous, intersect with
$pi_("sid")(#Re) times pi_("sid")(#Re)$ restricted to sailors who reserved something — which is
exactly what the universe above already does. Say which reading you use. ]
]

#q[6.37][Find the sids of sailors who have made a reservation on every date that appears in a
given relation $R("Dates")("day")$.][
#ans[ $ pi_("sid", "day")(#Re) div R("Dates") $ ]
#schem[Dividend: $("sid", "day")$. Divisor: $("day")$. Result: $("sid")$. ]
#why[ The answer attribute is `sid`; the quantified attribute is `day`. Note that the dividend
must be projected to exactly (sid, day) — if `bid` is kept, the result becomes (sid, bid) and
asks "for every date, this sailor reserved *this particular boat* on it". ]
#trap[ If $R("Dates")$ is the projection $pi_("day")(#Re)$ of the database itself, the query
becomes "reserved on every date on which anybody reserved", which is a real and interesting
query — and it is the one students often write by accident. Check which set the question
names. ]
]

#heading(level: 2)[6.6 Answers on the sample instance — a quick self-check]

#tab((auto, 1fr, auto),
  [*Q*], [*Answer on the instance*], [*Rows*],
  [6.4], [Dustin, Lubber, Horatio], [3 names],
  [6.10], [Dustin, Lubber], [2],
  [6.12], [Brutus, Andy, Rusty, Zorba], [5 — note Horatio appears once as a name],
  [6.13], [none; all four boats were reserved], [0],
  [6.15], [(22,64), (31,32), (58,71)], [3 pairs],
  [6.23], [none; nobody reserved all four boats], [0],
  [6.28], [Rusty, Zorba], [2],
  [6.29], [Lubber], [1],
  [6.30], [9], [1],
)
#v(2pt)
#mini[These counts are for the instance above only. They are a sanity check on your reading of the expression, never a substitute for it.]
