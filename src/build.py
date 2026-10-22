# Builds the PDF:  python src/build.py
import typst, pathlib
here = pathlib.Path(__file__).parent
out = here.parent / "Relational-Algebra-Complete-Question-Bank.pdf"
out.write_bytes(typst.compile(str(here / "main.typ")))
print("wrote", out)
