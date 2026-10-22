#import "lib.typ": *

#let Bk = R("Book")
#let Au = R("Author")
#let Wb = R("WrittenBy")
#let Me = R("Member")
#let Br = R("Borrow")

#part(7, "Books, Authors and Borrowing — complete solved question bank", blurb: [
  *What this part fixes.* The library schema exercises *many-to-many relationship* reasoning:
  a book has several authors, a member borrows many books, and the same book may be borrowed
  many times on different dates. Every question states whether it uses the *full* schema or
  the *simplified* one (§1.2B), because several queries are meaningful only in one of them.
])

#heading(level: 2)[7.0 The two schemas, side by side]

#grid(columns: (1fr, 1fr), gutter: 12pt,
  [*Full schema*
   #v(2pt)
   $R("Book")("BookID", "Title", "Publisher", "Category")$ \
   $R("Author")("AuthorID", "AuthorName")$ \
   $R("WrittenBy")("BookID", "AuthorID")$ \
   $R("Member")("MemberID", "MemberName")$ \
   $R("Borrow")("MemberID", "BookID", "BorrowDate", "ReturnDate")$],

  [*Simplified schema*
   #v(2pt)
   $R("Books")("BookID", "Title")$ \
   $R("BookAuthors")("BookID", "Author")$ \
   $R("Borrow")("MemberID", "BookID")$ \
   #v(3pt)
   #mini[No dates, no publisher, no separate author entity. A member borrows a given book at most once, so "borrowed twice" is undefined.],
  ],
)
#v(4pt)
#note[
  *Where the two schemas differ in expressiveness.* Anything mentioning a *date* — "latest",
  "at least two dates", "not yet returned" — is answerable only in the full schema. Anything
  mentioning an author as an *entity* with an id ("authors who wrote every category") needs
  the full schema. The simplified schema is used for the many "who borrowed what" questions in
  §7.1–7.2 because it keeps the expressions short and the idea visible.
]

#heading(level: 2)[7.1 Basic and join queries]

#q[7.1][Find all book titles. *(full schema)*][
#ans[ $ pi_("Title")(#Bk) $ ]
#schem[$("Title")$, duplicates removed — two books with the same title appear once. ]
#why[ Pure projection. ]
#trap[ If the question wants one row per book, project $("BookID", "Title")$ instead, and say
why. "List all titles" with set semantics cannot distinguish two copies of a title. ]
]

#q[7.2][Find the books published by "Pearson". *(full schema)*][
#ans[ $ sigma_("Publisher" = #C("Pearson"))(#Bk) $ ]
#schem[Schema of `Book`. ]
#why[ Tuple-local selection. ]
#trap[ Selecting $pi_("Title")(#Bk)$ first and then filtering is a type error, because
`Publisher` is gone. ]
]

#q[7.3][Find the titles of books written by the author with AuthorID 7. *(full schema)*][
#ans[ $ pi_("Title")(#Bk bowtie sigma_("AuthorID" = 7)(#Wb)) $ ]
#schem[$("Title")$. ]
#why[ `WrittenBy` carries the link; `Book` carries the title; the natural join is on `BookID`. ]
#trap[ Joining `WrittenBy` with `Author` is unnecessary for this question — the author is
identified by id, not by name. Adding it is harmless but wastes a join. ]
]

#q[7.4][Find the names of the authors of the book titled "DBMS". *(full schema)*][
#ans[ $ pi_("AuthorName")(#Au bowtie #Wb bowtie sigma_("Title" = #C("DBMS"))(#Bk)) $ ]
#schem[$("AuthorName")$. ]
#why[ Two joins walk `Author` → `WrittenBy` → `Book`. This is the standard "many-to-many"
chain, and the filter is pushed to the `Book` leaf. ]
#trap[ If the title is not unique, all authors of all books with that title are returned —
which is what the question literally asks. Say so if the schema does not make `Title` a key. ]
]

#q[7.5][Find the members who borrowed the book with BookID 12. *(full schema)*][
#ans[ $ pi_("MemberID")(sigma_("BookID" = 12)(#Br)) $ ]
#schem[$("MemberID")$. ]
#why[ `Borrow` already contains both attributes; no join is needed. ]
#trap[ Projecting to `MemberID` with $pi$ removes duplicates, so a member who borrowed book 12
three times appears once. If the question asks for borrowing *events*, keep the date. ]
]

