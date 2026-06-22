@positive
Feature: Positive API test cases

Scenario: Check Service Health
    #Case_0
    Given path '/'
    When method GET
    Then status 200
    And match response == '#notnull'

Scenario: Phonebook creation
    #Case_1
    Given path 'phonebook/create'
    When method GET
    Then status 200
    And match response.phonebook_id != null
    And match response.phonebook_id == '#string'
    * def PhonebookID = response.phonebook_id
    * print 'Created Phonebook ID:', PhonebookID

@NoteCreation
Scenario: Note Creation
    #Case_2

    * def PhonebookID = karate.call("../helpers/setup.feature@CreatePhonebook").PhonebookID

    Given path PhonebookID, 'create'
    And request
    """
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
    """

    When method POST
    Then status 200
    And match response.message == 'success'
    And match response.note_id[0] != null
    * def NoteID = response.note_id[0]
    * print 'Created Note ID:', NoteID

    # Case_2B
    Given path PhonebookID, 'create'
    And request
    """
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
    """
    When method POST
    Then status 200
    And match response.message == 'success'
    And match response.note_id[0] != null
    * def NoteID_2 = response.note_id[0]
    * print 'Created Second Note ID:', NoteID_2

Scenario: Update Note 
    # Case_3: Note update test

    * def setup = karate.call("../helpers/setup.feature@CreatePhonebookAndNote")
    * def PhonebookID = setup.PhonebookID
    * def NoteID = setup.NoteID

    Given path PhonebookID, 'update', NoteID
    And request
    """
    {
      "name": "NewNote",
      "surname": "NewTest",
      "number": 1,
      "comment": "New Positive Test Note"
    }
    """
    When method POST
    Then status 200
    And match response.message == 'success'
    And match response.note_id == NoteID

Scenario: Notes Listing
    # Case_4: Notes Listing test

    * def setup = karate.call("positive.feature@NoteCreation")
    * def PhonebookID = setup.PhonebookID
    * def NoteID = setup.NoteID
    * def NoteID_2 = setup.NoteID_2

    Given path PhonebookID, 'list'
    When method GET
    Then status 200
    * karate.set('expectedIds', [ NoteID, NoteID_2 ])
    And match response[*].id contains expectedIds
    And match response[1].number == 1

Scenario: Search Note test
    # Case_5: Search Note test

    * def setup = karate.call("positive.feature@NoteCreation")
    * def PhonebookID = setup.PhonebookID

    Given path PhonebookID, 'search'
    And request { "pattern": "Note" }
    When method POST
    Then status 200
    And match each response.notes[*].name contains 'Note'

Scenario: Note deletion
    # Case_6: Note deletion test

    * def setup = karate.call("positive.feature@NoteCreation")
    * def PhonebookID = setup.PhonebookID
    * def NoteID = setup.NoteID

    Given path PhonebookID, 'delete', NoteID
    When method DELETE
    Then status 200

Scenario: Phonebook deletion
    # Case_7: Phonebook deletion test

    * def setup = karate.call("positive.feature@NoteCreation")
    * def PhonebookID = setup.PhonebookID

    Given path 'phonebook/delete', PhonebookID
    When method DELETE
    Then status 200
    And match response.message == 'success'
    And match response.phonebook_id == PhonebookID
    * def PhonebookID = null