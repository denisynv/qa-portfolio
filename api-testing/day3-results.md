| # | Request | Actual status | Body (start) |
|---|---|---|---|
| 1 | GET /ping | 201 | Created |
| 2 | GET /booking | 200 | [{"bookingid":1},{"bookingid":2},{"bookingid":3},{"bookingid":4},{"boo |
| 3 | GET /booking/1 | 200 | {"firstname":"Susan","lastname":"Jones","totalprice":304,"depositpaid" |
| 4 | POST /booking | 200 | {"bookingid":4204,"booking":{"firstname":"Ivan","lastname":"Petrov","t |
| 5 | POST /auth | 200 | {"token":"626dda98d80f8e2"} |
| 6 | PUT /booking/4204 | 403 |  |
| 7 | PATCH /booking/4204 | 403 |  |
| 8 | DELETE /booking/4204 | 403 |  |
| 9 | GET /booking/4204 (after delete) | 200 | {"firstname":"Ivan","lastname":"Petrov","totalprice":150,"depositpaid" |
| 10 | PUT /booking/4226 (no token) | 403 |  |
