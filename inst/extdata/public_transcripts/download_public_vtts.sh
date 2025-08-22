#!/usr/bin/env bash
set -euo pipefail

# Download a small representative set of caption VTT files for public multi-session courses.
# Requirements: yt-dlp installed and available on PATH.

out_root="$(dirname "$0")"

require_tool() {
	command -v "$1" >/dev/null 2>&1 || { echo "ERROR: $1 not found on PATH" >&2; exit 1; }
}

require_tool yt-dlp

# Function to fetch English VTT captions for a given YouTube URL into a folder
fetch_vtt() {
	local url="$1"
	local outdir="$2"
	mkdir -p "$outdir"
	# Try manual subtitles first, then auto as fallback
	yt-dlp --skip-download --write-sub --sub-lang en --sub-format vtt -o "$outdir/%(title)s.%(id)s.%(ext)s" "$url" || \
	yt-dlp --skip-download --write-auto-sub --sub-lang en --sub-format vtt -o "$outdir/%(title)s.%(id)s.%(ext)s" "$url"
}

# Harvard CS50 (example lectures)
cs50_dir="$out_root/harvard_cs50"
fetch_vtt "https://www.youtube.com/watch?v=8mAITcNt710" "$cs50_dir"  # Lecture 0
fetch_vtt "https://www.youtube.com/watch?v=YoXxevp1WRQ" "$cs50_dir"  # Lecture 1
fetch_vtt "https://www.youtube.com/watch?v=1YQlLMuAqFo" "$cs50_dir"  # Lecture 2

# MIT OCW (choose specific lecture videos that have captions)
mit_dir="$out_root/mit_ocw"
fetch_vtt "https://www.youtube.com/watch?v=k6U-i4gXkLM" "$mit_dir"   # Example OCW Python intro video (captioned)
fetch_vtt "https://www.youtube.com/watch?v=3t9lM3i3fOg" "$mit_dir"

# Stanford Online Algorithms (playlist examples)
stan_dir="$out_root/stanford"
fetch_vtt "https://www.youtube.com/watch?v=A4JZ8iK1v3k" "$stan_dir"
fetch_vtt "https://www.youtube.com/watch?v=U2P2V_An2xU" "$stan_dir"

echo "Download complete. Files stored under: $out_root"