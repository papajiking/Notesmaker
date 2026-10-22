#import "lib.typ": *

#let Sa = R("Sailors")
#let Re = R("Reserves")
#let Bo = R("Boats")
#let Emp = R("Emp")
#let Do = R("Doctor")
#let Pa = R("Patient")
#let Pr = R("Prescription")
#let Pm = R("Prescription_Medicine")
#let Med = R("Medicine")

#part(9, "Advanced mixed questions combining multiple techniques", blurb: [
  *What this part fixes.* Real exam questions are rarely one pattern. They stack a quantifier
  on a join on a negation. Each solution here names the *patterns* it stacks (§1.14), states the
  intermediate schemas, and shows where a naive composition breaks. The schemas used are
  Sailors–Boats–Reserves and Hospital–Prescription.
])

#heading(level: 2)[9.1 Two quantifiers in one sentence]

#q[9.1][Find the names of sailors with rating above 8 who have reserved every green boat.][
#ans[ $ pi_("sname")( sigma_("rating" > 8)(#Sa) bowtie ( pi_("sid", "bid")(#Re) div pi_("bid")(sigma_("color" = #C("green"))(#Bo)) ) ) $ ]
#schem[The division returns $("sid")$; the selection on `Sailors` returns the full sailor
schema; the natural join is on `sid`; the result is $("sname")$. ]
#why[ Patterns stacked: 8 (selection) + 6 (division) + 1 (join). The selection restricts the
*answer*, not the quantification, so it is applied to `Sailors` outside the division. ]
#trap[ Applying the rating filter inside the dividend —
$pi_("sid", "bid")(sigma_("rating" > 8)(#Sa) bowtie #Re) div dots$ — also works *here* because
the join preserves `sid` and `bid`, but it is fragile: if the filter mentioned an attribute that
did not survive the join, it would silently change the meaning. The intersection form
$("division result") inter pi_("sid")(sigma_("rating" > 8)(#Sa))$ is the safest. ]
]

#q[9.2][Find the names of sailors who have reserved a boat that no sailor with rating 10 has
reserved.][
#ans[ Let $R("Taken") = pi_("bid")(#Re bowtie pi_("sid")(sigma_("rating" = 10)(#Sa)))$ be the boats
reserved by at least one rating-10 sailor, and
$R("Free") = pi_("bid")(#Bo) - R("Taken")$ the boats nobody with rating 10 has reserved. Then
$ pi_("sname")(#Sa bowtie pi_("sid")(#Re bowtie R("Free"))) $. ]
#schem[$R("Taken")$ and $R("Free")$: $("bid")$. The join with `Reserves` gives $("sid")$.
Result: $("sname")$. ]
#why[ Patterns stacked: 2 (difference) + 1 (join) + 8 (selection). The universal-looking phrase
"no sailor with rating 10" is *not* a universal quantifier over sailors — it is a negative
existential over the boat's reservations. Read the English: there is no rating-10 sailor who
reserved *this* boat. ]
#trap[ $pi_("bid")(#Bo) - pi_("bid")(#Re)$ would mean "never reserved by anyone", a much stronger
condition. And dropping the intermediate $R("Taken")$ step — writing
$pi_("bid")(#Bo) - pi_("bid")(#Re) times dots$ — is not even well-typed. Build the set in two
named steps. ]
]

#q[9.3][Find the names of sailors who have reserved every boat that has ever been reserved by a
sailor younger than 20, and who are themselves older than 40.][
#ans[ Let $R("YoungBoats") = pi_("bid")(#Re bowtie pi_("sid")(sigma_("age" < 20)(#Sa)))$.
Then $ pi_("sname")( sigma_("age" > 40)(#Sa) bowtie ( pi_("sid", "bid")(#Re) div R("YoungBoats") ) ) $. ]
#schem[$R("YoungBoats")$: $("bid")$. Division: $("sid")$. Result: $("sname")$. ]
#why[ The divisor is a *derived* set computed through two joins — the most common shape in
advanced questions. The outer selection is independent of the division and is applied to
`Sailors`. ]
#trap[ If $R("YoungBoats")$ is empty (no sailor younger than 20 has reserved anything), the
division returns every sailor in the dividend's projection — and the outer selection then
returns every sailor older than 40 who has made any reservation. Vacuous truth; state it. ]
]

#heading(level: 2)[9.2 Negation inside a universal]

#q[9.4][Find the names of sailors who have reserved *only* boats that have been reserved by
sailor 22.][
#ans[ $ pi_("sname")(#Sa bowtie ( pi_("sid")(#Re) - pi_("sid")(#Re bowtie ( pi_("bid")(#Bo) - pi_("bid")(sigma_("sid" = 22)(#Re)) )) )) $ ]
#schem[Innermost difference: $("bid")$ — boats never reserved by 22. Next: $("sid")$ — sailors
with a reservation of such a boat. Outer difference: $("sid")$. Result: $("sname")$. ]
#why[ Pattern 5 ("only X") with X itself defined by a negative condition (pattern 2). The
subtracted term must be *sailors who reserved a boat not in 22's set*, which requires the
double difference. ]
#trap[ Writing $pi_("sid")(#Re) - pi_("sid")(sigma_("sid" = 22)(#Re))$ is a set of sailors, not
a set of boats — a type error that is easy to make because both are "sets of ids". Check the
*attribute names*, not just the domains. ]
]

