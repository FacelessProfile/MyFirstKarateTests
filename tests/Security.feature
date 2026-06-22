@security
Feature: Security API test cases

Scenario: Case_S1: SQL Injection (SQLi) in search
    * def setup = karate.call('../helpers/setup.feature@CreatePhonebook')
    * def PhonebookID = setup.PhonebookID

    Given path PhonebookID, 'search'
    And request {"pattern": "' OR '1'='1"}
    When method POST
    Then assert responseStatus == 200 || responseStatus == 404
    And match response.detail == 'Note not found'

Scenario: Case_S2: XSS protection test
    * def setup = karate.call('../helpers/setup.feature@CreatePhonebook')
    * def PhonebookID = setup.PhonebookID

    Given path PhonebookID, 'create'
    And request 
    """
    {
      "note_list": [{
        "id": "0",
        "name": "<script>alert('Hacked')</script>",
        "surname": "XSS-Test",
        "number": 0,
        "comment": "<img src=x onerror=alert(1)>"
      }]
    }
    """
    When method POST
    Then status 200
    * def NoteID = response.note_id[0]

    Given path PhonebookID, 'search'
    And request {"pattern": "<script>alert('Hacked')</script>"}
    When method POST
    Then status 200
    And match response.notes[0].id == NoteID