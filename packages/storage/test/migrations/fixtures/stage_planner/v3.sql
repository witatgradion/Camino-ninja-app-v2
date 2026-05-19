-- Stage planner schema at v3 (post v3, pre v4).
-- stage_plans now has is_imported + name.
-- stages still has no stage_number / days_to_stay / stage_uuid
-- and no FK. date is NOT NULL.
CREATE TABLE stage_plans (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  route_id INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT,
  is_imported INTEGER NOT NULL DEFAULT 0,
  name TEXT
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
  updated_at TEXT
);

CREATE INDEX idx_stages_stage_plan_id ON stages(stage_plan_id);
CREATE INDEX idx_stages_date ON stages(date);

-- Happy-path plan 1.
INSERT INTO stage_plans (
  id, route_id, created_at, updated_at, is_imported, name
) VALUES
  (1, 10, '2024-06-10T08:00:00.000Z', '2024-06-10T08:00:00.000Z', 0, 'My plan');

INSERT INTO stages (
  id, stage_plan_id, route_id, date,
  start_city_id, end_city_id, created_at
) VALUES
  (1, 1, 10, '2024-06-15T08:00:00.000Z', 101, 102, '2024-06-10T08:00:00.000Z'),
  (2, 1, 10, '2024-06-16T08:00:00.000Z', 102, 103, '2024-06-10T08:00:00.000Z');

-- Plan 2: null name, empty string notes.
INSERT INTO stage_plans (
  id, route_id, created_at, updated_at, is_imported, name
) VALUES
  (2, 20, '2024-07-01T10:00:00.000Z', NULL, 1, NULL);

INSERT INTO stages (
  id, stage_plan_id, route_id, date,
  start_city_id, end_city_id,
  custom_start_notes, custom_end_notes, stage_notes,
  created_at
) VALUES
  (10, 2, 20, '2024-07-05T09:00:00.000Z', 201, 202, '', '', '', '2024-07-01T10:00:00.000Z'),
  (11, 2, 20, '2024-07-06T09:00:00.000Z', 202, 203, NULL, NULL, NULL, '2024-07-01T10:00:00.000Z');

-- Orphan stage (pre-FK-enforcement).
INSERT INTO stages (
  id, stage_plan_id, route_id, date,
  start_city_id, end_city_id, created_at
) VALUES
  (99, 9999, 10, '2024-06-20T08:00:00.000Z', 500, 501, '2024-06-10T08:00:00.000Z');
