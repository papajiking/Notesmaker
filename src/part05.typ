#import "lib.typ": *

#let Sa = R("Sailors")
#let Re = R("Reserves")
#let Bo = R("Boats")
#let Emp = R("Emp")

#part(5, "Maximum, minimum, ranking, ties and group-wise comparisons", blurb: [
  *What this part fixes.* Extremes are the classic "cannot use MAX()" question. The trick is
  always the same: *a value is the maximum exactly when no larger value exists.* Writing that
  as a set difference over a self-product gives every maximum query in the syllabus — global,
  per-group, after a selection, with ties, and for the $k$-th value. The part ends with the
  three things that are genuinely *not* expressible.
])

#heading(level: 2)[5.1 The master pattern]

#keybox[
*Maximum of an attribute.* Let $R("R")$ have attribute $a$.

#eq[$ "MaxVal"(a, R("R")) = pi_a (R("R")) - pi_("R1.a")( sigma_("R1.a" < "R2.a")(rho_("R1")(R("R")) times rho_("R2")(R("R"))) ) $]

Read the second term as "the values that are smaller than some other value" and subtract them.
What remains are the values that are smaller than *nothing* — the maxima.

*Minimum* is the same with $>$ in place of $<$.

*Records* with the maximum value are then
$R("R") bowtie "MaxVal"(a, R("R"))$ — a natural join on $a$, which preserves *all* ties.
]

#note[
  The one thing to be careful about: the subtraction must be on *values*, so the projection to
  $a$ is essential. If you subtract whole tuples you get "records that are beaten", which is a
  different (and usually wrong) answer, because a record can be beaten on $a$ yet still be
  tied for the maximum *value* after projection. See Q5.4.
]

#heading(level: 2)[5.2 Global maximum and minimum]

#q[5.1][Find the highest rating among sailors, without using MAX.][
#ans[ $ pi_("rating")(#Sa) - pi_("S1.rating")(sigma_("S1.rating" < "S2.rating")(rho_("S1")(#Sa) times rho_("S2")(#Sa))) $ ]
#schem[$pi_("rating")(#Sa)$: $("rating")$. The $sigma$ result has schema
$("S1.sid", "S1.sname", "S1.rating", "S1.age", "S2.sid", "S2.sname", "S2.rating", "S2.age")$;
projecting $A("S1.rating")$ gives $("rating")$, which is union compatible with the left
operand. ]
#why[ All values minus values that are less than some other value. The survivors are
precisely the maximum values. If several sailors share rating 10, the result is still a single
tuple $(10)$ — the question asked for the *value*, not the sailors. ]
#trap[ If the relation is empty, both operands are empty and the result is empty — there is no
maximum of an empty set, and returning the empty relation is the correct answer. Say so rather
than inventing a value. ]
]

#q[5.2][Find the minimum age among sailors.][
#ans[ $ pi_("age")(#Sa) - pi_("S1.age")(sigma_("S1.age" > "S2.age")(rho_("S1")(#Sa) times rho_("S2")(#Sa))) $ ]
#schem[$("age")$.]
#why[ Identical to Q5.1 with the inequality reversed. ]
#trap[ Do not "simplify" by negating the comparison inside a single product:
$sigma_(not("S1.age" > "S2.age"))$ is $<=$, which includes the equality case and therefore
removes *everything*, giving the empty relation for the minimum. Negating the *whole*
expression is not the same as negating the *condition inside* it — the set difference does the
negation, not the comparison operator. ]
]

#q[5.3][Find the sailor(s) with the highest rating: return the complete sailor tuples, and
preserve ties.][
#ans[ $ #Sa bowtie ( pi_("rating")(#Sa) - pi_("S1.rating")(sigma_("S1.rating" < "S2.rating")(rho_("S1")(#Sa) times rho_("S2")(#Sa))) ) $ ]
#schem[The natural join is on `rating`; result schema $("sid", "sname", "rating", "age")$ —
the same as `Sailors`. ]
#why[ Compute the maximum *value* first (Q5.1), then join back to get the records carrying that
value. Every sailor whose rating equals the maximum survives the join, so ties are preserved
automatically. This is why the natural join is the right tool here: it *is* the "records with
this value" operator. ]
#trap[ A common wrong answer is
$#Sa - pi_("sid", "sname", "rating", "age")(sigma_("S1.rating" < "S2.rating")(rho_("S1")(#Sa) times rho_("S2")(#Sa)))$.
It *also* works when ratings are distinct, and it is the pattern to use when the "maximum" is
defined over the *whole tuple* rather than one attribute (see Q5.4). But it silently differs
from the join form if two sailors tie on `rating` and one is subtracted for a different
reason. Prefer "value, then join". ]
]

