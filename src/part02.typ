#import "lib.typ": *

#let Sa = R("Sailors")
#let Re = R("Reserves")
#let Bo = R("Boats")
#let Emp = R("Emp")
#let Dept = R("Dept")

#part(2, "Basic university-level questions", blurb: [
  *What this part fixes.* One-relation queries (selection, projection, rename), the two-relation
  join, the Cartesian product, and the three ways a question can be *almost* right. Schema used:
  Sailors–Boats–Reserves for Q2.1–Q2.14 and Q2.17–Q2.20, and the employee schema
  $R("Emp")("eid", "ename", "sal", "deptno")$ / $R("Dept")("deptno", "dname", "loc")$ for Q2.15–Q2.16.
])

#heading(level: 2)[2.1 One relation: selection and projection]

#q[2.1][List the complete contents of the relation `Sailors`.][
#ans[ $#Sa$ ]
#why[ No operator is needed. In an exam, write the relation name and *state its schema*:
$(#A("sid"), #A("sname"), #A("rating"), #A("age"))$. A bare relation name is a legal
relational-algebra expression — the trivial query. ]
#trap[ Writing $pi_("sid", "sname", "rating", "age")(#Sa)$ is also correct and is *not*
wrong, but it is not "all tuples in the stored order": relational algebra has no order, and
$pi$ over all attributes returns the same set. Do not claim it preserves input order. ]
]

#q[2.2][Find the names of all sailors.][
#ans[ $ pi_("sname")(#Sa) $ ]
#schem[Result schema: $("sname")$. One row per *distinct* name — two sailors called "Jones"
produce one row. That is correct set semantics, not a bug.]
#why[ "Names" fixes the projection list; no condition is given, so no $sigma$. ]
#trap[ The classic error is $pi_("sname")(#Re)$ — `Reserves` has no `sname`. Projection can
only name attributes that are in the operand's schema. ]
]

#q[2.3][Find all sailors whose rating is greater than 7.][
#ans[ $ sigma_("rating" > 7)(#Sa) $ ]
#schem[Schema unchanged: $("sid", "sname", "rating", "age")$.]
#why[ "Greater than" is a comparison on a numeric attribute, so $sigma$ alone suffices. The
question asks for *sailors*, not names, so nothing is projected away. ]
#trap[ $sigma_("rating" > #C("7"))(#Sa)$ quotes a number — a type error. Also
$sigma_("rating" > 7)(pi_("sname")(#Sa))$ is illegal: `rating` has been projected away
before the selection could use it. *Select before you project.* ]
]

#q[2.4][Find the names and ages of sailors whose age is at least 30 but not more than 40.][
#ans[ $ pi_("sname", "age")(sigma_("age" >= 30 and "age" <= 40)(#Sa)) $ ]
#schem[Result schema: $("sname", "age")$.]
#why[ Two comparisons joined by $and$ inside one selection; the projection list follows the
order the question asked for. ]
#trap[ $sigma_(30 <= "age" <= 40)$ is not standard relational-algebra syntax in most
textbooks; write $sigma_("age" >= 30 and "age" <= 40)$. Also, "at least" is $>=$ (not $>$)
and "not more than" is $<=$. ]
]

#q[2.5][Find the sailors whose rating is either 8 or 10.][
#ans[ $ sigma_("rating" = 8 or "rating" = 10)(#Sa) $ ]
#schem[Schema unchanged.]
#why[ One selection with a disjunction. Equivalently
$sigma_("rating" = 8)(#Sa) union sigma_("rating" = 10)(#Sa)$, because the two sets of tuples
are both subsets of `Sailors` and are disjoint — the union cannot create a tuple that fails
the condition. ]
#trap[ $sigma_("rating" = 8 and "rating" = 10)(#Sa)$ is empty, not "either". $and$ inside a
single selection applies to the *same* tuple; a tuple cannot have two ratings. ]
]

