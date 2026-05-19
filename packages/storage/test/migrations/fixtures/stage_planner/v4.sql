-- Stage planner schema at v4 (post v4, pre v5).
-- stage_plans has uuid / plan_uuid / deleted_at.
-- stages has stage_number (nullable INTEGER).
-- date is still NOT NULL, no days_to_stay, no stage_uuid, no FK.
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

-- Plan with uuid already assigned, full 3-stage happy path.
INSERT INTO stage_plans (
  id, route_id, created_at, updated_at, is_imported, name,
  uuid, plan_uuid, deleted_at
) VALUES (
  1, 10, '2024-06-10T08:00:00.000Z', '2024-06-10T08:00:00.000Z',
  0, 'Plan with uuid',
  'aaaaaaaa-1111-2222-3333-444444444444', NULL, NULL
);

INSERT INTO stages (
  id, stage_plan_id, route_id, date,
  start_city_id, end_city_id, created_at, stage_number
) VALUES
  (1, 1, 10, '2024-06-15T08:30:00.000Z', 101, 102, '2024-06-10T08:00:00.000Z', 1),
  (2, 1, 10, '2024-06-16T08:30:00.000Z', 102, 103, '2024-06-10T08:00:00.000Z', 2),
  (3, 1, 10, '2024-06-17T08:30:00.000Z', 103, 104, '2024-06-10T08:00:00.000Z', 3);

-- Plan with NO uuid — v8 migration must backfill it.
INSERT INTO stage_plans (
  id, route_id, created_at, updated_at, is_imported, name
) VALUES (
  2, 20, '2024-07-01T10:00:00.000Z', NULL, 1, NULL
);

-- Legacy ISO datetime dates — v5 migration normalizes these.
-- Also exercises null stage_number (must later be healed or left
-- alone by the core migration; this data is intentionally messy).
INSERT INTO stages (
  id, stage_plan_id, route_id, date,
  start_city_id, end_city_id, created_at, stage_number,
  custom_start_notes
) VALUES
  (10, 2, 20, '2024-07-05T09:00:00.000Z', 201, 202, '2024-07-01T10:00:00.000Z', 1, ''),
  (11, 2, 20, '2024-07-06T09:00:00.000Z', 202, 203, '2024-07-01T10:00:00.000Z', 2, NULL);

-- Orphan stage.
INSERT INTO stages (
  id, stage_plan_id, route_id, date,
  start_city_id, end_city_id, created_at, stage_number
) VALUES
  (99, 9999, 10, '2024-06-20T08:00:00.000Z', 500, 501, '2024-06-10T08:00:00.000Z', 1);
