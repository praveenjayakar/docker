from flask import Flask, jsonify
import psutil

app = Flask(__name__)

@app.route('/metrics')
def get_server_metrics():
    # Gather server metrics using psutil
    cpu_usage = psutil.cpu_percent(interval=1)
    memory_info = psutil.virtual_memory()
    disk_info = psutil.disk_usage('/')

    # Prepare a JSON response with server metrics
    metrics = {
        'cpu_usage_percent': cpu_usage,
        'memory_usage_percent': memory_info.percent,
        'disk_usage_percent': disk_info.percent
    }

    return jsonify(metrics)

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)

