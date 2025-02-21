from flask_mail import Mail, Message
from flask import Flask ,request, jsonify
from datetime import datetime, timedelta
from . import db
import random


app = Flask(__name__)

app.config["MAIL_SERVER"] = "smtp.gmail.com"
app.config["MAIL_PORT"] = 587
app.config["MAIL_USE_TLS"] = True
app.config["MAIL_USERNAME"] = "navibu0@gmail.com"
app.config["MAIL_PASSWORD"] = "Navibu161308_" 

mail = Mail(app)

class User(db.Model):
    __tablename__ = 'users' 
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(100), unique=True, nullable=False)
    password_hash = db.Column(db.String(200), nullable=False)  
    is_verified = db.Column(db.Boolean, default=False) 
    verification_code = db.Column(db.String(6), nullable=True)  
    verification_expiry = db.Column(db.DateTime, nullable=True) 

    def generate_verification_code(self):
        """E-posta doğrulama kodu üretir ve süreyi ayarlar."""
        self.verification_code = str(random.randint(100000, 999999))  # 6 haneli kod
        self.verification_expiry = datetime.utcnow() + timedelta(minutes=5)  # 5 dakika geçerli
        db.session.commit()
    
    def send_verification_email(self):
        """Kullanıcıya doğrulama e-postası gönderir."""
        self.generate_verification_code()
        msg = Message("Hesabınızı Doğrulayın",
              sender="navibu0@gmail.com",
              recipients=[self.email])
        msg.body = f"Doğrulama Kodunuz: {self.verification_code}"

@app.route("/verify", methods=["POST"])
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

    if user.verification_code == code and user.verification_expiry > datetime.utcnow():
        user.is_verified = True
        user.verification_code = None  # Kod kullanıldı, sıfırlıyoruz.
        user.verification_expiry = None
        db.session.commit()
        return jsonify({"message": "Hesap başarıyla doğrulandı!"}), 200
    else:
        return jsonify({"message": "Kod geçersiz veya süresi dolmuş"}), 400
