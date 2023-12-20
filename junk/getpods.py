import subprocess

def get_pods(namespace="kube-system"):
    command = ["kubectl", "get", "pods", "--namespace", namespace, "-o", "json"]
    result = subprocess.run(command, capture_output=True, text=True)

    if result.returncode == 0:
        return result.stdout
    else:
        return f"Error: {result.stderr}"

# Example usage
pods_info = get_pods()
print(pods_info)

