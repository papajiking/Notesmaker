#import "lib.typ": *

#let Do = R("Doctor")
#let Pa = R("Patient")
#let Med = R("Medicine")
#let Pr = R("Prescription")
#let Pm = R("Prescription_Medicine")

#part(8, "Hospital and Prescription — complete solved question bank", blurb: [
  *What this part fixes.* The uploaded university exam pattern, in full. The five original
  questions are Q8.1–Q8.5 and are solved with the same care as the rest; Q8.6–Q8.27 extend the
  schema across joins, self-joins, division, difference, extremes and multi-condition queries.
  The two attributes named `SSN`, and the two named `FirstName`/`LastName`, make renaming
  mandatory in almost every query — that is the single most examined point of this schema.
])

#heading(level: 2)[8.0 Schema, keys and the two name clashes]

#table(
  columns: (auto, 1.5fr, 1.5fr),
  stroke: 0.4pt + l4, inset: (x: 5pt, y: 4pt), align: (left, left, left),
  table.header([*Relation*], [*Attributes*], [*Keys and foreign keys*]),
  [#Do], [("SSN", "FirstName", "LastName", "Specialty", "YearsOfExperience", "PhoneNum")],
    [PK: "SSN"],

  [#Pa], [("SSN", "FirstName", "LastName", "Address", "DOB", "PrimaryDoctor_SSN")],
    [PK: "SSN"; "PrimaryDoctor_SSN" $arrow.r$ #R("Doctor.SSN")],

  [#Med], [("TradeName", "UnitPrice", "GenericFlag")],
    [PK: "TradeName"],

  [#Pr], [("Id", "Date", "Doctor_SSN", "Patient_SSN")],
    [PK: "Id"; "Doctor_SSN" $arrow.r$ #R("Doctor.SSN"); "Patient_SSN" $arrow.r$ #R("Patient.SSN")],

  [#Pm], [("Prescription_Id", "TradeName", "NumOfUnits")],
    [PK: ("Prescription_Id", "TradeName"); "Prescription_Id" $arrow.r$ #R("Prescription.Id");
     "TradeName" $arrow.r$ #Med],
)
#v(3pt)
#note[
  *Name clashes to check before writing any expression.*
  + `Doctor.SSN` and `Patient.SSN` — same name, different entities. Always rename one:
    $rho_("D")(#Do)$ or $rho_("P")(#Pa)$, or qualify as $A("Doctor.SSN")$.
  + `Doctor.FirstName`, `Doctor.LastName` and `Patient.FirstName`, `Patient.LastName` — same
    problem for names.
  + `Prescription.Patient_SSN` and `Patient.SSN` — *different* names, so an explicit theta join
    $bowtie_("Patient_SSN" = "SSN")$ is needed; a natural join would silently produce nothing
    (no shared attribute name) and the result would be a Cartesian product.
]

#heading(level: 2)[8.1 The five original exam questions]

#q[8.1][List the first and last names of patients whose primary doctor is named John Smith.][
#ans[ $ pi_("Patient.FirstName", "Patient.LastName")( #Pa bowtie_(#A("Patient.PrimaryDoctor_SSN") = #A("Doctor.SSN")) sigma_("FirstName" = #C("John") and "LastName" = #C("Smith"))(rho_("Doctor")(#Do)) ) $ ]
#schem[The theta join's result carries all six `Patient` attributes plus all six `Doctor`
attributes — the join predicate uses attributes with *different* names, so nothing is merged.
The projection leaves the patient's two name attributes, and they must be *qualified*, because
`Doctor` also has `FirstName` and `LastName`. ]
#why[ Two relations, one join, one selection. The join predicate is
`Patient.PrimaryDoctor_SSN = Doctor.SSN` — an equijoin between attributes with *different*
names, which is exactly why a natural join cannot be used here. ]
#note[ Two equally acceptable spellings. Renaming the patient's attributes at the source avoids
all ambiguity:
$ pi_("pfn", "pln")( rho_("pfn" arrow.l "FirstName", "pln" arrow.l "LastName")(#Pa) bowtie_(#A("PrimaryDoctor_SSN") = #A("D.SSN")) sigma_("D.FirstName" = #C("John") and "D.LastName" = #C("Smith"))(rho_("D")(#Do)) ) $.
Or qualify the projection as above. What is *not* acceptable is an unqualified
$pi_("FirstName", "LastName")$ over a relation that owns both attributes twice. ]
#trap[ Three errors appear again and again. (i) *Using a natural join*: `Patient` and `Doctor`
share `SSN`, `FirstName` and `LastName`, so the natural join equates the patient's own SSN with
the doctor's — it returns patients who *are* John Smith, not patients *of* John Smith.
(ii) Treating "John Smith" as one value instead of a conjunction of two attributes.
(iii) Matching the *patient's* name against "John" instead of the doctor's. Read the sentence
twice: *whose primary doctor is named* John Smith. ]
]

#q[8.2][List the first and last names of doctors who are not primary doctors to any patient.][
#ans[ The simple form, subtracting on the key, is
$ pi_("FirstName", "LastName")( #Do bowtie ( pi_("SSN")(#Do) - pi_("PrimaryDoctor_SSN")(#Pa) ) ) $
The fully qualified form, which shows the join explicitly, is
$ pi_("D.FirstName", "D.LastName")( rho_("D")(#Do) bowtie rho_("M")( pi_("SSN")(#Do) - pi_("PrimaryDoctor_SSN")(#Pa) ) ) $
Here $rho_("M")$ names the intermediate set of "doctors who are somebody's primary doctor", and the natural join on `SSN` keeps the doctors outside it. ]
#schem[The inner difference is $("SSN")$ on both sides — union compatible, because
$pi_("PrimaryDoctor_SSN")(#Pa)$ is a set of doctor identifiers even though the attribute has a
different *name*. The natural join in the simple form equates `SSN`, and the projection gives
the doctor's names. ]
#why[ Pattern 2: universe = all doctors; witness = "appears in the `PrimaryDoctor_SSN` column".
A doctor who has *prescribed* many times but is nobody's primary doctor is correctly returned —
see Q8.3's distinction list. ]
#trap[ The name-based version
$pi_("FirstName", "LastName")(#Do) - pi_("FirstName", "LastName")(#Do bowtie #Pa bowtie_(dots))$
is wrong whenever two doctors share a name. It is also wrong in a subtler way: the natural join
`Doctor ⋈ Patient` matches on `SSN`, `FirstName` and `LastName` simultaneously, which is not
the join you want. Subtract on the key, always. ]
]

#q[8.3][For medicines written in more than 20 prescriptions, report the trade name and the total
number of units prescribed. *Do not use COUNT() or SUM().* Explain whether the requested total
can be computed in classical relational algebra, and distinguish the count of distinct
prescriptions from the sum of units.][
#nex[ Both parts of the request — "more than 20 prescriptions" and "total number of units" —
require aggregation. Neither is expressible in classical relational algebra. ]
#ans[ Not expressible. With the extended operator the intended query is

#eq[$ gamma_("TradeName"; "count"("Prescription_Id") arrow.l "n", "sum"("NumOfUnits") arrow.l "units")(#Pm) $]

followed by $sigma_("n" > 20)$ and a join with `Medicine` if `UnitPrice` is also wanted. In
classical relational algebra you may only write the *fixed-cardinality* fragments: "appears in
at least two prescriptions", "appears in at least three prescriptions", and so on. ]

#schem[The $gamma$ result has schema $("TradeName", "n", "units")$; the classical fragments are
all subsets of $pi_("TradeName")(#Pm)$, i.e. schema $("TradeName")$. ]

#why[ Three separate arguments are needed for full marks.

+ *"More than 20"* compares a numeral with the *cardinality* of a set of tuples. Cardinality is
  not a term of the algebra; there is no operator that turns a relation into a number.
+ *"Total number of units"* is a *sum* over a set of values, which again is not a term. Even
  with a fixed bound on the number of prescriptions, the sum of an unbounded multiset of
  values cannot be expressed.
+ *The two conditions are different.* "Written in more than 20 prescriptions" counts *rows*
  of `Prescription_Medicine`; "total units exceeds 20" sums the `NumOfUnits` column. A medicine
  prescribed once with 500 units fails the first test and passes the second. Contrast, on the
  same instance: Aspirin in 3 prescriptions of 100 units each has $n = 3$ and 300 units;
  Vitamin in 1 prescription of 300 units has $n = 1$ and 300 units. Same total, different
  counts — which is exactly why a student who answers one is not answering the other.
]
#note[ *What you *can* write.* For a fixed numeral $k$, "appears in at least $k$ prescriptions"
is expressible with $k$ distinct tuple variables:
$ R("AtLeast2") = pi_("P1.TradeName")( sigma_("P1.TradeName" = "P2.TradeName" and "P1.Prescription_Id" != "P2.Prescription_Id")( rho_("P1")(#Pm) times rho_("P2")(#Pm) ) ) $
and similarly for 3, 4, … . "More than 20" would need twenty-one variables, and — crucially —
the resulting formula changes *shape* with the numeral, so it does not express the query
"more than 20" as a function of a parameter. The examinable statement is: *fixed cardinality
is expressible; parameterised cardinality is not.* ]
#trap[ Do not write a $gamma$ expression and call it relational algebra. Do not invent a $div$
or a $-$ expression and hope. The mark for this question is awarded for (i) saying "not
expressible", (ii) naming the missing operator, (iii) explaining *why* it is missing, and
(iv) distinguishing the row count from the unit sum. A script that says all four gets full
marks even without writing the $gamma$ formula. ]
]

#q[8.4][List the first and last names of patients who have no prescriptions written by doctors
other than their primary doctors.][
#ans[ Define the set of *violators* — patients who have at least one prescription written by a
doctor other than their own primary doctor:

#eq[$ R("Bad") = pi_("SSN")( #Pa bowtie_(#A("Patient.SSN") = #A("Prescription.Patient_SSN")) sigma_("PrimaryDoctor_SSN" != "Doctor_SSN")(#Pr) ) $]

Then the answer is $ pi_("FirstName", "LastName")(#Pa bowtie (pi_("SSN")(#Pa) - R("Bad"))) $. ]
#schem[$R("Bad")$ has schema $("SSN")$ — patient identifiers. Both operands of the difference
are $("SSN")$, so it is union compatible. The final natural join on `SSN` restores the two name
attributes. ]
#why[ This is pattern 2. The universe is *all patients*; the witness is a prescription whose
`Doctor_SSN` differs from that patient's own `PrimaryDoctor_SSN`. The correlation is essential:
the two attributes must be read from the *same* patient's row, which is why `Patient` is joined
into the witness relation before the comparison. ]
#note[ *The three cases the question is really testing.*
#table(
  columns: (auto, 1fr, auto),
  stroke: 0.4pt + l4, inset: (x: 5pt, y: 3.5pt), align: (left, left, center),
  table.header([*Case*], [*Description*], [*Returned?*]),
  [A], [patient with no prescriptions at all], [*Yes* — vacuously: he has no prescription by another doctor],
  [B], [patient whose every prescription was written by his primary doctor], [*Yes*],
  [C], [patient with at least one prescription by another doctor], [*No*],
)
#v(2pt)
So "no prescriptions by other doctors" is A $union$ B. It is *not* "prescriptions, and all of
them by my primary doctor" (B only). The wording of the question asks for A $union$ B; if your
examiner wants B only, intersect with $pi_("Patient_SSN")(#Pr)$ and say so. ]
#trap[ The most common error is to forget the correlation: writing
$pi_("Patient_SSN")(sigma_("Doctor_SSN" != "PrimaryDoctor_SSN")(#Pr times #Pa))$ compares the
prescribing doctor with the primary doctor of *every* patient in the cross product. Without the
equality $A("Patient_SSN") = A("SSN")$ the expression is meaningless, yet it returns a
plausible-looking set and is rarely caught. ]
]

#q[8.5][List the SSNs of patients who have Aspirin and Vitamin trade names in one prescription.][
#ans[ $ pi_("Patient_SSN")( #Pr bowtie_(#A("Pr.Id") = #A("P1.Prescription_Id")) rho_("P1")(#Pm) bowtie_(#A("P1.Prescription_Id") = #A("P2.Prescription_Id")) rho_("P2")(#Pm) ) $ ]
with the conditions $A("P1.TradeName") = #C("Aspirin")$ and $A("P2.TradeName") = #C("Vitamin")$
added inside a $sigma$, giving

#eq[$ pi_("Patient_SSN")( sigma_("P1.TradeName" = #C("Aspirin") and "P2.TradeName" = #C("Vitamin"))( #Pr bowtie_(#A("Id") = #A("P1.Prescription_Id")) rho_("P1")(#Pm) bowtie_(#A("P1.Prescription_Id") = #A("P2.Prescription_Id")) rho_("P2")(#Pm) ) ) $]
#schem[The two copies of `Prescription_Medicine` are renamed so that the *same*
`Prescription_Id` can appear twice, once for Aspirin and once for Vitamin. Result:
$("Patient_SSN")$. ]
#why[ "In one prescription" is an equality between the two medicine rows' prescription
identifiers. Two copies of the relation are needed because the two medicines are two different
rows; the equality on `Prescription_Id` is what forces them into the *same* prescription, and
the join with `Prescription` supplies the patient. This is pattern 7 (self-join) combined with
pattern 1 (existence). ]
#note[ *Why the equality is the whole question.* If you drop
$A("P1.Prescription_Id") = A("P2.Prescription_Id")$ and keep only "the same patient", you answer
"has Aspirin in some prescription and Vitamin in some (possibly different) prescription" —
which is a *different* and much more common situation. The exam is testing exactly this. Use
two tuple variables and one equality. ]
#trap[ Three variants, all wrong for this question:
+ $sigma_("TradeName" = #C("Aspirin") and "TradeName" = #C("Vitamin"))(#Pm)$ — one row cannot
  have two trade names; the result is empty.
+ $pi_("Patient_SSN")(#Pr bowtie sigma_("TradeName" = #C("Aspirin"))(#Pm)) inter pi_("Patient_SSN")(#Pr bowtie sigma_("TradeName" = #C("Vitamin"))(#Pm))$ — different prescriptions,
  possibly different dates.
+ Comparing `P1.TradeName != P2.TradeName` but forgetting the prescription equality — returns
  patients with any two different medicines in any two prescriptions.
]
]

#heading(level: 2)[8.2 Twenty-two further questions on the same schema]

#q[8.6][List the full names of all doctors along with their specialty.][
#ans[ $ pi_("FirstName", "LastName", "Specialty")(#Do) $ ]
#schem[$("FirstName", "LastName", "Specialty")$. ]
#why[ One relation, one projection; `SSN` is not requested, so it is dropped. ]
#trap[ Two doctors may share a name and specialty, in which case the projection collapses them.
If the question wants one row per doctor, include `SSN` in the projection. ]
]

