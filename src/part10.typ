#import "lib.typ": *

#let Sa = R("Sailors")
#let Re = R("Reserves")
#let Bo = R("Boats")
#let Emp = R("Emp")
#let Pa = R("Patient")
#let Pr = R("Prescription")

#part(10, "Query equivalence, incorrect expressions, counterexamples and exam traps", blurb: [
  *What this part fixes.* The questions that carry the highest marks per line: "are these two
  expressions equivalent?", "find the error", "simplify", and "explain the difference between
  these two English sentences". §10.2 collects the eleven confusable pairs the brief asks for,
  each with the two expressions side by side.
])

#heading(level: 2)[10.1 Equivalence: the laws worth knowing]

Two expressions are *equivalent* if they return the same relation on *every* instance.
Counter-examples, not intuition, settle non-equivalence.

#table(
  columns: (1.15fr, 1fr, auto),
  stroke: 0.4pt + l4, inset: (x: 5pt, y: 4pt), align: (left, left, center),
  table.header([*Law*], [*Statement*], [*Holds?*]),
  [Cascade of selection], [$sigma_(theta_1)(sigma_(theta_2)(R)) = sigma_(theta_1 and theta_2)(R)$], [always],
  [Commutativity of selection], [$sigma_(theta_1)(sigma_(theta_2)(R)) = sigma_(theta_2)(sigma_(theta_1)(R))$], [always],
  [Selection over union], [$sigma_theta (R union S) = sigma_theta(R) union sigma_theta(S)$], [always],
  [Selection over difference], [$sigma_theta (R - S) = sigma_theta(R) - sigma_theta(S)$], [always],
  [Selection over join], [$sigma_theta (R bowtie S)$ — cannot always be pushed into one side], [only if $theta$ mentions only that side],
  [Projection cascade], [$pi_(L_1)(pi_(L_2)(R)) = pi_(L_1)(R)$ if $L_1 subset.eq L_2$], [always],
  [Projection and selection], [$pi_L(sigma_theta(R)) = pi_L(sigma_theta(pi_(L union "attr"(theta))(R)))$], [always],
  [Union: commutative, associative], [$R union S = S union R$], [always],
  [Intersection: commutative, associative], [$R inter S = S inter R$], [always],
  [Difference: neither], [$R - S != S - R$], [only when $R = S$],
  [Difference is not associative], [$(R - S) - T != R - (S - T)$], [fails when $R$ and $T$ overlap],
  [De Morgan (set form)], [$R - (S union T) = (R - S) inter (R - T)$], [always],
  [De Morgan (set form)], [$R - (S inter T) = (R - S) union (R - T)$], [always],
  [Join: commutative (natural)], [$R bowtie S = S bowtie R$], [always],
  [Join: associative (natural)], [$(R bowtie S) bowtie T = R bowtie (S bowtie T)$ when schemas allow], [always for natural join],
  [Division and union], [$R div (S_1 union S_2) != (R div S_1) union (R div S_2)$], [wrong in general — see Q4.15],
  [Division and intersection], [$R div (S_1 inter S_2) = (R div S_1) union (R div S_2)$], [true],
)

#heading(level: 2)[10.2 The eleven pairs of confusable sentences]

Each row gives the two English sentences, the two expressions, and the instance on which they
differ. This is the section examiners lift questions from.

#heading(level: 3)[Pair 1 — "reserved a red boat" versus "reserved only red boats"]

