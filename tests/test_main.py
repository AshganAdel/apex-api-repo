from fastapi.testclient import TestClient

from main import app

client = TestClient(app)

def test_health():
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_readiness():
    response = client.get("/ready")

    assert response.status_code == 200
    assert response.json()["database"] == "connected"


def test_create_item():
    response = client.post(
        "/items",
        json={
            "name": "Server",
            "description": "Production server"
        }
    )

    assert response.status_code == 201
    assert response.json()["name"] == "Server"


def test_get_items():
    response = client.get("/items")

    assert response.status_code == 200


def test_metrics():
    response = client.get("/metrics")

    assert response.status_code == 200
    assert "http_requests_total" in response.text