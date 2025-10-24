CREATE VIEW top_movies AS
SELECT m.title, m.release_year, d.director_name, m.imdb_rating
FROM movies m
JOIN directors d ON m.director_id = d.director_id
WHERE m.imdb_rating >= 8.5
ORDER BY m.imdb_rating DESC;
