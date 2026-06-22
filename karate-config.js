function fn() {
  var env = karate.env; 
  karate.log('karate.env system property was:', env);
  karate.configure('headers',
 {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  }
);
  var config = {};
  karate.configure('url', 'http://193.169.128.81:8000');
  karate.configure('afterScenario', function() {
    var pbId = karate.get('PhonebookID');
    if (pbId) {
      karate.log('Cleanup: Deleting phonebook:', pbId);
      karate.call('../helpers/setup.feature@DeletePhonebook', { PhonebookID: pbId });
    }
  });

  return config;
}
