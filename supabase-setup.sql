-- Engineering Technology Club — Supabase setup
-- Run this once in your Supabase project's SQL Editor (Project → SQL Editor → New query → paste → Run)

-- ---------- PROJECTS ----------
create table if not exists projects (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  lead text not null,
  collaborators text,                             -- optional, comma-separated names of others who worked on it
  description text not null,
  status text not null default 'In Progress',   -- e.g. 'Ongoing', 'In Progress', 'Complete'
  project_type text not null default 'Personal', -- e.g. 'Capstone', 'Personal', 'Club'
  paper_url text,                                 -- optional link to a paper/publication
  image_url text,                                 -- optional uploaded photo (Supabase Storage public URL)
  video_url text,                                 -- optional link to a video (YouTube, Vimeo, etc.)
  submitted_by_email text,                        -- not shown publicly, just for follow-up
  approved boolean not null default false,
  created_at timestamptz not null default now()
);

-- ---------- POSTINGS (jobs/internships) ----------
create table if not exists postings (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  company text not null,
  posting_type text not null default 'Internship', -- 'Internship' or 'Job'
  link text not null,
  notes text,
  submitted_by_email text,
  approved boolean not null default false,
  created_at timestamptz not null default now()
);

-- ---------- PEOPLE (officers + faculty advisor) ----------
-- NOTE: unlike projects/postings, this is NOT publicly submittable.
-- Only officers add/edit rows directly in Supabase's Table Editor.
-- The public site can only read this table.
create table if not exists people (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  role text not null,                              -- e.g. 'President', 'Vice President', 'Faculty Advisor'
  category text not null default 'Officer',        -- 'Officer' or 'Faculty Advisor'
  bio text not null,
  email text,                                       -- optional, shown publicly if provided
  photo_url text,                                   -- optional
  display_order int not null default 0,             -- lower numbers show first
  created_at timestamptz not null default now()
);

-- ---------- ROW LEVEL SECURITY ----------
-- Public can read only approved rows. Public can submit (insert) new rows,
-- but they land as approved = false until an officer flips it in the table editor.

alter table projects enable row level security;
alter table postings enable row level security;

create policy "Public can read approved projects"
  on projects for select
  using (approved = true);

create policy "Public can submit projects"
  on projects for insert
  with check (approved = false);

create policy "Public can read approved postings"
  on postings for select
  using (approved = true);

create policy "Public can submit postings"
  on postings for insert
  with check (approved = false);

alter table people enable row level security;

create policy "Public can read people"
  on people for select
  using (true);

-- No insert policy on purpose — only officers with dashboard access can add people,
-- via Table Editor, not through the public site.

-- ---------- SEED DATA (your two existing projects, pre-approved) ----------
insert into projects (title, lead, description, status, project_type, approved) values
  ('All-Sky Imager', 'Branden', 'Ultra-low-power auroral monitoring system built for deep-field Arctic deployment. Sub-2W target, custom sensor package, sponsored research project.', 'Ongoing', 'Capstone', true),
  ('Firefighter Exposure Monitor', 'Branden', 'Wearable device tracking gas exposure, temperature, and heart rate in real time, with wireless telemetry back to a command post.', 'In Progress', 'Personal', true);

-- Seed yourself as the first officer entry — edit the bio, then add the rest
-- (other officers, faculty advisor) directly in Table Editor.
insert into people (name, role, category, bio, display_order) values
  ('Branden', 'President', 'Officer', 'Senior in Mechatronics Engineering Technology. Replace this with a real bio.', 1);

-- To approve a new submission later: open Table Editor → projects (or postings) →
-- find the row → set "approved" to true. That's the entire moderation workflow.


-- ============================================================
-- MIGRATION: run this instead if you already ran the setup above
-- and just want to add the paper/publication link field.
-- (Safe to run even if the column already exists.)
-- ============================================================
alter table projects add column if not exists paper_url text;

-- Optional: attach a paper link to your existing ASI project.
-- Replace the URL below with the real one, then run this line.
-- update projects set paper_url = 'https://your-paper-link-here' where title = 'All-Sky Imager';


-- ============================================================
-- MIGRATION: photo upload + video link support
-- Safe to run even if you already ran the block above.
-- ============================================================
alter table projects add column if not exists image_url text;
alter table projects add column if not exists video_url text;
alter table projects add column if not exists collaborators text;

-- Team/leadership page (run this if you set the site up before this feature existed)
create table if not exists people (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  role text not null,
  category text not null default 'Officer',
  bio text not null,
  email text,
  photo_url text,
  display_order int not null default 0,
  created_at timestamptz not null default now()
);
alter table people enable row level security;
create policy "Public can read people" on people for select using (true);

-- Create a public storage bucket for uploaded project photos.
-- 5MB limit per file, images only.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('project-images', 'project-images', true, 5242880, array['image/png','image/jpeg','image/webp','image/gif'])
on conflict (id) do nothing;

-- Anyone can upload a photo (goes with an unapproved project until an officer approves it)
create policy "Public can upload project images"
on storage.objects for insert
to public
with check (bucket_id = 'project-images');

-- Anyone can view uploaded photos (needed so they render on the public site)
create policy "Public can view project images"
on storage.objects for select
to public
using (bucket_id = 'project-images');