#q[5.4][Find the sailor with the maximum rating using only set difference on whole tuples.
Compare with Q5.3 and explain when the two answers differ.][
#ans[ $ #Sa - pi_("sid", "sname", "rating", "age")(sigma_("S1.rating" < "S2.rating")(rho_("S1")(#Sa) times rho_("S2")(#Sa))) $ ]
#schem[The projection must list *all four* attributes of the $R("S1")$ side so that the
difference is union compatible with `Sailors`. This is the "preserve full schema when
subtracting records" rule. ]
#why[ A whole tuple is removed when it is *dominated* by another tuple. If rating is the only
criterion, a tied tuple is not dominated (it is not $<$ any other), so ties survive. The two
answers coincide whenever the only comparison is on the maximum attribute. ]
#note[ They differ as soon as the criterion is composite, e.g. "the sailor with the highest
rating, and among those the oldest". The whole-tuple method can express that with a compound
$sigma$; the "value then join" method needs two nested extremes. ]
#trap[ Forgetting one attribute in the projection produces a *well-typed* expression if the
remaining list happens to match — for instance projecting only $("sid", "rating")$ would be
union compatible with $pi_("sid", "rating")(#Sa)$, not with `Sailors`, so it is caught. But
projecting the wrong *four* attributes in a different order is not caught, and changes the
meaning. Always write the projection in the schema order of the target relation. ]
]

#heading(level: 2)[5.3 Second, third and k-th highest]

#q[5.5][Find the second-highest *distinct* rating.][
#ans[ Let $R("M") = pi_("rating")(#Sa) - pi_("S1.rating")(sigma_("S1.rating" < "S2.rating")(rho_("S1")(#Sa) times rho_("S2")(#Sa)))$.
Then $ R("Second") = pi_("rating")(sigma_("rating" < "M.rating")(#Sa) ) - pi_("S1.rating")(sigma_("S1.rating" < "S2.rating")(rho_("S1")(sigma_("rating" < "M.rating")(#Sa)) times rho_("S2")(sigma_("rating" < "M.rating")(#Sa)))) $ ]
#schem[Both $R("M")$ and $R("Second")$ have schema $("rating")$. ]
#why[ *Remove the maximum, then take the maximum of what is left.* The inner selection
$sigma_("rating" < "M.rating")(#Sa)$ restricts to strictly smaller ratings — note that it must
be applied to `Sailors`, joined with $R("M")$, or equivalently written as
$sigma_("rating" < 10)(#Sa)$ once the maximum is known. Then Q5.1 is applied to that restricted
relation. ]
#note[ An equivalent and shorter formulation: let $R("Below") = pi_("rating")(#Sa) - R("M")$.
Then the second-highest is
$R("Below") - pi_("S1.rating")(sigma_("S1.rating" < "S2.rating")(rho_("S1")(R("Below")) times rho_("S2")(R("Below"))))$.
Since $R("Below")$ is a *relation of values*, it can appear directly as a product operand —
this is legal because $rho$ renames a relation, and a relation of ratings is a relation. ]
#trap[ "Second-highest rating" vs "rating of the second-highest sailor": with ties, these are
different. If three sailors share rating 10 and one has 9, the second-highest *distinct*
rating is 9, but "the sailor in second place by rating" is ambiguous. State which you compute —
the distinct-value reading is the standard one. ]
]

#q[5.6][Find the sailor(s) with the second-highest rating, preserving ties.][
#ans[ Let $R("S2")$ be the expression of Q5.5 (the second-highest distinct rating). Then
$ #Sa bowtie R("S2") $. ]
#schem[$("sid", "sname", "rating", "age")$. ]
#why[ The same "value, then join" step as Q5.3. All sailors tied at the second-highest value
are returned. ]
#trap[ If there is only one distinct rating, the second-highest is *undefined*. The expression
returns the empty relation, which is the honest answer; a student who forces a value by using
$<=$ instead of $<$ returns the maximum itself. Do not. ]
]

#q[5.7][Find the third-highest distinct rating, and then the $k$-th highest.][
#ans[ *Third:* remove the top two values, then take the maximum of what remains.

#eq[$ R("Top2") = R("M") union R("S2") quad R("Third") = "Max"( pi_("rating")(#Sa) - R("Top2") ) $]

