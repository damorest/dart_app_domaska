import 'dart:convert' as convert;
//import 'dart:html';
import 'dart:io';
import 'package:sqlite3/sqlite3.dart';
import 'package:http/http.dart' as http;

class User {
  var count ;
  var gender;
  var name;
  var probability;

  void display() {
    print("$count $gender $name $probability");
  }
}
void main(List<String> arguments) async{

var user = User();
 getDB();
//  var txt = await creatFile("example");
//  print(txt);
//user.display();
//  creatFile("example");
 

final db = sqlite3.open("database.db");

//createDB(db, user.count, user.gender, user.name,user.probability);


  
  // You can run select statements with PreparedStatement.select, or directly
  // on the database:
  // final ResultSet resultSet =
  //     db.select('SELECT * FROM Names WHERE name LIKE ?', ['O %']);

  // You can iterate on the result set in multiple ways to retrieve Row objects
  // one by one.
  // for (final Row row in resultSet) {
  //   print('Artist[count: ${row['count']}, name: ${row['name']}]');
  // }

  // Register a custom function we can invoke from sql:
  // db.createFunction(
  //   functionName: 'dart_version',
  //   argumentCount: const AllowedArgumentCount(0),
  //   function: (args) => Platform.version,
  // );
  // print(db.select('SELECT dart_version()'));

  // // Don't forget to dispose the database to avoid memory leaks
  db.dispose();
}

 void getDB() async {
 print("Enter name new user");
 var userName = stdin.readLineSync();
   final url = Uri.https(
    'api.genderize.io',
    '/',
    {'name':'$userName'},
  );

  final response = await http.get(url);
  
  if (response.statusCode == 200) {    
    final jsonResponse = convert.jsonDecode(response.body);
    final itemCount = jsonResponse["count"];
    final itemGender = jsonResponse["gender"];
    final itemName = jsonResponse['name'];
    final itemPobability = jsonResponse['probability'];
    var jsonString = " \n count: $itemCount\n gender: $itemGender\n name: $itemName\n prob: $itemPobability\n";
   
    getDataInFile(await creatFile("example"),jsonString);
   
    print(" count: $itemCount\n gender: $itemGender\n name: $itemName\n prob: $itemPobability\n");
  } else {
    print('Код ошибки: ${response.statusCode}.');
  }  
}

void createDB(db, count, gender, name, probability) {
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
       ('$count','$gender','$name','$probability')
      ;""");
}
creatFile(String name) async{
  
  File file = File("$name.txt");
  //print(await File("hello.txt").exists());
  //print( await File("$name.txt").exists());

  // ignore: unrelated_type_equality_checks
   if(await File("$name.txt").exists() != true) {
   file.create();
    print("File $name.txt has been created");
  }else { print("File $name.txt already exists");}
  return file;
}

void getDataInFile(File file, String text) async{
await file.writeAsString(text, mode: FileMode.append);
}