#q[8.7][List the trade names of all generic medicines.][
#ans[ $ pi_("TradeName")(sigma_("GenericFlag" = #C("Y"))(#Med)) $ ]
#schem[$("TradeName")$. ]
#why[ `GenericFlag` is a stored attribute; the condition is tuple-local. ]
#trap[ If `GenericFlag` is stored as a Boolean rather than a character, the constant must match
the domain: $sigma_("GenericFlag" = "true")$. State the domain assumption. ]
]

#q[8.8][Find the names of patients who are older than 60.][
#ans[ $ pi_("FirstName", "LastName")(sigma_("DOB" < #C("1966-10-22"))(#Pa)) $ ]
#schem[$("FirstName", "LastName")$. ]
#why[ "Older than 60" is a comparison between the stored `DOB` and a *constant date* computed
from today's date. Relational algebra does not do arithmetic on dates, so the constant must be
written out; say how you computed it. ]
#trap[ The expression $sigma_("DOB" < "today" - 60)(#Pa)$ is not relational algebra: it
contains date arithmetic. If the paper wants that, write it as a comment and give the constant
form as the answer. ]
]

#q[8.9][Find the names of doctors who have prescribed at least one medicine.][
#ans[ $ pi_("D.FirstName", "D.LastName")( rho_("D")(#Do) bowtie_(#A("D.SSN") = #A("Doctor_SSN")) #Pr ) $ ]
#schem[$("FirstName", "LastName")$ of the doctor. ]
#why[ Existential: a prescription row linking the doctor to any patient. Note the theta join on
differently-named attributes. ]
#trap[ A doctor who has *seen* a patient as his primary doctor but never written a prescription
must not appear. The witness relation is `Prescription`, not `Patient`. ]
]

