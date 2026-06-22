@ignore
Feature: Setup helper for PhoneBook API

Background:
    * url 'http://193.169.128.81:8000'
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json' }

@CreatePhonebook
Scenario: CreatePhonebook
    Given path 'phonebook/create'
    When method GET
    Then status 200
    * def PhonebookID = response.phonebook_id

@CreatePhonebookAndNote
Scenario: CreatePhonebookAndNote
    Given path 'phonebook/create'
    When method GET
    Then status 200
    * def PhonebookID = response.phonebook_id


    Given path PhonebookID, 'create'
    And request
    """
    {
      "note_list": [
        {
          "id": "0",
          "name": "SetupNote",
          "surname": "Setup",
          "number": 0,
          "comment": "Setup comment"
        }
      ]
    }
    """
    When method POST
    Then status 200
    * def NoteID = response.note_id[0]

@DeletePhonebook
Scenario: DeletePhonebook
    * def pbId = karate.get('PhonebookID')
    Given path 'phonebook/delete', pbId
    When method DELETE
    Then status 200
