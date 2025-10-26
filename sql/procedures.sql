-- procedures.sql
-- A stored procedure to compute recommendations for a user using genre overlap.
-- It uses a temporary table and a cursor internally.

CREATE OR REPLACE PROCEDURE recommend_for_user(uid INT)
LANGUAGE plpgsql
AS $$
DECLARE
  cur_gen REFCURSOR;
  g RECORD;
BEGIN
  -- Clear old recommendations
  DELETE FROM recommendations WHERE user_id = uid;

  -- Temp table to hold scores
  CREATE TEMP TABLE tmp_scores (movie_id INT PRIMARY KEY, score INT DEFAULT 0) ON COMMIT DROP;

  -- Cursor: select distinct genres liked (rating >= 4)
  OPEN cur_gen FOR
    SELECT DISTINCT mg.genre_id
    FROM ratings r
    JOIN movie_genre mg ON r.movie_id = mg.movie_id
    WHERE r.user_id = uid AND r.rating >= 4;

  LOOP
    FETCH cur_gen INTO g;
    EXIT WHEN NOT FOUND;

    -- For each genre, increment score for movies in that genre excluding already rated
    INSERT INTO tmp_scores(movie_id, score)
    SELECT mg.movie_id, 1
    FROM movie_genre mg
    WHERE mg.genre_id = g.genre_id
      AND mg.movie_id NOT IN (SELECT movie_id FROM ratings WHERE user_id = uid)
    ON CONFLICT (movie_id) DO UPDATE SET score = tmp_scores.score + 1;
  END LOOP;
  CLOSE cur_gen;

  -- Normalize and insert top movies into recommendations
  INSERT INTO recommendations (user_id, movie_id, score)
  SELECT uid, ts.movie_id, ROUND(CAST(ts.score AS NUMERIC)/NULLIF((SELECT GREATEST(MAX(score),1) FROM tmp_scores),0),3) AS normalized
  FROM tmp_scores ts
  ORDER BY ts.score DESC
  LIMIT 20;

END;
$$;
