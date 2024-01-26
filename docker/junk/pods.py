import subprocess
import json

def get_pod_names(namespace="kube-system"):
    command = ["kubectl", "get", "pods", "--namespace", namespace, "-o", "json"]
    result = subprocess.run(command, capture_output=True, text=True)

    if result.returncode == 0:
        pods_info = json.loads(result.stdout)
        pod_names = [pod["metadata"]["name"] for pod in pods_info.get("items", [])]
        return pod_names
    else:
        return f"Error: {result.stderr}"

# Example usage
pod_names = get_pod_names()
for pod in pod_names:

   print(pod)

