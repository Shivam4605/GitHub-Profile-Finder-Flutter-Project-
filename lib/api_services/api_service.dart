import 'dart:convert';
import 'dart:developer';
import 'package:github_repo/models/profile_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  Future<ProfileModel> getUser({required String userName}) async {
    Uri url = Uri.parse("https://api.github.com/users/$userName");

    http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      
      log("API Response: $body");

      return ProfileModel.fromJson(body);
    } else {
      throw Exception("User not found");
    }
  }
}