#q[9.5][Find the names of sailors who have not reserved any boat that a rating-1 sailor has
reserved.][
#ans[ $ pi_("sname")(#Sa bowtie ( pi_("sid")(#Sa) - pi_("sid")(#Re bowtie pi_("bid")(#Re bowtie pi_("sid")(sigma_("rating" = 1)(#Sa)))) )) $ ]
#schem[Innermost: $("bid")$ of rating-1 sailors. Middle: $("sid")$ — sailors who reserved any
such boat. Outer difference: $("sid")$. ]
#why[ The "negative" is over a *set of boats*, and that set is itself computed by a join. The
universe is all sailors, so sailors with no reservations are correctly included. ]
#trap[ The natural-join chain $#Re bowtie pi_("bid")(...)$ is on `bid`, which is correct; but
a careless $#Re bowtie #Re$ (unrenamed) is ambiguous. Rename when the same relation appears
twice in one expression. ]
]

#q[9.6][Find the ordered pairs of sailors (x, y) such that x has reserved every boat that y has
reserved, and y has reserved at least one boat.][
#ans[ Let $R("P") = pi_("sid", "bid")(#Re)$. The candidate pairs are
$R("Cand") = pi_("x.sid", "y.sid")( rho_("x")(R("P")) times rho_("y")(R("P")) )$.
The pairs that *fail* are those for which some boat of $y$ is missing from $x$:
$ R("Miss") = pi_("x.sid", "y.sid")( rho_("x")(R("P")) times rho_("y")(R("P")) times rho_("z")(R("P")) )$
restricted by $A("z.sid") = A("y.sid")$, $A("y.bid") = A("z.bid")$, $A("x.bid") != A("z.bid")$.
Then the answer is $ R("Cand") - R("Miss") $. ]
#schem[$R("P")$: $("sid", "bid")$. $R("Cand")$ and $R("Miss")$: $("x.sid", "y.sid")$ — union
compatible, so the difference is legal. ]
#why[ "x covers y" is "$not exists$ a boat of y that is not a boat of x". That negative
existential over a *pair* of entities needs a third tuple variable ranging over the boat —
the three-variable device of Q7.33. The projection of the missing-pair relation onto
$(x, y)$ is what eliminates the third variable. ]
#note[ The condition "y has reserved at least one boat" is automatic: $R("Cand")$ was built from
$R("P")$, so a $y$ with no boat never appears in it. Saying so earns the edge-case mark. ]
#trap[ Testing only the positive direction gives "x has some boat that y has", not "x covers y".
The entire content of the query is in the subtracted term. ]
]

#q[9.7][Find the sailor(s) with the highest rating among those who have reserved at least one
red boat.][
#ans[ Let $R("Red") = pi_("sid")(#Re bowtie sigma_("color" = #C("red"))(#Bo))$ and
$R("Cand") = sigma_("rating" >= 0)(#Sa) bowtie R("Red")$ — i.e. the sailors who qualify. Then apply the
maximum-of-values pattern to $R("Cand")$:
$ R("Cand") bowtie ( pi_("rating")(R("Cand")) - pi_("C1.rating")( sigma_("C1.rating" < "C2.rating")( rho_("C1")(R("Cand")) times rho_("C2")(R("Cand")) ) ) ) $. ]
#schem[$R("Red")$: $("sid")$. $R("Cand")$: schema of `Sailors`. Result: schema of `Sailors`. ]
#why[ The selection and the existential are applied *first*, producing the candidate relation;
the extreme is then computed *over the candidates*. This ordering is the whole point of
"maximum after a selection" (Q5.12). ]
#trap[ Computing the global maximum and then intersecting with $R("Red")$ answers a different
question: "is the globally highest-rated sailor a red-boat reserver?" — usually empty. The
extreme must be taken over the restricted relation. ]
]

