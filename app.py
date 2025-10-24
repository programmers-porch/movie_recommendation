import psycopg2
import pandas as pd
from flask import Flask, render_template, request

app = Flask(__name__)

# Database connection
conn = psycopg2.connect(
    dbname="imdb_recommender",
    user="postgres",
    password="yourpassword",
    host="localhost",
    port="5432"
)

# Home route
@app.route('/')
def home():
    return render_template('index.html')

# Route to show top movies
@app.route('/top')
def top_movies():
    cur = conn.cursor()
    cur.execute("SELECT * FROM top_movies;")
    data = cur.fetchall()
    cur.close()
    return render_template('top.html', movies=data)

# Route to recommend by genre
@app.route('/recommend', methods=['POST'])
def recommend():
    genre = request.form['genre']
    cur = conn.cursor()
    cur.callproc('recommend_by_genre', [genre])
    data = cur.fetchall()
    cur.close()
    return render_template('recommend.html', genre=genre, movies=data)

if __name__ == '__main__':
    app.run(debug=True)
