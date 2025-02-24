class Config:
    SECRET_KEY = 'supersecretkey'
    SQLALCHEMY_DATABASE_URI = "mysql+pymysql://root:Navibu161308_@localhost/NavibuDB"
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    
    MAIL_SERVER = 'live.smtp.mailtrap.io'  # Düzeltildi
    MAIL_PORT = 587
    MAIL_USERNAME = 'api'
    MAIL_PASSWORD = 'd87e8948d46128ab8bd6594cb5265f14'
    MAIL_USE_TLS = True
    MAIL_USE_SSL = False

    MYSQL_HOST = 'localhost'
    MYSQL_USER = 'root'
    MYSQL_PASSWORD = 'Navibu161308_'
    MYSQL_DB = 'navibuDB'