#q[9.8][Find the boat(s) reserved by the largest number of *distinct* sailors — or explain why
you cannot.][
#nex[ "Largest number of distinct sailors" is a cardinality comparison. Not expressible. ]
#ans[ Not expressible in classical relational algebra. With $gamma$:
$ gamma_("bid"; "count"("sid") arrow.l n)(pi_("bid", "sid")(#Re)) $, then the maximum of $n$,
then a join back to `Boats` for the name. ]
#why[ Note the difference from Q9.7: there the extreme was over a *stored attribute* (`rating`);
here it is over a *computed count*. Stored values can be compared with $<$; counts cannot even
be formed. ]
#trap[ A student may try "the boat that is not dominated by another boat", with domination
meaning "has strictly more reserving sailors". That relation is not expressible, so the
self-join has no predicate to write. If you catch yourself unable to state the $sigma$
condition, that is the signal. ]
]

#q[9.9][Find the second-most-expensive medicine, and then the patients who received it.][
#ans[ Step 1: the maximum price is
$R("MaxP") = pi_("UnitPrice")(#Med) - pi_("M1.UnitPrice")(sigma_("M1.UnitPrice" < "M2.UnitPrice")(rho_("M1")(#Med) times rho_("M2")(#Med)))$.
Step 2: the second price is
$R("Second") = "Max"( pi_("UnitPrice")(#Med) - R("MaxP") )$, using Q5.1 on the reduced relation.
Step 3: the medicines at that price are $pi_("TradeName")(#Med bowtie R("Second"))$.
Step 4: the patients are
$ pi_("FirstName", "LastName")(#Pa bowtie_(#A("SSN") = #A("Patient_SSN")) #Pr bowtie_(#A("Id") = #A("Prescription_Id")) #Pm bowtie pi_("TradeName")(#Med bowtie R("Second"))) $. ]
#schem[$R("MaxP")$ and $R("Second")$: $("UnitPrice")$. Step 3: $("TradeName")$. Step 4: the
patient's two name attributes. ]
#why[ Four patterns stacked: 8 (maximum), 10 (remove then maximum), 1 (join), 8 again
(selection). Writing it as numbered steps is the safest exam style, and each step's schema is
easy to check. ]
#trap[ "Second-most-expensive medicine" and "second-highest price" are the same only because
price is attached to the medicine. If two medicines share the second price, *all* of them and
all their patients are returned — ties are preserved by construction. ]
]

#heading(level: 2)[9.4 Queries about the absence of a relationship]

#q[9.10][Find the names of patients who have never been prescribed anything by their own
primary doctor.][
#ans[ Let $R("Rx") = pi_("P.SSN")( rho_("P")(#Pa) bowtie_(#A("P.SSN") = #A("Patient_SSN")) sigma_("Doctor_SSN" = "PrimaryDoctor_SSN")(#Pr) )$
be the set of patients who *have* been prescribed something by their own primary doctor. Then

$ "Answer" = pi_("FirstName", "LastName")( #Pa bowtie_(#A("SSN") = #A("S")) rho_("S")( pi_("SSN")(#Pa) - R("Rx") ) ) $ ]
#schem[$R("Rx")$: $("SSN")$ — note that the projection $pi_("P.SSN")$ deliberately renames the
result to `SSN` so that the difference is union compatible with $pi_("SSN")(#Pa)$. The
difference also has schema $("SSN")$, and $rho_("S")$ gives it a name to join on. Result: the
patient's two names. ]
#why[ Pattern 2, with a *correlated* witness: after joining `Patient` into the witness relation
first, both `Doctor_SSN` and `PrimaryDoctor_SSN` sit in the same tuple, so the correlation is
one attribute equality inside a single $sigma$. This "join the correlated relation in first"
move is the key technique of Part 9. ]
#trap[ A common over-complication uses two copies of `Prescription` — one to test "has any
prescription" and one to test "by the primary doctor". Only the second test is needed. The
opposite error is subtler: projecting the witness to `Patient_SSN` instead of `SSN` breaks
union compatibility with $pi_("SSN")(#Pa)$, and some systems will accept it silently because both
are single attributes over the same domain. Check the *names*. ]
]

#q[9.11][Find the names of doctors who have prescribed for at least one patient who is not
their own primary patient.][
#ans[ $ pi_("D.FirstName", "D.LastName")( rho_("D")(#Do) bowtie_(#A("D.SSN") = #A("Doctor_SSN")) sigma_("PrimaryDoctor_SSN" != "Doctor_SSN")( #Pr bowtie_(#A("Patient_SSN") = #A("P.SSN")) rho_("P")(#Pa) ) ) $ ]
#schem[The inner join of `Prescription` with `Patient` has schema
$("Id", "Date", "Doctor_SSN", "Patient_SSN", "FirstName", "LastName", "Address", "DOB", "PrimaryDoctor_SSN")$
— note that `Patient_SSN` and `SSN` are different names, so the theta join keeps both. After
the $sigma$, the tuple contains both the prescribing doctor and the patient's primary doctor,
so the comparison is a single conjunct. Result: the doctor's two names. ]
#why[ Existential over prescriptions, with a correlation between the prescription's doctor and
the patient's primary doctor. Because the correlation attribute was brought into the same tuple
by the join, no nesting is needed. ]
#trap[ This is *not* the complement of Q8.4. Q8.4 asks whether *all* of a patient's
prescriptions come from the primary doctor; this asks whether *one* prescription does not.
Different quantifiers, different answer sets. Examiners deliberately put the two side by side. ]
]