#table(columns: (auto, 1.25fr, 1fr), stroke: 0.4pt + l4, inset: (x: 5pt, y: 4pt), align: (left, left, left),
  [*Sentence*], [*Expression*], [*Difference*],
  [Reserved a red boat],
    [$pi_("sname")(#Sa bowtie #Re bowtie sigma_("color" = #C("red"))(#Bo))$],
    [A sailor with one red and one blue reservation *qualifies*.],
  [Reserved only red boats],
    [$pi_("sname")(#Sa bowtie (pi_("sid")(#Re) - pi_("sid")(#Re bowtie sigma_("color" != #C("red"))(#Bo))))$],
    [The same sailor *fails*, because of the blue one.],
)
#v(2pt)
#mini[The quantifier changes from $exists$ to $forall$; the second expression is the first one *intersected with the absence of counter-examples*.]

#heading(level: 3)[Pair 2 — "a red and a green boat" versus "both colours in one reservation"]

#table(columns: (auto, 1.25fr, 1fr), stroke: 0.4pt + l4, inset: (x: 5pt, y: 4pt), align: (left, left, left),
  [*Sentence*], [*Expression*], [*Difference*],
  [Reserved a red boat and a green boat],
    [$pi_("sid")(#Re bowtie sigma_("color" = #C("red"))(#Bo)) inter pi_("sid")(#Re bowtie sigma_("color" = #C("green"))(#Bo))$],
    [Two *different* reservations are fine; a sailor who reserved red in March and green in July qualifies.],
  [Both colours in the same reservation],
    [not meaningful in the 3-attribute `Reserves` schema (Q6.32); expressible only with a `Reservation`/`Reservation_Item` schema],
    [The standard schema cannot hold two boats in one reservation, so the honest answer names the schema limitation. On the "same day" reading, add $A("R1.day") = A("R2.day")$.],
)

#heading(level: 3)[Pair 3 — "has all required books" versus "has at least one required book"]

#table(columns: (auto, 1.25fr, 1fr), stroke: 0.4pt + l4, inset: (x: 5pt, y: 4pt), align: (left, left, left),
  [*Sentence*], [*Expression*], [*Difference*],
  [Has all required books],
    [$pi_("MemberID", "BookID")(#R("Borrow")) div R("Required")$],
    [Fails if even one is missing.],
  [Has at least one required book],
    [$pi_("MemberID")(#R("Borrow") bowtie R("Required"))$],
    [Succeeds with a single one.],
)
#v(2pt)
#mini[Never "simplify" the first into the second. The division is the $forall$; the join is the $exists$.]

#heading(level: 3)[Pair 4 — "not a primary doctor for any patient" versus "has never treated a patient"]

#table(columns: (auto, 1.25fr, 1fr), stroke: 0.4pt + l4, inset: (x: 5pt, y: 4pt), align: (left, left, left),
  [*Sentence*], [*Expression*], [*Difference*],
  [Not the primary doctor of any patient],
    [$pi_("SSN")(#R("Doctor")) - pi_("PrimaryDoctor_SSN")(#R("Patient"))$],
    [Uses the `Patient.PrimaryDoctor_SSN` column only.],
  [Never treated any patient],
    [$pi_("SSN")(#R("Doctor")) - pi_("Doctor_SSN")(#R("Prescription"))$],
    [Uses the `Prescription` relation only.],
)
#v(2pt)
#mini[A doctor who has written fifty prescriptions but is nobody's primary doctor satisfies the first and not the second; a primary doctor who has never written a prescription satisfies the second and not the first. Both directions occur in real data, which is why this pair is examinable.]

#heading(level: 3)[Pair 5 — "no prescriptions by other doctors" versus "no prescriptions at all"]

#table(columns: (auto, 1.2fr, 1.05fr), stroke: 0.4pt + l4, inset: (x: 5pt, y: 4pt), align: (left, left, left),
  [*Sentence*], [*Expression*], [*Difference*],
  [No prescription by a doctor other than my primary doctor],
    [pattern of Q8.4: all patients minus patients having a non-primary prescription],
    [A patient with *zero* prescriptions *qualifies* — vacuously true.],
  [Has no prescriptions at all],
    [$pi_("SSN")(#Pa) - pi_("Patient_SSN")(#Pr)$],
    [Strictly the empty-prescription patients only.],
)
#v(2pt)
#mini[The first is "A $union$ B" in the case table of Q8.4; the second is "A" alone. Write the case table in the exam — it is usually worth a mark by itself.]

#heading(level: 3)[Pair 6 — "medicine occurs in more than 20 prescriptions" versus "total units exceed 20"]

#table(columns: (auto, 1fr, 1fr), stroke: 0.4pt + l4, inset: (x: 5pt, y: 4pt), align: (left, left, left),
  [*Sentence*], [*Quantity compared*], [*Expressible?*],
  [Occurs in more than 20 prescriptions], [$"count"("Prescription_Id")$ — a *row* count],
    [No. Needs $gamma$.],
  [Total number of units exceeds 20], [$"sum"("NumOfUnits")$ — a *value* sum],
    [No. Needs $gamma$.],
)
#v(2pt)
#mini[Two different aggregates, two different answers on the same data. Aspirin in 3 prescriptions of 100 units each: count 3, sum 300. Vitamin in 1 prescription of 300 units: count 1, sum 300. The same total, a completely different count.]

#heading(level: 3)[Pair 7 — "second-highest distinct cost" versus "second record in descending order"]

#table(columns: (auto, 1.2fr, 1.05fr), stroke: 0.4pt + l4, inset: (x: 5pt, y: 4pt), align: (left, left, left),
  [*Sentence*], [*Meaning*], [*Expressible?*],
  [Second-highest distinct cost], [the second element of $pi_("cost")(R)$ after removing the maximum (Q5.5)], [Yes],
  [Second record when sorted by cost descending], [a *position* in an ordering of tuples], [No — relations have no order, and ties make the position undefined],
)
#v(2pt)
#mini[With costs 100, 100, 90: the second-highest distinct cost is 90; the second record is 100 (if ties are listed) or 90 (if ties collapse) — the phrase itself is ambiguous. Only the distinct-value reading is well defined in classical RA.]

#heading(level: 3)[Pair 8 — "maximum cost overall" versus "maximum cost per doctor"]

#table(columns: (auto, 1.2fr, 1.05fr),
  stroke: 0.4pt + l4, inset: (x: 5pt, y: 4pt), align: (left, left, left),
  [*Sentence*], [*Expression*], [*Difference*],
  [Overall maximum],
    [$R("T") - pi_("T1.attr")(sigma_("T1.attr" < "T2.attr")(rho_("T1")(R("T")) times rho_("T2")(R("T"))))$],
    [No equality on a group attribute in the $sigma$.],
  [Maximum per doctor],
    [$R("T") - pi_("T1.attr", "T1.doc")(sigma_(theta)(rho_("T1")(R("T")) times rho_("T2")(R("T"))))$ with $theta = A("T1.doc") = A("T2.doc") and A("T1.attr") < A("T2.attr")$],
    [Two changes: the conjunct that ties the two tuples to the *same group*, and the projection, which must list the *full* schema of $R("T")$ — here `attr` and `doc`, not `attr` alone.],
)

#heading(level: 3)[Pair 9 — "at least two related records" versus "at least two distinct related entities"]

#table(columns: (auto, 1.2fr, 1.05fr), stroke: 0.4pt + l4, inset: (x: 5pt, y: 4pt), align: (left, left, left),
  [*Sentence*], [*Expression*], [*Difference*],
  [At least two reservations], [self-join of `Reserves` with $!=$ on `bid` or `day`], [Counts *rows*.],
  [At least two distinct boats], [self-join of $pi_("sid", "bid")(#Re)$ with $!=$ on `bid`], [Counts *entities*.],
)
#v(2pt)
#mini[On a schema whose key is (sid, bid, day), the same boat reserved on two days gives two rows and one entity. Read the noun after "two".]

#heading(level: 3)[Pair 10 — "every record satisfies a condition" versus "there is a record satisfying it"]

#table(columns: (auto, 1.2fr, 1.05fr), stroke: 0.4pt + l4, inset: (x: 5pt, y: 4pt), align: (left, left, left),
  [*Sentence*], [*Expression*], [*Difference*],
  [Every reservation is red], [$pi_("sid")(#Re) - pi_("sid")(#Re bowtie sigma_("color" != #C("red"))(#Bo))$], [$forall$: no counter-example],
  [Has a red reservation], [$pi_("sid")(#Re bowtie sigma_("color" = #C("red"))(#Bo))$], [$exists$: one witness],
)
#v(2pt)
#mini[The two use the *same* $sigma$ with the condition negated, and the second is not a subset of the first: a sailor with a red and a blue boat is in the second and not the first.]

#heading(level: 3)[Pair 11 — "same set of books" versus "same number of books"]

#table(columns: (auto, 1.15fr, 1.1fr), stroke: 0.4pt + l4, inset: (x: 5pt, y: 4pt), align: (left, left, left),
  [*Sentence*], [*Expressible?*], [*Why*],
  [Borrowed exactly the same set of books], [Yes — two-directional coverage (Q7.33)], [It is a Boolean combination of universals],
  [Borrowed the same *number* of books], [No], [It compares two cardinalities — needs $gamma$],
)
#v(2pt)
#mini[The word "same" is innocent-looking and hides either a set equality (expressible) or a cardinality equality (not). This is the single most reliable discriminator question in the syllabus.]

#heading(level: 2)[10.3 Error detection: eighteen expressions, each wrong in exactly one way]

#q[10.1][$pi_("sname")(#Re)$ — find the error.][
#ans[ `Reserves` has schema $("sid", "bid", "day")$; it has no `sname`. The projection names an
attribute outside the operand's schema — a type error. ]
#trap[ The repair depends on the intent: to get names of sailors who reserved *something*,
join with `Sailors` first. ]
]

#q[10.2][$sigma_("rating" > #C("7"))(#Sa)$ — find the error.][
#ans[ `rating` is numeric and $#C("7")$ is a string. Domain mismatch inside a comparison. ]
]

#q[10.3][$pi_("sid", "sname")(#Sa) - pi_("sid")(#Re)$ — find the error.][
#ans[ Not union compatible: two attributes against one. Project both sides to $("sid")$, or
add `sname` to both sides by first joining. ]
]

#q[10.4][$#Sa times #Sa$ — find the error.][
#ans[ Ambiguous attribute names: the product would have two attributes called `sid`, and the
definition of the product requires disjoint attribute sets. Rename at least one copy with
$rho$. ]
]

#q[10.5][$#Re div pi_("bid")(#Bo)$ — find the error.][
#ans[ Not a type error — it is well-typed and *returns the wrong thing*: schema $("sid", "day")$,
meaning "sailors who reserved every boat on a single day". Project to $("sid", "bid")$ first. ]
]

#q[10.6][$sigma_("color" = #C("red"))(pi_("bid")(#Bo))$ — find the error.][
#ans[ `color` has been projected away. Select *before* projecting. ]
]

#q[10.7][$pi_("sname")(#Sa) - pi_("sname")(#Sa bowtie #Re bowtie sigma_("color" = #C("red"))(#Bo))$ — find the error.][
#ans[ Not a type error, but semantically wrong: `sname` is not a key. Two different sailors
called Horatio cancel each other. Subtract on `sid`. ]
]

