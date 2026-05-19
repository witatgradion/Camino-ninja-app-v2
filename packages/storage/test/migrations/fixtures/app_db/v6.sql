-- Main app database schema at v6 (pre v7).
--
-- Schema is "v7-shaped" minus the legend color columns added in v8
-- (`light_legend_color`, `dark_legend_color` on `routes`).
-- The exact pre-v7 column shape doesn't matter because the
-- destructive `oldVersion < 7` upgrade branch DROPs everything
-- except `favorites_albergues` and recreates at the current
-- schema. What matters for the test:
--   1. `favorites_albergues` exists at the v6 shape and contains
--      rows that MUST survive the recreate.
--   2. Other tables exist with some seed data that MUST be wiped.
CREATE TABLE routes (
  id INTEGER PRIMARY KEY,
  order_key INTEGER NOT NULL,
  route_name TEXT,
  route_sub_name TEXT,
  legend_color TEXT
);

CREATE TABLE cities (
  id INTEGER PRIMARY KEY,
  order_key INTEGER NOT NULL,
  name TEXT,
  slug TEXT
);

CREATE TABLE albergues (
  id INTEGER PRIMARY KEY,
  name TEXT,
  city_id INTEGER,
  FOREIGN KEY (city_id) REFERENCES cities(id)
);

CREATE TABLE route_points (
  id INTEGER PRIMARY KEY,
  order_key INTEGER NOT NULL,
  route_id INTEGER,
  latitude REAL,
  longitude REAL,
  FOREIGN KEY (route_id) REFERENCES routes(id)
);

-- favorites_albergues at the v6 shape — same as the current
-- schema (the table predates v7) so the recreate has no work to
-- do here; the rows must survive untouched.
CREATE TABLE favorites_albergues (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  albergue_id INTEGER NOT NULL,
  city_id INTEGER NOT NULL,
  route_id INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT,
  deleted_at TEXT,
  FOREIGN KEY (albergue_id) REFERENCES albergues(id),
  UNIQUE(albergue_id)
);

-- Seed reference data (will be wiped by recreate).
INSERT INTO routes (id, order_key, route_name, route_sub_name, legend_color)
VALUES
  (1, 1, 'Camino Frances', 'Classic', '#FF0000'),
  (2, 2, 'Camino Portugues', NULL, '#00FF00');

INSERT INTO cities (id, order_key, name, slug) VALUES
  (100, 1, 'Saint Jean', 'saint-jean'),
  (101, 2, 'Roncesvalles', 'roncesvalles');

INSERT INTO albergues (id, name, city_id) VALUES
  (1000, 'Albergue A', 100),
  (1001, 'Albergue B', 101),
  (1002, 'Albergue C', 100),
  (1003, 'Albergue D', 101),
  (1004, 'Albergue E', 100);

INSERT INTO route_points (id, order_key, route_id, latitude, longitude) VALUES
  (5000, 1, 1, 43.1633, -1.2358),
  (5001, 2, 1, 43.0096, -1.3197);

-- Seed favorites_albergues — these rows MUST survive the recreate.
-- Five rows covering a few albergue/city/route combos with mixed
-- updated_at/deleted_at values to lock in that all columns ride
-- through unchanged.
INSERT INTO favorites_albergues
  (id, albergue_id, city_id, route_id, created_at, updated_at, deleted_at)
VALUES
  (1, 1000, 100, 1, '2026-01-10T10:00:00.000Z', '2026-01-10T10:00:00.000Z', NULL),
  (2, 1001, 101, 1, '2026-01-11T11:00:00.000Z', NULL, NULL),
  (3, 1002, 100, 1, '2026-01-12T12:00:00.000Z', '2026-02-01T00:00:00.000Z', NULL),
  (4, 1003, 101, 2, '2026-02-15T09:30:00.000Z', '2026-02-15T09:30:00.000Z', '2026-03-01T00:00:00.000Z'),
  (5, 1004, 100, 2, '2026-03-20T14:45:00.000Z', '2026-03-20T14:45:00.000Z', NULL);
