-- Stage planner schema at v5 (post v5, pre v7).
-- Same schema as v4 — v5 only normalizes stage.date values.
-- Dates should be yyyy-MM-dd only (the whole point of v5).
CREATE TABLE stage_plans (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  route_id INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT,
  is_imported INTEGER NOT NULL DEFAULT 0,
  name TEXT,
  uuid TEXT,
  plan_uuid TEXT,
  deleted_at TEXT
);

CREATE TABLE stages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  stage_plan_id INTEGER NOT NULL,
  route_id INTEGER NOT NULL,
  date TEXT NOT NULL,
  start_city_id INTEGER NOT NULL,
  end_city_id INTEGER NOT NULL,
  start_albergue_id INTEGER,
  end_albergue_id INTEGER,
  custom_start_notes TEXT,
  custom_end_notes TEXT,
  stage_notes TEXT,
  created_at TEXT,
  updated_at TEXT,
  stage_number INTEGER
);

CREATE INDEX idx_stages_stage_plan_id ON stages(stage_plan_id);
CREATE INDEX idx_stages_date ON stages(date);
CREATE INDEX idx_stage_plans_uuid ON stage_plans(uuid);

-- Plan 1 with 3 consecutive stages: dates are 1 day apart —
-- v7 should compute days_to_stay = 1, and starting_date from
-- the first stage.
INSERT INTO stage_plans (
  id, route_id, created_at, updated_at, is_imported, name,
  uuid, plan_uuid, deleted_at
) VALUES (
  1, 10, '2024-06-10T08:00:00.000Z', '2024-06-10T08:00:00.000Z',
  0, 'Plan one',
  'aaaaaaaa-1111-2222-3333-444444444444', NULL, NULL
);

INSERT INTO stages (
  id, stage_plan_id, route_id, date,
  start_city_id, end_city_id, created_at, stage_number
) VALUES
  (1, 1, 10, '2024-06-15', 101, 102, '2024-06-10T08:00:00.000Z', 1),
  (2, 1, 10, '2024-06-16', 102, 103, '2024-06-10T08:00:00.000Z', 2),
  (3, 1, 10, '2024-06-17', 103, 104, '2024-06-10T08:00:00.000Z', 3);

-- Plan 2: stages 3 days apart — v7 should compute days_to_stay = 3.
INSERT INTO stage_plans (
  id, route_id, created_at, updated_at, is_imported, name,
  uuid
) VALUES (
  2, 20, '2024-07-01T10:00:00.000Z', NULL, 0, NULL,
  'bbbbbbbb-1111-2222-3333-444444444444'
);

INSERT INTO stages (
  id, stage_plan_id, route_id, date,
  start_city_id, end_city_id, created_at, stage_number
) VALUES
  (10, 2, 20, '2024-07-05', 201, 202, '2024-07-01T10:00:00.000Z', 1),
  (11, 2, 20, '2024-07-08', 202, 203, '2024-07-01T10:00:00.000Z', 2);

-- Plan 3: no uuid yet — v8 migration must backfill it.
INSERT INTO stage_plans (
  id, route_id, created_at, updated_at, is_imported, name
) VALUES
  (3, 30, '2024-08-01T00:00:00.000Z', NULL, 0, '');

INSERT INTO stages (
  id, stage_plan_id, route_id, date,
  start_city_id, end_city_id, created_at, stage_number
) VALUES
  (20, 3, 30, '2024-08-10', 301, 302, '2024-08-01T00:00:00.000Z', 1);

-- Orphaned stage — the PR #364 regression trigger.
-- stage_plan_id = 9999 does not exist in stage_plans.
INSERT INTO stages (
  id, stage_plan_id, route_id, date,
  start_city_id, end_city_id, created_at, stage_number
) VALUES
  (99, 9999, 10, '2024-06-20', 500, 501, '2024-06-10T08:00:00.000Z', 1);
