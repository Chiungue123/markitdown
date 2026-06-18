# Turn your school materials into Markdown for token-efficient Claude study sessions

This guide shows how to use **MarkItDown** (the tool in this repo) to convert
**PDFs, PowerPoint, Word documents, and YouTube videos** into Markdown, then use
those Markdown files in Claude for focused, one-on-one studying on *only* that
material.

## The mental model (read this first)

MarkItDown is a **tool that runs on your own computer**. It is **not** a connector
that you drop a PDF into a Claude chat and it auto-converts. The flow is:

```
   your files  ──►  MarkItDown (on your computer)  ──►  clean .md files  ──►  Claude
```

You convert first, then bring the Markdown into Claude. The most efficient way to
do that is a **Claude Project** (explained below), where you upload the material
once and every chat in the project stays scoped to it.

### Why bother converting to Markdown?

Markdown is plain, structured text. A raw PDF or PowerPoint carries a lot of
layout/binary overhead and often extracts messily. Converting to Markdown strips
that away, so Claude spends its context (tokens) on the actual *content* of your
notes instead of formatting noise — cheaper sessions, and the model "sees" the
material more cleanly.

---

## 1. One-time setup

You need **Python 3.10 or newer**. In a terminal:

```bash
# Create an isolated environment so this doesn't touch the rest of your system
python -m venv .venv
source .venv/bin/activate          # Windows (PowerShell): .venv\Scripts\Activate.ps1

# Install MarkItDown with support for every file type
pip install 'markitdown[all]'
```

> Want a smaller install? Install only what you need:
> `pip install 'markitdown[pdf,pptx,docx,youtube-transcription]'`

Verify it works:

```bash
markitdown --version
```

---

## 2. Convert a single file

The basic command is `markitdown <input> -o <output.md>`:

```bash
# PDF
markitdown lecture-notes.pdf -o lecture-notes.md

# PowerPoint slides
markitdown chapter3-slides.pptx -o chapter3-slides.md

# Word document
markitdown essay-prompt.docx -o essay-prompt.md

# YouTube video (pulls the title, description, metadata, and transcript)
markitdown "https://www.youtube.com/watch?v=VIDEO_ID" -o lecture-video.md
```

> **YouTube note:** MarkItDown extracts the video's **transcript**, so the video
> must have captions (manual or auto-generated). No captions → no transcript.

---

## 3. Convert a whole folder at once (recommended)

Converting files one by one is tedious. Use the included **`convert.sh`** script to
process an entire folder — plus a list of YouTube URLs — in one command.

```bash
# 1) Put your source files in an "input" folder
mkdir -p study-tools/input
#    ...copy your .pdf / .pptx / .docx / .xlsx files into study-tools/input...

# 2) (Optional) list YouTube lectures, one URL per line:
#    study-tools/input/youtube-urls.txt
#    (blank lines and lines starting with # are ignored)

# 3) Run the converter
cd study-tools
./convert.sh                       # defaults: input -> ./input, output -> ./markdown
# or specify folders explicitly:
./convert.sh ~/Desktop/biology-class ~/Desktop/biology-md
```

You'll get one `.md` file per input, plus a summary like
`Done: 7 converted, 0 failed.` The Markdown files land in the output folder
(default `study-tools/markdown`), ready to hand to Claude.

> First run? If you see an error that `markitdown` isn't found, you missed the
> install step — the script prints the exact `pip install` command to fix it.

---

## 4. Use the Markdown in Claude — the token-efficient way

### Recommended: a Claude **Project** (load once, study many times)

This is the most efficient pattern for "study only this material" sessions:

1. Go to **claude.ai → Projects → Create Project** (e.g. "Biology — Midterm").
2. Open the project's **knowledge / files** area and **upload your `.md` files**
   (the ones from `study-tools/markdown`).
3. Now start chats *inside that project*. Every conversation is grounded on that
   material, and you only paid the token cost of loading it **once** — not on every
   message. Ask things like *"Quiz me on chapter 3,"* *"Explain mitosis using only
   my lecture notes,"* or *"Make flashcards from the slides."*

Because the material lives in the project, you can have many separate study
sessions without re-uploading, and Claude stays focused on *your* content.

### Quick alternative: a one-off chat

For a single document, just attach or paste the `.md` file into a normal chat. Good
for a quick question; less efficient if you'll study the same material repeatedly.

---

## 5. Optional: convert on-the-fly *inside* Claude Desktop (MCP connector)

If you use the **Claude Desktop** app, this repo also ships an MCP server
(`markitdown-mcp`) that lets Claude convert a file or URL to Markdown *during* a
chat — handy for quick, ad-hoc conversions without dropping to a terminal. It
exposes a single tool, `convert_to_markdown(uri)`, accepting `file:`, `http:`,
`https:`, and `data:` URIs.

> For building a **reusable study library**, the Project workflow in section 4 is
> still the better choice. Use the MCP connector for one-off "convert this real
> quick" moments.

### Setup (Docker is the recommended way)

1. Build the image from the MCP package folder in this repo:
   ```bash
   cd packages/markitdown-mcp
   docker build -t markitdown-mcp:latest .
   ```

2. Open Claude Desktop's config file
   (Claude Desktop → Settings → Developer → Edit Config, which opens
   `claude_desktop_config.json`) and add:

   ```json
   {
     "mcpServers": {
       "markitdown": {
         "command": "docker",
         "args": ["run", "--rm", "-i", "markitdown-mcp:latest"]
       }
     }
   }
   ```

3. To let it read **local files**, mount the folder that holds your materials into
   the container. Everything under that folder then appears under `/workdir`:

   ```json
   {
     "mcpServers": {
       "markitdown": {
         "command": "docker",
         "args": [
           "run", "--rm", "-i",
           "-v", "/Users/you/study-materials:/workdir",
           "markitdown-mcp:latest"
         ]
       }
     }
   }
   ```

   Then in Claude you can ask it to convert e.g. `file:///workdir/lecture.pdf` or a
   YouTube URL, and it returns Markdown inline.

4. Restart Claude Desktop. (Prefer not to use Docker? `pip install markitdown-mcp`
   and use `"command": "markitdown-mcp"` with no args instead.)

> **Security note:** the MCP server runs with your user's permissions and can read
> any file that user can access. It binds to `localhost` only. Don't expose it to
> the network. See `packages/markitdown-mcp/README.md` for full details.

---

## Quick reference

| Task | Command |
| --- | --- |
| Install everything | `pip install 'markitdown[all]'` |
| Convert one PDF | `markitdown notes.pdf -o notes.md` |
| Convert PowerPoint | `markitdown slides.pptx -o slides.md` |
| Convert Word doc | `markitdown paper.docx -o paper.md` |
| Convert YouTube | `markitdown "https://youtu.be/ID" -o video.md` |
| Convert a whole folder | `./study-tools/convert.sh INPUT_DIR OUTPUT_DIR` |
| Best way to study in Claude | Upload the `.md` files into a **Claude Project** |

Supported input formats also include Excel, HTML, images, audio, EPUB, CSV, JSON,
and ZIP archives — see the main `README.md` for the full list.
