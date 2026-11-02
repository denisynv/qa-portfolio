# Petstore API: test ideas and results

| | |
|---|---|
| **API** | Swagger Petstore v2, https://petstore.swagger.io/v2 |
| **Tool** | Swagger UI, "Try it out" |
| **Date** | 2 Nov 2026 |
| **Server header** | Jetty(9.4.58.v20250814) |
| **Tester** | Denis Yanev |
| **Note** | Shared public demo API. Other people use the same data, so I used a unique id (987654) |

## 1. What the spec shows (from Swagger UI)

| Endpoint | Documented responses I saw |
|---|---|
| POST /pet | 405 Invalid input |
| GET /pet/{petId} | 200 successful operation |

Swagger UI marked the 200 returned by POST, PUT and DELETE as **Undocumented**.

## 2. Flow I executed: create, read, update, delete

| Step | Request | Result | Observation |
|---|---|---|---|
| 1 | POST /pet (id 987654, name denis-test-dog, status available) | 200 | Body echoes the request exactly |
| 2 | GET /pet/987654 | 200 | Same data as created |
| 3 | PUT /pet (id 0, name doggie, extra field "sold" instead of "status") | 200 | Unknown field ignored; server generated id 9223372000001120000, no status field. Pet 987654 was not changed (GET still showed status available) |
| 4 | DELETE /pet/987654 | 200 | Body: code 200, type unknown, message 987654 |
| 5 | GET /pet/987654 | 404 | Body: code 1, type error, message Pet not found. Proves the delete worked |
| 6 | PUT /pet (id 987654, name doggie, status sold), sent after the delete | 200 | Response shows id 987654 and status sold. No 404 although the pet had been deleted |
| 7 | Follow-up response body (copied without its request header, assumed to be a GET) | 200 | Pet 987654 with status sold |
| 8 | DELETE /pet/987654 (cleanup) | 200 | Returned 200 although the pet had been deleted earlier, so the PUT in step 6 had re-created it |
| 9 | DELETE /pet/987655 (cleanup of the missing-name test pet) | 200 | Test data removed |

Note: in step 3 the server created a new record because the id was 0. The PUT in step 6 used the real id, but only after the pet had been deleted, so it is not a clean update test. See section 6.

## 3. Test ideas (5 per endpoint)

### POST /pet

| # | Test idea | Input | Expected | Actual | Status |
|---|---|---|---|---|---|
| 1 | Valid pet is created | All fields valid | 200, body echoes data | 200, body identical to request | Pass |
| 2 | Required field missing | Valid JSON without name (id 987655) | 4xx (spec lists 405) | **200**, pet created, response has no name field | Bug candidate |
| 3 | Wrong data type | photoUrls as the string "string" | 4xx | **500**, "something bad happened" | Bug candidate |
| 4 | Value outside the enum | status "banana" | 4xx (spec lists 405) | **200**, "banana" echoed back | Bug candidate |
| 5 | Empty body | {} | 4xx | **200**, pet created with generated id 9223372000001139000, photoUrls [] and tags [] | Bug candidate |

### GET /pet/{petId}

| # | Test idea | Input | Expected | Actual | Status |
|---|---|---|---|---|---|
| 1 | Existing pet | 987654 | 200, same data | 200, same data | Pass |
| 2 | Deleted pet | 987654 after delete | 404 | 404, "Pet not found" | Pass |
| 3 | Non-numeric id | abc | 4xx | Not run | Not executed |
| 4 | Unknown large id | 99999999999 | 404 | Not run | Not executed |
| 5 | Negative id | -1 | 4xx | Not run | Not executed |

### DELETE /pet/{petId}

| # | Test idea | Input | Expected | Actual | Status |
|---|---|---|---|---|---|
| 1 | Delete an existing pet | 987654 | 200 | 200, body code 200 / message 987654 | Pass |
| 2 | Pet is really gone | GET after delete | 404 | 404 | Pass |
| 3 | Delete the same id twice | 987654 again | 404 | Not run | Not executed |
| 4 | Non-numeric id | abc | 4xx | Not run | Not executed |
| 5 | Delete without the api_key header | none | Behaviour per spec | Not run | Not executed |

## 4. Invalid input experiments on POST /pet

| # | Change | Result | Where it was stopped |
|---|---|---|---|
| 1 | Malformed JSON (a comma left over after deleting a line) | Swagger UI error: "Parameter string value must be valid JSON" | Client side. No request was sent |
| 2 | photoUrls as a string instead of an array | 500, {"code":500,"type":"unknown","message":"something bad happened"} | Server |
| 3 | status "banana" | 200, value accepted and echoed | Server |
| 4 | id "abc" (tried twice) | Swagger UI error: "Value must be an integer" | Client side. No request was sent |
| 6 | Missing name, first retry (name removed from pet, category and tag, trailing commas left) | Swagger UI error: "Parameter string value must be valid JSON" | Client side. No request was sent |
| 7 | Missing name, valid JSON (only the pet-level name removed) | 200, pet created with id 987655 and no name field | Server |
| 5 | Empty body {} | 200, pet created with generated id | Server |

## 5. Findings (bug candidates)

| ID | Finding | Severity idea | Evidence |
|---|---|---|---|
| F1 | Wrong data type (photoUrls as string) causes a 500 server error instead of a 4xx client error | Medium to High | Section 4, row 2 |
| F2 | Enum is not enforced: status "banana" is accepted | Medium | Section 4, row 3 |
| F3 | Required fields are not enforced: an empty body and a body without name both create a pet (confirm in the Schema tab that name is marked required) | Medium | Section 4, rows 5 and 7 |
| F4 | Documentation gap: spec lists 405 for invalid input, which I never got; the 200 returned by POST, PUT and DELETE is undocumented | Low | Sections 1 and 4 |
| F5 | PUT with id 0 silently creates a new pet with a huge generated id and ignores the unknown field "sold" | Low to Medium | Section 2, step 3 |
| F6 | PUT on the id of a deleted pet returned 200 and re-created it (the next DELETE returned 200), so PUT behaves as create-or-update instead of returning 404 | Low | Section 2, steps 6 and 8 |

This is a demo API, so some behaviour may be simplified on purpose. I treat these as practice findings.

## 6. Not done yet or to redo

- [ ] Read the Schema tab and write down the required fields (red asterisk) and the allowed status values
- [x] Missing-name test with valid JSON: 200, pet created without name
- [x] PUT with status "sold" sent to id 987654: 200, response shows status sold
- [ ] Repeat as a clean update test: POST a new pet, PUT status "sold", GET to confirm, then DELETE
- [x] Clean up: DELETE /pet/987654 and /pet/987655 both returned 200
- [ ] Non-numeric id on GET and DELETE, and deleting the same id twice
- [ ] Repeat the id "abc" test in Postman, because Swagger UI blocks it before it reaches the server

## 7. What I learned

- Swagger UI validates some input in the browser (invalid JSON, wrong type for an integer), so those cases never reach the server. To test server-side validation, send the request from Postman or curl.
- The server and the spec can disagree: responses that exist but are "Undocumented", and documented codes that never appear.
- A 5xx caused by bad client input is a defect. The API should answer with a 4xx.
- On a shared public API, use unique ids and clean up the data you create.