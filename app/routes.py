from flask import Blueprint, render_template, request, redirect, url_for, session, flash
from .models import list_movies, get_movie, add_or_update_rating
from .recommend import call_proc_recommend, fallback_inline
from .db import query

main_bp = Blueprint('main_bp', __name__, template_folder='../templates')

@main_bp.route('/')
def index():
    movies = list_movies(50)
    return render_template('catalog.html', movies=movies)

@main_bp.route('/catalog')
def catalog():
    movies = list_movies(200)
    return render_template('catalog.html', movies=movies)

@main_bp.route('/movie/<int:movie_id>', methods=['GET', 'POST'])
def movie_detail(movie_id):
    user_id = session.get('user_id')
    movie = get_movie(movie_id)
    if not movie:
        flash('Movie not found', 'warning')
        return redirect(url_for('main_bp.catalog'))
    if request.method == 'POST':
        if not user_id:
            flash('Login required to rate', 'danger')
            return redirect(url_for('auth_bp.login'))
        rating = float(request.form.get('rating', 0))
        add_or_update_rating(user_id, movie_id, rating)
        flash('Rating saved', 'success')
        return redirect(url_for('main_bp.movie_detail', movie_id=movie_id))
    # get user rating
    user_rating = None
    if user_id:
        r = query("SELECT rating FROM ratings WHERE user_id=%s AND movie_id=%s", (user_id, movie_id), one=True)
        if r:
            user_rating = r['rating']
    return render_template('movie_detail.html', movie=movie, user_rating=user_rating)

@main_bp.route('/recommendations')
def recommendations():
    user_id = session.get('user_id')
    if not user_id:
        flash('Please log in to see recommendations', 'warning')
        return redirect(url_for('auth_bp.login'))
    try:
        recs = call_proc_recommend(user_id)
        if not recs:
            recs = fallback_inline(user_id, limit=20)
    except Exception:
        recs = fallback_inline(user_id, limit=20)
    return render_template('recommendations.html', recs=recs)
