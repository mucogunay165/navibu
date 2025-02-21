from flask import Flask
from routes.auth  import auth_bp
from models import db
from flask_mail import Mail

app = Flask(__name__)
mail = Mail()

app.config["SQLALCHEMY_DATABASE_URI"] = "mysql+pymysql://root:Navibu161308_@localhost/NavibuDB"
db.init_app(app)
mail.init_app(app)
app.register_blueprint(auth_bp)

if __name__ == "__main__":
    app.run(debug=True)


