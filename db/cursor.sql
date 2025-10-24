DO $$
DECLARE
    rec RECORD;
    cur CURSOR FOR
        SELECT title, imdb_rating FROM movies ORDER BY imdb_rating DESC LIMIT 5;
BEGIN
    OPEN cur;
    LOOP
        FETCH cur INTO rec;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Movie: %, Rating: %', rec.title, rec.imdb_rating;
    END LOOP;
    CLOSE cur;
END $$;
