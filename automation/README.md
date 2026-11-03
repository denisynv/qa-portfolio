# API tests (pytest + requests)

Six tests against the public Restful-Booker API: create, read, update, delete, unknown id (404), update without token (403).
Each test that needs a booking creates its own through a fixture, because data on the shared server disappears after a few minutes.

## Run
    python -m venv .venv
    .venv\Scripts\Activate.ps1
    pip install -r requirements.txt
    python -m pytest -v

Known API quirks asserted in the tests: create returns 200 (not 201), delete returns 201.