#q[10.8][$pi_("sid")(sigma_("bid" = 101 and "bid" = 103)(#Re))$ — find the error.][
#ans[ One tuple cannot have two values for `bid`; the result is always empty. Use two tuple
variables, or an intersection of two projections. ]
]

#q[10.9][$sigma_("S1.rating" < "S2.rating")(#Sa)$ — find the error.][
#ans[ `S1` and `S2` are not bound: no $rho$ has introduced them, and a selection cannot compare
two tuples of the same relation. The self-product with two renames is missing. ]
]

#q[10.10][$pi_("sid")(#Sa bowtie #Re) - pi_("sid")(#Sa bowtie #Re bowtie sigma_("color" = #C("red"))(#Bo))$ — is this "sailors who never reserved a red boat"?][
#ans[ Yes for the reservers, but *no* for sailors with no reservations: they are in neither
operand, so they are not returned. The question's universe must be $pi_("sid")(#Sa)$, not
$pi_("sid")(#Sa bowtie #Re)$. ]
#trap[ This is the single most common "looks right, is subtly wrong" expression in the whole
subject. The visible symptom is that sailors with zero reservations silently disappear. ]
]

#q[10.11][$pi_("sname")(#Sa bowtie #Re)$ — find the error, if any.][
#ans[ No error. The natural join merges the shared `sid`; the projection is well-typed. It
returns the names of sailors who made at least one reservation. ]
#trap[ Watch the difference from $pi_("sname")(#Sa bowtie #Bo)$: `Sailors` and `Boats` share no
attribute name, so that expression is a *Cartesian product* — every sailor paired with every
boat. Legal, and almost never intended. ]
]

