# PhoneBook API test plan

## Background
| Parameter | Value |
| :--- | :--- |
| **Base URL** | `http://193.169.128.81:8000` |
| **Headers** | `content-type: application/json`<br>`accept: application/json` |
| **Testing Tool** | Karate Labs Framework |

## Positive cases

### Case_0: Check service health
* Method: GET
* Query: GET BaseURL/
* Expected: Status 200 + plain text/string body
* Not expected: Status 500 OR timeout

### Case_1: Phonebook creation test
* Method: GET
* Query: GET BaseURL/phonebook/create
* Expected: Status 200 + JSON body with valid id
* Assertions: match response.phonebook_id != null AND response.phonebook_id == '#string'
* Not expected: Status 500 OR empty id
* PostActions: Save response.phonebook_id as ${PhonebookID}

### Case_2: Note creation test
* Context: Case_1 passed AND ${PhonebookID}
* Method: POST
* Query: POST BaseURL/${PhonebookID}/create
* Payload:
```JSON
{
  "note_list": [
    {
      "id": "0",
      "name": "Note",
      "surname": "Test",
      "number": 0,
      "comment": "Some Positive Test Note"
    }
  ]
}
```
* Expected: Status 200 + JSON body
* Assertions: match response.message == 'success' AND response.note_id[0] != null
* Not expected: Status 500 OR wrong data
* PostAction: Save response.note_id[0] as ${NoteID}

### Case_2B: Second Note creation test
* Context: Case_1 AND Case_2 passed
* Method: POST
* Query: POST BaseURL/${PhonebookID}/create
* Payload:
```JSON
{
  "note_list": [
    {
      "id": "0",
      "name": "Second Test Note",
      "surname": "Test",
      "number": 1,
      "comment": "Second Positive Note with same surname"
    }
  ]
}
```
* Expected: Status 200 + JSON body
* Assertions: match response.message == 'success' AND response.note_id[0] != null
* Not expected: Status 500
* PostAction: Save response.note_id[0] as ${NoteID_2}

### Case_3: Note update test
* Context: Case_1 AND Case_2 are passed AND ${PhonebookID}, ${NoteID} are gathered
* Method: POST
* Query: POST BaseURL/${PhonebookID}/update/${NoteID}
* Payload:
```JSON
{
    "name":"NewNote",
    "surname":"NewTest",
    "number": 1,
    "comment": "New Positive Test Note"
}
```
* Expected: Status 200 + JSON body
* Assertions: match response.message == 'success' AND response.note_id == '${NoteID}'
* Not expected: Status 500 OR old data returned

### Case_4: Notes Listing test
* Context: [Case_1,Case_2,Case_2B] passed
* Method: GET
* Query: GET BaseURL/${PhonebookID}/list
* Expected: Status 200 + JSON array with 2 objects
* Assertions: match response[*].id contains ['${NoteID}', '${NoteID_2}'] AND response[1].number == 1
* Not expected: Status 500 OR Empty array OR missing notes

### Case_5: Search Note test
* Context: [Case_1,Case_2,Case_2B] passed
* Method: POST
* Query: POST BaseURL/${PhonebookID}/search
* Payload:
```JSON
{
  "pattern": "Note"
}
```
* Expected: Status 200 + JSON body containing a list of notes
* Assertions: match response.notes[*].name contains "Note"
* Not expected: Status 500 OR empty array

### Case_6: Note deletion test
* Context: Case_1 AND Case_2 passed
* Method: DELETE
* Query: DELETE BaseURL/${PhonebookID}/delete/${NoteID}
* Expected: Status 200
* Not expected: Status 500

### Case_7: Phonebook deletion test
* Context: Case_1 passed
* Method: DELETE
* Query: DELETE BaseURL/phonebook/delete/${PhonebookID}
* Expected: Status 200 + JSON body
* Assertions: match response.message == 'success' AND response.phonebook_id == '${PhonebookID}'
* Not expected: Status 500

## Negative cases

### Case_N1: Delete Phonebook that doesnt exist
* Method: DELETE
* Query: DELETE BaseURL/phonebook/delete/99999999-9999-9999-9999-999999999999
* Expected: Status 404 Not Found
* Not expected: Status 500

### Case_N2: Create Note with incorrect data
* Description: inserting string in a 'number' field (which type is integer (by schema))
* Context: Case_1 passed AND ${PhonebookID} 
* Method: POST
* Query: POST BaseURL/${PhonebookID}/create
* Payload:
```JSON
{
  "note_list": [
    {
      "id": "0",
      "name": "Test",
      "surname": "Test",
      "number": "Validation Test - string input in integer field",
      "comment": "Data type test"
    }
  ]
}
```
* Expected: Status 422 Validation Err
* Not expected: Status 200 OR Status 500

### Case_N3: Create Note without required fields
* Description: NoteList requires array "note_list" to be created. That test checks if empty payload will be accepted OR not
* Context: Case_1 passed AND ${PhonebookID}
* Method: POST
* Query: POST BaseURL/${PhonebookID}/create
* Payload:
```JSON
{}
```
* Expected: Status 422 Validation ERR
* Not expected: Status 200

### Case_N4: Update Note in Phonebook that doesent exist
* Context: Case_2 passed AND ${NoteID}
* Method: POST
* Query: POST BaseURL/FAKE-PHONEBOOK-ID-12345/update/${NoteID}
* Payload:
```JSON
{
  "name": "New"
}
```
* Expected: Status 404 Not Found
* Not expected: Status 500

### Case_N5: Delete Note that doesnt exist
* Context: Case_1 passed AND ${PhonebookID}
* Method: DELETE
* Query: DELETE BaseURL/${PhonebookID}/delete/FAKE-NOTE-ID-12345
* Expected: Status 404 Not Found
* Not expected: Status 500