#q[7.6][Find the titles of books borrowed by the member with MemberID 5. *(full schema)*][
#ans[ $ pi_("Title")(#Bk bowtie sigma_("MemberID" = 5)(#Br)) $ ]
#schem[$("Title")$. ]
#why[ Filter on `Borrow`, join to `Book`, project the title. ]
#trap[ If the member borrowed the same title twice, the projection collapses the two rows.
That is correct under set semantics and is usually what "titles" means. ]
]

#q[7.7][Find the member names together with the titles of the books they borrowed. *(full schema)*][
#ans[ $ pi_("MemberName", "Title")(#Me bowtie #Br bowtie #Bk) $ ]
#schem[$("MemberName", "Title")$. ]
#why[ The natural join equates `MemberID` between `Member` and `Borrow`, and `BookID` between
`Borrow` and `Book`; the projection keeps only the two descriptive attributes. ]
#trap[ The result is a set of *pairs*. If a member borrowed two books with the same title, or
two members share a name, the pairs collapse — and that is correct for a pair-set. If the
question wants ids as well, include them. ]
]

#q[7.8][Find the titles of books written by any author in the set {AuthorID 3, AuthorID 5}. *(full schema)*][
#ans[ $ pi_("Title")(#Bk bowtie sigma_("AuthorID" = 3 or "AuthorID" = 5)(#Wb)) $ ]
#schem[$("Title")$. ]
#why[ A finite set of identifiers is a disjunction inside one selection. ]
#trap[ If the set has twenty members, the selection becomes unwieldy; the alternative is to
store the set as a relation and use a natural join, which is exactly the "constant relation"
technique of Q6.34. ]
]

#q[7.9][Find the books that have never been borrowed. *(full schema)*][
#ans[ $ pi_("BookID")(#Bk) - pi_("BookID")(#Br) $ ]
#schem[$("BookID")$. ]
#why[ Universe = all books; witness = any borrow row. ]
#trap[ $pi_("Title")(#Bk) - pi_("Title")(#Bk bowtie #Br)$ is the name-set version and is wrong
when two books share a title. Subtract on the key. ]
]

#q[7.10][Find the members who have never borrowed a book. *(full schema)*][
#ans[ $ pi_("MemberID")(#Me) - pi_("MemberID")(#Br) $ ]
#schem[$("MemberID")$. ]
#why[ Same negative pattern with the member as the universe. ]
#trap[ Do not subtract on `MemberName`; two members may share a name, and the difference would
delete the wrong one. ]
]

#heading(level: 2)[7.2 Set operations]

#q[7.11][Find the members who have borrowed book A (BookID 12) or book B (BookID 15). *(full schema)*][
#ans[ $ pi_("MemberID")(sigma_("BookID" = 12 or "BookID" = 15)(#Br)) $ ]
#schem[$("MemberID")$, a set. ]
#why[ One selection with a disjunction. The union form
$pi_("MemberID")(sigma_("BookID" = 12)(#Br)) union pi_("MemberID")(sigma_("BookID" = 15)(#Br))$
is equally correct. ]
#trap[ Union is *not* needed and, if written carelessly as a union of `Borrow` relations, is
still fine here (they have the same schema) — but the projection must come after the union, not
inside it, or the two sides may not line up. ]
]

#q[7.12][Find the members who have borrowed both book A and book B. *(full schema)*][
#ans[ $ pi_("MemberID")(sigma_("BookID" = 12)(#Br)) inter pi_("MemberID")(sigma_("BookID" = 15)(#Br)) $ ]
#schem[$("MemberID")$. ]
#why[ Two independent existences; intersection on the member key. ]
#trap[ The intersection cannot be taken on `Borrow` tuples: a single borrow row has one
book, so intersecting the two filtered `Borrow` relations always yields the empty set. ]
]

#q[7.13][Find the members who have borrowed book A but not book B. *(full schema)*][
#ans[ $ pi_("MemberID")(sigma_("BookID" = 12)(#Br)) - pi_("MemberID")(sigma_("BookID" = 15)(#Br)) $ ]
#schem[$("MemberID")$. ]
#why[ Difference of key sets. ]
#trap[ Note that this does *not* say "borrowed only A"; a member who borrowed A and C is
included. That is Q7.31's territory. ]
]

