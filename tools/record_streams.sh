#!/usr/bin/env bash
# EarnOnGTA6 multi-streamer recorder (run on the owner's computer).
# Records each channel in streamers-live.txt to 30-minute files, one recorder per channel,
# saved into the Google Drive "EarnOnGTA6 Clip Drop" folder (sync it with Google Drive for desktop).
#
# Requires: streamlink (pip install streamlink) and ffmpeg (for segment checks).
# Usage:   tools/record_streams.sh "/path/to/Google Drive/My Drive/EarnOnGTA6 Clip Drop" [channels-file]
# Stop:    Ctrl+C, or kill the PIDs printed on start.
#
# channels-file: one line per streamer, "platform/channel", e.g.
#   twitch/kaicenat
#   kick/santi
#   youtube/@IShowSpeed        (YouTube live: use the channel handle)
set -uo pipefail

drop=${1:?Give the Clip Drop folder path (Google Drive synced folder)}
list=${2:-streamers-live.txt}
seg=${SEG:-00:30:00}           # file length; 30 minutes per the owner's request
mkdir -p "$drop"

command -v streamlink >/dev/null || { echo "Install streamlink first: pip install streamlink"; exit 1; }
[[ -f $list ]] || { echo "Channels file not found: $list"; exit 1; }

record() {
  local plat=$1 chan=$2 out="$drop/$(echo "$plat-$chan" | tr -c 'A-Za-z0-9@_-\n' '_')"
  local url
  case $plat in
    twitch)  url="https://www.twitch.tv/$chan" ;;
    kick)    url="https://kick.com/$chan" ;;
    youtube) url="https://www.youtube.com/$chan/live" ;;
    *) echo "Unknown platform $plat"; return ;;
  esac
  mkdir -p "$out"
  # Wait for the channel to go live, then record in 30-minute segments until the stream ends.
  while true; do
    streamlink --twitch-disable-ads --hls-duration "$seg" --loglevel info \
      -o "$out/$chan-%Y%m%d-%H%M%S.ts" "$url" best || true
    sleep 60   # offline or stream ended: check again in a minute
  done
}

pids=()
while IFS= read -r line; do
  line=${line%%#*}; line=$(echo "$line" | xargs)
  [[ -z $line ]] && continue
  plat=${line%%/*}; chan=${line#*/}
  record "$plat" "$chan" &
  pids+=($!)
  echo "Recording $plat/$chan (pid $!)"
done < "$list"

echo "Running ${#pids[@]} recorders. Files go to: $drop"
wait
