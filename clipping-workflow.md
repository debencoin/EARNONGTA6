# Clipping workflow

How a link becomes a credited, ready-to-post vertical clip. Follows `playbook.md` sections 6 and 7 and the safety rules.

> Social posting is paused until setup questions 1 to 4 are answered (see `playbook.md` section 1).

## 1. Submit a link (intake)

Links go in the **EarnOnGTA6 Clip Requests** Google Sheet:
https://docs.google.com/spreadsheets/d/1ddQn81euZUgyDSng3C2jeZmyJpMXMV2sWlGw8DabQT8/edit

Editors: the page owner and **earnongta@gmail.com**. One row per clip idea:

| Column | What to put |
|---|---|
| id | next number, 4 digits (0002, 0003...) |
| submitted_at / submitted_by | date, your name or email |
| source_url | link to the **original public post** (not a repost) |
| creator_handle / creator_platform | who made it, where |
| source_type | `official` (Rockstar, PlayStation, Xbox) or `creator` |
| permission | `official`, `allows sharing`, `asked`, or `granted` |
| start_time / end_time | the moment to clip, e.g. 00:02:10 to 00:02:28 |
| hook_idea | on-screen hook, e.g. THE HIDDEN CAR NOBODY FOUND |
| pillar | News, Tips, Gameplay clips, Nostalgia, Spotlight, Countdown, Question |
| spoiler? | yes if it shows story moments |
| status | leave as `new` |

Never submit: leaks, datamined or leaked builds, "play early" content, pirated copies, exploits, protected or deleted posts, or reposts where the original creator is unknown.

## 2. Review (before any clipping)

**Owner permission rule (2026-11-18):** the page owner confirmed we have full creator permission for every link the owner sends in. For those rows, set `permission` to `granted (owner)` and skip the ask-first step. On-screen and caption credit is optional for owner-submitted links (owner, 2026-11-18: "No need to credit them they gave permission"). Leak, spoiler and cutscene checks still apply to every clip.

A row moves from `new` to `approved` only if every box is checked. Otherwise `rejected` with a reason in `reviewer_notes`.

- [ ] Public post, still up, original creator identified
- [ ] Not a leak, exploit, "play early" trick, or pirated source
- [ ] Official material, or the creator allows sharing / granted permission (credit is not permission; DM first when reachable: "Love this clip, ok if we share it with credit?")
- [ ] Creator not on the avoid list and no past takedown (`takedowns.md`)
- [ ] Any fact in the hook or caption is in `facts.md`
- [ ] Spoilers flagged; no spoiler in the hook or thumbnail
- [ ] Rockstar footage: respectful, never implies we're Rockstar

## 3. Get the source file

- **Long videos (streams, long YouTube videos):** run them through the AI clipping tool (OpusClip ClipAnything or Klap, free plan limits first; never upgrade without asking). Always review AI picks; they miss context and can pick a spoiler.
- **Short clips:** use the original file the creator sent, Rockstar's official media downloads, or a copy you have the right to use.
- Save the source as `media/raw/<id>-src.mp4` and write the source URL next to it in `media/raw/<id>-source.txt`. Large video files stay in cloud storage, not git.

## 4. Make it ours (edit)

Every clip gets: a hook in the first second, a tight 7 to 30 s trim, big burned-in captions, our own value (tip, label, short commentary, then-vs-now), and the credit.

**With ffmpeg (this repo):**
```bash
tools/make_clip.sh -i media/raw/0007-src.mp4 -s 00:02:10 -e 00:02:28 \
  -k "THE HIDDEN CAR NOBODY FOUND" -c "@creatorname" \
  -S media/raw/0007.srt -o media/edits/0007.mp4
```
Output: 1080x1920 MP4 (H.264, AAC, 30 fps): source centered on a blurred fill, hook at the top, captions above the credit, credit above the bottom UI zone. Emoji are stripped from on-screen text (put them in the caption). Captions file is optional `.srt` (CapCut auto-captions can export one).

**With CapCut:** 9:16 canvas, same layout: hook top third, captions centered, credit bottom above the UI.

A plain repost is not enough: Instagram limits reach for unoriginal reposts, and adding only a watermark, border or credit does not count.

## 5. QA before scheduling

- [ ] Hook readable in the first second, on mute
- [ ] Clip ends on the payoff, no dead air at the start
- [ ] Captions inside the safe area, nothing covered by app UI
- [ ] Credit visible and matches the original creator
- [ ] No nudity or sensitive frames (the game is M-rated); mark sensitive media where needed
- [ ] Length fits the platform (X up to 140 s for non-Premium; Reels under 3 min; Shorts up to 3 min; default 7 to 30 s)

Set the sheet row to `clipped` and fill `clip_file`.

## 6. Caption and schedule (paused until setup is answered)

Use the templates in `idea-bank.md`:
```
[One-line hook or reaction]

🎥 @creator
```
X: no hashtags. Instagram: 3 to 5 relevant hashtags. TikTok/Shorts: a few relevant ones. Label story clips `SPOILER`.

In Buffer: confirm the channel name and avatar, set an explicit time in America/Phoenix, upload the video file (or a direct public HTTPS MP4 link, never a share page). Breaking official news: "Share now". If upload fails, post the caption with a link to the original public post, or skip the slot. Never post without credit.

## 7. After posting

- Sheet row: `posted`, add the links.
- `log.md`: time, platform, text, media, credit, link.
- `scoreboard.csv`: fill views and engagement at 12h, 24h, 72h. Blank if unknown, never guess.
- Takedown request: remove the same day, set the row to `taken down`, log it in `takedowns.md`.