*$k$-th:* define $R("Top")_0 = emptyset$ and
$R("Top")_(i+1) = R("Top")_i union "Max"( pi_("rating")(#Sa) - R("Top")_i )$.
Then the $k$-th highest is $"Max"(pi_("rating")(#Sa) - R("Top")_(k-1))$. ]
#schem[Every intermediate is a relation of schema $("rating")$, so the unions are legal. ]
#why[ "Remove the largest, repeat" is the definition of the $k$-th largest in a set. Because
each step is expressible in classical RA, every *fixed* $k$ is expressible: the expression is
a finite composition of the same five operators. ]
#trap[ This is expressible for a *fixed numeral* $k$ written into the query. It is *not*
expressible for "$k$-th highest where $k$ is a column value" — that needs arithmetic and
counting. See Q5.27 and §10.6. Examiners often ask the fixed case and expect you to note the
distinction. ]
]

#heading(level: 2)[5.4 Global versus group-wise extremes]

#q[5.8][Using $R("Emp")("eid", "ename", "sal", "deptno")$ and $R("Dept")("deptno", "dname", "loc")$,
find the highest salary in each department, returning the employees.][
#ans[ $ #Emp - pi_("E1.eid", "E1.ename", "E1.sal", "E1.deptno")( sigma_("E1.deptno" = "E2.deptno" and "E1.sal" < "E2.sal")( rho_("E1")(#Emp) times rho_("E2")(#Emp) ) ) $ ]
#schem[The product has eight attributes; the projection keeps the four of the $R("E1")$ side in
the *schema order of* `Emp`, so the difference is union compatible. Result schema
$("eid", "ename", "sal", "deptno")$. ]
#why[ An employee is *not* a group maximum iff there exists another employee *in the same
department* with a strictly larger salary. The equality on `deptno` is what makes the
comparison group-local; without it you would get the global maximum. Ties survive because the
comparison is strict. ]
#trap[ Three separate errors are common. (i) Omitting `E1.deptno = E2.deptno` — global instead
of per-department. (ii) Omitting the projection or shortening it — the subtraction then either
fails union compatibility or, worse, produces a different relation and no error. (iii) Using
$<=$ — every employee has someone with an equal salary (himself), so *every* row is removed
and the answer is empty. ]
]

#q[5.9][Find the department(s) whose average salary is the highest — without $gamma$ and
without averages. Is it expressible?][
#nex[ "Highest average salary" is a *computed group statistic*. Classical relational algebra
has no aggregation, so averages cannot even be formed, let alone compared. The honest answer
is: not expressible. ]

#ans[ Not expressible in classical relational algebra. It becomes expressible with the
extended grouping operator:
$ gamma_("deptno"; "avg"("sal") arrow.l "avgsal")(#Emp) $, then the maximum-of-values
pattern on `avgsal`, then a join back. ]
#why[ Every expressible query in classical RA is a first-order formula over the stored tuples;
"average" requires summing an unbounded number of values, which first-order logic over a
finite structure cannot do without aggregation. ]
#trap[ Students often try to compare salaries pairwise and conclude "the department whose
every member earns more than every member of any other department". That is a *different*
query (dominance), and it is expressible — but it is not "highest average". If you write it,
label it as a different interpretation, not as an answer to this question. ]
]

#q[5.10][Find the highest salary in the department with the most employees. Discuss.][
#nex[ "The department with the most employees" is a cardinality comparison between groups —
again an aggregate. ]
#ans[ Not expressible in classical relational algebra; needs
$gamma_("deptno"; "count"("eid") arrow.l n)(#Emp)$ followed by a maximum and a join. ]
#why[ Contrast with Q5.8, which *is* expressible. The difference is that Q5.8 compares salaries
*within* a group using a stored value, while this question compares the *sizes* of groups. ]
#trap[ A common wrong instinct is "find the department that is not smaller than any other",
i.e. $not exists$ a department with more employees. That condition *is* expressible — it is a
finite formula — but it computes *maximal* departments, and if two departments tie for the
largest size both are returned, which is right, while a department that is smaller than
another is excluded. Actually this works! See the note below. ]
#note[
  Careful: "the department with the most employees" *is* expressible when read as
  "no other department has strictly more employees", because "more employees" can be phrased as
  the existence of an injective mapping — which is not first-order over the relation alone.
  In practice, examiners treat it as *not expressible* and expect the $gamma$ answer. If you
  want to argue expressibility, you must exhibit a first-order formula; the natural attempt
  ("there is no department $d'$ with $|d'| > |d|$") quantifies over *sets*, not tuples, and is
  therefore not a formula of the classical algebra. State the limitation explicitly.
]
]