#q[8.10][Find the names of patients who have never received a prescription.][
#ans[ $ pi_("FirstName", "LastName")( #Pa bowtie ( pi_("SSN")(#Pa) - pi_("Patient_SSN")(#Pr) ) ) $ ]
#schem[Inner difference: $("SSN")$; result: the patient's two name attributes. ]
#why[ Pattern 2 with `Patient` as the universe. ]
#trap[ If the join is a natural join, the shared attributes are `SSN`, `FirstName` and
`LastName`; here that is harmless because the right operand has only `SSN` — but in general,
prefer the explicit key join. ]
]

#q[8.11][Find the names of doctors who have prescribed for every patient.][
#ans[ $ pi_("FirstName", "LastName")( rho_("D")(#Do) bowtie_(#A("D.SSN") = #A("Doctor_SSN")) ( pi_("Doctor_SSN", "Patient_SSN")(#Pr) div pi_("SSN")(#Pa) ) ) $ ]
#schem[The division returns $("Doctor_SSN")$; the join restores names. ]
#why[ The dividend is $pi_("Doctor_SSN", "Patient_SSN")(#Pr)$ — the relation pairing doctors with
the patients they have prescribed for. The divisor is every patient. ]
#trap[ Dividing `Prescription` itself gives $("Doctor_SSN", "Id", "Date")$ as the retained attributes,
which asks for a doctor who has a prescription with *every* patient *and* a fixed prescription
id — impossible. Project first. ]
]

