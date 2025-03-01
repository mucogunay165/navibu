from flask import Flask
from config import Config
from extensions import db, mail
from routes.auth import auth_bp
from routes.user_routes import user_routes_bp

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    db.init_app(app)
    mail.init_app(app)

    app.register_blueprint(auth_bp, url_prefix="/auth")
    app.register_blueprint(user_routes_bp, url_prefix="/api")

    return app

app = create_app()

if __name__ == "__main__":
    app.run(debug=True)


