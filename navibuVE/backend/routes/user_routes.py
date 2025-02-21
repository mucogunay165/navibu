from flask import Blueprint, request, jsonify
from backend.models import db, User, Route, user_routes

user_routes_bp = Blueprint('user_routes', __name__)

@user_routes_bp.route('/add_favorite_route', methods=['POST'])
def add_favorite_route():
    data = request.json
    user = User.query.get(data['user_id'])
    route = Route.query.get(data['route_id'])

    if not user or not route:
        return jsonify({"error": "User or Route not found"}), 404

    user.favorite_routes.append(route)
    db.session.commit()

    return jsonify({"message": "Route added to favorites"}), 200

# Kullanıcının favori hatlarını listeleme
@user_routes_bp.route('/get_favorite_routes/<int:user_id>', methods=['GET'])
def get_favorite_routes(user_id):
    user = User.query.get(user_id)
    if not user:
        return jsonify({"error": "User not found"}), 404

    favorite_routes = [{"id": r.id, "name": r.route_short_name} for r in user.favorite_routes]
    
    return jsonify(favorite_routes), 200
