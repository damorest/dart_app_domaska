import 'dart:convert' as convert;
import 'dart:html';

import 'package:http/http.dart' as http;

void main(List<String> arguments) async {
 
   final url = Uri.https(
    'api.genderize.io',
    '/',
    {'name': 'Oleg'},    
  );


  // Await the HTTP GET response, then decode the
  // JSON data it contains.
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
