# Demo — preview the pipeline without your own files

`make_sample_materials.py` generates a small Biology 101 lecture (a **PDF handout**
and a **PowerPoint deck**) so you can see the whole convert-to-Markdown flow on
realistic input before using your own school materials.

## Run it

```bash
# 1) Install demo-only dependencies (reportlab makes the PDF; python-pptx the deck).
#    python-pptx is already present if you ran setup.sh / installed markitdown[all].
pip install reportlab python-pptx

# 2) Generate the sample files into study-tools/input/
python study-tools/demo/make_sample_materials.py

# 3) Convert them to Markdown
./study-tools/convert.sh

# 4) Look at the results in study-tools/markdown/
```

You can pass a different output folder as an argument:

```bash
python study-tools/demo/make_sample_materials.py /tmp/my-demo-input
```

## What to expect

- **`photosynthesis-slides.pptx` → Markdown**: clean — each slide becomes a heading
  with its bullet points.
- **`photosynthesis-handout.pdf` → Markdown**: good, but PDFs can show occasional
  glyph/spacing artifacts depending on how they were created. This is normal for
  PDF extraction; PPTX and DOCX are usually cleaner.

Then upload the generated `.md` files into a Claude Project and try prompts like
*"Quiz me on photosynthesis using only these notes"* — see `../STUDY-GUIDE.md`.
