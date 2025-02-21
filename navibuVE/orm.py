from flask import Flask, request, jsonify 
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)

# Veritabanı Konfigürasyonu (MySQL Kullanıyoruz)
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql://root:Navibu161308_@localhost/navibuDB'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# Ara Tablo (Many-to-Many için)
user_routes = db.Table('user_routes',
    db.Column('user_id', db.Integer, db.ForeignKey('users.id', ondelete="CASCADE"), primary_key=True),
    db.Column('route_id', db.Integer, db.ForeignKey('routes.id', ondelete="CASCADE"), primary_key=True)
)

# Kullanıcı Modeli
class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(100), unique=True, nullable=False)
    password = db.Column(db.String(255), nullable=False)
    favorite_routes = db.relationship('Route', secondary=user_routes, backref=db.backref('users', lazy=True))

# Rota Modeli
class Route(db.Model):
    __tablename__ = 'routes'
    id = db.Column(db.Integer, primary_key=True)
    route_short_name = db.Column(db.String(50), nullable=False)
    route_long_name = db.Column(db.String(200), nullable=False)

@app.route('/add_favorite_route', methods=['POST'])
def add_favorite_route():
    data = request.json
    user = User.query.get(data['user_id'])
    route = Route.query.get(data['route_id'])

    if not user or not route:
        return jsonify({"error": "User or Route not found"}), 404

    user.favorite_routes.append(route)
    db.session.commit()

    return jsonify({"message": "Route added to favorites"}), 200


@app.route('/get_favorite_routes/<int:user_id>', methods=['GET'])
def get_favorite_routes(user_id):
    user = User.query.get(user_id)
    if not user:
        return jsonify({"error": "User not found"}), 404

    favorite_routes = [{"id": r.id, "name": r.route_short_name} for r in user.favorite_routes]
    
    return jsonify(favorite_routes), 200


with app.app_context():
    db.create_all()
