-- views.sql

-- View: movie_info with aggregated genre names
CREATE OR REPLACE VIEW movie_info AS
SELECT
  m.movie_id,
  m.title,
  m.release_year,
  m.description,
  ms.avg_rating,
  COALESCE(string_agg(g.name, ', ' ORDER BY g.name), '') AS genres
FROM movies m
LEFT JOIN movie_genre mg ON m.movie_id = mg.movie_id
LEFT JOIN genres g ON mg.genre_id = g.genre_id
LEFT JOIN movie_stats ms ON ms.movie_id = m.movie_id
GROUP BY m.movie_id, m.title, m.release_year, m.description, ms.avg_rating;