#q[10.12][$rho_("X")(#Sa) union #Sa$ — find the error, if any.][
#ans[ No error: $rho$ changes only the relation name, not the schema, so the operands are union
compatible. The result takes the *left* operand's relation name, $R("X")$. ]
#trap[ Renaming to a name already in scope — $rho_("Sailors")(#Sa)$ used together with `Sailors` —
creates genuine ambiguity. Use fresh names. ]
]

#q[10.13][$pi_("rating")(#Sa bowtie #Re) - pi_("rating")(#Sa)$ — what does this compute?][
#ans[ Nothing meaningful: the left operand has no `rating` (the natural join does keep it,
since `Reserves` has no `rating`) — so actually this *is* well-typed and computes
"ratings of sailors who have reserved, minus all ratings", which is always empty, because every
reserving sailor is a sailor. The expression is a disguised empty relation. ]
#why[ A useful reminder that well-typedness and meaningfulness are different. If an expression
looks suspiciously empty, check whether one side's set is a subset of the other's. ]
]

#q[10.14][$sigma_("age" > 30)(#Sa) - sigma_("rating" > 5)(#Sa)$ — find the error.][
#ans[ No type error (both operands are `Sailors`), and the meaning is "sailors older than 30
who do not have a rating above 5" — a legitimate but rarely intended query. The *likely* intent
was a conjunction, which is one selection with $and$. ]
#trap[ Set difference of two selections on the same relation is $sigma_(theta_1 and not theta_2)$,
never $sigma_(theta_1 and theta_2)$. Adding conditions is $and$ inside one $sigma$; subtracting
sets is a different operation. ]
]

