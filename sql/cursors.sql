-- cursors.sql
-- Example usage of a cursor in a DO block for debugging / admin
DO $$
DECLARE
  cur CURSOR FOR SELECT genre_id, name FROM genres;
  rec RECORD;
BEGIN
  OPEN cur;
  LOOP
    FETCH cur INTO rec;
    EXIT WHEN NOT FOUND;
    RAISE NOTICE 'Genre: % (%), Movies: %', rec.name, rec.genre_id, (SELECT COUNT(*) FROM movie_genre WHERE genre_id = rec.genre_id);
  END LOOP;
  CLOSE cur;
END
$$ LANGUAGE plpgsql;
