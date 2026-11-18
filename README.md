# EarnOnGTA6

Faceless GTA 6 fan page: the site at https://earnongta6.onrender.com plus the page's operating files.

**Fan page. Not affiliated with Rockstar Games.**

## Website
Static, no build step. Render publishes the repo root on every push to `main`.

- `index.html` – the page (countdown, news, tips, clips)
- `data.js` – all site content. Edit this to add news, tips or clips. Every news item needs an official source link from `facts.md`; every clip needs a credit.
- `favicon.svg` – our own E6 mark (never use Rockstar logos or key art)

## Operating files
| File | Purpose |
|---|---|
| `playbook.md` | Account info, voice, mix, slots, rules |
| `facts.md` | Verified facts only, each with its official source link |
| `idea-bank.md` | Ready-to-go drafts by pillar |
| `watchlist.md` | Official accounts, creators, streamers, subreddits |
| `log.md` | Every post that went out |
| `scoreboard.csv` | Per-post metrics at 12h / 24h / 72h |
| `learning.md` | Wins, losses, current rules, weekly reviews |
| `takedowns.md` | Removal requests and what we did |
| `clipping-workflow.md` | Link intake → review → edit → QA → schedule |
| `tools/make_clip.sh` | ffmpeg clip maker: 9:16, hook, captions, credit |
| `media/official`, `media/raw`, `media/edits` | Source and finished clips (keep large files out of git; use cloud storage) |

`archive/creator-city.html` is the previous version of the site.