#q[7.14][Find the books written by author A but not by author B. *(full schema)*][
#ans[ $ pi_("BookID")(sigma_("AuthorID" = 3)(#Wb)) - pi_("BookID")(sigma_("AuthorID" = 5)(#Wb)) $ ]
#schem[$("BookID")$. ]
#why[ Both operands are sets of book identifiers. ]
#trap[ A book with *two* authors, 3 and 5, appears on both sides and is correctly excluded —
"written by A but not by B" means B is not among its authors. Check the wording: "written by A
but not by B" is not "written by A alone". ]
]

#q[7.15][Find the books that have more than one author. *(full schema)*][
#ans[ $ pi_("W1.BookID")( sigma_("W1.BookID" = "W2.BookID" and "W1.AuthorID" != "W2.AuthorID")( rho_("W1")(#Wb) times rho_("W2")(#Wb) ) ) $ ]
#schem[$("BookID")$. ]
#why[ "More than one" is "at least two distinct", which is a self-join with $!=$ on the author.
No counting is needed, because *two* is a fixed numeral: two distinct witnesses suffice. ]
#trap[ $pi_("BookID")(#Wb)$ cannot answer this. A two-author book produces two different tuples
$(b, a_1)$ and $(b, a_2)$, and projecting to `BookID` collapses them to one row — so the
projection *destroys* exactly the information you need. Duplicate rows are not duplicates of
the key. ]
]

#q[7.16][Find the authors who have not written any book. *(full schema)*][
#ans[ $ pi_("AuthorID")(#Au) - pi_("AuthorID")(#Wb) $ ]
#schem[$("AuthorID")$. ]
#why[ Universe = all authors; witness = any `WrittenBy` row. ]
#trap[ To print names, join back afterwards:
$pi_("AuthorName")(#Au bowtie (pi_("AuthorID")(#Au) - pi_("AuthorID")(#Wb)))$. ]
]

#heading(level: 2)[7.3 Division and universal queries]

#q[7.17][Find the members who have borrowed every book. *(full schema)*][
#ans[ $ pi_("MemberID", "BookID")(#Br) div pi_("BookID")(#Bk) $ ]
#schem[$("MemberID")$. ]
#why[ The dividend is projected to (answer attribute, quantified attribute); the divisor is the
whole book set. ]
#trap[ Dividing `Borrow` itself is *legal* in the full schema, because `Borrow` has attributes
(MemberID, BookID, BorrowDate, ReturnDate) and the divisor's schema is a subset — but the
result is (MemberID, BorrowDate, ReturnDate), a different and much stronger query. Project
first. ]
]

#q[7.18][Find the members who have borrowed every book in the category "DB". *(full schema)*][
#ans[ $ pi_("MemberID", "BookID")(#Br) div pi_("BookID")(sigma_("Category" = #C("DB"))(#Bk)) $ ]
#schem[$("MemberID")$. ]
#why[ The category restriction belongs inside the divisor, because it defines the quantified
set. ]
#trap[ If no book has category "DB", the divisor is empty and every member who has borrowed at
least one book is returned. State the vacuous-truth reading. ]
]

#q[7.19][Find the members who have borrowed all books written by author 7. *(full schema)*][
#ans[ $ pi_("MemberID", "BookID")(#Br) div pi_("BookID")(sigma_("AuthorID" = 7)(#Wb)) $ ]
#schem[$("MemberID")$. ]
#why[ The quantified set is computed through the relationship `WrittenBy`. ]
#trap[ A student may try to use `Author` here; only `WrittenBy` carries the link. Including
`Author` adds nothing and can hide the mistake. ]
]

#q[7.20]["Find the authors who wrote every book in a given set." Under what reading is this
expressible? *(full schema)*][
#ans[ *Not* as stated for a general set of books: "every book" is a fixed set only if the set
is named in the query. With a named set $R("S")("BookID")$ it *is* expressible:
$ pi_("AuthorID", "BookID")(#Wb) div R("S") $ ]
#schem[$("AuthorID")$. ]
#why[ Division quantifies over a *given* set. If the set is "all books in the library" it is
$pi_("AuthorID", "BookID")(#Wb) div pi_("BookID")(#Bk)$, which is a real (and usually empty)
query. If the set is "all books in some category" it is again division with a filtered
divisor. ]
#trap[ "Every book" without a qualifier means $pi_("BookID")(#Bk)$, and in practice no author
writes every book — expect the empty relation and do not "repair" it. ]
]

