-- Stage planner schema at v2 (pre v3 migration).
-- stage_plans has no is_imported / name / uuid / plan_uuid /
-- deleted_at / starting_date. stages has no stage_number /
-- days_to_stay / stage_uuid and no FK. date is NOT NULL.
CREATE TABLE stage_plans (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  route_id INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT
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

-- Happy-path plan 1: three consecutive days.
INSERT INTO stage_plans (id, route_id, created_at, updated_at)
VALUES (1, 10, '2024-06-10T08:00:00.000Z', '2024-06-10T08:00:00.000Z');

INSERT INTO stages (
  id, stage_plan_id, route_id, date,
  start_city_id, end_city_id, created_at
) VALUES
  (1, 1, 10, '2024-06-15T08:00:00.000Z', 101, 102, '2024-06-10T08:00:00.000Z'),
  (2, 1, 10, '2024-06-16T08:00:00.000Z', 102, 103, '2024-06-10T08:00:00.000Z'),
  (3, 1, 10, '2024-06-17T08:00:00.000Z', 103, 104, '2024-06-10T08:00:00.000Z');

-- Happy-path plan 2: two stages, null updated_at.
INSERT INTO stage_plans (id, route_id, created_at, updated_at)
VALUES (2, 20, '2024-07-01T10:00:00.000Z', NULL);

INSERT INTO stages (
  id, stage_plan_id, route_id, date,
  start_city_id, end_city_id, start_albergue_id,
  custom_start_notes, created_at
) VALUES
  (10, 2, 20, '2024-07-05T09:00:00.000Z', 201, 202, 501, '', '2024-07-01T10:00:00.000Z'),
  (11, 2, 20, '2024-07-06T09:00:00.000Z', 202, 203, NULL, NULL, '2024-07-01T10:00:00.000Z');

-- Orphaned stage: stage_plan_id references a non-existent plan.
-- This is the PR #364 regression scenario — pre-v2.2.364 FK
-- enforcement was off so these could exist in prod.
INSERT INTO stages (
  id, stage_plan_id, route_id, date,
  start_city_id, end_city_id, created_at
) VALUES
  (99, 9999, 10, '2024-06-20T08:00:00.000Z', 500, 501, '2024-06-10T08:00:00.000Z');