#q[8.12][Find the trade names of medicines that have never been prescribed.][
#ans[ $ pi_("TradeName")(#Med) - pi_("TradeName")(#Pm) $ ]
#schem[$("TradeName")$. ]
#why[ Universe = all medicines; witness = any `Prescription_Medicine` row. ]
#trap[ A medicine can exist in `Medicine` and never appear in any prescription — that is the
point of the question; do not conclude the answer is always empty. ]
]

#q[8.13][Find the names of patients whose primary doctor has specialty "Cardiology".][
#ans[ $ pi_("FirstName", "LastName")( #Pa bowtie_(#A("PrimaryDoctor_SSN") = #A("D.SSN")) sigma_("D.Specialty" = #C("Cardiology"))(rho_("D")(#Do)) ) $ ]
#schem[The patient's $("FirstName", "LastName")$ — qualify the projection because `Doctor` also
has them. ]
#trap[ Do not confound "primary doctor is a cardiologist" with "was prescribed by a
cardiologist": the second uses `Prescription.Doctor_SSN`, the first uses
`Patient.PrimaryDoctor_SSN`. Read which attribute is named. ]
]

#q[8.14][Find the names of patients all of whose prescriptions were written by doctors with at
least 10 years of experience.][
#ans[ $ pi_("FirstName", "LastName")( #Pa bowtie ( pi_("SSN")(#Pa) - pi_("P.SSN")( #Pr bowtie_(#A("Patient_SSN") = #A("P.SSN")) rho_("P")(#Pa) bowtie_(#A("Doctor_SSN") = #A("D.SSN")) sigma_("D.YearsOfExperience" < 10)(rho_("D")(#Do)) ) ) ) $ ]
#schem[The subtracted term is the set of patient SSNs that have a *violating* prescription —
written by a doctor with fewer than 10 years. The difference is $("SSN")$, and the projection
gives the names. ]
#why[ "All of whose prescriptions satisfy C" is pattern 5 with the complement of C: patients
having at least one prescription that fails C are removed. Patients with no prescriptions at all
survive vacuously — say whether that is intended. ]
#trap[ Writing $sigma_("YearsOfExperience" >= 10)$ and joining positively gives "has at least
one prescription by an experienced doctor" — the opposite quantifier. The negation must be
inside the subtracted term: *violators are removed*, not *satisfiers are kept*. ]
]

