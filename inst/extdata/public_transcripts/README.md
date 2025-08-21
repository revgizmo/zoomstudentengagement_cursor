## Public Course Transcripts (Real, Publicly Available)

This folder is for real VTT transcripts from public multi-session courses. Our aim is to use public course caption files as internal test examples while respecting licenses and participant consent.

### Sources targeted
- Harvard CS50 (multi-session course)
  - Site: https://cs50.harvard.edu/x/
  - Videos: YouTube CS50 channel (public, multi-year, CC BY-NC-SA)
- MIT OpenCourseWare (multi-session courses)
  - Site: https://ocw.mit.edu/
  - Many videos provide captions/transcripts under CC BY-NC-SA
- Selected university public lectures and municipal meetings (Zoom-based) where captions/transcripts are published under public/open licenses

We store citations and URLs in `sources.csv`. To keep repository size reasonable and respect upstream ownership, the recommended approach is to re-download caption files using the provided script when needed.

### Folder layout
```
inst/extdata/public_transcripts/
  harvard_cs50/           # CS50 lecture captions (.vtt)
  mit_ocw/                # MIT OCW lecture captions (.vtt)
  stanford/               # Stanford open lectures (.vtt)
  sources.csv             # Course-level citation and license notes
  download_public_vtts.sh # Helper to fetch VTTs (needs yt-dlp)
  verify_public_transcripts.R # Quick parse/verify script
```

### Licensing and usage
- Always honor each source’s license terms. Many courses are CC BY-NC-SA or similar.
- Retain attribution and do not remove embedded copyright notices.
- Use strictly for internal testing/examples within this repository context.

### How to fetch caption VTT files
Use `download_public_vtts.sh` to fetch a small representative set of VTT caption files per course. The script requires `yt-dlp`.

- Install yt-dlp using pipx (preferred):
  - `pipx install yt-dlp`
- Or create a venv and install:
  - `python3 -m venv .venv && . .venv/bin/activate && pip install yt-dlp`
- Then run:
  - `bash inst/extdata/public_transcripts/download_public_vtts.sh`

The script fetches English VTT captions (manual if available, otherwise auto) for several known lectures in each series and stores them under the appropriate course folder.

### Notes
- If some sources block direct programmatic access, you may need to fetch a small subset manually and place the `.vtt` files into the corresponding course subfolder.
- Where captions are not provided in VTT but another format is available (e.g., SRT), you can convert to VTT with `ffmpeg -i input.srt output.vtt`.
- Keep the dataset modest (e.g., 3–5 sessions per course) to maintain repo and CI performance.