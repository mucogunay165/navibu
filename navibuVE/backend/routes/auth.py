import datetime
from flask import Flask,Blueprint, request, jsonify
from werkzeug.security import generate_password_hash, check_password_hash
from models.user import db, User

auth_bp = Blueprint("auth",__name__)

@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.json
    email = data["email"]
    password = data["password"]  
    existing_user = User.query.filter_by(email=email).first()
    if existing_user:
        return jsonify({"error": "Bu e-posta zaten kayıtlı!"}), 400
    hashed_password = generate_password_hash(password)
    new_user = User(email=email, password_hash=hashed_password)
    new_user.verification_code = new_user.generate_verification_code()
    new_user.verification_expiry = datetime.datetime.utcnow() + datetime.timedelta(minutes=30)
    db.session.add(new_user)
    db.session.commit()
    new_user.send_verification_email()
    return jsonify({"message": "User registered"}), 201

@auth_bp.route("/verify", methods=["POST"])
def verify_user():
    """Kullanıcının doğrulama kodunu kontrol eder."""
    data = request.json
    email = data.get("email")
    code = data.get("code")

    user = User.query.filter_by(email=email).first()

    if not user:
        return jsonify({"message": "Kullanıcı bulunamadı"}), 404

    if user.is_verified:
        return jsonify({"message": "Kullanıcı zaten doğrulanmış"}), 400

    if user.verification_code == code and user.verification_expiry > datetime.datetime.utcnow():
        user.is_verified = True
        user.verification_code = None 
        user.verification_expiry = None
        db.session.commit()
        return jsonify({"message": "Hesap başarıyla doğrulandı!"}), 200
    else:
        return jsonify({"message": "Kod geçersiz veya süresi dolmuş"}), 400


@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.json
    user = User.query.filter_by(email=data['email']).first()

    if not user or not check_password_hash(user.password, data['password']):
        return jsonify({"error": "Invalid credentials"}), 401

    return jsonify({"message": "Login successful", "user_id": user.id}), 200