#q[5.11][Find the cheapest medicine in the `Medicine(TradeName, UnitPrice, GenericFlag)`
relation, and the most expensive one.][
#ans[ $ "Cheapest" = pi_("TradeName", "UnitPrice", "GenericFlag")(#R("Medicine")) - pi_("M1.TradeName", "M1.UnitPrice", "M1.GenericFlag")( sigma_("M1.UnitPrice" > "M2.UnitPrice")( rho_("M1")(#R("Medicine")) times rho_("M2")(#R("Medicine")) ) ) $
$ "Most expensive" = #R("Medicine") - pi_("M1.TradeName", "M1.UnitPrice", "M1.GenericFlag")( sigma_("M1.UnitPrice" < "M2.UnitPrice")( rho_("M1")(#R("Medicine")) times rho_("M2")(#R("Medicine")) ) ) $ ]
#schem[Both results have the schema of `Medicine`, $("TradeName", "UnitPrice", "GenericFlag")$. ]
#why[ Here the extreme is required on *records*, not on a single value, because the question
asks for "the cheapest medicine" — the whole row. The whole-tuple pattern (Q5.4) is therefore
the natural one; the projection must list all three attributes. ]
#trap[ If the question asked only for the *price*, project $("UnitPrice")$ on both sides and
compare only that attribute. Mixing the two modes — projecting three attributes on the left and
one on the right — breaks union compatibility. ]
]

#heading(level: 2)[5.5 Extremes after a selection, and extremes over dates]

#q[5.12][Find the highest rating among sailors who are older than 30.][
#ans[ $ pi_("rating")(sigma_("age" > 30)(#Sa)) - pi_("S1.rating")( sigma_("S1.rating" < "S2.rating")( rho_("S1")(sigma_("age" > 30)(#Sa)) times rho_("S2")(sigma_("age" > 30)(#Sa)) ) ) $ ]
#schem[$("rating")$. ]
#why[ *Apply the selection first, to both copies.* The extreme is taken over the restricted
relation, not over all sailors and then filtered — those two give different answers whenever
the global maximum is held by a young sailor. ]
#trap[ The shortcut
$sigma_("age" > 30)("HighestRated")$ is wrong: it answers "is the globally highest-rated
sailor also over 30?", which is usually empty. Selection and extremum do not commute. This is
the "maximum after applying a selection condition" trap, and it is worth a full question in
most papers. ]
]

#q[5.13][Find the most recent prescription date for each doctor, using
`Prescription(Id, Date, Doctor_SSN, Patient_SSN)`.][
#ans[ $ #R("Presc") - pi_("P1.Id", "P1.Date", "P1.Doctor_SSN", "P1.Patient_SSN")( sigma_("P1.Doctor_SSN" = "P2.Doctor_SSN" and "P1.Date" < "P2.Date")( rho_("P1")(#R("Presc")) times rho_("P2")(#R("Presc")) ) ) $ ]
#schem[Result schema equals that of `Prescription`. ]
#why[ Exactly the Q5.8 pattern with `Date` in place of `sal` and `Doctor_SSN` in place of
`deptno`. ISO date strings compare chronologically as strings, so $<$ is the right operator. ]
#trap[ If dates were stored as $"DD/MM/YYYY"$ strings, $<$ would compare day-of-month first and
give nonsense. Either convert to ISO, or compare the three components as a lexicographic tuple
— and say which you are doing. ]
]

#heading(level: 2)[5.6 Ranking: four different questions that share one word]

#table(
  columns: (auto, 1fr, 1fr),
  stroke: 0.4pt + l4, inset: (x: 5pt, y: 4pt), align: (left, left, left),
  table.header([*Reading*], [*What is being ordered*], [*Expression*]),
  [Ranking distinct values], [the set of values, not the rows],
    [$"Max"(pi_a R)$, $"Max"(pi_a R - "Max"(pi_a R))$, … (Q5.5, Q5.7)],
  [Ranking individual records], [rows, broken by a tie-breaker on the key],
    [whole-tuple pattern with a compound $sigma$ (Q5.14)],
  [Ranking with ties], [rows, all ties of a value reported together],
    [value-then-join (Q5.3, Q5.6) — ties are preserved by construction],
  [Ranking within each group], [rows, ordered inside their own partition],
    [group-wise pattern: equality on the group attribute in the $sigma$ (Q5.8, Q5.15)],
)
#v(4pt)
#note[
  Classical relational algebra has *no order* and no row number, so "rank" can only mean one
  of the four things above. A question that says "give the rank of each sailor" with no
  tie-breaking rule is under-specified; say so, then answer the closest expressible reading.
]

