# Turn your school materials into Markdown for token-efficient Claude study sessions

Convert a whole folder of school material — **PDFs, PowerPoints, Word docs, Excel
sheets, YouTube videos, and article links** — into Markdown with **one command**,
then drag the result into a Claude Project for focused, cheap study sessions.

## How it works

```
~/Desktop/StudyMaterials/Pharmacology/     ← you drag your files in here
        │
        │   studyprep Pharmacology
        ▼
~/Desktop/StudyMaterials/Pharmacology/markdown/   ← drag this into a Claude Project
```

Your original files are **never modified or moved**. The Markdown lands in a new
`markdown` subfolder inside the subject folder.

### Why convert at all?

- **Avoids expensive vision tokens.** An image-heavy PDF uploaded directly can be
  processed as page images, which costs far more than plain text.
- **Strips layout noise** — headers, footers, page numbers, column artifacts.
- **A Claude Project loads it once** and reuses it across every chat, instead of
  re-uploading each session.

---

## One-time setup

You need **Python 3.10+** (macOS: `python3 --version` to check).

```bash
cd /path/to/markitdown
./study-tools/install.sh
```

That single command:
1. creates a Python environment and installs MarkItDown,
2. makes `studyprep` runnable from **any** folder,
3. creates `~/Desktop/StudyMaterials/`.

Then **open a new Terminal window** so the `studyprep` command is picked up.

---

## Everyday use

1. In Finder, open **`~/Desktop/StudyMaterials`**
2. Make a folder for the subject, e.g. **`Pharmacology`**
3. Drag in your PDFs, slides, and documents
4. *(Optional)* create a **`urls.txt`** in that folder with YouTube or article
   links, one per line:
   ```
   # lines starting with # are ignored
   https://www.youtube.com/watch?v=VIDEO_ID
   https://en.wikipedia.org/wiki/Photosynthesis
   ```
5. In Terminal — from anywhere:
   ```bash
   studyprep Pharmacology
   ```
6. Drag the new **`markdown`** folder into a Claude Project.

Running `studyprep` with no arguments lists your available subjects.
You can also pass a full path to any folder: `studyprep ~/Downloads/lecture-stuff`.

### No terminal? Double-click instead

Double-click **`study-tools/StudyPrep.command`** in Finder. It opens a window,
lists your subjects, and you pick one by number.

> First time only: if macOS refuses to open it, right-click the file → **Open** →
> **Open**, or run `chmod +x study-tools/StudyPrep.command` once.

<details>
<summary>Optional: right-click any folder → “Convert to Markdown”</summary>

1. Open **Automator** → **New** → **Quick Action**
2. Set *“Workflow receives current”* to **folders** in **Finder**
3. Add the **Run Shell Script** action, set *Pass input* to **as arguments**
4. Paste:
   ```bash
   for f in "$@"; do
     /full/path/to/markitdown/study-tools/studyprep "$f"
   done
   ```
5. Save it as **Convert to Markdown**

Now right-click any folder in Finder → Quick Actions → **Convert to Markdown**.
</details>

---

## What you get back

Every run writes a **`conversion-report.md`** into the `markdown` folder listing
what converted, what needs attention, and what failed **with the reason**. Nothing
fails silently. Examples:

- a YouTube video with **no captions** → flagged, because there is no transcript to extract
- a **scanned PDF** with no text layer → flagged as "likely a scan or images"
- a damaged or misnamed file → flagged with the actual error

---

## Important: images, diagrams, and tables

| What's in your file | Converted to Markdown? |
| --- | --- |
| **Real text tables** (selectable text) | ✅ Yes — becomes a proper Markdown table |
| **Diagrams / figures / photos** | ❌ No — images are skipped |
| **Scanned pages, or tables that are pictures** | ❌ No — there's no text to extract (you'll be warned) |

**What to do about diagrams:** don't try to convert them. **Screenshot the figure
and attach the image to your Claude Project** alongside the Markdown files —
Claude reads images natively. That's free, immediate, and works better than OCR
for most study material.

---

## Studying in Claude

Create a **Project** (claude.ai → Projects → Create Project), upload the contents
of the `markdown` folder into the project knowledge, and start chats inside it.
Every conversation is grounded on that material only, loaded once. Try:

- *"Quiz me on chapter 3 using only my notes."*
- *"Make flashcards from the lecture slides."*
- *"Explain the Krebs cycle the way my professor did, then test me."*

---

## Optional: convert on-the-fly inside Claude Desktop (MCP connector)

This repo also ships an MCP server so Claude Desktop can convert a file or URL
during a chat. Good for quick one-offs; the Project workflow above is still better
for a reusable study library.

1. Build the image:
   ```bash
   cd packages/markitdown-mcp
   docker build -t markitdown-mcp:latest .
   ```
2. Claude Desktop → Settings → Developer → Edit Config, and add (mounting your
   study folder so Claude can reach local files):
   ```json
   {
     "mcpServers": {
       "markitdown": {
         "command": "docker",
         "args": [
           "run", "--rm", "-i",
           "-v", "/Users/YOUR_NAME/Desktop/StudyMaterials:/workdir",
           "markitdown-mcp:latest"
         ]
       }
     }
   }
   ```
3. Restart Claude Desktop. Ask it to convert `file:///workdir/Biology/notes.pdf`
   or any URL. It exposes one tool, `convert_to_markdown(uri)`.

> Not using Docker? `pip install markitdown-mcp` and use `"command": "markitdown-mcp"`.
> Security: the server runs with your user's permissions and binds to localhost only.
> See `packages/markitdown-mcp/README.md`.

---

## Quick reference

| Task | Command |
| --- | --- |
| One-time setup | `./study-tools/install.sh` |
| Convert a subject | `studyprep Pharmacology` |
| List your subjects | `studyprep` |
| Convert any folder | `studyprep ~/Downloads/stuff` |
| No terminal | double-click `study-tools/StudyPrep.command` |
| Try it with samples | see `study-tools/demo/README.md` |

Supported inputs include PDF, PPTX, DOCX, XLSX/XLS, HTML, CSV, JSON, XML, EPUB,
Jupyter notebooks, Outlook `.msg`, plus YouTube and article URLs.