#q[10.15][$pi_("sid")(#Re div pi_("bid")(#Bo))$ — find the error.][
#ans[ The division already returns $("sid")$, so the outer projection is redundant but legal.
The real trap is the inner one: `Reserves div pi_(bid)(Boats)` has schema $("sid", "day")$,
so the projection returns `sids` of sailors who reserved all boats *on one day*, which is the
wrong query (Q4.13). ]
]

#q[10.16][$gamma_("bid"; "count"("sid"))(pi_("bid", "sid")(#Re))$ — is this relational algebra?][
#ans[ No. $gamma$ is the *extended* grouping/aggregation operator. It is not part of the
classical algebra of $pi, sigma, rho, union, -, times$ (and the derived $inter, bowtie, div$).
In an exam that says "classical relational algebra only", writing $gamma$ is normally accepted
only as a *supplementary* answer after stating that the query is not expressible classically. ]
]

#q[10.17][Is `SELECT sname FROM Sailors WHERE rating > 7` a relational algebra expression?][
#ans[ No — it is SQL. Its relational-algebra equivalent is $pi_("sname")(sigma_("rating" > 7)(#Sa))$.
The examiner asks for the algebra, not the SQL; translating SQL into algebra is a legitimate
*first step*, but the SQL itself is not the answer. ]
]

#q[10.18][$pi_("sid")(#Sa) - pi_("sid")(#Re) inter pi_("sid")(sigma_("age" < 20)(#Sa))$ — find
both errors.][
#ans[ (i) Precedence: in the absence of brackets $inter$ binds tighter than $-$, so this parses
as $pi_("sid")(#Sa) - (pi_("sid")(#Re) inter pi_("sid")(sigma_("age" < 20)(#Sa)))$ — probably
not the intent. (ii) The phrase "$-$ before $inter$" is genuinely ambiguous across textbooks,
so always bracket. ]
#why[ There is no universal precedence agreement; the safe rule is to parenthesise every
compound expression. This is why every expression in this book is fully bracketed. ]
]