#q[5.14][Find the sailors who are the oldest in their rating group, breaking ties by sid (i.e.
the single oldest sailor per rating, and if two share the maximum age, the one with the
smaller sid). Is this deterministically expressible?][
#ans[ The *first* part — "oldest in each rating group", ties preserved — is:
$ #Sa - pi_("S1.sid", "S1.sname", "S1.rating", "S1.age")( sigma_("S1.rating" = "S2.rating" and "S1.age" < "S2.age")( rho_("S1")(#Sa) times rho_("S2")(#Sa) ) ) $

The *tie-break by sid* is also expressible, because it is a stored attribute:
$ #Sa - pi_("S1.sid", "S1.sname", "S1.rating", "S1.age")( sigma_("S1.rating" = "S2.rating" and ("S1.age" < "S2.age" or ("S1.age" = "S2.age" and "S1.sid" > "S2.sid")))( rho_("S1")(#Sa) times rho_("S2")(#Sa) ) ) $ ]
#schem[Both results have schema $("sid", "sname", "rating", "age")$. ]
#why[ The compound $sigma$ says: "there exists another sailor in my rating group who is either
older than me, or the same age with a smaller sid". Anyone satisfying that is not the winner.
This is a *total order* on the group because `sid` is unique, so exactly one winner per group
survives. ]
#trap[ A tie-break on something that is *not* unique (say `sname`) does not give a total order,
and the expression then returns several sailors per group. That is not an error in the
expression — it is a guarantee the data does not support. Say so. ]
]

#q[5.15][For each boat, find the sailor(s) who reserved it most recently.][
#ans[ $ pi_("R1.sid", "R1.bid")(#Re) ... $ — written fully, with the group-wise pattern on
`Reserves`:
$ #Re - pi_("R1.sid", "R1.bid", "R1.day")( sigma_("R1.bid" = "R2.bid" and "R1.day" < "R2.day")( rho_("R1")(#Re) times rho_("R2")(#Re) ) ) $ ]
#schem[Result schema equals `Reserves`: $("sid", "bid", "day")$. If the question asks for
sailor names, join with `Sailors` afterwards. ]
#why[ The group attribute is `bid`; the compared attribute is `day`. A reservation is not the
latest for its boat exactly when another reservation of the *same* boat has a later date. ]
#trap[ The natural join $rho_("R1")(#Re) bowtie rho_("R2")(#Re)$ equates all three attributes
and returns only identical rows, so the $sigma$ on `day` is unsatisfiable. Use $times$. ]
]

#q[5.16][Find the patient(s) with the highest number of prescriptions. Explain the difficulty.][
#nex[ "Highest number of prescriptions" compares *counts*, so it is not expressible in
classical relational algebra. ]
#ans[ Not expressible. With the extended operator:
$ gamma_("Patient_SSN"; "count"("Id") arrow.l n)(#R("Presc")) $, then the maximum-of-values
pattern on $n$, then a join back to `Patient` for names. ]
#why[ This is the single most important "not expressible" example for the hospital schema. It
looks exactly like Q5.14 but is fundamentally different: Q5.14 compares *stored values*, this
compares *cardinalities of sets*. Classical RA can say "there exist three prescriptions"; it
cannot say "there exist more prescriptions than for any other patient". ]
]

#heading(level: 2)[5.7 Fixed-cardinality conditions without aggregates]

#q[5.17][Find the sailors who have made *exactly one* reservation.][
#ans[ $ R("Once") = pi_("sid")(#Re) - pi_("R1.sid")(sigma_("R1.sid" = "R2.sid" and "R1.bid" != "R2.bid")(rho_("R1")(pi_("sid", "bid")(#Re)) times rho_("R2")(pi_("sid", "bid")(#Re)))) $
$ "Answer" = pi_("sname")(#Sa bowtie R("Once")) $ ]
#schem[$R("Once")$: $("sid")$. Result: $("sname")$. ]
#why[ "Exactly one" is "at least one" minus "at least two". "At least two" is expressed by
existence of two *distinct* boats, which is a self-join with $!=$ — no counting involved.
Projecting to $("sid", "bid")$ first is essential so that "two distinct boats" is what is
measured. ]
#trap[ If the question means "exactly one *reservation record*" (one day, one boat), then
measure distinct $("sid", "bid", "day")$ triples instead. On this schema a sailor cannot reserve the
same boat twice on the same day, so the two readings differ only when the same boat is reserved
on two days. State which one you mean. ]
]

