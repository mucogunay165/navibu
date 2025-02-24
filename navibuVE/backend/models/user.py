from flask_mail import Mail, Message
from datetime import datetime, timedelta
from extensions import mail,db
import random

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
        mail.send(msg)

