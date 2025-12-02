import subprocess

def get_dropbox_status():
    try:
        result = subprocess.check_output(
            ["/home/jake/.local/bin/dropbox", "status"],
            stderr=subprocess.STDOUT
        ).decode().strip()
        return {"running": True, "status": result}
    except subprocess.CalledProcessError as e:
        return {"running": False, "status": f"error: {e.output.decode().strip()}"}
    except FileNotFoundError:
        return {"running": False, "status": "dropbox CLI not found"}