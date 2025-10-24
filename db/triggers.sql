CREATE TABLE rating_log (
    log_id SERIAL PRIMARY KEY,
    movie_id INT,
    old_rating NUMERIC(2,1),
    new_rating NUMERIC(2,1),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION log_rating_update()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO rating_log (movie_id, old_rating, new_rating)
    VALUES (NEW.movie_id, OLD.rating, NEW.rating);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_rating_update
AFTER UPDATE ON ratings
FOR EACH ROW
EXECUTE FUNCTION log_rating_update();
