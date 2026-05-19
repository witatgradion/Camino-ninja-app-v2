-- Stage planner schema at v7 (post v7, pre v8).
-- stage_plans has starting_date. stages has days_to_stay, nullable
-- date, and an FK to stage_plans(id) ON DELETE CASCADE.
-- stage_uuid does not exist yet — v8 migration must add it and
-- backfill.
CREATE TABLE stage_plans (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  route_id INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT,
  is_imported INTEGER NOT NULL DEFAULT 0,
  name TEXT,
  uuid TEXT,
  plan_uuid TEXT,
  deleted_at TEXT,
  starting_date TEXT
);

CREATE TABLE stages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  stage_plan_id INTEGER NOT NULL,
  route_id INTEGER NOT NULL,
  date TEXT,
  start_city_id INTEGER NOT NULL,
  end_city_id INTEGER NOT NULL,
  start_albergue_id INTEGER,
  end_albergue_id INTEGER,
  custom_start_notes TEXT,
  custom_end_notes TEXT,
  stage_notes TEXT,
  created_at TEXT,
  updated_at TEXT,
  stage_number INTEGER,
  days_to_stay INTEGER NOT NULL DEFAULT 1,
  FOREIGN KEY (stage_plan_id)
    REFERENCES stage_plans(id) ON DELETE CASCADE
);

CREATE INDEX idx_stages_stage_plan_id ON stages(stage_plan_id);
CREATE INDEX idx_stages_route_id ON stages(route_id);
CREATE INDEX idx_stages_date ON stages(date);
CREATE INDEX idx_stages_start_city_id ON stages(start_city_id);
CREATE INDEX idx_stages_end_city_id ON stages(end_city_id);
CREATE INDEX idx_stages_stage_number ON stages(stage_number);
CREATE INDEX idx_stage_plans_uuid ON stage_plans(uuid);

-- Plan 1: has uuid, has starting_date, 3 stages.
INSERT INTO stage_plans (
  id, route_id, created_at, updated_at, is_imported, name,
  uuid, plan_uuid, deleted_at, starting_date
) VALUES (
  1, 10, '2024-06-10T08:00:00.000Z', '2024-06-10T08:00:00.000Z',
  0, 'Plan one',
  'aaaaaaaa-1111-2222-3333-444444444444', NULL, NULL, '2024-06-15'
);

INSERT INTO stages (
  id, stage_plan_id, route_id, date,
  start_city_id, end_city_id, created_at, stage_number,
  days_to_stay
) VALUES
  (1, 1, 10, '2024-06-15', 101, 102, '2024-06-10T08:00:00.000Z', 1, 1),
  (2, 1, 10, '2024-06-16', 102, 103, '2024-06-10T08:00:00.000Z', 2, 1),
  (3, 1, 10, '2024-06-17', 103, 104, '2024-06-10T08:00:00.000Z', 3, 1);

-- Plan 2: missing uuid — v8 must backfill.
INSERT INTO stage_plans (
  id, route_id, created_at, updated_at, is_imported, name,
  starting_date
) VALUES
  (2, 20, '2024-07-01T10:00:00.000Z', NULL, 0, NULL, '2024-07-05');

INSERT INTO stages (
  id, stage_plan_id, route_id, date,
  start_city_id, end_city_id, created_at, stage_number,
  days_to_stay
) VALUES
  (10, 2, 20, '2024-07-05', 201, 202, '2024-07-01T10:00:00.000Z', 1, 3),
  (11, 2, 20, '2024-07-08', 202, 203, '2024-07-01T10:00:00.000Z', 2, 1);

-- Plan 3: empty-string uuid (trimmed-empty edge case) — v8 must
-- backfill.
INSERT INTO stage_plans (
  id, route_id, created_at, updated_at, is_imported, name,
  uuid, starting_date
) VALUES
  (3, 30, '2024-08-01T00:00:00.000Z', NULL, 0, '', '   ', NULL);

INSERT INTO stages (
  id, stage_plan_id, route_id,
  start_city_id, end_city_id, created_at, stage_number,
  days_to_stay
) VALUES
  (20, 3, 30, 301, 302, '2024-08-01T00:00:00.000Z', 1, 1);