#q[7.21][Find the publishers that publish books in every required category, where the required
categories are given by $R("ReqCat")("Category")$. *(full schema)*][
#ans[ $ pi_("Publisher", "Category")(#Bk) div R("ReqCat") $ ]
#schem[$("Publisher")$. ]
#why[ The relation of interest is (Publisher, Category) pairs, obtained by projecting `Book`.
The divisor is the requirement relation. This is the cleanest example of "publisher covers all
categories". ]
#trap[ If the requirement is "every category that occurs in the library", use
$pi_("Publisher", "Category")(#Bk) div pi_("Category")(#Bk)$. Both are sensible; read which one
the question specifies. ]
]

#q[7.22][Find the members who have borrowed every book borrowed by member 5. *(full schema)*][
#ans[ $ pi_("MemberID", "BookID")(#Br) div pi_("BookID")(sigma_("MemberID" = 5)(#Br)) $ ]
#schem[$("MemberID")$. ]
#why[ Exactly the pattern of Q4.4 with the library schema. ]
#trap[ Member 5 appears in his own answer; whether to exclude him is a matter of the question's
wording, not of the algebra. If asked to exclude, subtract $pi_("MemberID")(sigma_("MemberID" = 5)(#Br))$. ]
]

#q[7.23][Explain the correct dividend and divisor schemas for the four division queries above.][
#tab((auto, auto, auto, auto),
  [*Query*], [*Dividend*], [*Divisor*], [*Result*],
  [7.17], [$("MemberID", "BookID")$], [$("BookID")$], [$("MemberID")$],
  [7.18], [$("MemberID", "BookID")$], [$("BookID")$ from DB books], [$("MemberID")$],
  [7.19], [$("MemberID", "BookID")$], [$("BookID")$ of author 7], [$("MemberID")$],
  [7.21], [$("Publisher", "Category")$], [$("Category")$ required], [$("Publisher")$],
)
#v(2pt)
#mini[In every case the dividend is exactly "answer attributes $union$ divisor attributes", and the divisor is exactly the set being quantified over. Nothing else is allowed.]
]

#heading(level: 2)[7.4 Advanced queries]

#q[7.24][Find the most-borrowed book (the book borrowed the largest number of times), without
using counting. Is it expressible? *(full schema)*][
#nex[ "Most borrowed" compares *counts* of borrow rows. Classical relational algebra cannot
count, so the query is *not expressible*. ]
#ans[ Not expressible. It becomes expressible with the extended operator $gamma$:
$ gamma_("BookID"; "count"("MemberID") arrow.l n)(#Br) $, then the maximum-of-values pattern on
$n$, then a join back to `Book` for the title. ]
#why[ This is *the* example examiners use to test whether you understand the limits of the
algebra. Note the contrast with "the most expensive book", which *is* expressible because price
is a stored value; "most borrowed" is a stored *count* that must be computed. ]
#trap[ A very common wrong answer is "the book that is not dominated by any other book", where
domination is defined by a self-join on `BookID` — but counting has no tuple-level
counterpart, so the natural expressions either return all books or none. If you write one,
explain why it does not compute the maximum count. ]
]

#q[7.25][Find the latest borrowing date. *(full schema)*][
#ans[ $ pi_("BorrowDate")(#Br) - pi_("B1.BorrowDate")( sigma_("B1.BorrowDate" < "B2.BorrowDate")( rho_("B1")(#Br) times rho_("B2")(#Br) ) ) $ ]
#schem[$("BorrowDate")$. ]
#why[ The standard maximum-of-values pattern (Q5.1) applied to a date attribute. With ISO
dates, the string comparison $<$ coincides with the chronological one. ]
#trap[ If dates are stored as $"DD/MM/YYYY"$, string comparison is chronological only within a
year and only if zero-padded. State the assumption or compare components. ]
]

