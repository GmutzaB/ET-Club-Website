# Engineering Technology Club — Website

A single-file site (blueprint/drafting theme) for the PennWest Engineering Technology Club, with a **managed backend (Supabase)** for member-submitted projects and job/internship postings.

No server to run — GitHub Pages hosts the static file, Supabase's free tier hosts the data. Nothing to maintain.

> **Note on this build:** this is a first iteration — a working v1 built to get the club online quickly with real functionality (project showcase, job postings, review queue), not a final or permanent design. It's intentionally simple (one HTML file, a managed backend, no accounts) so it's easy for any future officer to understand, edit, and hand off, even without a web development background. If a future officer or club wants to redesign it, rebrand it, or rebuild it as a more advanced app later, that's expected — see the rebuild guide at the bottom of this file.

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

## Team section (officers + faculty advisor)

This one works differently on purpose — there's no public submission form, since you don't want random visitors adding themselves as "officers." Instead:

1. Go to your Supabase dashboard → **Table Editor → people**.
2. Click **Insert row** and fill in `name`, `role` (e.g. "Vice President" or "Faculty Advisor"), `category` ("Officer" or "Faculty Advisor"), and `bio`. `email` and `photo_url` are optional. `display_order` controls the order people appear in (lower numbers first).
3. Save — it shows up on the site immediately, no approval step needed since only people with dashboard access can add rows in the first place.

There's a placeholder row already seeded (from the setup script) — edit it with a real bio, then add the rest of the officers and your faculty advisor the same way.

## Editing static content

The About, What We Do, Events, and Join sections are still plain HTML — edit them directly in `index.html`. Look for the yellow **EDIT ME** boxes marking the spots that need your real info (meeting time, contact email, event dates).

## Customizing further

- Colors: defined once under `:root` in the `<style>` block (`--blueprint`, `--amber`, `--paper`, etc.)
- Fonts: IBM Plex Mono (headers/labels) and IBM Plex Sans (body) — swap the Google Fonts `<link>` tag and the `--mono` / `--sans` variables to change them.
- To add fields to a project or posting (e.g. a link to a GitHub repo), add a column in Supabase's Table Editor, then update the form and the render function in `index.html` to match.

---

## Rebuilding this from scratch (design + technical guide)

If you (or a future officer) ever want to redesign or rebuild this rather than just edit it, here's exactly what this build is and how it's put together, so you can recreate the same approach — or intentionally deviate from it.

### What this actually is
- **Frontend:** one static `index.html` file — plain HTML, CSS, and vanilla JavaScript. No framework (React, Vue, etc.), no build step, no `npm install`. What you see in the file is exactly what runs in the browser.
- **Hosting:** GitHub Pages — free static hosting directly from a GitHub repo. Any static site (HTML/CSS/JS) can be hosted this way.
- **Backend:** Supabase — a free "backend-as-a-service" that gives you a Postgres database, a public API, file storage, and security rules, all without running your own server. The site talks to it directly from the browser using the `@supabase/supabase-js` JavaScript library (loaded via CDN, see the `<script type="module">` near the bottom of `index.html`).
- **Data model:** two tables (`projects`, `postings`), each with an `approved` boolean. Public users can insert new rows (they land unapproved) and read only approved rows. Officers approve by hand in Supabase's Table Editor — no custom admin panel was built.
- **File uploads:** a public Supabase Storage bucket (`project-images`) with a 5MB/file limit and image-only file types enforced at the bucket level.

### Design approach
- **Theme:** a "blueprint/drafting" motif for the dark hero section (grid lines, a drawing title block) paired with a "spec sheet" light paper tone for the content sections — grounded in actual engineering drawing conventions rather than a generic template.
- **Colors:** pulled directly from the club's logo files (PennWest Vulcan Black `#141414` and Vulcan Red `#c8202f`-family), not a generic palette. If rebranding, start from whatever official color/logo assets exist rather than picking colors freestyock.
- **Type:** IBM Plex Mono (headers, labels, data) + IBM Plex Sans (body) — both free via Google Fonts, chosen for a technical/engineering feel.
- **Structure:** every visual choice (grid lines, title block, mono labels) ties back to the "engineering drawing" concept as a throughline, rather than mixing unrelated visual ideas.

### If you want to rebuild it yourself, step by step
1. **Pick your stack.** For something this size, a single static HTML file + Supabase is genuinely hard to beat — no build tools, no hosting cost, no server maintenance, and any future officer can read the whole thing top to bottom. Only reach for a framework (Next.js, React, etc.) if the site is going to grow well beyond "show some content, take some submissions."
2. **Design around your actual identity.** Pull real brand assets (logos, official colors) rather than starting from a generic aesthetic — a distinctive, subject-grounded design reads as intentional rather than templated.
3. **Model your data before writing any UI.** Decide what a "project" or "posting" actually needs as fields, sketch it as a simple table, and only then build the form and display around it.
4. **Default to no accounts.** Unless you specifically need per-user logins, a public-submit + officer-moderation model (like this site uses) avoids the entire complexity of authentication.
5. **Write the SQL as a single idempotent script** (`create table if not exists`, `on conflict do nothing`) so it's safe to re-run and easy to hand to the next person without them needing to understand migrations.
6. **Keep secrets appropriately scoped.** The Supabase anon/publishable key is meant to be public — it's safe in client-side code. Never put a Supabase *service role* key (or any other secret/admin key) in a static site; that one must stay server-side only.
7. **Document the handoff, not just the code.** A README that explains *why* choices were made (like this one) is what actually lets a non-technical future officer keep the site alive after you graduate.

