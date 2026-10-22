#import "lib.typ": *

#let Sa = R("Sailors")
#let Re = R("Reserves")
#let Bo = R("Boats")
#let S1 = "S1"
#let S2 = "S2"

#part(1, "Short notes and operator reference", blurb: [
  *What this part fixes.* The exact notation, arity and *schema rule* of all nine classical
  operators; what "union compatible" means; how division is defined; what set semantics
  costs you; which operators are *not* allowed in this book and why; and the 20 logical
  patterns from which every exam question in Parts 2–9 is built.
])

#heading(level: 2)[1.1 What relational algebra is, and why the examiner asks for it]

Relational algebra is a *procedural* query language: an expression is a tree of operators,
each of which takes one or two relations and returns one relation. Because every operator
returns a relation, expressions nest arbitrarily. That closure property is what makes the
algebra composable, and it is also why a single operator applied to the wrong operand type —
a relation where an attribute is expected, say — makes the whole answer worth zero.

Two things are tested when a university paper asks for "the relational algebra" of a query:

+ *Can you decompose an English sentence into logical quantifiers?* ("all", "only", "no",
  "at least two", "maximum", "same as").
+ *Can you build a well-typed expression tree* whose root schema is exactly the schema the
  question asks for, using only the permitted operators?

The second is where most marks leak. A student answers "names of sailors who reserved a red
boat" with $pi_("bname")(sigma_("color" = #C("red"))(#Bo))$ — correct in spirit, wrong in
schema, and it never touches `Reserves`. The fix is mechanical: *write the target schema
first, then the source schema, then bridge them.*

#heading(level: 2)[1.2 The three schemas used throughout]

Every question in this book belongs to one of three families. They are defined here once;
Parts 6, 7 and 8 restate them together with sample instances.

#heading(level: 3)[A. Sailors, Boats, Reserves — the *Database System Concepts* running example]