#q[9.12][Find the names of patients who have received exactly one medicine (one distinct trade
name), across all their prescriptions.][
#ans[ $ R("One") = pi_("Patient_SSN")(#Pr bowtie_(#A("Id") = #A("Prescription_Id")) #Pm) - pi_("Q.Patient_SSN")( sigma_("Q.Patient_SSN" = "R.Patient_SSN" and "Q.TradeName" != "R.TradeName")( rho_("Q")(pi_("Patient_SSN", "TradeName")(#Pr bowtie_(#A("Id") = #A("Prescription_Id")) #Pm)) times rho_("R")(pi_("Patient_SSN", "TradeName")(#Pr bowtie_(#A("Id") = #A("Prescription_Id")) #Pm)) ) ) $
Then $ pi_("FirstName", "LastName")(#Pa bowtie_(#A("SSN") = #A("Patient_SSN")) R("One")) $. ]
#schem[$R("One")$: $("Patient_SSN")$. Result: patient names. ]
#why[ "Exactly one" is "at least one" minus "at least two" (pattern 13). "At least two"
requires two distinct trade names for the same patient — a self-join with equality on the
patient and inequality on the medicine. ]
#trap[ If "exactly one medicine" is meant *per prescription* rather than across all
prescriptions, the projection must keep `Prescription_Id` and the universe becomes pairs
(patient, prescription). Read which noun "one" counts. ]
]

#q[9.13][Find the sailors who have made exactly as many reservations as sailor 22 — or explain
why this is not expressible.][
#nex[ Comparing two cardinalities needs counting. Not expressible. ]
#ans[ Not expressible in classical relational algebra. With $gamma$:
$ gamma_("sid"; "count"() arrow.l n)(#Re) $, then restrict to $A("sid") = 22$ to get $n_0$, then
select the sids with $n = n_0$. ]
#why[ The comparison is between two *computed numbers*. Even though the word "exactly" appears,
it is not the fixed-numeral "exactly" of Q5.17 — the right-hand side is not a literal but a
count that must be evaluated. ]
#trap[ The fixed-numeral special case *is* expressible: "sailors with exactly as many
reservations as 22" stops being expressible only because 22's count is data-dependent. If the
question said "sailors with exactly three reservations", it would be expressible (three
witnesses). This contrast is the best short answer to "what does classical RA lack?" ]
]

#q[9.14][Find the names of sailors who have reserved at least two boats that are red *and* at
least one boat that is green.][
#ans[ Let $R("Red2") = pi_("sid")(#Re bowtie sigma_("color" = #C("red"))(#Bo))$ and
$R("G1") = pi_("sid")(#Re bowtie sigma_("color" = #C("green"))(#Bo))$.
The "at least two distinct red boats" condition is
$ R("TwoRed") = pi_("R1.sid")( sigma_("R1.sid" = "R2.sid" and "R1.bid" != "R2.bid")( rho_("R1")(#Re bowtie sigma_("color" = #C("red"))(#Bo)) times rho_("R2")(#Re bowtie sigma_("color" = #C("red"))(#Bo)) ) ) $.
Then the answer is $ pi_("sname")(#Sa bowtie (R("TwoRed") inter R("G1"))) $. ]
#schem[$R("TwoRed")$ and $R("G1")$: $("sid")$. Result: $("sname")$. ]
#why[ Two different cardinality shapes — "at least two of X" (self-join) and "at least one of
Y" (join) — combined by intersection on the key. This is the standard way to combine conditions
with different quantifiers: compute each as a key set, then use a set operator. ]
#trap[ "At least two red *boats*" is not "at least two red *reservations*": a sailor who
reserved the same red boat on two days has two reservations but one red boat. Projecting to
`(sid, bid)` before the self-join is the fix, exactly as in Q3.8. ]
]