#q[8.15][Find the names of doctors who have prescribed more than one medicine in a single
prescription.][
#ans[ Let $R("Multi")$ be the set of prescriptions that contain at least two distinct medicines:
$ R("Multi") = pi_("P1.Prescription_Id")( sigma_("P1.Prescription_Id" = "P2.Prescription_Id" and "P1.TradeName" != "P2.TradeName")( rho_("P1")(#Pm) times rho_("P2")(#Pm) ) ) $
Then $ pi_("FirstName", "LastName")( rho_("D")(#Do) bowtie_(#A("D.SSN") = #A("Doctor_SSN")) #Pr bowtie_(#A("Id") = #A("Prescription_Id")) R("Multi") ) $. ]
#schem[$R("Multi")$: $("Prescription_Id")$. The join chain returns the doctor's two name
attributes. ]
#why[ "More than one medicine in one prescription" is *at least two distinct trade names sharing
a prescription id* — a self-join with equality on the prescription and inequality on the
medicine. No counting is needed, because *two* is a fixed numeral. ]
#trap[ Dropping the equality on `Prescription_Id` answers "has prescribed two different
medicines at some time", a much weaker condition. Dropping the inequality on `TradeName`
answers nothing at all: every prescription trivially pairs with itself. ]
]

#q[8.16][Find the names of patients who have received the most expensive medicine (by
UnitPrice).][
#ans[ Let $R("MaxP") = pi_("UnitPrice")(#Med) - pi_("M1.UnitPrice")( sigma_("M1.UnitPrice" < "M2.UnitPrice")( rho_("M1")(#Med) times rho_("M2")(#Med) ) )$ be the maximum
unit price, and $R("Top") = pi_("TradeName")(#Med bowtie R("MaxP"))$ the medicines at that price.
Then $ pi_("FirstName", "LastName")( #Pa bowtie_(#A("SSN") = #A("Patient_SSN")) #Pr bowtie_(#A("Id") = #A("Prescription_Id")) #Pm bowtie R("Top") ) $. ]
#schem[$R("MaxP")$: $("UnitPrice")$. $R("Top")$: $("TradeName")$. Result: the patient's names. ]
#why[ Maximum-of-values (Q5.1), then join through the prescription chain to the patient. Ties are
preserved: every medicine at the maximum price is in $R("Top")$, and every patient who received
any of them is returned. ]
#trap[ The tempting "most expensive medicine *prescribed*" is the same query — the price is
attached to the medicine, not to the line item. If prices could differ per prescription, the
schema would need a price column on `Prescription_Medicine`. Say which model you are using. ]
]

