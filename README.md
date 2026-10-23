# Shred Log

A phone-first workout logger for the Old Sckool Six-Week Shred plan, shared by Chris and Garry.

- Four training days (Back, Legs, Shoulders, Arms) with every movement, target sets × reps and coaching pointers
- Log kg and reps per set, tick it off, and a 90-second rest timer starts
- Last session's numbers show under each lift and as placeholders
- Bodyweight, finisher minutes and notes per session
- Progress tab: top set per lift, kg gained since the start, bodyweight trend, full history with edit and delete
- Chris and Garry each have their own log; both can view and log for either (handy when training together)
- Works offline in the gym and syncs when signal returns; installs to your home screen

Live app: **https://sidrad1983.github.io/Shared-log/**

## How it's built

A single `index.html` with no build step, hosted on GitHub Pages. Logs are stored in a free
[Supabase](https://supabase.com) Postgres database. Sign-in is email and password, and row-level security
means only the emails in the `members` table can read or write anything.

| File | What it does |
|---|---|
| `index.html` | The whole app: plan, UI, sync |
| `config.js` | Supabase project URL and public anon key |
| `sw.js` | Offline caching so the app opens with no signal |
| `manifest.webmanifest`, `icons/` | Home-screen install |
| `supabase/schema.sql` | Tables, members list and access rules |

## One-time setup

1. **Supabase project:** create a free project at supabase.com (London region).
2. **Database:** open SQL Editor → New query, paste `supabase/schema.sql`, put in both email addresses, and click Run.
3. **Sign-in redirect:** go to Authentication → URL Configuration and set Site URL to
   `https://sidrad1983.github.io/Shared-log/`.
4. **Connect the app:** put the Project URL and anon public key from Project Settings → API into `config.js`.
5. **GitHub Pages:** in the repo, go to Settings → Pages, set Source to "Deploy from a branch" with `main` / root, and click Save.

## Getting it on your phone

1. Open the live app link.
2. Tap **First time here? Create your account** and use the email on the members list.
3. Tap the link in the confirmation email, then sign in.
4. Add it to your home screen. On iPhone, use Safari → Share → Add to Home Screen. On Android, use Chrome → ⋮ → Add to Home screen.

## Changing the plan

The programme is the `PLAN` object near the top of the script in `index.html`. Each movement is
`[name, sets, reps, coaching pointer]`. If you rename a movement, add it to `KEEP_KEY` with its old ID
so earlier logs stay linked (see "Seated Row"). Commit, and the live app updates within a minute or two.

## Adding someone

Run this in the SQL Editor:
`insert into public.members (email, name) values ('them@example.com', 'Name');`
Then add a button for them next to Chris and Garry in `index.html` (search for `data-who`).
