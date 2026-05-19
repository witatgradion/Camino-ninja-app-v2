-- Stage planner schema at v8 (post v8, pre v9).
-- stages now has the stage_uuid column (added in v8) plus the
-- unique (stage_plan_id, stage_uuid) index. The fixture mixes
-- backfilled rows (real uuid) with rows whose stage_uuid is NULL
-- or blank — these can exist on real devices either because v8
-- partially completed, or because rows were inserted via a code
-- path that didn't auto-generate a uuid. v9 must heal them.
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
  stage_uuid TEXT,
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
CREATE UNIQUE INDEX idx_stages_plan_stage_uuid
  ON stages(stage_plan_id, stage_uuid);

-- Plan 1: all stages have valid stage_uuid (the healthy path).
INSERT INTO stage_plans (
  id, route_id, created_at, updated_at, is_imported, name,
  uuid, plan_uuid, deleted_at, starting_date
) VALUES (
  1, 10, '2024-06-10T08:00:00.000Z', '2024-06-10T08:00:00.000Z',
  0, 'Plan one',
  'aaaaaaaa-1111-2222-3333-444444444444', NULL, NULL, '2024-06-15'
);

INSERT INTO stages (
  id, stage_plan_id, route_id, stage_uuid, date,
  start_city_id, end_city_id, created_at, stage_number,
  days_to_stay
) VALUES
  (1, 1, 10, 'stage-uuid-0001', '2024-06-15', 101, 102,
   '2024-06-10T08:00:00.000Z', 1, 1),
  (2, 1, 10, 'stage-uuid-0002', '2024-06-16', 102, 103,
   '2024-06-10T08:00:00.000Z', 2, 1),
  (3, 1, 10, 'stage-uuid-0003', '2024-06-17', 103, 104,
   '2024-06-10T08:00:00.000Z', 3, 1);

-- Plan 2: one stage with NULL stage_uuid, one with valid.
-- v9 must backfill the NULL.
INSERT INTO stage_plans (
  id, route_id, created_at, updated_at, is_imported, name,
  uuid, starting_date
) VALUES (
  2, 20, '2024-07-01T10:00:00.000Z', NULL, 0, 'Plan two',
  'bbbbbbbb-1111-2222-3333-444444444444', '2024-07-05'
);

INSERT INTO stages (
  id, stage_plan_id, route_id, stage_uuid, date,
  start_city_id, end_city_id, created_at, stage_number,
  days_to_stay
) VALUES
  (10, 2, 20, NULL, '2024-07-05', 201, 202,
   '2024-07-01T10:00:00.000Z', 1, 3),
  (11, 2, 20, 'stage-uuid-0011', '2024-07-08', 202, 203,
   '2024-07-01T10:00:00.000Z', 2, 1);

-- Plan 3: one stage with blank/whitespace stage_uuid (trimmed-empty
-- edge case). v9 must backfill it.
INSERT INTO stage_plans (
  id, route_id, created_at, updated_at, is_imported, name,
  uuid, starting_date
) VALUES (
  3, 30, '2024-08-01T00:00:00.000Z', NULL, 0, 'Plan three',
  'cccccccc-1111-2222-3333-444444444444', NULL
);

INSERT INTO stages (
  id, stage_plan_id, route_id, stage_uuid,
  start_city_id, end_city_id, created_at, stage_number,
  days_to_stay
) VALUES
  (20, 3, 30, '   ', 301, 302, '2024-08-01T00:00:00.000Z', 1, 1);
