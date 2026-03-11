"""Hello World Python application for ECS deployment."""

from flask import Flask, jsonify
import os
import socket

app = Flask(__name__)


@app.route("/")
def hello():
    """Return a Hello World message with container metadata."""
    return jsonify(
        message="Hello World from ECS!",
        hostname=socket.gethostname(),
        version=os.environ.get("APP_VERSION", "1.0.0"),
    )


@app.route("/health")
def health():
    """Health check endpoint for ALB target group."""
    return jsonify(status="healthy"), 200


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)
