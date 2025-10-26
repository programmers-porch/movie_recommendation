-- triggers.sql
-- Trigger function to maintain movie_stats aggregate whenever ratings change.

CREATE OR REPLACE FUNCTION trg_update_movie_stats() RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO movie_stats(movie_id, rating_count, rating_sum, avg_rating)
    VALUES (NEW.movie_id, 1, NEW.rating, ROUND(NEW.rating::numeric,2))
    ON CONFLICT (movie_id) DO UPDATE
    SET rating_count = movie_stats.rating_count + 1,
        rating_sum = movie_stats.rating_sum + NEW.rating,
        avg_rating = ROUND((movie_stats.rating_sum + NEW.rating)::numeric / (movie_stats.rating_count + 1), 2);

    UPDATE movies SET -- keep updated (duplicate optional)
      -- nothing required here, movie_stats holds avg
      created_at = movies.created_at
    WHERE movie_id = NEW.movie_id;
    RETURN NEW;

  ELSIF TG_OP = 'UPDATE' THEN
    -- recompute aggregate from ratings
    UPDATE movie_stats
    SET (rating_count, rating_sum, avg_rating) = (
      SELECT COUNT(*), SUM(rating)::int, ROUND(AVG(rating)::numeric,2)
      FROM ratings WHERE movie_id = NEW.movie_id
      GROUP BY movie_id
    )
    WHERE movie_stats.movie_id = NEW.movie_id;

    RETURN NEW;

  ELSIF TG_OP = 'DELETE' THEN
    -- recompute or delete
    IF (SELECT COUNT(*) FROM ratings WHERE movie_id = OLD.movie_id) = 0 THEN
      DELETE FROM movie_stats WHERE movie_id = OLD.movie_id;
    ELSE
      UPDATE movie_stats
      SET (rating_count, rating_sum, avg_rating) = (
        SELECT COUNT(*), SUM(rating)::int, ROUND(AVG(rating)::numeric,2)
        FROM ratings WHERE movie_id = OLD.movie_id
        GROUP BY movie_id
      )
      WHERE movie_stats.movie_id = OLD.movie_id;
    END IF;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Attach triggers
DROP TRIGGER IF EXISTS ratings_after_insert ON ratings;
CREATE TRIGGER ratings_after_insert AFTER INSERT ON ratings
  FOR EACH ROW EXECUTE PROCEDURE trg_update_movie_stats();

DROP TRIGGER IF EXISTS ratings_after_update ON ratings;
CREATE TRIGGER ratings_after_update AFTER UPDATE ON ratings
  FOR EACH ROW EXECUTE PROCEDURE trg_update_movie_stats();

DROP TRIGGER IF EXISTS ratings_after_delete ON ratings;
CREATE TRIGGER ratings_after_delete AFTER DELETE ON ratings
  FOR EACH ROW EXECUTE PROCEDURE trg_update_movie_stats();
