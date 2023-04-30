import 'dart:convert' as convert;
import 'dart:io';
import 'package:sqlite3/sqlite3.dart';
//import 'dart:html';

import 'package:http/http.dart' as http;

void main(List<String> arguments) async{
//getDB();

final db = sqlite3.open("database.db");

createDB(db);

  
  // You can run select statements with PreparedStatement.select, or directly
  // on the database:
  final ResultSet resultSet =
      db.select('SELECT * FROM Names WHERE name LIKE ?', ['O %']);

  // You can iterate on the result set in multiple ways to retrieve Row objects
  // one by one.
  for (final Row row in resultSet) {
    print('Artist[count: ${row['count']}, name: ${row['name']}]');
  }

  // Register a custom function we can invoke from sql:
  db.createFunction(
    functionName: 'dart_version',
    argumentCount: const AllowedArgumentCount(0),
    function: (args) => Platform.version,
  );
  print(db.select('SELECT dart_version()'));

  // Don't forget to dispose the database to avoid memory leaks
  db.dispose();
}

void getDB() async {
 
   final url = Uri.https(
    'api.genderize.io',
    '/',
    {'name': 'Oleg'},    
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonResponse = convert.jsonDecode(response.body);
    final itemCount = jsonResponse["count"];
    final itemGender = jsonResponse["gender"];
    final itemName = jsonResponse['name'];
    final itemPobability = jsonResponse['probability'];
    print('count: $itemCount gender: $itemGender name: $itemName prob: $itemPobability');
  } else {
    print('Код ошибки: ${response.statusCode}.');
  }
}
void createDB(db) {
  print(sqlite3.version);

  // Create a table and insert some data
  db.execute('''
    CREATE TABLE IF NOT EXISTS Names (
      count INTEGER,
      gender TEXT,
      name TEXT Unique,
      probability REAL
    );
  ''');
  // Prepare a statement to run it multiple times:
  //  "count": 58730,
  //   "gender": "male",
  //   "name": "Oleg",
  //   "probability": 1.0
  // final stmt = db.prepare('INSERT INTO Names (count) VALUES (?), (gender) VALUES (?), (name) VALUES (?), (probability) VALUES (?)');
  // stmt
  //   ..execute([58730])
  //   ..execute(['male'])
  //   ..execute(['Oleg'])
  //   ..execute([1.0]);
  final stmt = db.execute("""
      INSERT INTO Names (count, gender, name, probability)
      values
       (58730,'male','Olya',1.1)
      ;""");

}
