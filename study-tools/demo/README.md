# Demo — try the tool without your own files

`make_sample_materials.py` generates a small Biology 101 lecture (a **PDF handout**
and a **PowerPoint deck**) so you can watch the whole flow work before using your
real school material.

## Run it

```bash
# 1) Demo-only dependency (python-pptx already comes with the main install)
pip install reportlab

# 2) Generate sample files into ~/Desktop/StudyMaterials/Demo
python study-tools/demo/make_sample_materials.py

# 3) Convert them
studyprep Demo

# 4) Look in ~/Desktop/StudyMaterials/Demo/markdown/
```

Pass a different folder if you like:

```bash
python study-tools/demo/make_sample_materials.py ~/Desktop/StudyMaterials/Biology
```

## What to expect

- **`photosynthesis-slides.pptx` → Markdown**: clean — each slide becomes a heading
  with its bullet points.
- **`photosynthesis-handout.pdf` → Markdown**: good, though PDFs can show occasional
  glyph or spacing artifacts depending on how they were made. PPTX and DOCX are
  usually cleaner.

Then upload the generated `.md` files into a Claude Project and try
*"Quiz me on photosynthesis using only these notes."* See `../STUDY-GUIDE.md`.