#q[2.6][Find the names of sailors who have reserved boat 103.][
#ans[ $ pi_("sname")(sigma_("bid" = 103)(#Re) bowtie #Sa) $ ]
#schem[$sigma_("bid" = 103)(#Re)$ has schema $("sid", "bid", "day")$. The natural join with
`Sailors` equates `sid`, giving $("sid", "bid", "day", "sname", "rating", "age")$; the
projection leaves $("sname")$.]
#why[ Two relations are involved — the reservation and the sailor's name — so a join on the
common attribute `sid` is unavoidable. Selecting on `bid` *before* joining keeps the
intermediate relation small, which is also the efficient plan. ]
#trap[ Writing $pi_("sname")(sigma_("bid" = 103)(#Sa))$ fails: `Sailors` has no `bid`.
Writing $pi_("sname")(#Sa times sigma_("bid" = 103)(#Re))$ is legal but returns the same
answer only because the product is filtered by nothing — it pairs *every* sailor with the
reservation. The natural join is what enforces "the same sailor". ]
]

#q[2.7][Find the names of sailors who have reserved a red boat.][
#ans[ $ pi_("sname")(#Sa bowtie #Re bowtie sigma_("color" = #C("red"))(#Bo)) $ ]
#schem[$(#A("sid"), #A("sname"), #A("rating"), #A("age"), #A("bid"), #A("day"), #A("bname"), #A("color"))$
before projection; after projection, $("sname")$.]
#why[ "A red boat" is an existential condition: there must *exist* a reservation row linking
this sailor to a boat whose colour is red. A chain of natural joins realises the existential
quantifier; the projection then removes the witnesses. This is pattern 1 of §1.14. ]
#trap[ The join order is free but the *joins are not optional*. Dropping `Sailors` gives boat
names, not sailor names; dropping `Reserves` gives the cartesian product of sailors and red
boats, i.e. every sailor. ]
]

#q[2.8][Find the names of sailors who reserved a boat on 2019-10-01.][
#ans[ $ pi_("sname")(#Sa bowtie sigma_("day" = #C("2019-10-01"))(#Re)) $ ]
#schem[Result schema $("sname")$.]
#why[ The date is an attribute of `Reserves`, so the selection is pushed onto `Reserves` and
only the `sname` lookup needs the join with `Sailors`. ]
#trap[ Dates in these notes are ISO strings, so string equality is correct. If your course
stores dates as $A("DD")"/"A("MM")"/"A("YYYY")$ strings, comparison is still equality, but
*range* comparisons would then sort wrongly — see Q7.25. ]
]

#q[2.9][Find all the colours in which boats exist.][
#ans[ $ pi_("color")(#Bo) $ ]
#schem[Result schema: $("color")$, a set of colours.]
#why[ Projection with duplicate elimination is exactly "the distinct values of an
attribute". This is the one place where a student who is used to SQL must resist adding
anything: there is no DISTINCT keyword in relational algebra because duplicate removal is
built into $pi$. ]
#trap[ Asking for "all colours" of a *specific* boat is different: that is
$pi_("color")(sigma_("bid" = 103)(#Bo))$, which returns at most one row. ]
]

#q[2.10][Find the sids and names of sailors whose rating is 10, together with the boats they
have reserved.][
#ans[ $ pi_("sid", "sname", "bid")(sigma_("rating" = 10)(#Sa) bowtie #Re) $ ]
#schem[$("sid", "sname", "bid")$. Note `rating` is used in the selection but is not in the
answer, so it is projected away *after* being used.]
#why[ The selection is applied to `Sailors` *before* the join so that `rating` is still
available. This is the single most frequently examined ordering point in Part 2. ]
#trap[ $pi_("sid", "sname", "bid")(sigma_("rating" = 10)(#Sa bowtie #Re))$ is also correct —
selection distributes over the join because `rating` survives the join. But
$sigma_("rating" = 10)(pi_("sid", "sname", "bid")(#Sa bowtie #Re))$ is a *type error*:
`rating` is no longer in the schema after the projection. Rule: *a condition may only
mention attributes present in the operand's schema.* ]
]

#q[2.11][Using only $pi$ and $sigma$, express "the sname of every sailor who is older than
every sailor with rating 10". Is it possible without a join?][
#ans[ *No.* A selection can only test attributes of one tuple, so it cannot compare one
sailor's age with another sailor's age. A self-join (or a division-style difference) is
required:
$ pi_("sname")(#Sa) - pi_("sname")(#Sa bowtie (pi_("sid")(#Sa) - pi_("sid")(sigma_("age" > 60)(#Sa)))) $
]
#why[ This is a *conceptual* question, and examiners use it to test whether you know that
$sigma$ is tuple-local. The second expression is only a sketch: it hard-codes a threshold.
The correct general expression needs a self-product — see Q5.20 for the fully general form. ]
#trap[ Do not answer "yes, with a nested selection". Nested $sigma$s compose conditions on
the *same* tuple; they never introduce a second tuple variable. ]
]

