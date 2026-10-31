# Day 3: Restful-Booker, first manual API requests

Base URL: https://restful-booker.herokuapp.com

| # | Request | Expected (REST convention) | Actual | Comment |
|---|---|---|---|---|
| 1 | GET /ping | 200 | 201 | Differs from convention: expected 200, got 201 (possible quirk) |
| 2 | GET /booking | 200, list of IDs | 200 | As expected |
| 3 | GET /booking/1 | 200, booking JSON | 200 | As expected |
| 4 | POST /booking | 201 Created | 200 | Differs from convention: expected 201 Created, got 200 (possible quirk) |
| 5 | POST /auth | 200, token | 200 | As expected |
| 6 | PUT /booking/233 (token) | 200, updated booking | 200 | As expected |
| 7 | PATCH /booking/233 (token) | 200, only given field changed | 200 | As expected |
| 8 | DELETE /booking/233 (token) | 200 or 204 | 201 | Differs from convention: expected 200 or 204, got 201 (possible quirk) |
| 9 | GET /booking/233 after delete | 404 | 404 | As expected |
| 10 | PUT /booking/244 (no token) | 401 or 403 | 403 | As expected |

## Quirks and possible bugs
- Row 1 GET /ping: expected 200, got 201
- Row 4 POST /booking: expected 201 Created, got 200
- Row 8 DELETE /booking/233 (token): expected 200 or 204, got 201

## What I learned and debugging notes
- Bookings disappear after a few minutes on the shared server, so a test must create its own data.
- I got 404 and 405 on PUT when the booking no longer existed.
- I got 403 on PUT until the token was fresh and the Cookie header was typed exactly as token=<value>.
- PUT, PATCH and DELETE need a token; the POST /auth response body contains it.
- A scripted request needed the token sent as a proper cookie; sending it as a plain header was rejected with 403.
