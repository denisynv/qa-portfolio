# API tests (pytest + requests)

Six tests against the public Restful-Booker API: create, read, update, delete, unknown id (404), update without token (403).
Each test that needs a booking creates its own through a fixture, because data on the shared server disappears after a few minutes.

## Run
    python -m venv .venv
    .venv\Scripts\Activate.ps1
    pip install -r requirements.txt
    python -m pytest -v

Known API quirks asserted in the tests: create returns 200 (not 201), delete returns 201.

## Concepts used in these tests

| Concept | Meaning in this project |
|---|---|
| pytest | Test runner. It finds files named `test_*.py` and functions named `test_*` and runs them |
| `assert` | The check. If the condition is false, the test fails and pytest shows the values |
| fixture (`@pytest.fixture`) | Setup function that gives a test its data. `booking_id` creates a fresh booking, `token` logs in. A test receives it by naming it as a parameter |
| `requests` | Python library that sends HTTP requests (`post`, `get`, `put`, `delete`) and returns a response with `.status_code` and `.json()` |
| `timeout=15` | A request that does not answer in 15 seconds fails instead of hanging forever |
| Independent tests | Each test creates its own data, so the order does not matter and one failure does not break the others |
| Status code quirks | This API returns 200 on create and 201 on delete. The tests assert what the API really does and say so in a comment |

## What each test checks

| Test | Checks |
|---|---|
| test_create_booking | Status 200, an integer booking id, the first name echoed back |
| test_get_booking | Status 200 and the stored last name |
| test_update_booking | PUT with a valid token changes the first name |
| test_delete_booking | DELETE returns 201, and a following GET returns 404 |
| test_get_unknown_booking_returns_404 | A missing id gives 404 |
| test_update_without_token_is_rejected | PUT without a token gives 403 |
