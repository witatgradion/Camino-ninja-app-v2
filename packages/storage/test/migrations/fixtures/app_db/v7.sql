-- Main app database schema at v7 (pre v8).
-- routes does NOT have light_legend_color / dark_legend_color
-- columns — v8 migration adds them non-destructively.
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

-- Seed data.
INSERT INTO routes (id, order_key, route_name, route_sub_name, legend_color)
VALUES
  (1, 1, 'Camino Frances', 'Classic', '#FF0000'),
  (2, 2, 'Camino Portugues', NULL, '#00FF00');

INSERT INTO cities (id, order_key, name, slug) VALUES
  (100, 1, 'Saint Jean', 'saint-jean'),
  (101, 2, 'Roncesvalles', 'roncesvalles');

INSERT INTO albergues (id, name, city_id) VALUES
  (1000, 'Albergue A', 100),
  (1001, 'Albergue B', 101);
