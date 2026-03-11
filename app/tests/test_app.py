"""Unit tests for the Hello World application."""

import pytest
from app import app


@pytest.fixture
def client():
    """Create a test client for the Flask application."""
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


def test_hello_endpoint(client):
    """Test the root endpoint returns Hello World message."""
    response = client.get("/")
    assert response.status_code == 200
    data = response.get_json()
    assert data["message"] == "Hello World from ECS!"
    assert "hostname" in data
    assert "version" in data


def test_health_endpoint(client):
    """Test the health check endpoint."""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "healthy"
