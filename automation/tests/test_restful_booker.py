import requests
import pytest

BASE_URL = "https://restful-booker.herokuapp.com"
HEADERS = {"Content-Type": "application/json", "Accept": "application/json"}
BOOKING = {
    "firstname": "Ivan",
    "lastname": "Petrov",
    "totalprice": 150,
    "depositpaid": True,
    "bookingdates": {"checkin": "2026-12-01", "checkout": "2026-12-05"},
    "additionalneeds": "Breakfast",
}


@pytest.fixture
def token():
    r = requests.post(f"{BASE_URL}/auth",
                      json={"username": "admin", "password": "password123"},
                      headers=HEADERS, timeout=15)
    assert r.status_code == 200
    return r.json()["token"]


@pytest.fixture
def booking_id():
    r = requests.post(f"{BASE_URL}/booking", json=BOOKING,
                      headers=HEADERS, timeout=15)
    assert r.status_code == 200
    return r.json()["bookingid"]


def test_create_booking():
    r = requests.post(f"{BASE_URL}/booking", json=BOOKING,
                      headers=HEADERS, timeout=15)
    assert r.status_code == 200  # documented quirk: create returns 200, not 201
    body = r.json()
    assert isinstance(body["bookingid"], int)
    assert body["booking"]["firstname"] == "Ivan"


def test_get_booking(booking_id):
    r = requests.get(f"{BASE_URL}/booking/{booking_id}",
                     headers=HEADERS, timeout=15)
    assert r.status_code == 200
    assert r.json()["lastname"] == "Petrov"


def test_update_booking(booking_id, token):
    updated = {**BOOKING, "firstname": "Georgi"}
    r = requests.put(f"{BASE_URL}/booking/{booking_id}", json=updated,
                     headers={**HEADERS, "Cookie": f"token={token}"}, timeout=15)
    assert r.status_code == 200
    assert r.json()["firstname"] == "Georgi"


def test_delete_booking(booking_id, token):
    r = requests.delete(f"{BASE_URL}/booking/{booking_id}",
                        headers={**HEADERS, "Cookie": f"token={token}"}, timeout=15)
    assert r.status_code == 201  # documented quirk: delete returns 201
    r2 = requests.get(f"{BASE_URL}/booking/{booking_id}",
                      headers=HEADERS, timeout=15)
    assert r2.status_code == 404


def test_get_unknown_booking_returns_404():
    r = requests.get(f"{BASE_URL}/booking/999999999",
                     headers=HEADERS, timeout=15)
    assert r.status_code == 404


def test_update_without_token_is_rejected(booking_id):
    r = requests.put(f"{BASE_URL}/booking/{booking_id}", json=BOOKING,
                     headers=HEADERS, timeout=15)
    assert r.status_code == 403
