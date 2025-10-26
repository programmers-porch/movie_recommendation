from flask import Blueprint, request, jsonify, session, redirect, url_for, flash, render_template
from .models import create_user, get_user_by_username
from .utils import check_password

auth_bp = Blueprint('auth_bp', __name__, template_folder='../templates')

@auth_bp.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form.get('username', '').strip()
        email = request.form.get('email', '').strip()
        password = request.form.get('password', '')
        if not username or not password:
            flash('Username and password required', 'danger')
            return redirect(url_for('auth_bp.register'))
        try:
            uid = create_user(username, email, password)
            session['user_id'] = uid
            flash('Registered successfully', 'success')
            return redirect(url_for('main_bp.index'))
        except Exception as e:
            flash(f'Error creating user: {e}', 'danger')
            return redirect(url_for('auth_bp.register'))
    return render_template('register.html')

@auth_bp.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username', '').strip()
        password = request.form.get('password', '')
        user = get_user_by_username(username)
        if user and check_password(user['password_hash'], password):
            session['user_id'] = user['user_id']
            flash('Logged in', 'success')
            return redirect(url_for('main_bp.index'))
        flash('Invalid credentials', 'danger')
        return redirect(url_for('auth_bp.login'))
    return render_template('login.html')

@auth_bp.route('/logout')
def logout():
    session.pop('user_id', None)
    flash('Logged out', 'info')
    return redirect(url_for('main_bp.index'))
