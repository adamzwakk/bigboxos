#!/usr/bin/env python3
import os
import subprocess
import configparser
import datetime

CARTRIDGE_MOUNT = "/mnt/cartridge"
CART_INI = os.path.join(CARTRIDGE_MOUNT, "cart.ini")
LOG_FILE = "/home/bbuser/console_menu.log"

# Whitelisted runtimes
allowed_runtimes = {
    "scummvm": "/run/current-system/sw/bin/scummvm",
    "dosbox": "/run/current-system/sw/bin/dosbox",
    "ecwolf": "/run/current-system/sw/bin/ecwolf",
}

def log(message):
    with open(LOG_FILE, "a") as f:
        f.write(f"{datetime.datetime.now()} - {message}\n")

def launch_cartridge():
    if not os.path.exists(CART_INI):
        log("No cart.ini found")
        return

    config = configparser.ConfigParser()
    config.read(CART_INI)

    if "game" not in config:
        log("cart.ini missing [game] section")
        return

    runtime_key = config["game"].get("runtime", "").strip()
    cmd = config["game"].get("cmd", "").strip()
    args = config["game"].get("args", "").strip()
    run_from_files = config["game"].getboolean("run_from_files", fallback=False)

    work_dir = os.path.join(CARTRIDGE_MOUNT, "files") if run_from_files else CARTRIDGE_MOUNT
    if not os.path.exists(work_dir):
        log(f"Directory {work_dir} does not exist")
        return

    if runtime_key:
        if runtime_key not in allowed_runtimes:
            log(f"Runtime '{runtime_key}' not allowed")
            return
        exe_path = allowed_runtimes[runtime_key]
    elif cmd:
        exe_path = cmd
    else:
        log("No runtime or cmd specified in cart.ini")
        return

    game_cmd = [exe_path] + args.split() if args else [exe_path]
    log(f"Launching game: {game_cmd} cwd={work_dir}")

    try:
        subprocess.call(
            game_cmd,
            cwd=work_dir,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            stdin=subprocess.DEVNULL,
        )
    except Exception as e:
        log(f"Launch error: {e}")

if __name__ == "__main__":
    launch_cartridge()
