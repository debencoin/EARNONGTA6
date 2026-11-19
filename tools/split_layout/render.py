"""Split-screen vertical clip: streamer facecam on top, GTA 6 gameplay below, burned captions + credit.

Usage (run from the folder that holds the .ass file):
  python render.py SEG.mp4 CAPTIONS.ass OUT.mp4 --start 1.0 --dur 21.16 \
      --cam X Y W H --game-x GX --credit "@KaiCenat"

  SEG.mp4     full-frame 1920x1080 source segment
  --start     seconds into SEG where the clip begins (captions are timed from here)
  --cam       facecam box in the 1920x1080 source frame (pixels)
  --game-x    left edge of the 911x1080 gameplay crop (default centered: 504)
Layout (1080x1920): facecam panel 1080x640 on top, gameplay panel 1080x1280 below,
captions centered on the seam, credit near the bottom above the app UI.
"""
import argparse, os, shutil, subprocess, tempfile

p = argparse.ArgumentParser()
p.add_argument("seg"); p.add_argument("ass"); p.add_argument("out")
p.add_argument("--start", type=float, default=1.0)
p.add_argument("--dur", type=float, required=True)
p.add_argument("--cam", type=int, nargs=4, required=True)
p.add_argument("--game-x", type=int, default=504)
p.add_argument("--credit", required=True)
a = p.parse_args()

cx, cy, cw, ch = a.cam
gx = max(0, min(1920 - 911, a.game_x))

# Add the credit line to a copy of the captions file
tmpdir = tempfile.mkdtemp()
ass_copy = os.path.join(tmpdir, "c.ass")
txt = open(a.ass, encoding="utf-8").read()
txt = txt.replace("[Events]", "[Events]", 1)
txt = txt.replace("[V4+ Styles]\n", "[V4+ Styles]\n", 1)
style = "Style: Credit,Arial Black,44,&H00FFFFFF,&H00FFFFFF,&H00000000,&H80000000,-1,0,0,0,100,100,0,0,1,4,2,5,40,40,0,1\n"
txt = txt.replace("\n[Events]", style + "\n[Events]", 1)
h, rem = divmod(a.dur + 1, 3600); m, s = divmod(rem, 60)
txt = txt.rstrip("\n") + f"\nDialogue: 1,0:00:00.00,{int(h)}:{int(m):02d}:{s:05.2f},Credit,,0,0,0,,{{\\pos(540,1560)}}{a.credit}\n"
open(ass_copy, "w", encoding="utf-8").write(txt)

fc = (
    f"[0:v]split=2[a][b];"
    f"[a]crop={cw}:{ch}:{cx}:{cy},scale=1080:640:force_original_aspect_ratio=increase,crop=1080:640,setsar=1[cam];"
    f"[b]crop=911:1080:{gx}:0,scale=1080:1280,setsar=1[game];"
    f"[cam][game]vstack=inputs=2,fps=30,format=yuv420p,ass=c.ass[v]"
)
cmd = ["ffmpeg", "-hide_banner", "-loglevel", "error", "-y", "-ss", str(a.start), "-t", str(a.dur),
       "-i", os.path.abspath(a.seg), "-filter_complex", fc, "-map", "[v]", "-map", "0:a?",
       "-c:v", "libx264", "-preset", "medium", "-crf", "19", "-profile:v", "high",
       "-c:a", "aac", "-b:a", "160k", "-ar", "48000", "-movflags", "+faststart", os.path.abspath(a.out)]
subprocess.run(cmd, check=True, cwd=tmpdir)
shutil.rmtree(tmpdir, ignore_errors=True)
print("Done:", a.out)
