from .db import get_conn, query

def call_proc_recommend(user_id):
    conn = get_conn()
    try:
        with conn:
            with conn.cursor() as cur:
                cur.callproc('recommend_for_user', (user_id,))
        # fetch recommendations from table
        recs = query("SELECT r.movie_id, m.title, r.score FROM recommendations r JOIN movies m ON r.movie_id = m.movie_id WHERE r.user_id = %s ORDER BY r.score DESC LIMIT 20;", (user_id,))
        return recs
    finally:
        conn.close()

def fallback_inline(user_id, limit=10):
    sql = """
    WITH user_genres AS (
      SELECT mg.genre_id
      FROM ratings r JOIN movie_genre mg ON r.movie_id = mg.movie_id
      WHERE r.user_id = %s AND r.rating >= 4
    ), genre_counts AS (
      SELECT m.movie_id, COUNT(*) AS match_score
      FROM movies m
        JOIN movie_genre mg ON m.movie_id = mg.movie_id
        JOIN user_genres ug ON mg.genre_id = ug.genre_id
      WHERE m.movie_id NOT IN (SELECT movie_id FROM ratings WHERE user_id = %s)
      GROUP BY m.movie_id
    )
    SELECT m.movie_id, m.title, gc.match_score
    FROM movies m JOIN genre_counts gc ON m.movie_id = gc.movie_id
    ORDER BY gc.match_score DESC
    LIMIT %s;
    """
    return query(sql, (user_id, user_id, limit))