#q[2.12][Explain why $pi_("sname")(#Sa) - pi_("sname")(sigma_("rating" < 8)(#Sa))$ does *not*
compute "names of sailors whose rating is at least 8".][
#ans[ It computes "names that appear on some sailor with rating $>= 8$ *and* do not
appear on any sailor with rating $< 8$". Both are sets of *names*, and names are not keys. ]
#why[ `sname` is not a key of `Sailors`: two different sailors may share a name. If "Jones"
has one tuple with rating 9 and another with rating 7, then Jones appears on both sides and
is subtracted away, even though a rating-$>=8$ Jones exists. ]
#schem[Both operands have schema $("sname")$, so the expression is *well-typed* — the error
is semantic, not syntactic. That is exactly why it is a favourite exam trap.]
#trap[ The safe rule: *do set operations on keys, not on descriptive attributes.* Write
$pi_("sid")(#Sa) - pi_("sid")(sigma_("rating" < 8)(#Sa))$ and join back to `Sailors` for the
name. ]
]

#heading(level: 2)[2.2 Rename and aliasing]

#q[2.13][Give three different correct ways to write "the names of sailors with rating 8",
using $rho$ at least once.][
#ans[ (i) $pi_("sname")(sigma_("rating" = 8)(#Sa))$;
(ii) $pi_("sname")(sigma_("rating" = 8)(rho_("S")(#Sa)))$;
(iii) $pi_(#A("S.sname"))(sigma_(#A("S.rating") = 8)(rho_("S")(#Sa)))$ ]
#schem[All three return $("sname")$. In (iii) the qualified names are needed only if another
relation with the same attribute names is in scope.]
#why[ $rho$ changes only the *name* used to refer to the relation; it does not change tuples
or schema. Renaming is therefore always semantics-preserving when the new name is fresh. ]
#trap[ Renaming to a name already in scope, e.g. $rho_("Sailors")(#Sa)$ inside an expression
that also uses the original `Sailors`, creates an ambiguity rather than an alias. Use fresh
names such as $R("S")$, $R("S1")$, $R("S2")$. ]
]

#q[2.14][Write the expression for "names of sailors who are older than 30" so that the
result's attribute is called `name` instead of `sname`.][
#ans[ $ rho_("name" arrow.l "sname")(pi_("sname")(sigma_("age" > 30)(#Sa))) $
or equivalently $pi_("name")(rho_("name" arrow.l "sname")(sigma_("age" > 30)(#Sa)))$ ]
#schem[Result schema: $("name")$.]
#why[ The third form of $rho$ renames *attributes only*, which is what is wanted when the
relation name is irrelevant but the output column must match a specification. ]
#trap[ $rho_("name")(pi_("sname")(dots))$ renames the *relation* to "name", not the attribute.
The arrow form is the attribute rename. ]
]

#heading(level: 2)[2.3 Cartesian product, theta join, equijoin, natural join]

#q[2.15][Find every (employee, department-name) pair such that the employee works in that
department. Then find every *possible* pair of employees and departments, and explain the
difference.][
#ans[ $ "Working pairs": quad pi_("ename", "dname")(#Emp bowtie_(#A("Emp.deptno") = #A("Dept.deptno")) #Dept) $
$ "All possible pairs": quad #Emp times #Dept $ ]
#schem[The product has schema
$("eid", "ename", "sal", "deptno", "deptno", "dname", "loc")$ — `deptno` appears *twice*,
which is exactly why the product must be renamed or qualified before it can be used. The
theta join keeps both copies too; only the natural join merges them.]
#why[ The product pairs *every* employee with *every* department, including combinations
that do not correspond to employment. The theta join adds the predicate that makes the pair
meaningful. Cardinalities: $|#Emp| dot |#Dept|$ versus at most $|#Emp|$. ]
#trap[ $#Emp times #Dept$ is only legal here because the shared attribute `deptno` is
*qualified* in any subsequent reference; strictly, the definitions in SKS require the
operands to have disjoint attribute sets. If you must write the product, rename first:
$rho_("E")(#Emp) times rho_("D")(#Dept)$. ]
]


