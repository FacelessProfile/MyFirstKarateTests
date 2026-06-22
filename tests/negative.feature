@negative
Feature: Negative API test cases

Scenario: Delete Phonebook that doensent exist
    # Case_N1: Delete Phonebook that doesent exist
    Given path 'phonebook/delete/99999999-9999-9999-9999-999999999999'
    When method DELETE
    Then status 404

Scenario: Unexisted note and phonebook
    # Case_N4: Update Note in Phonebook that doesent exist
    * def setup = karate.call('../helpers/setup.feature@CreatePhonebookAndNote')
    * def PhonebookID = setup.PhonebookID
    * def NoteID = setup.NoteID

    Given path 'FAKE-PHONEBOOK-ID-12345', 'update', NoteID
    And request {"name": "New"}

    When method POST
    Then status 404

    # Case_N5: Delete Note that doesnt exist
    Given path PhonebookID, 'delete', 'FAKE-NOTE-ID-12345'
    When method DELETE
    Then status 404

Scenario Outline: <caseID> : <description>
    # Case_N2-N3,N6
    * def PhonebookID = karate.call('../helpers/setup.feature@CreatePhonebook').PhonebookID

    Given path PhonebookID, 'create'
    And request karate.readAsString(payloadFile)
    
    When method POST
    Then status <expected>

    Examples:
      | caseID  | description                         | expected | payloadFile                              |  
      | Case_N2 | Create Note with incorrect data     | 422      | ../helpers/payloads/str_inNumber_field.json |  
      | Case_N3 | Create Note without required fields | 422      | ../helpers/payloads/empty.json              |  
      | Case_N6 | Create Note with broken payload     | 422      | ../helpers/payloads/broken_pb.json          |  