#q[7.26][Find the members who borrowed books on at least two distinct dates. *(full schema)*][
#ans[ $ pi_("MemberID")( sigma_("B1.MemberID" = "B2.MemberID" and "B1.BorrowDate" != "B2.BorrowDate")( rho_("B1")(#Br) times rho_("B2")(#Br) ) ) $ ]
#schem[$("MemberID")$. ]
#why[ Self-join with equality on the member and inequality on the date. ]
#trap[ Do not use the natural join: `Borrow` has three shared attributes with its renamed copy
and the join would require the rows to be identical. Use $times$ plus explicit conditions. ]
]

#q[7.27][Find the books borrowed by every member in the set {MemberID 1, MemberID 2}. *(full schema)*][
#ans[ $ pi_("BookID", "MemberID")(#Br) div pi_("MemberID")(sigma_("MemberID" = 1 or "MemberID" = 2)(#Me)) $ ]
#schem[$("BookID")$. ]
#why[ The divisor is a constant relation built by selection — Q6.34's technique. ]
#trap[ If one of the two members does not exist in `Member`, the divisor has one row instead
of two and the answer silently changes. Build the constant relation explicitly if the question
supplies it as data. ]
]

#q[7.28][Find the authors who have written books in every category in $R("ReqCat")("Category")$. *(full schema)*][
#ans[ We need an author–category relation. Build it by joining:
$ R("AC") = pi_("AuthorID", "Category")(#Wb bowtie #Bk) $
and then divide: $ R("AC") div R("ReqCat") $. ]
#schem[$R("AC")$: $("AuthorID", "Category")$. Result: $("AuthorID")$. ]
#why[ Division needs a binary relation pairing the answer attribute with the quantified
attribute. That relation does not exist in the schema; you must *derive* it by joining
`WrittenBy` with `Book`. This "derive the relation, then divide" step is what the question is
really testing. ]
#trap[ Trying to divide `WrittenBy` directly fails because its schema is
(BookID, AuthorID) and `Category` never appears. The join is not optional. ]
]

#q[7.29][Find the members who have borrowed books by every author in the set {3, 5}. *(full schema)*][
#ans[ Let $R("MB") = pi_("MemberID", "AuthorID")(#Br bowtie #Wb)$. Then
$ R("MB") div pi_("AuthorID")(sigma_("AuthorID" = 3 or "AuthorID" = 5)(#Au)) $ ]
#schem[$R("MB")$: $("MemberID", "AuthorID")$. Result: $("MemberID")$. ]
#why[ Again the binary relation must be derived. Note the join path:
`Borrow` → `WrittenBy` on `BookID`. ]
#trap[ A member who borrowed a book with *both* authors 3 and 5 satisfies the condition with a
single borrow. That is correct for the "has borrowed a book by every author" reading, and it is
the reading division implements. ]
]

#q[7.30][Find the books that were borrowed but never returned. State the NULL convention. *(full schema)*][
#note[
  Classical relational algebra has no NULL. Two conventions are possible and the answer must
  say which one is in force.
  *(a) Sentinel convention.* $A("ReturnDate") = #C("⊥")$ marks "not yet returned". Then the
  answer is a straightforward selection.
  *(b) Null convention.* $A("ReturnDate")$ may be NULL for "unknown", and comparison with NULL
  is never true. Then "not returned" is *not* the complement of "returned": an unknown return
  date does not prove the book is outstanding. The honest classical answer is "not
  expressible", and the honest SQL answer needs `IS NULL`.
]
#ans[ Under convention *(a)*:
$ pi_("BookID", "MemberID")(sigma_("ReturnDate" = #C("⊥"))(#Br)) $
Under convention *(b)*: not expressible in classical relational algebra without extending
the schema; with SQL NULL semantics it is `WHERE ReturnDate IS NULL`. ]
#schem[$("BookID", "MemberID")$ — or add `BorrowDate` if individual loans are wanted. ]
#why[ The trap is the word "never": a book returned once and borrowed again and not yet
returned *is* currently outstanding, but it was returned at least once. The expression above
answers the *current* state; the historical question needs a division over loan events. ]
#trap[ $pi_("BookID")(#Br) - pi_("BookID")(sigma_("ReturnDate" != #C("⊥"))(#Br))$ looks right
and is right under convention (a) — it is the same set. Under convention (b) it is wrong
because `!= NULL` is not true. State the convention before you write the expression. ]
]