#q[2.16][Find the names of employees who earn more than *every* employee in department 10.][
#ans[ Let $R_1 = rho_("E")(#Emp) times rho_("D10")(sigma_("deptno" = 10)(#Emp))$ and
$R_2 = pi_("E.eid")(sigma_("E.sal" <= "D10.sal")(R_1))$. Then
$ pi_("ename")(#Emp bowtie (pi_("eid")(#Emp) - R_2)) $ ]
#schem[$R_1$: $("E.eid", "E.ename", "E.sal", "E.deptno", "D10.eid", "D10.ename", "D10.sal", "D10.deptno")$.
$R_2$: $("E.eid")$ — employees who are beaten by, or equal to, *someone* in department 10.
The final join has schema $("eid", "ename", "sal", "deptno")$, projected to $("ename")$.]
#why[ "More than every $x$" is "$not$ ($<=$ some $x$)". The $sigma$ finds the witnesses that
disqualify an employee; set difference removes exactly those employees. This is pattern 6
(the counter-example method) applied without division, because the condition is a comparison
rather than a membership test. ]
#trap[ Two errors are common. (i) Using $pi_("ename")$ for the difference: two employees may
share a name, so the subtraction removes innocent employees — always subtract on the *key*,
`eid`, then join back for the name. (ii) Using $<$ instead of $<=$ in $R_2$: the employee
who *equals* the department-10 maximum must also be excluded, because the question says
*more than every*, not *at least*. ]
]

#q[2.17][State the difference between the natural join and the equijoin of `Emp` and `Dept`,
and give the schema of each.][
#ans[ $ "Equijoin": quad #Emp bowtie_(#A("Emp.deptno") = #A("Dept.deptno")) #Dept quad
"Natural join": quad #Emp bowtie #Dept $ ]
#schem[Nothing: the two expressions return the *same tuples*. They differ in schema: the
equijoin keeps two `deptno` columns, the natural join keeps one.]
#why[ The natural join is defined as an equijoin on *all* same-named attributes followed by
removal of the duplicate column. Here the only shared name is `deptno`, so the two coincide
on tuples. If the relations also shared an unrelated name — say both had `name` — the natural
join would equate that too, which is usually a bug. ]
#trap[ In an exam, "natural join is an equijoin" is only half a mark. The full answer is:
*equijoin on all common attributes, then project away one copy of each common attribute.*
And if the relations share no attribute name, the natural join degenerates to a Cartesian
product — a fact examiners like to test. ]
]