#q[5.18][Find the sailors who have made exactly two distinct reservations. First show why a
counting attempt cannot be written, then give the classical expression.][
#ans[ The counting attempt "$|sigma_("sid" = s)(#Re)| = 2$" cannot be written at all:
cardinality of a set is not a term of classical relational algebra. The classical expression
uses *three distinct witnesses*:
$ R("Two+") = pi_("R1.sid")(sigma_("R1.sid" = "R2.sid" and "R1.day" != "R2.day")(rho_("R1")(#Re) times rho_("R2")(#Re))) $
$ R("Three+") = pi_("R1.sid")(sigma_("R1.sid" = "R2.sid" and "R2.sid" = "R3.sid" and "R1.day" != "R2.day" and "R2.day" != "R3.day" and "R1.day" != "R3.day")(rho_("R1")(#Re) times rho_("R2")(#Re) times rho_("R3")(#Re))) $
$ "Answer" = pi_("sname")(#Sa bowtie (R("Two+") - R("Three+"))) $ ]
#schem[Each intermediate has schema $("sid")$; the final result is $("sname")$. ]
#why[ "Exactly two" is "at least two" minus "at least three". Each of those is a pure
existence statement over *distinct* tuple variables, so both are first-order and therefore
expressible. This is the general recipe of §10.6: a fixed numeral can always be eliminated in
favour of that many distinct witnesses. ]
#trap[ Reusing two variables cannot express "three distinct days": a formula with only
$R("R1")$ and $R("R2")$ can say "there are two different days", never "there are three". The
number of variables must be at least the numeral. Also, the pairwise $!=$ conjuncts are all
needed — with three witnesses, excluding only $A("R1.day") != A("R2.day")$ and
$A("R2.day") != A("R3.day")$ still allows $A("R1")$ and $A("R3")$ to share a day. ]
]

#q[5.19][Which of these is expressible in classical relational algebra? (a) sailors with at
least two reservations; (b) sailors with more reservations than sailor 22; (c) sailors with
exactly 5 reservations; (d) sailors with more reservations than any other sailor.][
#ans[ #tab((auto, 1fr, 1fr),
  [*(a)*], [*Yes*], [self-join with $!=$ on the day or boat (Q5.17)],
  [*(b)*], [*No*], [compares two cardinalities; needs $gamma$],
  [*(c)*], [*Yes in principle, No in practice*], [a fixed numeral 5 needs five distinct tuple variables; expressible but unwieldy, and most syllabi mark it "not expressible"],
  [*(d)*], [*No*], ["more than any other" is a maximum of a count; needs $gamma$],
) ]
#why[ The dividing line is whether the condition mentions a *number that must be computed*.
(a) and (c) use fixed numerals; (b) and (d) require computing a count for every sailor and
comparing. ]
#trap[ Examiners who set (c) usually want "not expressible" with the explanation that counting
is required. If you can write the five-variable expression, do, and then explain that the
syllabus convention is to call it inexpressible because the query's *structure* must change
with the numeral. That answer gets full marks either way. ]
]

#q[5.20][Find the sailors who are older than every sailor with rating 10, using the
counter-example method — and explain why the naive "maximum" approach is wrong.][
#ans[ Let $R("T10") = sigma_("rating" = 10)(#Sa)$ and
$R("Beaten") = pi_("S.sid")(sigma_("S.age" <= "T.age")(rho_("S")(#Sa) times rho_("T")(R("T10"))))$.
Then $ pi_("sname")(#Sa bowtie (pi_("sid")(#Sa) - R("Beaten"))) $. ]
#schem[$R("Beaten")$: $("sid")$. Result: $("sname")$. ]
#why[ "$>$ every" is "$not$ ($<=$ some)": a sailor fails iff he is at most as old as *some*
rating-10 sailor. Computing the maximum age among rating-10 sailors and comparing would give
the same answer *only if* $R("T10")$ is non-empty and the maximum exists; it also requires an
extra extreme query. The counter-example method is shorter and correct even for the empty
case. ]
#note[ When $R("T10")$ is empty, $R("Beaten")$ is empty and every sailor is returned — vacuously
true, and the mathematically correct reading of "older than every member of the empty set". ]
#trap[ Using $<$ instead of $<=$ in $R("Beaten")$ excludes sailors who are *equal* to a
rating-10 sailor, but "older than every" requires strict superiority, so equality must
disqualify. This off-by-one in the comparison is the most common error in the whole part. ]
]

#q[5.21][Find the sailors with the maximum rating *among those who are older than 25*.
Then find the maximum rating among those who are *not* older than 25, and explain why the two
answers can be equal even when the two groups are disjoint.][
#ans[ $ "MaxYoung" = pi_("rating")(sigma_("age" <= 25)(#Sa)) - pi_("S1.rating")( sigma_("S1.rating" < "S2.rating")( rho_("S1")(sigma_("age" <= 25)(#Sa)) times rho_("S2")(sigma_("age" <= 25)(#Sa)) ) ) $
$ "MaxOld" = pi_("rating")(sigma_("age" > 25)(#Sa)) - pi_("S1.rating")( sigma_("S1.rating" < "S2.rating")( rho_("S1")(sigma_("age" > 25)(#Sa)) times rho_("S2")(sigma_("age" > 25)(#Sa)) ) ) $ ]
#schem[Both $("rating")$. ]
#why[ Both groups can contain sailors with rating 10 — rating values are not partitioned by
age. The two maxima are *values*, and values can coincide across disjoint groups. ]
#trap[ Concluding "the groups are disjoint, so the maxima must differ" is a non-sequitur.
Also note that if one group is empty its maximum is the empty relation, not zero. ]
]

