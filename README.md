# Engineering Technology Club — Website

A single-file site (blueprint/drafting theme) for the PennWest Engineering Technology Club, with a **managed backend (Supabase)** for member-submitted projects and job/internship postings.

No server to run — GitHub Pages hosts the static file, Supabase's free tier hosts the data. Nothing to maintain.

## Part 1 — Get the site live on GitHub Pages

1. Create a new GitHub repo (e.g. `et-club-site`).
2. Upload `index.html`, `README.md`, `supabase-setup.sql`, and the `assets/` folder (with the four logo SVGs) to it — keep the folder structure intact, since `index.html` references them at `assets/...`.
3. Go to **Settings → Pages**.
4. Under **Build and deployment → Source**, choose **Deploy from a branch** → `main` → `/ (root)` → **Save**.
5. Your site goes live at `https://yourusername.github.io/repo-name/` within a minute or two.

## Part 2 — Set up the database (Supabase, free)

1. Go to **supabase.com** and sign up (free tier is plenty for a club site).
2. Click **New Project**. Pick a name, a password (save it somewhere — you likely won't need it again, but keep it), and a region close to you. Wait ~2 minutes for it to spin up.
3. In the left sidebar, go to **SQL Editor → New query**.
4. Open `supabase-setup.sql` from this repo, copy the whole thing, paste it into the SQL Editor, and click **Run**. This creates the `projects` and `postings` tables, sets up the security rules, and seeds your two existing projects.
5. In the left sidebar, go to **Project Settings → API**. You'll need two values from this page:
   - **Project URL** (looks like `https://xxxxxxxx.supabase.co`)
   - **anon public** key (a long string — this is safe to expose publicly, it's designed for this)

## Part 3 — Connect the site to the database

1. Open `index.html` and find this block near the bottom (search for `SUPABASE_URL`):
   ```html
   <script>
     const SUPABASE_URL = 'YOUR_SUPABASE_PROJECT_URL';
     const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';
   </script>
   ```
2. Replace the two placeholder strings with your actual Project URL and anon key from Part 2, step 5.
3. Save, commit, and push to GitHub. The Projects and Postings sections will now load live from your database.

## How moderation works

Anyone can submit a project or a posting through the forms on the site — it lands in the database with `approved = false` and does **not** show up publicly yet.

To approve something:
1. Go to your Supabase dashboard → **Table Editor**.
2. Open the `projects` or `postings` table.
3. Find the new row, click into the `approved` column, and set it to `true`.
4. It'll appear on the live site within a few seconds (next time someone loads the page).

That's the entire moderation workflow — no admin panel to build, no login system. Any officer with access to the Supabase project (you can invite co-officers as project members in Supabase's dashboard under **Project Settings → Team**) can approve submissions this way.

## Editing static content

The About, What We Do, Events, and Join sections are still plain HTML — edit them directly in `index.html`. Look for the yellow **EDIT ME** boxes marking the spots that need your real info (meeting time, contact email, event dates).

## Customizing further

- Colors: defined once under `:root` in the `<style>` block (`--blueprint`, `--amber`, `--paper`, etc.)
- Fonts: IBM Plex Mono (headers/labels) and IBM Plex Sans (body) — swap the Google Fonts `<link>` tag and the `--mono` / `--sans` variables to change them.
- To add fields to a project or posting (e.g. a link to a GitHub repo), add a column in Supabase's Table Editor, then update the form and the render function in `index.html` to match.
