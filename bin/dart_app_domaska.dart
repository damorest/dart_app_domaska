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

createBase();
 getDB();


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
   
   if(!checkExist(userName??""))
   {
    InsertDB(itemCount,itemGender,itemName,itemPobability);
    getDataInFile(await creatFile("example"),jsonString);
     print(" count: $itemCount\n gender: $itemGender\n name: $itemName\n prob: $itemPobability\n");

   }     
    
  } else {
    print('Код ошибки: ${response.statusCode}.');
  }  
}

void InsertDB(count, gender, name, probability) {
  final db = sqlite3.open("database.db");
  // //print(sqlite3.version);
  // // Create a table and insert some data
  // db.execute('''
  //   CREATE TABLE IF NOT EXISTS Names (
  //     count INTEGER,
  //     gender TEXT,
  //     name TEXT UNIQUE ON CONFLICT IGNORE,
  //     probability REAL
  //   );
  // ''');
  
  final stmt = db.execute("""
      INSERT INTO Names (count, gender, name, probability)
      values
       ('$count','$gender','$name','$probability')
      ;"""); 
    
      db.dispose();
}

creatFile(String name) async{
  
  File file = File("$name.txt");
  
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

bool checkExist(String userName,) {
final db = sqlite3.open("database.db");
final resultSet =
db.select('SELECT * FROM Names WHERE name = "$userName"');
print(resultSet);
if(resultSet.length > 0)
{
  print("User allready exist");
  return true;
  
}else {
  return false;
}
}
void createBase() {
  final db = sqlite3.open("database.db");
  //print(sqlite3.version);
  // Create a table and insert some data
  db.execute('''
    CREATE TABLE IF NOT EXISTS Names (
      count INTEGER,
      gender TEXT,
      name TEXT UNIQUE ON CONFLICT IGNORE,
      probability REAL
    );
  ''');
}