### Case_N6: Broken JSON payload
* Context: Case_1 passed AND ${PhonebookID}
* Method: POST
* Query: POST BaseURL/${PhonebookID}/create
* Payload:
```JSON 
{ 
"note_list": [{ 
"name": "broken"
```
* Expected: Status 400 Bad Request OR Status 422
* Not expected: Status 200 OR Status 500

## Security Tests

### Case_S1: SQL Injection (SQLi) in search
* Description: Checks input sanitization in backend logic
* Context: Case_1 passed AND ${PhonebookID}
* Method: POST
* Query: POST BaseURL/${PhonebookID}/search
* Payload:
```JSON
{
    "pattern": "' OR '1'='1"
}
```
* Expected: Status 200
* Assertions: match response.detail == 'Note not found'
* Not expected: Status 500 OR full DB data array

### Case_S2: XSS protection test
* Description: Test will insert JS code in text fields
* Context: Case_1 passed AND ${PhonebookID}
* Method: POST
* Query: POST BaseURL/${PhonebookID}/create
* Payload:
```JSON
{
  "note_list": [
    {
      "id": "0",
      "name": "<script>alert('Hacked')</script>",
      "surname": "XSS-Test",
      "number": 0,
      "comment": "<img src=x onerror=alert(1)>"
    }
  ]
}
```
* Expected: Status 200 AND data saved as escaped text
* Not expected: XSS script successful execution OR Status 500

## Stress Tests (Boundary)

### Case_B1: Buffer overflow
* Context: Case_1 passed AND ${PhonebookID}
* Method: POST
* Query: POST BaseURL/${PhonebookID}/create
* Payload:
```JSON
{
  "note_list": [
    {
      "id": "0",
      "name": "StressTest",
      "surname": "Boundary",
      "number": 0,
      "comment": "A" * 100000
    }
  ]
}
```
* Expected: Status 200 OR Status 400 Bad Request
* Not Expected: Status 500

### Case_B2: Mass Array Creation (1000 notes batch creation)
* Context: Case_1 passed AND ${PhonebookID}
* Method: POST
* Query: POST BaseURL/${PhonebookID}/create
* Payload:
```JSON
{
  "note_list": [
    {
      "id": "0",
      "name": "BatchNote_${i}",
      "surname": "Stress",
      "number": ${i},
      "comment": "Batch insert test"
    }
    // AND 1000 more note_lists like this
  ]
}
```
* Expected: Status 200 OR Status 413 (Too large)
* Not expected: Status 500

### Case_B3: Float data type insertion
* Context: Case_1 passed AND ${PhonebookID}
* Method: POST
* Query: POST BaseURL/${PhonebookID}/create
* Payload:
```JSON
{
  "note_list": [
    {
      "id": "0",
      "name": "FloatTest",
      "surname": "Mutation",
      "number": 88.88,
      "comment": "Testing float insertion into integer field"
    }
  ]
}
```
* Expected: Status 200 OR Status 422 (ValidationERR)
* Not Expected: Status 500 OR float saved as a string

### Case_B4: Unicode and Emoji Insertion
* Context: Case_1 passed AND ${PhonebookID}
* Method: POST
* Query: POST BaseURL/${PhonebookID}/create
* Payload:
```JSON
{
  "note_list": [
    {
      "id": "0",
      "name": "龙트시 ∑∫∏√∞≠≡≤≥",
      "surname": "Chao𠜎 ʇsǝʇ uʍop ǝpısdn",
      "number": 12345,
      "comment": "Test 🧑‍💻 הפעלה النظام: 🚀🔥 中文本"
    }
  ]
}
```
* Expected: Status 200 AND data saved correctly
* Not expected: Status 500 OR data corruption

### Case_B5: Integer Boundary
* Description: Test checks if a negative number is acceptable
* Context: Case_1 passed AND ${PhonebookID}
* Method: POST
* Query: POST BaseURL/${PhonebookID}/create
* Payload:
```JSON
{
  "note_list": [
    {
      "id": "0",
      "name": "IntTest",
      "surname": "Negative",
      "number": -999999,
      "comment": "Negative num"
    }
  ]
}
```
* Expected: Status 200 OK OR Status 422 Validation Error
* Not Expected: Status 500
### Case_B5B: Integer Boundary (MaxInt)
* Context: Case_1 passed AND ${PhonebookID}
* Method: POST
* Query: POST BaseURL/${PhonebookID}/create
* Payload:
```JSON
{
  "note_list": [
    {
      "id": "0",
      "name": "IntTest",
      "surname": "Limit",
      "number": 9223372036854775808,
      "comment": "MaxInt64 Test"
    }
  ]
}
```
* Expected: Status 200 OK OR Status 422 Validation Error
* Not Expected: Status 500

### Case_B6: Empty strings in required fields
* Context: Case_1 passed AND ${PhonebookID}
* Method: POST
* Query: POST BaseURL/${PhonebookID}/create
* Payload:
```json
{
"note_list": [{
"id": "0",
     "name": "",
     "surname": "",
     "number": 123,
     "comment": "Empty strings"
}]
}
```
* Expected: Status 422 Validation Error OR Status 200
* Not Expected: Status 500

### Case_B7: Idempotency DELETE check
* Context: Case_1 called here AND Case_1 passed
* Method: DELETE
* Query: DELETE BaseURL/phonebook/delete/${PhonebookID} _**(call twice)**_
* Expected: First call Status 200, second call Status 404 OR Status 200
* Not expected: Status 500 on second call

## TODO
- [ ] Get this plan approved
- [ ] Read the Karate Documentation
- [ ] Implement this tests with Karate Framework
- [ ] Run implemented tests
- [ ] Review the results
