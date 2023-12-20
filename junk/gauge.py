from flask import Flask, render_template
from flask_socketio import SocketIO
import psutil
import json
from threading import Thread
import time

app = Flask(__name__)
socketio = SocketIO(app)

# Function to emit server metrics via WebSocket
def emit_server_metrics():
    while True:
        cpu_percent = psutil.cpu_percent(interval=1)
        memory_percent = psutil.virtual_memory().percent
        disk_percent = psutil.disk_usage('/').percent

        metrics = {
            'cpu_percent': cpu_percent,
            'memory_percent': memory_percent,
            'disk_percent': disk_percent
        }

        socketio.emit('update_metrics', json.dumps(metrics))
        time.sleep(1)

# Route to serve the HTML page with the real-time metrics dashboard
@app.route('/')
def index():
    return render_template('index_gauge.html')

# SocketIO event handler for client connections
@socketio.on('connect')
def handle_connect():
    print('Client connected')

# SocketIO event handler for client disconnections
@socketio.on('disconnect')
def handle_disconnect():
    print('Client disconnected')

if __name__ == '__main__':
    # Start the WebSocket thread
    metrics_thread = Thread(target=emit_server_metrics)
    metrics_thread.start()

    # Run the Flask app with WebSocket support
    socketio.run(app, host='0.0.0.0', port=5000)

