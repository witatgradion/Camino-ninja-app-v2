# In-App DB Export Guide (Phase 3a)

**Audience:** Product owner, internal beta wrangler — anyone
collecting anonymized real-user database samples to feed the
golden-DB corpus (Phase 3 of the DB Test Harness plan).

## What this does

The app contains a flow that copies the stage-planner SQLite
database (`stage_planner_database.db`), strips free-text user
content, zips it with a manifest, and either attaches it to a
bug report or hands the zip to the system share sheet.

The export is implemented in `packages/storage/lib/src/db_exporter.dart`.
Two collection paths exist; pick the one that matches the
tester's workflow.

## Collection paths

### Beta-tester flow (recommended)

This is the easy path. Zero training, no easter eggs, no
copy-paste — the tester just files a bug report.

1. Open the app on a beta build (staging flavor on TestFlight or
   internal testing).
2. Go to **More → Something not working?**.
3. Describe what happened in the feedback field as usual.
4. Tick the **Include stage plan data** checkbox at the bottom
   of the form.
5. Submit.

The app builds the anonymized archive on the fly and uploads it
as the `db_dump` multipart part of `POST /api/v1/bug_reports`.
The archive does not show up in the UI; the user only sees a
plain success toast.

The backend stores the archive alongside the bug-report record.
Pull it from there (process TBD with the server team) for
second-pass review and addition to the golden corpus.

The checkbox **defaults to unchecked**. Users must opt in
explicitly. The subtitle on the checkbox names exactly what gets
redacted. Do not change that wording without a strong reason —
it's the user's informed-consent surface.

### Power-user / direct-share flow

This is the fallback if the bug-report flow is broken or the
tester (or product owner) wants to inspect the archive locally
before it goes anywhere.

1. Open the app on a beta build.
2. Go to the **More** tab.
3. Scroll to the bottom. You'll see a line of small text like
   "Current version 2.2.395".
4. Tap that line **7 times** within ~3 seconds. It does not
   visibly change.
5. A short "Preparing DB export…" toast appears, then the system
   share sheet opens with a file named
   `db_export_<flavor>_<version>_<timestamp>.zip`.
6. Send it via the agreed channel (e.g. AirDrop, email).

If the tap window times out (3s without another tap), the
counter resets — that's the only thing that can go wrong here.

## Who can trigger this (current limitation)

Both flows are gated by `AppConfig.flavor != Flavor.production`.
That means:

- Development build: yes.
- Staging build (TestFlight beta / internal testers): yes.
- Production build (App Store / Play Store): **no** — the
  checkbox is gated server-side and the easter egg is a no-op.

So beta testers must be on a **staging-flavor TestFlight build**
to run either flow. Phase 4 may extend the gate to a Firebase
Remote Config flag that can target a small cohort of prod users;
that's not in scope yet.

## What's in the archive

```
db_export_staging_2.2.395_1714003200.zip
├── stage_planner_database.db        (anonymized copy)
└── manifest.json
```

`manifest.json` (schema v2) looks like:

```json
{
  "schemaVersion": 2,
  "appVersion": "2.2.395",
  "buildNumber": "202395",
  "flavor": "staging",
  "platform": "ios",
  "osVersion": "Version 18.0",
  "exportedAt": "2026-04-26T12:00:00.000Z",
  "stagePlannerDatabaseVersion": 7,
  "scrubbedColumns": [...],
  "rowCounts": {
    "stage_planner": { "stage_plans": 3, "stages": 27 }
  }
}
```

Schema v2 dropped `app_database.db`. Almost every migration bug
in our history has lived in `stage_planner_database` (PR #364
orphans, stage-update, optional-dates); `app_database` is
mostly server-seeded reference data the user can't easily get
into a weird shape, and dropping it cuts the archive from ~11 MB
to tens of KB so it can ride on a bug-report upload without
friction.