#q[7.31][Find the members who have borrowed only books from the category "DB". *(full schema)*][
#ans[ $ pi_("MemberID")(#Br) - pi_("MemberID")( sigma_("Category" != #C("DB"))(#Br bowtie #Bk) ) $ ]
#schem[$("MemberID")$. ]
#why[ Pattern 5: members with at least one borrow, minus members with a non-DB borrow. The join
with `Book` is performed once, inside the subtracted term. ]
#trap[ "Only DB books" excludes members who borrowed nothing, because they are not in
$pi_("MemberID")(#Br)$. If the intended reading is "vacuously only DB", use
$pi_("MemberID")(#Me) - pi_("MemberID")(sigma_("Category" != #C("DB"))(#Br bowtie #Bk))$ and say
so. Also note that $sigma_("Category" != #C("DB"))$ is the complement of
$sigma_("Category" = #C("DB"))$ only when `Category` is never NULL. ]
]

#q[7.32][Find the members who have borrowed books from category A but none from category B.
*(full schema)*][
#ans[ $ pi_("MemberID")(sigma_("Category" = #C("A"))(#Br bowtie #Bk)) - pi_("MemberID")(sigma_("Category" = #C("B"))(#Br bowtie #Bk)) $ ]
#schem[$("MemberID")$. ]
#why[ Two independent existential conditions, one positive and one negative, combined by
difference. ]
#trap[ A member who borrowed a book that is *both* A and B (impossible here, since category is
a single attribute — but possible if categories were multi-valued) would be excluded. With a
multi-valued category, the second term should select on the same book. Say which model you
use. ]
]

#q[7.33][Find the pairs of members who have borrowed exactly the same set of books. *(full
schema)*][
#ans[ Let $R("MB") = pi_("MemberID", "BookID")(#Br)$ and let
$R("Pairs") = pi_("MemberID")(#Me) times pi_("MemberID")(#Me)$ be every ordered pair of
members. Define the *violation* relation

#eq[$ R("V") = pi_("A.mid", "A.bid", "B.mid")( rho_("A")(R("MB")) times rho_("Mem")(pi_("MemberID")(#Me)) ) - pi_("A.mid", "A.bid", "B.mid")( sigma_("A.bid" = "B.bid")( rho_("A")(R("MB")) times rho_("B")(R("MB")) ) ) $]

Then $R("Bad") = pi_("A.mid", "B.mid")(R("V"))$ holds the ordered pairs $(a, b)$ such that
$a$ has a book that $b$ lacks, and the answer is

#eq[$ R("Pairs") - R("Bad") - rho_("A.mid" arrow.l "B.mid", "B.mid" arrow.l "A.mid")(R("Bad")) $]
]
#schem[$R("MB")$: $("MemberID", "BookID")$. $R("Pairs")$: $("MemberID", "MemberID")$.
$R("V")$: three attributes — a member, a book, and a member who lacks that book.
$R("Bad")$: two member ids. The final difference has the same schema as $R("Pairs")$. ]
#why[ "Exactly the same set" is *two* coverage conditions: $a$ covers $b$ and $b$ covers $a$.
The violation relation $R("V")$ computes, for every ordered pair and every book, whether the
first member has the book while the second does not — a three-place statement that needs three
tuple variables. Subtracting the projection of $R("V")$ removes every pair where coverage
fails in one direction; subtracting the *swapped* version removes failures in the other. ]
#note[
  The compact textbook statement is "$(a, b)$ such that each has borrowed every book the other
  has", i.e. two divisions. The expression above is that statement written out with the five
  primitive operators, and it is what to produce if the question forbids division. Note that
  the diagonal pair $(a, a)$ survives, which is correct: every member has borrowed exactly the
  same books as himself. Remove it with $sigma_("A.mid" != "B.mid")$ if unordered distinct
  pairs are wanted.
]
#trap[ Testing only one direction returns all pairs $(a, b)$ where $b$ borrowed everything $a$
did — a *superset* condition, not equality. Both directions are required, and it is the second
subtraction that makes the query symmetric. ]
]
