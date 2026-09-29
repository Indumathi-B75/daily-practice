from flask import Flask
import psycopg2
import os

app = Flask(__name__)

DATABASE_URL = os.environ.get("DATABASE_URL")


@app.route("/")
def home():
    try:
        conn = psycopg2.connect(DATABASE_URL)
        cursor = conn.cursor()

        cursor.execute("SELECT * FROM students;")
        students = cursor.fetchall()

        cursor.close()
        conn.close()

        return {
            "status": "success",
            "students": students
        }

    except Exception as e:
        return {
            "status": "error",
            "message": str(e)
        }


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
