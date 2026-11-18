#!/usr/bin/env bash
# EarnOnGTA6 clip maker: turns a source video into a ready-to-post vertical clip.
#   - trims to start/end
#   - 1080x1920 (9:16): source centered over a blurred fill (no black bars)
#   - big hook text at the top (visible from the first frame)
#   - optional burned-in captions from an .srt file (large, centered, high contrast)
#   - credit line ("🎥 @creator" style) above the bottom UI safe zone
#   - MP4, H.264, AAC, 30 fps, faststart (works on X, Reels, TikTok, Shorts, Threads)
#
# Usage:
#   tools/make_clip.sh -i SOURCE -s START -e END -k "HOOK TEXT" -c "@creator" [-S captions.srt] [-o out.mp4]
#
#   SOURCE  local file or direct .mp4 URL (a file you have the right to use; see clipping-workflow.md)
#   START/END  timestamps like 00:01:12.5 or 72.5. Keep clips 7 to 30 s.
#
# Example:
#   tools/make_clip.sh -i media/raw/0007-src.mp4 -s 00:02:10 -e 00:02:28 \
#     -k "THE HIDDEN CAR NOBODY FOUND" -c "@creatorname" -o media/edits/0007.mp4
#
# Env: FONT (fontconfig name, default "Inter Display:style=Bold", falls back automatically)
set -euo pipefail

in="" ss="" to="" hook="" credit="" srt="" out=""
while getopts "i:s:e:k:c:S:o:h" opt; do
  case $opt in
    i) in=$OPTARG;; s) ss=$OPTARG;; e) to=$OPTARG;; k) hook=$OPTARG;;
    c) credit=$OPTARG;; S) srt=$OPTARG;; o) out=$OPTARG;;
    *) sed -n '2,22p' "$0"; exit 1;;
  esac
done
[[ -z $in || -z $ss || -z $to || -z $hook || -z $credit ]] && { sed -n '2,22p' "$0"; echo; echo "Missing a required flag (-i -s -e -k -c). Every clip needs a hook and a credit."; exit 1; }
command -v ffmpeg >/dev/null || { echo "ffmpeg is not installed"; exit 1; }
[[ -n $srt && ! -f $srt ]] && { echo "Captions file not found: $srt"; exit 1; }

to_sec() { awk -F: '{s=0; for(i=1;i<=NF;i++) s=s*60+$i; print s}' <<<"$1"; }
dur=$(awk -v a="$(to_sec "$ss")" -v b="$(to_sec "$to")" 'BEGIN{printf "%.3f", b-a}')
awk -v d="$dur" 'BEGIN{exit !(d>0)}' || { echo "END must be after START"; exit 1; }
awk -v d="$dur" 'BEGIN{exit !(d>60)}' && echo "Warning: ${dur}s is long. 7 to 30 s is our default."

out=${out:-media/edits/clip-$(date +%Y%m%d-%H%M%S).mp4}
mkdir -p "$(dirname "$out")"
font=${FONT:-"Inter Display:style=Bold"}
fc-match -q "$font" 2>/dev/null || true

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
# Hook: uppercase, wrapped to ~16 chars per line so it stays big and inside the safe area
# On-screen text drops emoji (most video fonts can't draw them; keep emoji for the caption)
noemoji() { perl -CSD -pe 's/[^\x{0000}-\x{2BFF}]//g; s/[\x{2600}-\x{27BF}]//g; s/^\s+|\s+$//g'; }
printf '%s' "$hook" | noemoji | tr '[:lower:]' '[:upper:]' | fold -s -w 16 | sed 's/[[:space:]]*$//' > "$tmp/hook.txt"
printf '%s' "$credit" | noemoji > "$tmp/credit.txt"

esc() { sed -e 's/\\/\\\\/g' -e "s/:/\\\\:/g" -e "s/'/\\\\'/g" -e 's/,/\\,/g' <<<"$1"; }
fc="[0:v]split=2[bgsrc][fgsrc];"
fc+="[bgsrc]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,boxblur=24:2,eq=brightness=-0.12[bg];"
fc+="[fgsrc]scale=1080:1920:force_original_aspect_ratio=decrease[fg];"
fc+="[bg][fg]overlay=(W-w)/2:(H-h)/2,setsar=1,fps=30"
fc+=",drawtext=font='$(esc "$font")':textfile='$(esc "$tmp/hook.txt")':fontsize=82:fontcolor=white:line_spacing=10:borderw=7:bordercolor=black:x=(w-text_w)/2:y=230"
if [[ -n $srt ]]; then
  # Convert to ASS at 1080x1920 so caption size/position are in real pixels
  ffmpeg -hide_banner -loglevel error -y -i "$srt" "$tmp/cap.ass"
  sed -i -e 's/^PlayResX:.*/PlayResX: 1080/' -e 's/^PlayResY:.*/PlayResY: 1920/' \
    -e 's/^Style: Default,.*/Style: Default,Inter Display,72,\&H00FFFFFF,\&H00FFFFFF,\&H00000000,\&H00000000,-1,0,0,0,100,100,0,0,1,5,0,2,60,60,470,1/' "$tmp/cap.ass"
  fc+=",ass='$(esc "$tmp/cap.ass")'"
fi
fc+=",drawtext=font='$(esc "$font")':textfile='$(esc "$tmp/credit.txt")':fontsize=44:fontcolor=white:borderw=4:bordercolor=black:x=(w-text_w)/2:y=h-380[v]"

ffmpeg -hide_banner -loglevel error -y -ss "$ss" -t "$dur" -i "$in" \
  -filter_complex "$fc" -map "[v]" -map "0:a?" \
  -c:v libx264 -preset medium -crf 20 -profile:v high -pix_fmt yuv420p \
  -c:a aac -b:a 160k -ar 48000 -movflags +faststart "$out"

echo "Done: $out (${dur}s, 1080x1920)"
echo "Next: QA checklist in clipping-workflow.md, then log it in log.md"
