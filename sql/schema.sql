-- schema.sql
-- Normalized schema (1NF -> 2NF -> 3NF)

-- Drop if exists for re-run
DROP TABLE IF EXISTS recommendations CASCADE;
DROP TABLE IF EXISTS movie_stats CASCADE;
DROP TABLE IF EXISTS ratings CASCADE;
DROP TABLE IF EXISTS movie_genre CASCADE;
DROP TABLE IF EXISTS genres CASCADE;
DROP TABLE IF EXISTS movies CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- USERS table
CREATE TABLE users (
  user_id SERIAL PRIMARY KEY,
  username VARCHAR(100) UNIQUE NOT NULL,
  email VARCHAR(150) UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- MOVIES table (basic movie metadata)
CREATE TABLE movies (
  movie_id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  release_year SMALLINT,
  imdb_id VARCHAR(50),
  tmdb_id VARCHAR(50),
  description TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- GENRES table
CREATE TABLE genres (
  genre_id SERIAL PRIMARY KEY,
  name VARCHAR(100) UNIQUE NOT NULL
);

-- Junction table: MOVIE <-> GENRE (many-to-many)
CREATE TABLE movie_genre (
  movie_id INT NOT NULL REFERENCES movies(movie_id) ON DELETE CASCADE,
  genre_id INT NOT NULL REFERENCES genres(genre_id) ON DELETE CASCADE,
  PRIMARY KEY (movie_id, genre_id)
);

-- RATINGS table (user ratings / history)
CREATE TABLE ratings (
  rating_id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  movie_id INT NOT NULL REFERENCES movies(movie_id) ON DELETE CASCADE,
  rating NUMERIC(2,1) CHECK (rating >= 0 AND rating <= 5),
  rated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE (user_id, movie_id)
);

-- movie_stats: cached aggregates (optional)
CREATE TABLE movie_stats (
  movie_id INT PRIMARY KEY REFERENCES movies(movie_id) ON DELETE CASCADE,
  rating_count INT DEFAULT 0,
  rating_sum INT DEFAULT 0,
  avg_rating NUMERIC(3,2) DEFAULT NULL
);

-- recommendations: stores generated recs per user (optional)
CREATE TABLE recommendations (
  rec_id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  movie_id INT NOT NULL REFERENCES movies(movie_id) ON DELETE CASCADE,
  score NUMERIC(6,3),
  generated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE (user_id, movie_id)
);