#q[8.17][Find the names of patients who have been prescribed both Aspirin and Vitamin (not
necessarily in one prescription), and contrast with Q8.5.][
#ans[ $ pi_("FirstName", "LastName")( #Pa bowtie_(#A("SSN") = #A("Patient_SSN")) ( pi_("Patient_SSN")(#Pr bowtie_(#A("Id") = #A("Prescription_Id")) sigma_("TradeName" = #C("Aspirin"))(#Pm)) inter pi_("Patient_SSN")(#Pr bowtie_(#A("Id") = #A("Prescription_Id")) sigma_("TradeName" = #C("Vitamin"))(#Pm)) ) ) $ ]
#schem[Both intersected operands are $("Patient_SSN")$. ]
#why[ Two independent existences, intersected on the patient key. This is *weaker* than Q8.5:
any pair of prescriptions suffices. ]
#trap[ If you intersect on whole `Prescription` tuples instead of on the patient, you get the
empty relation, because a single prescription cannot contain both medicines unless the
self-join of Q8.5 is used. The projection before the intersection is what makes the two
existences independent. ]
]

#q[8.18][Find the SSNs of patients whose every prescription contains at least one generic
medicine.][
#ans[ $ pi_("SSN")(#Pa) - pi_("Patient_SSN")( #Pr - pi_("Pr.Id", "Pr.Date", "Pr.Doctor_SSN", "Pr.Patient_SSN")( rho_("Pr")(#Pr) bowtie_(#A("Id") = #A("Prescription_Id")) #Pm bowtie_(#A("TradeName") = #A("M.TradeName")) sigma_("GenericFlag" = #C("Y"))(rho_("M")(#Med)) ) ) $ ]
#schem[The inner subtraction is between two relations of schema
$("Id", "Date", "Doctor_SSN", "Patient_SSN")$; the result is $("Patient_SSN")$; the outer
difference is $("SSN")$. ]
#why[ "Every prescription of this patient has a generic item" = all patients minus patients
having a prescription with *no* generic item. The prescription with no generic item is found by
subtracting from `Prescription` the prescriptions that do have one. The projection in the middle
is essential to restore the exact schema of `Prescription` before the subtraction. ]
#trap[ This is the "preserve the full schema when subtracting records" rule of §1.7 in action.
If you project only `Id`, the subtraction is on ids, and the outer difference then subtracts
`Id`s from `SSN`s — a type error that a careless script will not notice because both are
single-attribute relations of the same domain type. ]
]

#q[8.19][Find the names of doctors who have never prescribed for patient "Ravi Kumar".][
#ans[ $ pi_("FirstName", "LastName")( #Do bowtie ( pi_("SSN")(#Do) - pi_("Doctor_SSN")( #Pr bowtie_(#A("Patient_SSN") = #A("P.SSN")) sigma_("P.FirstName" = #C("Ravi") and "P.LastName" = #C("Kumar"))(rho_("P")(#Pa)) ) ) ) $ ]
#schem[Inner witness: $("Doctor_SSN")$. Difference: $("SSN")$. Result: the doctor's two name
attributes. ]
#why[ Pattern 2. The universe is all doctors; the witness is "has a prescription whose patient
is Ravi Kumar". Only the prescribing relation counts — a doctor who merely has Ravi as his
*primary* patient has not prescribed for him. ]
#trap[ If several patients are called Ravi Kumar, all of them count, because name is not a key.
If the question expects a single patient, it should give the SSN; say so in your answer. ]
]

#q[8.20][Find the trade names of medicines whose unit price is higher than the price of every
generic medicine.][
#ans[ Let $R("GMax") = pi_("UnitPrice")(sigma_("GenericFlag" = #C("Y"))(#Med)) - pi_("M1.UnitPrice")( sigma_("M1.UnitPrice" < "M2.UnitPrice")( rho_("M1")(sigma_("GenericFlag" = #C("Y"))(#Med)) times rho_("M2")(sigma_("GenericFlag" = #C("Y"))(#Med)) ) )$.
Then $ pi_("TradeName")(#Med bowtie sigma_("UnitPrice" > "GMax.UnitPrice")(#Med times rho_("GMax")(R("GMax")))) $. ]
#schem[$R("GMax")$: $("UnitPrice")$. Result: $("TradeName")$. ]
#why[ "Higher than every generic" is a comparison against a *single computed value* — the
maximum generic price — because "higher than all of them" is equivalent to "higher than the
largest of them". Computing the maximum first is simpler than the counter-example method. ]
#note[ When the comparison set is defined by a condition rather than named, the *maximum* is
the right reduction: $forall g in G: x > g "  iff  " x > max(G)$, valid whenever $G$ is
non-empty. For the empty case, "higher than every generic" is vacuously true and the
counter-example form handles it correctly, while the maximum form would return the empty
relation. Prefer the counter-example form if the empty case matters. ]
#trap[ Using $sigma_("GenericFlag" != #C("Y"))$ to find non-generic medicines and comparing
pairwise answers "higher than some non-generic", not "higher than every generic". ]
]

