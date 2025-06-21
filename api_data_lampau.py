from flask import Flask, jsonify
import mysql.connector

app = Flask(__name__)

# Konfigurasi koneksi database
db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': '',
    'database': 'kolam_cerdas'
}

@app.route('/data_lampau', methods=['GET'])
def get_data_lampau():
    try:
        db = mysql.connector.connect(**db_config)
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM data_kolam ORDER BY timestamp DESC LIMIT 100")
        rows = cursor.fetchall()
        return jsonify(rows)
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)})
    finally:
        if db.is_connected():
            cursor.close()
            db.close()

if __name__ == '__main__':
    app.run(debug=True, port=5000)
