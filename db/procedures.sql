CREATE OR REPLACE PROCEDURE recommend_by_genre(IN g_name VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT m.title, m.imdb_rating
    FROM movies m
    JOIN movie_genres mg ON m.movie_id = mg.movie_id
    JOIN genres g ON g.genre_id = mg.genre_id
    WHERE g.genre_name ILIKE g_name
    ORDER BY m.imdb_rating DESC
    LIMIT 10;
END;
$$;

CALL recommend_by_genre('Action');
