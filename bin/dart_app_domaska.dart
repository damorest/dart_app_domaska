import 'dart:convert' as convert;
import 'dart:ffi';
//import 'dart:html';
import 'dart:io';
import 'package:sqlite3/sqlite3.dart';
import 'package:http/http.dart' as http;

class User {
   var count= 55 ;
  var gender  = "man";
  var name = "";
  var probability = 1.00;

  User(String startName){
    this.name = startName;

  }
  toJson(){
    return convert.jsonEncode({"count": "${this.count}", "gender": this.gender, "name": this.name, "probability": "${this.probability}" });
  }

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
   
   var userToSend;
    var exustingUser = checkExist(userName??"");
    if(exustingUser != null){
      userToSend = exustingUser;
      print("user exsist");
    }else{
   
    InsertDB(itemCount,itemGender,itemName,itemPobability);
    getDataInFile(await creatFile("example"),jsonString);
     print(" count: $itemCount\n gender: $itemGender\n name: $itemName\n prob: $itemPobability\n");
     userToSend = new User(itemName);

    }

    print(userToSend.toJson());

    final urlPost = Uri.https(
    'server-1-x67l.onrender.com',    
  );
  Map<String,String> headers = {
    'Content-type' : 'application/json',
    'Accept' : 'application/json',
  };

    var responseToSend = await http.post(urlPost, body:userToSend.toJson(),headers: headers);
    print(responseToSend.body);

    
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

checkExist(String userName,) {
  final db = sqlite3.open("database.db");
  final resultSet =
  db.select('SELECT * FROM Names WHERE name = "$userName"');
  print(resultSet);
  if(resultSet.length > 0)
  {
    String newName = resultSet[0]["name"];
    User user = User(newName);
    
    print("User allready exist");

    return user;
    
  }

  return null;

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

