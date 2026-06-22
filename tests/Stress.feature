@stress @boundary
Feature: Stress and Boundary API test cases

Scenario Outline: <caseID> : <description>
    * def setup = karate.call('../helpers/setup.feature@CreatePhonebook')
    * def PhonebookID = setup.PhonebookID
    * def getPayload = 
    """
    function(id) {
      if (id === 'Case_B1') {
        return karate.read('../helpers/js_funcs/boundaryChar.js')();
      }
      if (id === 'Case_B2') {
       return karate.read('../helpers/js_funcs/stressBatch.js')();
      }
      return {};
    }
    """
    * def payload = getPayload(caseID)

    Given path PhonebookID, 'create'
    And request payload
    When method POST
    Then assert responseStatus == expected_1 || responseStatus == expected_2

    Examples:
      | caseID  | description                            | expected_1 | expected_2 |  
      | Case_B1 | Buffer overflow (100k chars)           | 200        | 400        |  
      | Case_B2 | Mass Array Creation (1000 notes batch) | 200        | 413        |  


Scenario Outline: <caseID> : <description>
    * def setup = karate.call('../helpers/setup.feature@CreatePhonebook')
    * def PhonebookID = setup.PhonebookID

    Given path PhonebookID, 'create'
    And request read(payloadFile)
    When method POST
    Then assert responseStatus == expected_1 || responseStatus == expected_2

    Given path PhonebookID, 'list'
    When method GET
    Then status 200


    Examples:
      | caseID   | description                      | expected_1 | expected_2 | payloadFile                          |  
      | Case_B3  | Float data type insertion        | 200        | 422        | ../helpers/payloads/float_mutation.json |  
      | Case_B4  | Unicode and Emoji Insertion      | 200        | 200        | ../helpers/payloads/unicode_emoji.json  |  
      | Case_B5  | Integer Boundary (Negative num)  | 200        | 422        | ../helpers/payloads/negative_int.json   |  
      | Case_B5B | Integer Boundary (MaxInt64)      | 200        | 422        | ../helpers/payloads/max_int64.json      |  
      | Case_B6  | Empty strings in required fields | 422        | 200        | ../helpers/payloads/empty_strings.json  |  

  Scenario: Case_B7 : Idempotency DELETE check
    * def setup = karate.call('../helpers/setup.feature@CreatePhonebook')
    * def PhonebookID = setup.PhonebookID

    Given path 'phonebook/delete', PhonebookID
    When method DELETE
    Then status 200
    Given path 'phonebook/delete', PhonebookID
    When method DELETE
    Then assert responseStatus == 200 || responseStatus == 404

    * def PhonebookID = null