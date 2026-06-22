function() {
  var generator = function(i) { 
    return { "id": "0", "name": "BatchNote_" + i, "surname": "Stress", "number": i, "comment": "Batch insert test" }; 
  };
  var list = karate.repeat(1000, generator);
  return { "note_list": list };
}