#heading(level: 2)[10.4 Simplification]

#q[10.19][Simplify $pi_("sname")(sigma_("rating" > 7)(sigma_("age" < 40)(#Sa)))$.][
#ans[ $ pi_("sname")(sigma_("rating" > 7 and "age" < 40)(#Sa)) $ ]
#why[ Cascade of selection (§10.1). Both conditions are tuple-local to the same relation, so
they combine into one $sigma$. ]
]

#q[10.20][Simplify $sigma_("rating" > 7)(#Sa bowtie #Re)$.][
#ans[ $ sigma_("rating" > 7)(#Sa) bowtie #Re $, provided `rating` is in `Sailors` only — it is.
Pushing the selection to the leaf reduces the intermediate relation and is always safe when the
attribute survives the join. ]
#trap[ Pushing a selection *through* a projection is not always safe; pushing through a union,
intersection or difference is safe; pushing through a division is not. ]
]

#q[10.21][Simplify $(pi_("sid")(#Sa) union pi_("sid")(#Sa)) - pi_("sid")(#Re)$.][
#ans[ $ pi_("sid")(#Sa) - pi_("sid")(#Re) $. Union is idempotent under set semantics: $R union R = R$. ]
#trap[ Under *bag* semantics (SQL's UNION ALL) this simplification is invalid. Classical
relational algebra is set-based, so it holds. State the semantics you are assuming. ]
]

#q[10.22][Simplify $pi_("sid")(pi_("sid", "bid")(#Re))$.][
#ans[ $ pi_("sid")(#Re) $. Projection cascade: a projection of a projection equals the
projection onto the smaller attribute list, provided that list is a subset of the inner one. ]
]

#q[10.23][Is $sigma_("rating" > 7)(#Sa) union sigma_("rating" <= 7)(#Sa)$ simplifiable?][
#ans[ Yes — to $#Sa$. The two selections partition the relation, and their union recovers it. ]
#why[ This is the set analogue of the law of excluded middle; it is worth remembering as a way to
*prove* that a partition-based expression is correct. ]
]

#heading(level: 2)[10.5 Why certain simplifications are unsound]

#tab((auto, 1fr, 1fr),
  [*Attempted simplification*], [*Status*], [*Counterexample or reason*],
  [$sigma_theta(R bowtie S) = sigma_theta(R) bowtie S$], [safe iff $theta$ mentions only $R$'s attributes], [if $theta$ mentions $S$'s attributes, the right side is a type error or a different filter],
  [$pi_L(sigma_theta(R)) = sigma_theta(pi_L(R))$], [unsafe], [$theta$ may mention an attribute not in $L$],
  [$pi_L(R bowtie S) = pi_L(R) bowtie pi_L(S)$], [unsafe in general], [join attributes may be projected away, turning the join into a product],
  [$sigma_theta(R div S) = sigma_theta(R) div S$], [unsafe], [$theta$ may mention attributes that division removes],
  [$(R div S) div T = R div (S times T)$], [true when schemas allow], [worth proving once; it is the associativity of division],
  [$R div (S_1 union S_2) = (R div S_1) union (R div S_2)$], [*false*], [Q4.15; dividing by a bigger set is harder, so the left side is smaller],
  [$R div (S_1 inter S_2) = (R div S_1) union (R div S_2)$], [true], [both sides quantify "every element of the smaller set"; prove by cases],
  [$R - (S - T) = (R - S) union (R inter T)$], [true], [useful in error detection],
)
#v(3pt)
#mini[Learn the four "*unsafe*" rows. They are the source of nearly every "is this simplification valid?" question.]

#heading(level: 2)[10.6 Fixed cardinality is expressible; computed cardinality is not]

