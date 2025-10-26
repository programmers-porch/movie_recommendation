from .db import query, execute, get_conn
from .utils import hash_password, check_password
from psycopg2.extras import RealDictCursor

# Users
def create_user(username, email, password):
    pwd = hash_password(password)
    sql = "INSERT INTO users (username, email, password_hash) VALUES (%s,%s,%s) RETURNING user_id;"
    conn = get_conn()
    try:
        with conn:
            with conn.cursor() as cur:
                cur.execute(sql, (username, email, pwd))
                return cur.fetchone()[0]
    finally:
        conn.close()

def get_user_by_username(username):
    return query("SELECT user_id, username, password_hash FROM users WHERE username = %s", (username,), one=True)

# Movies
def list_movies(limit=100):
    return query("SELECT * FROM movie_info ORDER BY title LIMIT %s", (limit,))

def get_movie(movie_id):
    return query("SELECT * FROM movie_info WHERE movie_id = %s", (movie_id,), one=True)

# Ratings
def add_or_update_rating(user_id, movie_id, rating):
    sql = """
    INSERT INTO ratings (user_id, movie_id, rating)
    VALUES (%s,%s,%s)
    ON CONFLICT (user_id, movie_id) DO UPDATE SET rating = EXCLUDED.rating, rated_at = NOW();
    """
    return execute(sql, (user_id, movie_id, rating))
