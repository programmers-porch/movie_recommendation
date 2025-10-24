-- Database
CREATE DATABASE imdb_recommender;
\c imdb_recommender;

-- 1. Movie Table (Main entity)
CREATE TABLE movies (
    movie_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    release_year INT,
    certificate VARCHAR(20),
    runtime VARCHAR(20),
    imdb_rating NUMERIC(3,1),
    overview TEXT,
    director_id INT,
    gross BIGINT,
    votes BIGINT
);

-- 2. Director Table (1NF - separate from movie)
CREATE TABLE directors (
    director_id SERIAL PRIMARY KEY,
    director_name VARCHAR(255) UNIQUE NOT NULL
);

-- 3. Genre Table
CREATE TABLE genres (
    genre_id SERIAL PRIMARY KEY,
    genre_name VARCHAR(100) UNIQUE NOT NULL
);

-- 4. Movie-Genre Mapping (Many-to-Many)
CREATE TABLE movie_genres (
    movie_id INT REFERENCES movies(movie_id) ON DELETE CASCADE,
    genre_id INT REFERENCES genres(genre_id) ON DELETE CASCADE,
    PRIMARY KEY (movie_id, genre_id)
);

-- 5. Actors Table
CREATE TABLE actors (
    actor_id SERIAL PRIMARY KEY,
    actor_name VARCHAR(255) UNIQUE NOT NULL
);

-- 6. Movie-Actor Relationship (Many-to-Many)
CREATE TABLE movie_actors (
    movie_id INT REFERENCES movies(movie_id) ON DELETE CASCADE,
    actor_id INT REFERENCES actors(actor_id) ON DELETE CASCADE,
    PRIMARY KEY (movie_id, actor_id)
);

-- 7. Ratings Table (User rating)
CREATE TABLE ratings (
    rating_id SERIAL PRIMARY KEY,
    movie_id INT REFERENCES movies(movie_id),
    user_id INT,
    rating NUMERIC(2,1),
    rated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
