# Relational Algebra — Complete Solved Question Bank

**[Download the PDF](Relational-Algebra-Complete-Question-Bank.pdf)** — 84 pages, B.Tech CSE (MANIT Bhopal pattern).

Classical relational algebra only (π, σ, ρ, ∪, −, ×, ⋈, ∩, ÷). No SQL. No aggregate functions.
Every question has: statement, expression, intermediate schemas, step-by-step derivation, plain-language
explanation, and common mistakes / edge cases.

## Contents

| Part | Topic |
|---|---|
| 1 | Short notes, operator reference, union compatibility, division, 20-pattern catalogue |
| 2 | Basic university-level questions (selection, projection, rename, joins) |
| 3 | Joins, self-joins, set operations, negative / "never" queries |
| 4 | Division, "all / every / only", universal quantification |
| 5 | Maximum, minimum, ranking, ties, group-wise extremes, k-th highest |
| 6 | Sailors & Boats — all 37 required queries |
| 7 | Books, Authors and Borrowing — 33 queries, full + simplified schema |
| 8 | Hospital & Prescription — the 5 exam questions + 22 more |
| 9 | Advanced mixed multi-technique queries |
| 10 | Query equivalence, error detection, counterexamples, the 11 confusable sentence pairs |
| 11 | Practice paper (questions only, exam timing) |
| 12 | Answer key, marking scheme, coverage checklist |

## Rebuilding

```bash
pip install typst
python src/build.py
```

Source is Typst in `src/` (`main.typ` imports `lib.typ` for macros and `part01.typ` … `part12.typ`).