#q[8.21][Find the pairs of doctors who have prescribed exactly the same set of medicines.][
#ans[ Let $R("DM") = pi_("Doctor_SSN", "TradeName")(#Pr bowtie_(#A("Id") = #A("Prescription_Id")) #Pm)$.
Define $R("Pairs") = pi_("SSN")(#Do) times pi_("SSN")(#Do)$ and
$R("Missing") = pi_("A.sid", "B.sid")( sigma_("X.sid" = "A.sid" and "X.sid" != "B.sid" and "X.TradeName" = "Y.TradeName")( dots ) )$ — see the construction below.
The clean statement is the pair of divisions: $(d_1, d_2)$ such that $d_1$ covers $d_2$ and
$d_2$ covers $d_1$. ]
#ans[ *Construction.* Let $R("Pairs") = rho_("A")(#Do) times_(...) ...$ — written with the
three-variable device of Q7.33:
$ R("V") = pi_("X.d", "X.m", "Y.d")( rho_("X")(R("DM")) times rho_("Yd")(pi_("SSN")(#Do)) ) - pi_("X.d", "X.m", "Yd.SSN")( sigma_("X.m" = "Z.m")( rho_("X")(R("DM")) times rho_("Z")(R("DM")) times rho_("Yd")(pi_("SSN")(#Do)) ) ) $,
$ R("Bad") = pi_("X.d", "Y.d")(R("V")) $, and the answer is
$ R("Pairs") - R("Bad") - rho_("X.d" arrow.l "Y.d", "Y.d" arrow.l "X.d")(R("Bad")) $. ]
#schem[Every intermediate is a pair of doctor identifiers, $("SSN", "SSN")$. ]
#why[ "Same set of medicines" is the two-directional coverage condition — identical in structure
to Q7.33 with members replaced by doctors and books by medicines. ]
#trap[ Do not attempt to compare `(Doctor_SSN, TradeName)` pairs directly with set equality;
relations are not first-class values that can be compared. The two-directional difference is the
only classical formulation. ]
]

#q[8.22][Find the names of patients who have prescriptions from at least three different
doctors.][
#ans[ $ pi_("FirstName", "LastName")( #Pa bowtie_(#A("SSN") = #A("A.Patient_SSN")) sigma_("A.Patient_SSN" = "B.Patient_SSN" and "B.Patient_SSN" = "C.Patient_SSN" and "A.Doctor_SSN" != "B.Doctor_SSN" and "B.Doctor_SSN" != "C.Doctor_SSN" and "A.Doctor_SSN" != "C.Doctor_SSN")( rho_("A")(#Pr) times rho_("B")(#Pr) times rho_("C")(#Pr) ) ) $ ]
#schem[Three-way self-product: 12 attributes; after $sigma$ and $pi$: $("Patient_SSN")$. ]
#why[ "At least three distinct" needs three witnesses — three tuple variables with pairwise
inequalities. This is the fixed-cardinality pattern (§10.6). ]
#trap[ Two variables cannot express "three distinct doctors": with only $A$ and $B$ you can
force $A != B$, but a third doctor is invisible. The number of variables must be at least the
numeral. ]
]

#q[8.23][Find the names of doctors whose every prescription had at least two medicines in it.][
#ans[ $ pi_("FirstName", "LastName")( rho_("D")(#Do) bowtie_(#A("D.SSN") = #A("W.Doctor_SSN")) ( pi_("SSN")(#Do) - pi_("W.Doctor_SSN")( #Pr - pi_("Id", "Date", "Doctor_SSN", "Patient_SSN")( sigma_("P1.Prescription_Id" = "P2.Prescription_Id" and "P1.TradeName" != "P2.TradeName")( #Pr times rho_("P1")(#Pm) times rho_("P2")(#Pm) ) ) ) ) ) $ ]
#schem[The subtracted term is a set of prescriptions with at least two items, projected to the
prescription schema; the outer subtraction gives doctors with a *single-item* prescription;
the final difference gives doctors with none. ]
#why[ Two nested instances of pattern 5: "every prescription of this doctor" and "at least two
items per prescription". ]
#trap[ The projection inside must restore the exact `Prescription` schema, not just `Id` — if
you subtract on `Id` you get a set of ids, and subtracting that from `Prescription` (4
attributes) is a union-compatibility error. ]
]

