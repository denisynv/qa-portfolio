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

Note: step 3 did not test what I intended (updating the status of my pet). With id 0 the server created a new record instead. See section 6.

## 3. Test ideas (5 per endpoint)

### POST /pet

| # | Test idea | Input | Expected | Actual | Status |
|---|---|---|---|---|---|
| 1 | Valid pet is created | All fields valid | 200, body echoes data | 200, body identical to request | Pass |
| 2 | Required field missing | Valid JSON without name | 4xx (spec lists 405) | Not run | Not executed |
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
| 4 | id "abc" | Swagger UI error: "Value must be an integer" | Client side. No request was sent |
| 5 | Empty body {} | 200, pet created with generated id | Server |

## 5. Findings (bug candidates)

| ID | Finding | Severity idea | Evidence |
|---|---|---|---|
| F1 | Wrong data type (photoUrls as string) causes a 500 server error instead of a 4xx client error | Medium to High | Section 4, row 2 |
| F2 | Enum is not enforced: status "banana" is accepted | Medium | Section 4, row 3 |
| F3 | Required fields are not enforced: an empty body creates a pet (verify which fields the Schema tab marks as required) | Medium | Section 4, row 5 |
| F4 | Documentation gap: spec lists 405 for invalid input, which I never got; the 200 returned by POST, PUT and DELETE is undocumented | Low | Sections 1 and 4 |
| F5 | PUT with id 0 silently creates a new pet with a huge generated id and ignores the unknown field "sold" | Low to Medium | Section 2, step 3 |

This is a demo API, so some behaviour may be simplified on purpose. I treat these as practice findings.

## 6. Not done yet or to redo

- [ ] Read the Schema tab and write down the required fields (red asterisk) and the allowed status values
- [ ] Missing-name test with valid JSON (remove the whole "name" line including its comma)
- [ ] PUT that really updates the status of an existing pet: create it, PUT with the same id and status "sold", GET to confirm, then DELETE
- [ ] Non-numeric id on GET and DELETE, and deleting the same id twice
- [ ] Repeat the id "abc" test in Postman, because Swagger UI blocks it before it reaches the server

## 7. What I learned

- Swagger UI validates some input in the browser (invalid JSON, wrong type for an integer), so those cases never reach the server. To test server-side validation, send the request from Postman or curl.
- The server and the spec can disagree: responses that exist but are "Undocumented", and documented codes that never appear.
- A 5xx caused by bad client input is a defect. The API should answer with a 4xx.
- On a shared public API, use unique ids and clean up the data you create.