#tab((auto, 1fr),
  [*Relation*], [*Schema, keys and foreign keys*],
  [#R("Sailors")], [("sid", "sname", "rating", "age"); primary key "sid". "rating" is an integer 1–10; "age" is in years],
  [#R("Boats")], [("bid", "bname", "color"); primary key "bid"],
  [#R("Reserves")], [("sid", "bid", "day"); primary key ("sid", "bid", "day");
   "sid" $arrow.r$ #R("Sailors"), "bid" $arrow.r$ #R("Boats")],
)
#v(3pt)
#note[
  The composite key on `Reserves` matters. It says a sailor reserves a given boat *at most
  once per day*, but may reserve it again on another day. Consequently
  $pi_("sid", "bid")(#Re)$ is a *set* with duplicates removed: a sailor who reserved boat 103
  on three days appears once. "At least two reservations" is therefore *not* the same as
  "at least two boats"; see Q6.21 and Q6.37.
]

#heading(level: 3)[B. Library — Books, Authors and Borrowing]

Two versions are used, and every question states which one applies.

*Full schema (the default).*

#tab((auto, 1fr),
  [*Relation*], [*Schema, keys and foreign keys*],
  [#R("Book")], [("BookID", "Title", "Publisher", "Category"); PK "BookID"],
  [#R("Author")], [("AuthorID", "AuthorName"); PK "AuthorID"],
  [#R("WrittenBy")], [("BookID", "AuthorID"); PK ("BookID", "AuthorID"); FKs to Book and Author],
  [#R("Member")], [("MemberID", "MemberName"); PK "MemberID"],
  [#R("Borrow")], [("MemberID", "BookID", "BorrowDate", "ReturnDate");
   PK ("MemberID", "BookID", "BorrowDate"); FKs to Member and Book.
   "ReturnDate" $=$ #C("⊥") means *not yet returned*],
)
#v(3pt)
*Simplified schema.* $#R("Books") ("BookID", "Title")$, $#R("BookAuthors") ("BookID", "Author")$,
$#R("Borrow") ("MemberID", "BookID")$ — no dates, no publisher, one author name per row, and
the key of `Borrow` is ("MemberID", "BookID"). In the simplified schema a member borrows a
given book at most once, so "borrowed twice" is not merely hard — it is meaningless.

#heading(level: 3)[C. Hospital and Prescription — the university exam pattern]

#tab((auto, 1fr),
  [*Relation*], [*Schema, intended keys and foreign keys*],
  [#R("Doctor")], [("SSN", "FirstName", "LastName", "Specialty", "YearsOfExperience", "PhoneNum"); PK #R("SSN")],
  [#R("Patient")], [("SSN", "FirstName", "LastName", "Address", "DOB", "PrimaryDoctor_SSN");
   PK #R("SSN"); "PrimaryDoctor_SSN" $arrow.r$ #R("Doctor.SSN")],
  [#R("Medicine")], [("TradeName", "UnitPrice", "GenericFlag"); PK #R("TradeName")],
  [#R("Prescription")], [("Id", "Date", "Doctor_SSN", "Patient_SSN"); PK #R("Id");
   FKs "Doctor_SSN" $arrow.r$ #R("Doctor"), "Patient_SSN" $arrow.r$ #R("Patient")],
  [#R("Prescription_Medicine")], [("Prescription_Id", "TradeName", "NumOfUnits");
   PK ("Prescription_Id", "TradeName"); FKs to Prescription and Medicine],
)
#v(3pt)
#note[
  *Two attributes are named* "SSN": `Doctor.SSN` and `Patient.SSN`. In an unqualified
  expression this is an ambiguity error, not a stylistic preference. Every solution in Part 8
  renames the relations — $rho_#R("D") (#R("Doctor"))$, $rho_#R("P") (#R("Patient"))$ — or
  qualifies explicitly the moment both appear. The same applies to "FirstName" and
  "LastName", which both relations own.
]

#heading(level: 2)[1.3 Operator reference: arity, schema, semantics]

Throughout, $#R("R") (A_1, dots, A_n)$ and $#R("S") (B_1, dots, B_m)$ are relations, and
$"attr" (#R("R"))$ denotes the attribute set of $#R("R")$.

#table(
  columns: (auto, auto, 1.55fr, 1.5fr),
  stroke: 0.4pt + l4, inset: (x: 5pt, y: 4pt), align: (left, left, left, left),
  table.header([*Operator*], [*Arity*], [*Schema rule*], [*Semantics*]),
  [$sigma_theta (#R("R"))$], [1], [$"attr" = "attr"(#R("R"))$],
    [Keeps the tuples satisfying $theta$. Never removes attributes.],
  [$pi_(i_1, dots, i_k)(#R("R"))$], [1], [${i_1, dots, i_k} subset.eq "attr"(#R("R"))$; result has $k$ attributes in the written order],
    [Keeps the named columns and *removes duplicate rows* (set semantics).],
  [$rho_#R("X") (#R("R"))$], [1], [same attributes, new relation name $#R("X")$],
    [Renames the relation. $rho_(#R("X") (a_1, dots, a_n))(#R("R"))$ renames relation *and* attributes positionally.],
  [$#R("R") union #R("S")$], [2], [requires $n = m$ and $"dom"(A_i) = "dom"(B_i)$ for all $i$; names come from the left operand],
    [Tuples in $#R("R")$ or $#R("S")$ or both. Duplicates collapse.],
  [$#R("R") - #R("S")$], [2], [same union-compatibility rule],
    [Tuples in $#R("R")$ that are *not* in $#R("S")$. Not commutative.],
  [$#R("R") inter #R("S")$], [2], [same rule],
    [Tuples in both. Derived: $#R("R") - (#R("R") - #R("S"))$.],
  [$#R("R") times #R("S")$], [2], [$"attr"(#R("R")) union "attr"(#R("S"))$; $n dot m$ attributes, $|#R("R")| dot |#R("S")|$ tuples],
    [Every tuple of $#R("R")$ paired with every tuple of $#R("S")$. Illegal if the two share an attribute name and neither is renamed.],
  [$#R("R") bowtie_theta #R("S")$], [2], [as $times$, then $sigma_theta$],
    [$sigma_theta (#R("R") times #R("S"))$ — a *theta join*. Both copies of a compared attribute survive.],
  [$#R("R") bowtie #R("S")$], [2], [$"attr"(#R("R")) union "attr"(#R("S"))$, shared names merged once],
    [Natural join: equates every pair of same-named attributes, then removes the duplicate copy.],
  [$#R("R") div #R("S")$], [2], [requires $"attr"(#R("S")) subset.eq "attr"(#R("R"))$; result attributes $= "attr"(#R("R")) - "attr"(#R("S"))$],
    [Tuples $t$ such that for *every* tuple $s$ in $#R("S")$, $t$ concatenated with $s$ is in $#R("R")$.],
)

#v(4pt)
#note[
  *The schema rule is the examinable part.* For every intermediate relation you create, write
  its schema beside it, exactly as every worked solution in this book does.
]

#heading(level: 3)[1.4 Selection: the details that are actually examined]

Selection takes *rows* that satisfy a condition. The condition may reference any attribute
of the operand and may be built from $and$, $or$, $not$ and the comparisons $=$, $!=$,
$<$, $<=$, $>$, $>=$.

#eq[$ sigma_("rating" > 7 and "age" < 40)(#Sa) quad sigma_("color" = #C("red") or "color" = #C("green"))(#Bo) $]

Two identities are worth memorising because they justify the simplifications in Part 10:

#eq[$ sigma_(theta_1)(sigma_(theta_2)(#R("R"))) = sigma_(theta_1 and theta_2)(#R("R")) quad
     sigma_(theta_1)(#R("R") union #R("S")) = sigma_(theta_1)(#R("R")) union sigma_(theta_1)(#R("S")) $]

The second holds for union, intersection and difference — selection distributes over all
three set operations — but *not* over projection or division.

#trap[
  $sigma_("rating" = #C("high"))(#Sa)$ is a type error: "rating" is numeric. In this book
  string constants are always green and quoted, numeric constants never are. Also, $sigma$
  cannot compare attributes of *different tuples* unless those tuples were first brought
  together by a product or a self-join — see Part 3.
]

#heading(level: 3)[1.5 Projection: duplicate elimination is the whole point]

$pi_("color")(#Bo)$ does *not* return one row per boat. It returns the *set of colours that
occur*: if sixty boats are red, the output contains exactly one #C("red"). This is not a
technicality, it is the reason $pi_("sid")(#Re)$ can stand in for "sailors who have made a
reservation" with no DISTINCT keyword.

Consequences used repeatedly below:

- $pi_("sid")(#Sa) - pi_("sid")(#Re)$ is exactly "sailors with no reservation", because both
  operands are *sets of sids* with the same domain.
- $pi_("sid", "bid")(#Re)$ loses the day. Anything that needs the day must project *after*
  the day has been used, never before.
- Idempotence: $pi_("sid")(pi_("sid", "bid")(#Re)) = pi_("sid")(#Re)$.

#heading(level: 3)[1.6 Rename: the three forms]

#tab((auto, 1fr),
  [*Form*], [*Effect*],
  [$rho_#R("X") (#R("R"))$], [the relation called $#R("R")$ is called $#R("X")$; attributes unchanged],
  [$rho_(#R("X") (a_1, dots, a_n))(#R("R"))$], [relation renamed to $#R("X")$ *and* the $i$-th attribute renamed to $a_i$, in schema order],
  [$rho_(a_1 arrow.l b_1, a_2 arrow.l b_2)(#R("R"))$], [only the listed attributes are renamed, which is what you need when the relation name must stay],
)
#v(3pt)
Self-joins *require* a rename on at least one side; otherwise $#Sa times #Sa$ is ill-formed
because every attribute name is duplicated. This one-mark question appears in almost every
paper.

#heading(level: 2)[1.7 Union compatibility, and why it is always tested]

$#R("R") union #R("S")$, $#R("R") - #R("S")$ and $#R("R") inter #R("S")$ are defined only if

+ $#R("R")$ and $#R("S")$ have the *same number* of attributes, and
+ the $i$-th attribute of $#R("R")$ has the *same domain* as the $i$-th attribute of $#R("S")$,
  for every $i$.

Attribute *names* need not agree; the result takes its names from the left operand. This is
why the standard solution to "sailors who never reserved a red boat" must project *both*
sides to the same attribute list before subtracting:

#eq[$ pi_("sid")(#Sa) - pi_("sid")(#Re bowtie sigma_("color" = #C("red"))(#Bo)) $]

The left operand has schema ("sid"); the right operand has been reduced to ("sid") as well.
Subtracting a two-attribute relation from a one-attribute relation is the single most common
error in the subject.

#trap[
  $#Sa - #Re$ is not union compatible: four attributes against three, and only "sid" in
  common. Worse, $pi_("sid", "sname")(#Sa) - pi_("sid")(#Re)$ is *also* illegal (two
  attributes against one). Always project both sides to the *same list*.
]

#heading(level: 2)[1.8 Cartesian product, theta join, equijoin, natural join]

Given $#R("R") (A, B)$ and $#R("S") (C, D)$, the product $#R("R") times #R("S")$ has schema
$(A, B, C, D)$ and $|#R("R")| dot |#R("S")|$ tuples. If the two relations share an attribute
name, the product is illegal until one side is renamed: the result would have two attributes
of the same name and no way to refer to either.

#tab((auto, 1fr),
  [*Join form*], [*Meaning and schema*],
  [$#R("R") bowtie_theta #R("S")$],
    [$sigma_theta (#R("R") times #R("S"))$. Schema is the concatenation of both. If $theta$
     names an attribute that both relations own, it is ambiguous unless qualified.],

  [$#R("R") bowtie_("R".A = "S".A) #R("S")$],
    [*Equijoin* on $A$. Both copies of $A$ remain in the schema; project one away if the
     question asks for a clean schema.],

  [$#R("R") bowtie #R("S")$],
    [*Natural join*. Legal in a well-posed question only when the shared attributes are
     exactly the ones that should be equated. One copy of each shared attribute survives.],

  [$rho_#R("R1") (#R("R")) times rho_#R("R2") (#R("R"))$],
    [the *self-product*, the workhorse of every "pairs", "same" and "maximum" query in
     Parts 3 and 5.],
)
#v(3pt)
#note[
  In *Database System Concepts* the unadorned $bowtie$ denotes the natural join, and it
  degenerates to $times$ when the operands share no attribute name. This book follows that
  convention. When a question needs an equijoin on attributes that are *not* identically
  named — for example `Doctor.SSN = Patient.PrimaryDoctor_SSN` — an explicit theta join is
  written and the duplicated column is projected away.
]

#heading(level: 2)[1.9 Division: the only operator that answers "for all"]

*Definition.* Let $#R("R") (X, Y)$ and $#R("S") (Y)$, where $Y$ is the entire schema of
$#R("S")$ and a subset of the schema of $#R("R")$. Then

#eq[$ #R("R") div #R("S") = { t in pi_X (#R("R")) : forall s in #R("S"), (t, s) in #R("R") } $]

so $"attr"(#R("R") div #R("S")) = X = "attr"(#R("R")) - "attr"(#R("S"))$.

The fundamental identity — memorise it, because it *is* the answer to "derive division from
the other five operators":

#eq[$ #R("R") div #R("S") = pi_X (#R("R")) - pi_X ( (pi_X (#R("R")) times #R("S")) - #R("R") ) $]

Read it as: take every candidate answer $t$; form all pairs $(t, s)$ that a perfect answer
would have to contain; subtract the pairs actually present; every $t$ that still has a missing
pair is disqualified; remove those from the candidates.

Three practical rules for division in exams:

+ *The divisor must have exactly the schema you want to quantify over.* "all boats" means
  $pi_("bid")(#Bo)$; "all red boats" means $pi_("bid")(sigma_("color" = #C("red"))(#Bo))$;
  "all boats reserved by sailor 22" means $pi_("bid")(sigma_("sid" = 22)(#Re))$.
+ *The dividend must already be projected to exactly (answer attributes + divisor
  attributes).* If it carries an extra column, division silently answers a different
  question, because the extra column survives into the result.
+ *Empty divisor edge case.* If $#R("S")$ is empty, every tuple of $pi_X(#R("R"))$ is an answer,
  even when $#R("R")$ is empty. That is the vacuous truth which makes "sailors who reserved
  every red boat" return *all sailors* when no red boat exists. Examiners award a mark for
  noticing it; see Q4.19.

#heading(level: 2)[1.10 The derived operators you are allowed to use]

Only $pi$, $sigma$, $rho$, $union$, $-$ and $times$ are primitive; $inter$, $bowtie$ and
$div$ are derived and must be expandable on demand.

#tab((auto, 1fr),
  [*Derived form*], [*Primitive definition*],
  [$#R("R") inter #R("S")$], [$#R("R") - (#R("R") - #R("S"))$],
  [$#R("R") bowtie_theta #R("S")$], [$sigma_theta (#R("R") times #R("S"))$],
  [$#R("R") bowtie #R("S")$], [$pi_("attr"(#R("R")) union "attr"(#R("S"))) (#R("R") bowtie_("R".a_1 = "S".a_1 and dots) #R("S"))$ over the shared attributes $a_1, dots$],
  [$#R("R") div #R("S")$], [$pi_X (#R("R")) - pi_X ( pi_X (#R("R")) times #R("S") - #R("R") )$, with $X = "attr"(#R("R")) - "attr"(#R("S"))$],
  [$sigma_(theta_1 or theta_2)(#R("R"))$], [$sigma_(theta_1)(#R("R")) union sigma_(theta_2)(#R("R"))$, valid because both results are subsets of the same relation],
  [*semijoin* / *antijoin*], [*Not classical.* Semijoin is $pi_("attr"(#R("R")))(#R("R") bowtie #R("S"))$; antijoin is $#R("R") - pi_("attr"(#R("R")))(#R("R") bowtie #R("S"))$. Usable as an annotation, never as the main answer in a classical-RA paper.],
)

#heading(level: 2)[1.11 What set semantics costs, and where aggregates are forbidden]

Classical relational algebra is defined over *sets*. There is no duplicate count, no order,
and therefore:

- "how many", "more than 20 prescriptions", "total units", "average price", "rank by salary"
  are *not first-order expressible*. They need the extended grouping operator
  $gamma_("group", "agg"("attr"))(#R("R"))$ or SQL's `COUNT`/`SUM`/`AVG`.
- "maximum" and "minimum" *are* expressible, but only as a set difference against a
  self-join, and only as *values*. "The most expensive medicine" is a maximum-of-values
  question and is expressible; "the book borrowed the most times" is a counting question in
  disguise and is not.
- "exactly $k$" for a *fixed numeral* $k$ is expressible without aggregation (Q5.26(a), §10.6),
  because it is a Boolean combination of existence conditions over *distinct* tuple
  variables. "Exactly $k$" where $k$ is a *stored attribute value* is not.

That distinction — *fixed cardinality is expressible, computed cardinality is not* — is
worth a full question in most papers and is treated systematically in Q5.22–Q5.27 and §10.6.

#heading(level: 2)[1.12 Evaluating an expression: precedence and walking the tree]

There is no universal precedence agreement, so every compound expression in this book is
fully parenthesised. The *de facto* convention is

#eq[$ "precedence": quad pi, sigma, rho quad > quad times, bowtie quad > quad inter quad > quad union , - $]

with binary operators left-associative. When in doubt add brackets: an examiner cannot mark
a bracketed expression wrong for being explicit, but a badly bracketed expression that
changes the meaning loses the marks for the actual query.

*Read an expression bottom-up.* At every node ask: what is its schema, and which English
condition does it implement? Every worked solution in Parts 6–8 does this node by node using
names like $#R("R")_1$, $#R("R")_2$, $#R("Ans")$.

#heading(level: 2)[1.13 The recipe: seven steps that work on any question]

#keybox[
+ *Underline the quantifier words.* at least one / all / only / none / exactly one / more
  than / the maximum / the same / both / either.
+ *Write the answer schema.* ("names" $arrow.r$ "sname"; "sailors" $arrow.r$ "sid";
  "pairs" $arrow.r$ two copies of an identifier).
+ *Write the source schema*: which relations actually carry those attributes.
+ *Pick the pattern* from §1.14. The quantifier word decides the pattern; everything else is
  plumbing.
+ *Build inner to outer*, naming each intermediate relation and writing its schema beside it.
+ *Check union compatibility* at every set operation, and *check for ambiguity* at every join.
+ *Check the edge cases*: empty relations, ties, duplicates, "no records at all", and whether
  the query is expressible at all.
]

#heading(level: 2)[1.14 The 20-pattern catalogue]

Every question in Parts 2–9 is an instance of one of these twenty shapes. Learn the shape,
not the example.

#table(
  columns: (auto, 1.5fr, 1.15fr, 1fr),
  stroke: 0.4pt + l4, inset: (x: 4.5pt, y: 4pt), align: (left, left, left, left),
  table.header([*No.*], [*English trigger*], [*Shape*], [*Where solved*]),
  [1], [at least one; some; who did X], [$pi_"id"(#R("A") bowtie #R("B") bowtie sigma_theta(#R("C")))$], [Q2.6, Q6.4],
  [2], [none; never; who did not], [$pi_"id"(#R("A")) - pi_"id"(#R("A") bowtie #R("B") bowtie sigma_theta(#R("C")))$], [Q3.9, Q6.12],
  [3], [both X and Y], [pattern 1 twice, then $inter$], [Q6.10, Q7.12],
  [4], [X but not Y], [pattern 1 for X minus pattern 1 for Y], [Q6.11, Q7.13],
  [5], [only X], [all minus the ones related to a non-X], [Q6.31, Q7.31],
  [6], [all; every; each], [division, or pattern 2 with the counter-example set], [Q4.1–Q4.22],
  [7], [pairs; same; more than each other], [$rho$ twice, $times$, $sigma$ on the two copies], [Q3.4, Q6.15],
  [8], [maximum; most expensive; oldest], [$#R("R") - pi_"attr"(sigma_("R1".a < "R2".a)(rho_("R1")(#R("R")) times rho_("R2")(#R("R"))))$], [Q5.1, Q5.8],
  [9], [minimum; cheapest; earliest], [pattern 8 with the inequality reversed], [Q5.2, Q5.11],
  [10], [second highest], [maximum of the relation after removing the maximum], [Q5.5, Q5.6],
  [11], [k-th highest, ties preserved], [$k-1$ nested "remove the maximum" steps], [Q5.7],
  [12], [per-group maximum], [no better tuple exists *within the same group*], [Q5.14–Q5.16],
  [13], [exactly one], [pattern 1 minus "at least two"], [Q5.24],
  [14], [at least two], [self-join of the relationship with $!=$ on the identifiers], [Q5.23, Q6.21],
  [15], [exactly the same set], [two divisions: $A div B$ and $B div A$], [Q7.33, Q8.21],
  [16], [all ... that satisfy C], [divide by $pi(sigma_C(dots))$], [Q4.12, Q6.35],
  [17], [only ... that satisfy C], [pattern 5 applied to $sigma_(not C)$], [Q6.33, Q8.14],
  [18], [maximum within a selection], [apply $sigma$ first, then pattern 8], [Q5.18, Q5.19],
  [19], [same set of X for two identifiers], [pattern 15], [Q7.33],
  [20], [count / sum / average / "more than n"], [*not expressible*; needs $gamma$], [Q5.27, Q7.24, Q8.3],
)

#heading(level: 2)[1.15 The five words that decide the answer]

#table(
  columns: (auto, 1fr, 1fr),
  stroke: 0.4pt + l4, inset: (x: 5pt, y: 4pt), align: (left, left, left),
  table.header([*Word*], [*Logical form*], [*Operator that implements it*]),
  [at least one], [$exists$], [join, then $pi$],
  [none / never], [$not exists$], [set difference],
  [all / every], [$forall$], [division, or $-$ against a counter-example set],
  [only], [$forall$ over the *complement*], [$-$ of the "bad" tuples],
  [exactly one], [$exists$ and not (at least two)], [difference of joins],
)
#v(3pt)
These five are not interchangeable, and papers deliberately mix them. "Has all required
books" is a $forall$; "has at least one required book" is an $exists$; "has only required
books" is a $forall$ over the *complement* of the required set. §10.2 puts the confusable
pairs side by side.

#heading(level: 2)[1.16 Assumptions declared once, used everywhere]

+ *Set semantics.* No duplicates; every operator is a set operator; $pi$ eliminates
  duplicates.
+ *No NULLs in the classical core.* Where a schema has an optional value — only
  `Borrow.ReturnDate` in this book — we encode "not yet returned" by an explicit constant
  #C("⊥"), and say so. A question that stipulates SQL NULLs is answered with the classical
  expression *plus* an explicit statement of the convention; see Q7.30.
+ *Keys are as declared.* "Same record" is decided by the primary key; "same value" is
  decided by the attribute. That difference is exactly what separates Q6.15 from Q6.16.
+ *Ties are preserved.* No expression in this book silently returns "one of the maximum";
  where a maximum is asked for, all of them are returned. When a question demands exactly one
  row, we say plainly that classical relational algebra cannot choose deterministically.
+ *Domains are compatible* whenever a comparison is made: numbers with numbers, strings with
  strings, and dates in ISO form $"YYYY-MM-DD"$, whose lexicographic order is chronological.

#heading(level: 2)[1.17 Coverage map]

This table is the contract for the book; Part 12 repeats it with tick marks and answer
references.

#table(
  columns: (1fr, auto, auto, auto),
  stroke: 0.4pt + l4, inset: (x: 5pt, y: 3.4pt), align: (left, center, center, center),
  table.header([*Category*], [*Part*], [*Questions*], [*Checklist*]),
  [Selection, projection, rename], [2], [Q2.1–Q2.14], [C1],
  [Product, theta join, equijoin, natural join], [2–3], [Q2.15–Q2.20, Q3.1–Q3.3], [C2],
  [Union, intersection, difference, union compatibility], [3], [Q3.5–Q3.14], [C3],
  [Self-joins, pairs, "same as"], [3, 6], [Q3.4, Q6.15–Q6.21], [C4],
  [Negative queries: never, none, without, except], [3], [Q3.9–Q3.14], [C5],
  [Division and universal quantification], [4], [Q4.1–Q4.22], [C6],
  [Maximum, minimum, ties, k-th highest], [5], [Q5.1–Q5.13], [C7],
  [Group-wise extremes, ranking, exactly-k], [5], [Q5.14–Q5.27], [C8],
  [Sailors–Boats complete bank], [6], [Q6.1–Q6.37], [C9],
  [Library complete bank], [7], [Q7.1–Q7.33], [C10],
  [Hospital complete bank incl. the five exam questions], [8], [Q8.1–Q8.27], [C11],
  [Mixed multi-technique queries], [9], [Q9.1–Q9.14], [C12],
  [Equivalence, error detection, simplification], [10], [Q10.1–Q10.18], [C13],
  [Not expressible in classical RA], [5, 7, 8, 10], [Q5.27, Q7.24, Q8.3, Q10.16–Q10.18], [C14],
)
