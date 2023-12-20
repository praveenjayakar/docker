from flask import Flask, render_template
import psutil

app = Flask(__name__)

# Function to convert bytes to megabytes
def bytes_to_mb(bytes_value):
    return round(bytes_value / (1024 ** 2), 2)

# Route to show server metrics
@app.route('/')
def server_metrics():
    cpu_percent = psutil.cpu_percent()
    memory_info = psutil.virtual_memory()
    disk_info = psutil.disk_usage('/')

    # Convert bytes to megabytes
    memory_info_total_mb = bytes_to_mb(memory_info.total)
    memory_info_used_mb = bytes_to_mb(memory_info.used)
    memory_info_free_mb = bytes_to_mb(memory_info.free)

    disk_info_total_mb = bytes_to_mb(disk_info.total)
    disk_info_used_mb = bytes_to_mb(disk_info.used)
    disk_info_free_mb = bytes_to_mb(disk_info.free)

    return render_template('server_metrics.html',
                           cpu_percent=cpu_percent,
                           memory_info_total=memory_info_total_mb,
                           memory_info_used=memory_info_used_mb,
                           memory_info_free=memory_info_free_mb,
                           memory_info_percent=memory_info.percent,
                           disk_info_total=disk_info_total_mb,
                           disk_info_used=disk_info_used_mb,
                           disk_info_free=disk_info_free_mb,
                           disk_info_percent=disk_info.percent)

if __name__ == '__main__':
    app.run(host="0.0.0.0",debug=True)

