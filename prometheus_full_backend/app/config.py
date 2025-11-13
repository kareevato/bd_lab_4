from dotenv import load_dotenv
import os

class Config:
    def __init__(self):
        load_dotenv()
        user = os.getenv("DB_USER", "prometheus_user")
        pwd = os.getenv("DB_PASSWORD", "prometheus_pass_123")
        host = os.getenv("DB_HOST", "127.0.0.1")
        port = os.getenv("DB_PORT", "3306")
        name = os.getenv("DB_NAME", "prometheus")
        self.SQLALCHEMY_DATABASE_URI = f"mysql+pymysql://{user}:{pwd}@{host}:{port}/{name}?charset=utf8mb4"
        self.SQLALCHEMY_TRACK_MODIFICATIONS = False
        self.SECRET_KEY = os.getenv("APP_SECRET", "change_me")
