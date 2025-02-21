import csv
from flask_mysqldb import MySQL
from flask import Flask
from . import db

class Route(db.Model):
    __tablename__ = 'routes'
    id = db.Column(db.Integer, primary_key=True)
    route_short_name = db.Column(db.String(50), nullable=False)
    route_long_name = db.Column(db.String(200), nullable=False)

app = Flask(__name__)

app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'Navibu161308_'
app.config['MYSQL_DB'] = 'navibuDB'

mysql = MySQL(app)

def import_routes():
    with app.app_context():
        cursor = mysql.connection.cursor()

        try:
            with open('routes.csv', 'r', encoding='utf-8') as file:
                reader = csv.reader(file)
                next(reader)  # Skip header row
                
                for row in reader:
                    if not row or len(row) < 5:  # Boş veya eksik satırları atla
                        continue
                    route_id, _, route_short_name, route_long_name, route_type, *_ = row
                    cursor.execute("INSERT IGNORE INTO routes (route_id, route_short_name, route_long_name, route_type) VALUES (%s, %s, %s, %s)",
                                 (route_id, route_short_name, route_long_name, route_type))
            
            mysql.connection.commit()
            print("Rotalar başarıyla yüklendi.")
            
        except Exception as e:
            print(f"Hata oluştu: {e}")
            mysql.connection.rollback()
            
        finally:
            cursor.close()

