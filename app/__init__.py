import os
from flask import Flask
from dotenv import load_dotenv

load_dotenv()

def create_app():
    app = Flask(__name__, template_folder="../templates", static_folder="../static")
    app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'dev-secret')
    # DB config via env, used by db.get_conn
    # register blueprints
    from .routes import main_bp
    from .auth import auth_bp
    app.register_blueprint(main_bp)
    app.register_blueprint(auth_bp, url_prefix='/auth')
    return app