If you have a v1 archive (older form: `app_database.db` +
`stage_planner_database.db` + `manifest.json` with
`appDatabaseVersion`), it's still usable for migration tests —
just note it's pre-shrink data.

**Reader note:** v2 is *not* a strict superset of v1 — the
`appDatabaseVersion` key and the `app` entry under `rowCounts`
are gone. Any future tool that parses the manifest must branch
on `schemaVersion` (treat v1-only keys as optional / absent).

## What's anonymized vs preserved

**Anonymized** (set to `NULL` across every row before zipping):

- `stage_planner_database.db`:
  - `stage_plans.name` — user-typed plan name
  - `stages.custom_start_notes` — free-text
  - `stages.custom_end_notes` — free-text
  - `stages.stage_notes` — free-text

The `.db` file in the archive has already had user-typed text
replaced with NULL — the original data never leaves the device.

The single source of truth is the `dbExporterScrubbedColumns`
constant at the top of `packages/storage/lib/src/db_exporter.dart`.
If you add a new free-text column elsewhere, update that list.

**Preserved** (we want this for migration tests):

- All schema (tables, columns, indexes, constraints).
- All row counts and IDs (route IDs, city IDs, plan IDs, etc.).
- All dates (`created_at`, `updated_at`, `date`, `starting_date`,
  `deleted_at`, etc.).
- FK relationships (`stage_plan_id`, `route_id`, etc.) — and FK
  integrity is asserted in tests.
- Plan structure (`days_to_stay`, `stage_number`, soft-delete
  tombstones, sync UUIDs).

**Not in either DB** (and therefore not at risk):

- Auth tokens — live in `flutter_secure_storage`, not SQLite.
- FCM push tokens — live in `SharedPreferences`, not SQLite.
- User email / display name — live in remote `users` table, not
  in either local DB.

If you find a column we missed, treat it as a security incident:
discard the archive, add the column to `dbExporterScrubbedColumns`,
ship a fix, and re-collect.

## Where the archives go

For the **beta-tester flow**: archives ride on
`POST /api/v1/bug_reports` and land in the bug-report storage.
Coordinate with the server team for the retrieval process.

For the **power-user flow**: to be agreed with the product
owner. Suggested options:

- A dedicated mailbox the product owner controls.
- A signed-URL upload to a private S3 bucket.
- AirDrop straight to the product owner's laptop (fine for the
  first few).

Whichever channel is chosen, the archive should not sit in any
shared chat or wiki — even after anonymization, treat it as
sensitive until the second-pass review.

## What to do with an archive

1. **Second-pass PII review.** Open the DB in your favorite
   SQLite browser. Skim every column not in
   `dbExporterScrubbedColumns`. If something looks like real
   user content, do not commit — patch the exporter, re-collect.
2. **Rename by shape** so the test name is descriptive of the
   case, not the user. Examples:
   - `long-plan-legacy-dates.db`
   - `pre-v2.2.364-orphans.db`
   - `multi-route-with-soft-deletes.db`
3. **Drop into** `packages/storage/test/golden_dbs/`. Phase 3's
   `golden_migration_test.dart` will pick it up automatically.
4. Commit with a body that documents the shape and the source
   release (e.g. "collected from staging build 2.2.395"). Never
   include the tester's identity in the commit.

## Operational notes

- The flow uses SQLite's `VACUUM INTO` to copy the DB without
  closing the live connection. Users can keep using the app
  during the export; nothing is locked for more than the time it
  takes to write the copy.
- The intermediate (un-zipped) copy lives in the OS temp
  directory and is deleted before the archive is shared/uploaded.
  Only the final zip survives, and it lives in
  `getTemporaryDirectory()` — the OS will eventually clean it up.
- The bug-report flow logs `BugReportSubmittedEvent` with
  `includes_db_dump: true|false` — that field reflects what was
  actually uploaded (so an opt-in user whose export failed
  reports `false`), not just the checkbox state.
- The power-user (easter-egg) flow has no analytics event. It's
  a fallback utility, not a user-facing feature.