#q[5.22][Give the general recipe for "$k$-th highest" when ties are present, and show why
"$k$-th value" and "$k$-th record" diverge.][
#keybox[
+ *$k$-th distinct value.* Repeatedly remove the maximum, $k-1$ times, then take the maximum
  (Q5.7). Ties do not affect the result, because values are a set.
+ *$k$-th record.* Impose a total order using a unique tie-breaker (a key), then repeatedly
  remove the maximum tuple. If no total order exists in the data, the question is
  under-specified.
]
#ans[ With ratings 10, 10, 9: the 2nd *distinct* value is 9; the 2nd *record* by rating is
also 9 if we order 10, 10, 9 and count rows; the 2nd record under "ties share a rank" does not
exist as a single row. Three different answers to one English sentence. ]
#why[ Set semantics makes values canonical and records non-canonical: a set has no second
element unless you supply an order, and relations have no order. Hence only the
distinct-value reading is stable across all of classical RA. ]
#trap[ Never write "$R("R")[2]$" or "the second tuple". Indexing does not exist in relational
algebra; any answer that depends on position is wrong by definition. ]
]

#q[5.23][For each department, find the employee(s) with the lowest salary, but only for
departments that have at least two employees.][
#ans[ Let
$R("Min1") = #Emp - pi_("E1.eid", "E1.ename", "E1.sal", "E1.deptno")( sigma_("E1.deptno" = "E2.deptno" and "E1.sal" > "E2.sal")( rho_("E1")(#Emp) times rho_("E2")(#Emp) ) )$
and $R("TwoPlus") = pi_("E1.deptno")(sigma_("E1.deptno" = "E2.deptno" and "E1.eid" != "E2.eid")(rho_("E1")(#Emp) times rho_("E2")(#Emp)))$.
Then $ R("Min1") bowtie R("TwoPlus") $. ]
#schem[$R("Min1")$: schema of `Emp`. $R("TwoPlus")$: $("deptno")$. The natural join is on
`deptno`. Result: schema of `Emp`. ]
#why[ Two independent conditions — a group-wise extreme, and a group-level existence
condition. Each is computed separately and combined by a join on the group attribute. The
existential condition uses the *key* `eid` for the inequality so that two distinct rows are
counted, not two distinct salaries. ]
#trap[ Using $sigma_("E1.sal" != "E2.sal")$ for "at least two employees" counts two employees
with different salaries — a department with two employees on the same salary would be
wrongly excluded. Cardinality statements must compare *keys*. ]
]

#q[5.24][Find the sailors who have made *exactly one* reservation, and explain why this is
expressible while "exactly one more than sailor 22" is not.][
#ans[ Let $R("Res") = pi_("sid", "bid", "day")(#Re)$ be the set of reservation records.
$ R("Two+") = pi_("R1.sid")( sigma_("R1.sid" = "R2.sid" and "R1.day" != "R2.day")( rho_("R1")(R("Res")) times rho_("R2")(R("Res")) ) ) $
$ R("Once") = pi_("sid")(R("Res")) - R("Two+") $ and the names come from
$ pi_("sname")(#Sa bowtie R("Once")) $. ]
#schem[$R("Res")$: $("sid", "bid", "day")$. $R("Two+")$ and $R("Once")$: $("sid")$. Result:
$("sname")$. ]
#why[ "Exactly one" is "at least one" minus "at least two", and "at least two" is two
*distinct* witnesses — a fixed numeral, so the formula needs only two tuple variables. Nothing
is counted; the two variables simply witness that a second record exists. ]
#trap[ "Exactly one more than sailor 22" fails at the first step: the bound is a *computed
count*, so no fixed number of tuple variables can express it. The distinction is not the word
"exactly" but whether the bound is a literal in the query text. See §10.6. ]
]

