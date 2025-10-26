"""
Load MovieLens 'ml-latest-small' CSVs into the normalized DB.
Place movies.csv and ratings.csv in /data before running.

Usage:
  source venv/bin/activate
  python scripts/load_data.py
"""
import os
import pandas as pd
import psycopg2
from psycopg2.extras import execute_values
from dotenv import load_dotenv

load_dotenv()

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "movie_recommender")
DB_USER = os.getenv("DB_USER", "movie_user")
DB_PASS = os.getenv("DB_PASS", "moviepass")

DATA_DIR = os.path.join(os.path.dirname(__file__), '..', 'data')

def get_conn():
    return psycopg2.connect(host=DB_HOST, port=DB_PORT, dbname=DB_NAME, user=DB_USER, password=DB_PASS)

def load_genres_and_movies():
    movies_csv = os.path.join(DATA_DIR, 'movies.csv')
    if not os.path.exists(movies_csv):
        print("movies.csv not found in data/ - abort.")
        return

    movies_df = pd.read_csv(movies_csv)
    # Extract unique genres
    genres = set()
    for g in movies_df['genres'].fillna('(no genres listed)'):
        if g == '(no genres listed)':
            continue
        for item in g.split('|'):
            genres.add(item.strip())

    conn = get_conn()
    cur = conn.cursor()
    # Insert genres
    for g in sorted(genres):
        cur.execute("INSERT INTO genres (name) VALUES (%s) ON CONFLICT (name) DO NOTHING;", (g,))
    conn.commit()

    # Insert movies and movie_genre relationships
    for _, row in movies_df.iterrows():
        title = row['title']
        # try parse year from title like "Toy Story (1995)"
        year = None
        import re
        m = re.search(r'\((\d{4})\)', title)
        if m:
            year = int(m.group(1))
        # insert movie
        cur.execute("INSERT INTO movies (title, release_year) VALUES (%s, %s) ON CONFLICT (title) DO NOTHING RETURNING movie_id;", (title, year))
        res = cur.fetchone()
        if res:
            movie_id = res[0]
        else:
            # fetch existing id
            cur.execute("SELECT movie_id FROM movies WHERE title=%s;", (title,))
            movie_id = cur.fetchone()[0]

        # insert movie_genre
        if row['genres'] != '(no genres listed)':
            for g in row['genres'].split('|'):
                g = g.strip()
                cur.execute("SELECT genre_id FROM genres WHERE name=%s;", (g,))
                genre_id = cur.fetchone()[0]
                cur.execute("INSERT INTO movie_genre (movie_id, genre_id) VALUES (%s, %s) ON CONFLICT DO NOTHING;", (movie_id, genre_id))
    conn.commit()
    cur.close()
    conn.close()
    print("Movies & genres loaded.")

def load_ratings():
    ratings_csv = os.path.join(DATA_DIR, 'ratings.csv')
    if not os.path.exists(ratings_csv):
        print("ratings.csv not found in data/ - abort.")
        return
    ratings_df = pd.read_csv(ratings_csv)
    conn = get_conn()
    cur = conn.cursor()
    # Note: MovieLens userIds may not match your users table; for demo we upsert users
    user_ids = ratings_df['userId'].unique()
    for uid in user_ids:
        cur.execute("INSERT INTO users (username, email, password_hash) VALUES (%s, %s, %s) ON CONFLICT (username) DO NOTHING;", (f"user{uid}", f"user{uid}@example.com", 'seeded'))
    conn.commit()

    # Insert ratings (use user matching by username user{userId})
    records = []
    for _, r in ratings_df.iterrows():
        username = f"user{int(r['userId'])}"
        cur.execute("SELECT user_id FROM users WHERE username=%s;", (username,))
        user_id = cur.fetchone()[0]
        movieId = int(r['movieId'])
        rating = float(r['rating'])
        records.append((user_id, movieId, rating))
    # Bulk insert with ON CONFLICT DO UPDATE
    for rec in records:
        cur.execute("""
            INSERT INTO ratings (user_id, movie_id, rating) VALUES (%s,%s,%s)
            ON CONFLICT (user_id, movie_id) DO UPDATE SET rating = EXCLUDED.rating, rated_at = NOW();
        """, rec)
    conn.commit()
    cur.close()
    conn.close()
    print("Ratings loaded.")

if __name__ == "__main__":
    load_genres_and_movies()
    load_ratings()