#q[8.24][Find the most recent prescription date for each doctor.][
#ans[ $ #Pr - pi_("P1.Id", "P1.Date", "P1.Doctor_SSN", "P1.Patient_SSN")( sigma_("P1.Doctor_SSN" = "P2.Doctor_SSN" and "P1.Date" < "P2.Date")( rho_("P1")(#Pr) times rho_("P2")(#Pr) ) ) $ ]
#schem[Schema of `Prescription`. ]
#why[ Group-wise maximum of `Date` within each `Doctor_SSN` (Q5.13). ]
#trap[ Using the global maximum (without the `Doctor_SSN` equality) returns only the single
most recent prescription in the hospital. The equality inside the $sigma$ is what makes it
per-doctor. ]
]

#q[8.25][Find the names of patients who have received every medicine that the patient with SSN
"123" has received.][
#ans[ Let $R("PT") = pi_("Patient_SSN", "TradeName")( #Pr bowtie_(#A("Id") = #A("Prescription_Id")) #Pm )$
be the "patient received medicine" relation, and let
$ R("P123") = pi_("TradeName")( sigma_("Patient_SSN" = #C("123"))(rho_("Q")(R("PT"))) ) $.
Then the answer is

$ pi_("FirstName", "LastName")( #Pa bowtie_(#A("SSN") = #A("Patient_SSN")) ( R("PT") div R("P123") ) ) $ ]
#schem[$R("PT")$: $("Patient_SSN", "TradeName")$. $R("P123")$: $("TradeName")$. The division
returns $("Patient_SSN")$, and the natural join with `Patient` on `SSN`... careful: the division
result's attribute is named `Patient_SSN`, which is *not* the name of `Patient.SSN`. The join
must be written as a theta join $bowtie_(#A("Patient_SSN") = #A("SSN"))$, or the division result
must be renamed first with $rho_("Patient_SSN" arrow.l "SSN")$. ]
#why[ Same shape as Q4.4 and Q7.22: the quantified set is computed through two joins, and the
division is performed on the derived binary relation. Patient 123 himself appears in the answer,
since he received all of his own medicines. ]
#trap[ Two errors are common. (i) A *natural* join between the division result and `Patient`
finds no shared attribute name at all, degenerating into a Cartesian product — always check
that the attribute names match, or rename. (ii) If patient 123 has received no medicine, the
divisor is empty and every patient who received any medicine is returned (vacuous truth). ]
]

#q[8.26][Find the names of doctors who have prescribed every medicine in $R("ReqMed")("TradeName")$.][
#ans[ $ pi_("FirstName", "LastName")( rho_("D")(#Do) bowtie_(#A("D.SSN") = #A("Doctor_SSN")) ( pi_("Doctor_SSN", "TradeName")(#Pr bowtie_(#A("Id") = #A("Prescription_Id")) #Pm) div R("ReqMed") ) ) $ ]
#schem[$("FirstName", "LastName")$ of doctors. ]
#why[ The binary relation must be derived by joining `Prescription` and
`Prescription_Medicine`, because `Doctor_SSN` and `TradeName` never appear in the same stored
relation. ]
#trap[ Dividing `Prescription_Medicine` directly fails: it has no `Doctor_SSN`. The join is the
point of the question. ]
]

#q[8.27][Explain, using this schema, which of the following are expressible and why:
(a) patients with at least two prescriptions; (b) patients with more prescriptions than their
primary doctor; (c) patients whose prescriptions were all written by their primary doctor;
(d) patients with the most prescriptions.][
#ans[ #tab((auto, 1fr, 1fr),
  [*(a)*], [*Yes*], [self-join of `Prescription` on `Patient_SSN` with $!=$ on `Id` (pattern 14)],
  [*(b)*], [*No*], [compares two computed counts; needs $gamma$],
  [*(c)*], [*Yes*], [pattern 5 with the complement: subtract patients having a non-primary prescription (Q8.4)],
  [*(d)*], [*No*], [maximum of a computed count; needs $gamma$],
) ]
#why[ (a) and (c) are Boolean combinations of existence statements over a *fixed* number of
tuple variables. (b) and (d) require building a number per entity and comparing numbers — that
is aggregation, and it is exactly what the classical algebra lacks. ]
#trap[ (b) looks deceptively similar to (a). "More than X" where X is a *computed count* is
never expressible in classical RA, even when the two counts are over the same relation. ]
]
