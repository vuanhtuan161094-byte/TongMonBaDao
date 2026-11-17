#!/usr/bin/env python3
"""Serve the owner Wiki on loopback only. No LAN/public interface is opened."""
from __future__ import annotations

import argparse
import http.server
import sys
import threading
import webbrowser
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
HOST = "127.0.0.1"
PORT = 8766
PORT_FALLBACK_COUNT = 16


class LocalOnlyServer(http.server.ThreadingHTTPServer):
    daemon_threads = True
    allow_reuse_address = False


def make_handler():
    return lambda *args, **kwargs: http.server.SimpleHTTPRequestHandler(*args, directory=str(ROOT), **kwargs)


def bind_loopback(start_port: int) -> LocalOnlyServer:
    last_error = None
    for port in range(start_port, min(start_port + PORT_FALLBACK_COUNT, 65536)):
        try:
            return LocalOnlyServer((HOST, port), make_handler())
        except OSError as exc:
            last_error = exc
    if last_error is None:
        raise OSError("No valid loopback port is available in the configured range.")
    raise last_error


def main() -> int:
    for stream in (sys.stdout, sys.stderr):
        if hasattr(stream, "reconfigure"):
            stream.reconfigure(encoding="utf-8", errors="backslashreplace")
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--no-open", action="store_true", help="serve localhost without opening the system browser")
    parser.add_argument("--port", type=int, default=PORT, help="preferred localhost port (default: 8766)")
    args = parser.parse_args()
    if not 1024 <= args.port <= 65535:
        print("Port must be between 1024 and 65535.")
        return 2
    try:
        server = bind_loopback(args.port)
    except OSError as exc:
        print(f"Không thể mở Wiki trên loopback từ port {args.port}: {exc}")
        return 2
    port = int(server.server_address[1])
    url = f"http://{HOST}:{port}/wiki/"
    print("TMB Wiki — Tàng Kinh Các (owner-only)")
    print(f"Local URL: {url}")
    if port != args.port:
        print(f"Port {args.port} đang bận; đã bind port loopback khả dụng kế tiếp {port}.")
    print("Bind: 127.0.0.1 only; no LAN or public access.")
    print("Close this window to stop the local server.")
    if not args.no_open:
        threading.Timer(0.8, lambda: webbrowser.open(url, new=1)).start()
    try:
        server.serve_forever(poll_interval=0.25)
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
