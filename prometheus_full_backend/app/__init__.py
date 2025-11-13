from flask import Flask
from .config import Config
from .db import db

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config())
    db.init_app(app)

    with app.app_context():
        from . import models  # register models
        db.create_all()

        from .controllers.generic import make_blueprint
        tables = [
            ('roles','Role'),('users','User'),('user_roles','UserRole'),
            ('courses','Course'),('course_instructors','CourseInstructor'),
            ('modules','Module'),('lessons','Lesson'),('enrollments','Enrollment'),
            ('tests','Test'),('questions','Question'),('options','Option'),
            ('test_attempts','TestAttempt'),('test_attempt_answers','TestAttemptAnswer'),
            ('progress','Progress'),('notifications','Notification')
        ]
        for path, model in tables:
            app.register_blueprint(make_blueprint(model), url_prefix=f"/api/{path}")

    @app.get('/')
    def index():
        return {"app":"Prometheus API","status":"ok"}

    return app