#q[2.18][Find the names of sailors who reserved a red boat, together with the boat name, using
a three-relation join. State the schema at each step.][
#ans[ $ pi_("sname", "bname")(sigma_("color" = #C("red"))(#Bo) bowtie #Re bowtie #Sa) $ ]
#schem[After $sigma$: $("bid", "bname", "color")$.
After the first join with `Reserves` on `bid`: $("bid", "bname", "color", "sid", "day")$.
After the second join with `Sailors` on `sid`: adds $("sname", "rating", "age")$.
After projection: $("sname", "bname")$.]
#why[ Each natural join consumes exactly one shared attribute, so a chain of joins walks the
foreign-key path $R("Boats") arrow.r R("Reserves") arrow.r R("Sailors")$. Left-deep order
(boat first) is the cheapest because the selection shrinks it to red boats only. ]
#trap[ The joins must be *natural* on the right attribute. If the schema used different names
(say `Reserves.boatid`), the natural join would silently degenerate into a product and the
answer would multiply rows. Always check which attributes are shared. ]
]

#q[2.19][Find the sids of sailors who reserved a boat before 2019-10-05 and whose rating is
at least 8.][
#ans[ $ pi_("sid")(sigma_("rating" >= 8)(#Sa) bowtie sigma_("day" < #C("2019-10-05"))(#Re)) $ ]
#schem[Result schema: $("sid")$.]
#why[ Both conditions are tuple-local to their own relation, so both selections are pushed
down to the leaves. Only then is the join performed. Pushing selections down is always safe
(§10.5) and reduces the intermediate size. ]
#trap[ Do not put both conditions in one $sigma$ over the join result and then forget that
the attribute `sid` is ambiguous — after a natural join there is only one `sid`, so
$sigma_("rating" >= 8 and "day" < #C("2019-10-05"))(#Sa bowtie #Re)$ is legal too. Either is
accepted; the pushed-down version is better style. ]
]

#q[2.20][Using $times$ and $sigma$ only (no $bowtie$), express Q2.7.][
#ans[ $ pi_("sname")(sigma_("Sailors.sid" = "Reserves.sid" and "Reserves.bid" = "Boats.bid" and "color" = #C("red"))(#Sa times #Re times #Bo)) $ ]
#schem[The product has 4 + 3 + 3 = 10 attributes; the result is $("sname")$.]
#why[ This is the definition of the join expanded into the primitive operators, and it is
what an examiner is checking when the question says "using only the primitive operations".
The three conjuncts are: the two foreign-key equalities plus the colour filter. ]
#trap[ $#Sa times #Re times #Bo$ is *ambiguous* as written — all three relations share no
name except through `sid`/`bid`, but `Sailors` and `Reserves` both have `sid`, and
`Reserves` and `Boats` both have `bid`. A product is legal only after renaming, e.g.
$rho_("S")(#Sa) times rho_("R")(#Re) times rho_("B")(#Bo)$, or if you qualify every
reference as above. When in doubt, rename. ]
]

#heading(level: 2)[2.4 The most common Part-2 errors, collected]

#tab((auto, 1fr),
  [*Wrong expression*], [*Why it is wrong, and the fix*],
  [$pi_("sname")(#Re)$], [`Reserves` has no `sname`. Project only attributes that exist; join first.],
  [$sigma_("rating" > #C("7"))(#Sa)$], [numeric constant quoted as a string. Remove the quotes.],
  [$sigma_("color" = #C("red"))(pi_("bid")(#Bo))$], [type error: `color` was projected away. Select before projecting.],
  [$#Sa minus #Re$], [not union compatible (4 vs 3 attributes, only `sid` shared). Project both sides to the same list.],
  [$#Sa times #Sa$], [ambiguous attribute names. Rename one copy with $rho$.],
  [$#Sa bowtie #Bo$], [natural join on no shared attribute = Cartesian product: 3 × 3 attributes, every pair. Not an error, but almost never what is wanted.],
  [$#Sa bowtie_(#A("sid") = #A("bid")) #Bo$], [compares a sailor id with a boat id. Usually a thinko; check the join attribute.],
  [$pi_("sname", "sname")(#Sa)$], [duplicate attribute in a projection list. Write each attribute once.],
)
