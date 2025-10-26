-- seed_data.sql (small samples for immediate testing)

-- Insert genres
INSERT INTO genres (name) VALUES ('Action') ON CONFLICT DO NOTHING;
INSERT INTO genres (name) VALUES ('Comedy') ON CONFLICT DO NOTHING;
INSERT INTO genres (name) VALUES ('Drama') ON CONFLICT DO NOTHING;
INSERT INTO genres (name) VALUES ('Sci-Fi') ON CONFLICT DO NOTHING;
INSERT INTO genres (name) VALUES ('Romance') ON CONFLICT DO NOTHING;

-- Insert movies
INSERT INTO movies (title, release_year, description) VALUES
  ('The Matrix', 1999, 'A hacker discovers reality is simulated.') ON CONFLICT DO NOTHING;
INSERT INTO movies (title, release_year, description) VALUES
  ('Inception', 2010, 'A thief who infiltrates dreams.') ON CONFLICT DO NOTHING;
INSERT INTO movies (title, release_year, description) VALUES
  ('Toy Story', 1995, 'Toys come to life.') ON CONFLICT DO NOTHING;
INSERT INTO movies (title, release_year, description) VALUES
  ('The Godfather', 1972, 'Crime family drama.') ON CONFLICT DO NOTHING;
INSERT INTO movies (title, release_year, description) VALUES
  ('The Notebook', 2004, 'Romantic drama.') ON CONFLICT DO NOTHING;

-- Map genres to movies (resolve ids dynamically)
WITH m AS (
  SELECT movie_id, title FROM movies
)
INSERT INTO movie_genre (movie_id, genre_id)
SELECT m.movie_id, g.genre_id
FROM m JOIN genres g ON
  (m.title = 'The Matrix' AND g.name = 'Sci-Fi')
  OR (m.title = 'Inception' AND g.name = 'Sci-Fi')
  OR (m.title = 'Toy Story' AND g.name = 'Comedy')
  OR (m.title = 'The Godfather' AND g.name = 'Drama')
  OR (m.title = 'The Notebook' AND g.name = 'Romance')
ON CONFLICT DO NOTHING;

-- Insert a test user with password hash placeholder (replace via app or generate)
INSERT INTO users (username, email, password_hash) VALUES
  ('testuser','test@example.com','REPLACE_WITH_HASH') ON CONFLICT DO NOTHING;

-- Example ratings (if user exists and movie ids align)
-- Use app registration to create real users (recommended).
