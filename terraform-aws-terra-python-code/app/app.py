from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from config import Config

app = Flask(__name__)
app.config.from_object(Config)
db = SQLAlchemy(app)

# ── Model ─────────────────────────
class Student(db.Model):
    __tablename__ = 'students'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    course = db.Column(db.String(100), default='General')

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'email': self.email,
            'course': self.course
        }

# ✅ Create table AFTER model
with app.app_context():
    db.create_all()

# ── ROUTES ─────────────────────────

# 1️⃣ Home
@app.route('/')
def home():
    return jsonify({'message': 'Student API running'})

# 2️⃣ GET all students
@app.route('/students', methods=['GET'])
def get_all_students():
    students = Student.query.all()
    return jsonify([s.to_dict() for s in students])

# 3️⃣ GET student by ID
@app.route('/students/<int:id>', methods=['GET'])
def get_student(id):
    student = Student.query.get_or_404(id)
    return jsonify(student.to_dict())

# 4️⃣ CREATE student
@app.route('/students', methods=['POST'])
def add_student():
    data = request.get_json()

    student = Student(
        name=data['name'],
        email=data['email'],
        course=data.get('course', 'General')
    )

    db.session.add(student)
    db.session.commit()

    return jsonify({
        'message': 'Student added',
        'student': student.to_dict()
    }), 201

# 5️⃣ UPDATE student
@app.route('/students/<int:id>', methods=['PUT'])
def update_student(id):
    student = Student.query.get_or_404(id)
    data = request.get_json()

    student.name = data.get('name', student.name)
    student.email = data.get('email', student.email)
    student.course = data.get('course', student.course)

    db.session.commit()

    return jsonify({
        'message': 'Student updated',
        'student': student.to_dict()
    })

# 6️⃣ DELETE student
@app.route('/students/<int:id>', methods=['DELETE'])
def delete_student(id):
    student = Student.query.get_or_404(id)

    db.session.delete(student)
    db.session.commit()

    return jsonify({'message': 'Student deleted'})