#q[5.25][Find the sailor(s) with the highest rating after removing all sailors younger than 25
from consideration — and explain why "removing records first" changes the answer in a way that
"removing values first" does not.][
#ans[ Let $R("Elig") = sigma_("age" >= 25)(#Sa)$. Then
$ R("Elig") bowtie ( pi_("rating")(R("Elig")) - pi_("E1.rating")( sigma_("E1.rating" < "E2.rating")( rho_("E1")(R("Elig")) times rho_("E2")(R("Elig")) ) ) ) $. ]
#schem[$R("Elig")$: schema of `Sailors`. Result: schema of `Sailors`. ]
#why[ The extreme must be taken over the *reduced relation* (Q5.12). Removing records can
remove the holder of the global maximum, in which case the eligible maximum is a different
value; removing *values* — that is, projecting first — would leave the maximum intact but lose
the sailors who hold it. ]
#note[ This is the cleanest illustration of "maximum after removing certain records". On the
sample instance of Part 6, Zorba (16) is excluded, so the highest eligible rating is 10 held by
Rusty — the exclusion changed nothing; but if Rusty were 24, the answer would change to 9. ]
#trap[ Applying the age filter *after* the extremum —
$sigma_("age" >= 25)("HighestRated")$ — answers "is the globally highest-rated sailor at least
25?", which is a different and usually empty question. ]
]

#q[5.26][State precisely which of the following are expressible in classical relational algebra,
and give the expression or the reason:
(a) sailors with exactly three reservations; (b) sailors with exactly $n$ reservations where $n$
is an attribute of `Sailors`; (c) the third-highest distinct rating; (d) the average rating of
each rating group.][
#ans[ *(a) Expressible.* Three distinct tuple variables:
$ R("Three+") = pi_("R1.sid")( sigma_(theta)( rho_("R1")(#Re) times rho_("R2")(#Re) times rho_("R3")(#Re) ) ) $
with $theta$ the conjunction of the three sid-equalities and the three pairwise day-inequalities;
then "exactly three" $= R("Three+") - R("Four+")$, where $R("Four+")$ uses four variables.
*(b) Not expressible.* The number of tuple variables would have to depend on a stored value.
*(c) Expressible* — three nested "remove the maximum" steps (Q5.7).
*(d) Not expressible* — averaging is an aggregate. ]
#schem[(a) and (c): $("sid")$ and $("rating")$ respectively. ]
#why[ The dividing line is again *fixed versus computed* cardinality (§1.11, §10.6), and the
presence or absence of an arithmetic aggregate for (d). ]
#trap[ Part (a) is often marked "not expressible" by students who confuse it with part (b).
Write out why three variables suffice and the marker will see the distinction. ]
]

#q[5.27][Give the complete list of the questions in this part that are *not* expressible, with
the operator each one needs.][
#tab((auto, 1fr, auto),
  [*Question*], [*What must be computed*], [*Missing operator*],
  [Q5.9], [average salary per department], [$gamma$ with `avg`],
  [Q5.10], [number of employees per department], [$gamma$ with `count`],
  [Q5.16], [number of prescriptions per patient], [$gamma$ with `count`],
  [Q5.19(b), (d)], [comparison of two counts], [$gamma$ with `count`],
  [Q5.24], ["exactly one more than sailor 22"], [$gamma$ with `count`],
  [Q5.26(b)], ["exactly $n$ reservations" where $n$ is an attribute], [$gamma$ with `count`],
  [Q5.26(d)], [average rating per group], [$gamma$ with `avg`],
)
#v(3pt)
#why[ Every entry has the same shape: a *number* has to be produced from a set of tuples and
then compared. Classical relational algebra has no operator that turns a relation into a
number; $gamma$ is that operator, and it belongs to the extended algebra. ]
#trap[ Note what is *not* in the list: Q5.8 (highest salary per department), Q5.13 (latest
prescription per doctor), Q5.14 (oldest per rating group), Q5.22 (*k*-th highest for fixed $k$).
Those compare *stored values*, which needs no aggregation — only a self-join and a set
difference. Confusing the two families is the single most costly mistake in this part. ]
]
