import json
import mysql.connector
from paho.mqtt.client import Client

# Konfigurasi database MySQL
db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': '',           	   # ganti kalau ada
    'database': 'kolam_cerdas'     # ganti kalau beda
}

# Koneksi ke database
db = mysql.connector.connect(**db_config)
cursor = db.cursor()

# Simpan data ke tabel data_kolam
def simpan_data(data):
    sql = """
    INSERT INTO data_kolam (kolam_id, suhuAir, phAir, `do`, tinggiAir, beratPakan)
    VALUES (%s, %s, %s, %s, %s, %s)
    """
    values = (
        int(data['kolam']),
        float(data['suhuAir']),
        float(data['phAir']),
        float(data['do']),
        int(data['tinggiAir']),
        int(data['beratPakan'])
    )
    cursor.execute(sql, values)
    db.commit()
    print("✅ Data berhasil disimpan ke database!")

# Callback saat konek ke broker
def on_connect(client, userdata, flags, rc):
    print("Terhubung ke broker MQTT! Kode:", rc)
    client.subscribe("K6/kolam/sensor/status")

# Callback saat menerima pesan
def on_message(client, userdata, msg):
    print("📩 Pesan diterima:", msg.payload.decode())
    try:
        data = json.loads(msg.payload.decode())
        simpan_data(data)
    except Exception as e:
        print("⚠️ Gagal memproses data:", e)

# Setup MQTT Client
client = Client()
client.on_connect = on_connect
client.on_message = on_message

client.connect("mqtt.eclipseprojects.io", 1883, 60)
client.loop_forever()