#keybox[
*The rule.* Let $k$ be a *numeral written in the query*. Then "at least $k$", "at most $k$",
"exactly $k$" are expressible, using $k$ distinct tuple variables. If the bound is a *value that
must be computed* (an attribute, a count of another set, a sum), the query is not expressible.
]

*Worked example: "sailors with exactly two distinct boats".*
$ R("Two") = pi_("R1.sid")(sigma_("R1.sid" = "R2.sid" and "R1.bid" != "R2.bid")( rho_("R1")(#Re) times rho_("R2")(#Re) ))$
$ R("Three") = pi_("R1.sid")(sigma_("R1.sid" = "R2.sid" and "R2.sid" = "R3.sid" and "R1.bid" != "R2.bid" and "R2.bid" != "R3.bid" and "R1.bid" != "R3.bid")( rho_("R1")(#Re) times rho_("R2")(#Re) times rho_("R3")(#Re) ))$
$ "Exactly2" = R("Two") - R("Three") $

*Why the same trick fails for "more than 20".* The expression would need twenty-one variables
and, worse, its *shape* would change with the numeral. A query language is a fixed set of
operators; "more than $n$" for arbitrary $n$ requires a fixpoint or a counting operator. This
is the precise sense in which classical relational algebra is weaker than SQL.

#q[10.24][Which is expressible: "sailors with at least two reservations", "sailors with more
reservations than sailor 22", "sailors with exactly five reservations"?][
#ans[ First: yes (two variables). Second: no (compares a computed count with another computed
count — needs $gamma$). Third: yes in principle (five variables), no in the syllabus convention,
which treats any query whose structure depends on a numeral as "requires counting". ]
#why[ The bright line is not the *word* "exactly" but whether the bound is a literal in the
query text or a value that must be computed. ]
]

#heading(level: 2)[10.7 Queries that cannot be expressed: the full list]

#tab((auto, 1fr, 1.3fr),
  [*Category*], [*Example*], [*Why not*],
  [Counting], ["patients with more than 20 prescriptions" (Q8.3)], [cardinality is not a term],
  [Summing], ["total units prescribed" (Q8.3)], [sum is not a term],
  [Averaging], ["department with the highest average salary" (Q5.9)], [average is not a term],
  [Maximum of a count], ["most-borrowed book" (Q7.24)], [needs counting first],
  [Comparison of counts], ["patients with more prescriptions than their doctor" (Q8.27b)], [needs two counts],
  [Ranking by position], ["the second record in descending order" (§10.2 pair 7)], [relations have no order],
  [Deterministic choice among ties], ["one of the oldest sailors"], [requires an order or an arbitrary choice],
  [Arithmetic on attribute values], ["employees whose salary exceeds twice the department average"], [arithmetic over aggregates],
  [Transitive closure], ["all employees who report to X, directly or indirectly"], [needs a fixpoint; not first-order],
  [Conditional/derived columns], ["salary minus 10% as a new attribute"], [no arithmetic in the output schema in classical RA],
)
#v(3pt)
#mini[Every entry in this table has the same cure: an extended operator ($gamma$ for the first six, a fixpoint operator for the ninth, an extended projection for the last). Saying *which* extension is needed is worth as much as saying "not expressible".]

#heading(level: 2)[10.8 A ten-point checklist for the exam hall]

#keybox[
+ Did I write the *answer schema* first?
+ Is every $union / inter / -$ between operands with the *same attribute list*?
+ Did I *rename* one copy of any relation that appears twice?
+ Is every attribute in a $sigma$ or $pi$ actually *in the operand's schema*?
+ Did I subtract on the *key*, not on a descriptive attribute?
+ Did I *project before dividing*, and is the divisor exactly the quantified set?
+ Are *ties* preserved (strict inequalities, joins rather than tuple subtraction)?
+ Did I handle the *empty* case: empty divisor, empty witness set, no records at all?
+ Is the query *expressible* at all — and if not, did I say which operator is missing?
+ Did I *bracket* every compound expression?
]
