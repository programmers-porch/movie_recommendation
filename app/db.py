import os
import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv
load_dotenv()

DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_PORT = os.getenv('DB_PORT', '5432')
DB_NAME = os.getenv('DB_NAME', 'movie_recommender')
DB_USER = os.getenv('DB_USER', 'movie_user')
DB_PASS = os.getenv('DB_PASS', 'moviepass')

def get_conn():
    return psycopg2.connect(host=DB_HOST, port=DB_PORT, dbname=DB_NAME, user=DB_USER, password=DB_PASS)

def query(sql, params=None, one=False):
    conn = get_conn()
    try:
        with conn:
            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                cur.execute(sql, params or ())
                if cur.description:
                    rows = cur.fetchall()
                    return rows[0] if one and rows else rows
                return None
    finally:
        conn.close()

def execute(sql, params=None):
    conn = get_conn()
    try:
        with conn:
            with conn.cursor() as cur:
                cur.execute(sql, params or ())
                return True
    finally:
        conn.close()
