import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'constants.dart';
import 'breach.dart';
import 'paste.dart';

final String apiRoot = "https://haveibeenpwned.com/api/v2/";
final String breachedAccount = apiRoot + "breachedaccount/";
final String pastedAccount = apiRoot + "pasteaccount/";
final String includeUnverified = "?includeUnverified=true";
final String logoBase = "https://haveibeenpwned.com/Content/Images/PwnedLogos/";

Future<List<Breach>> getBreaches(account) async {
  final response =
  await http.get(
    breachedAccount + account + includeUnverified,
    headers: {
      HttpHeaders.userAgentHeader : appTitle
    }
  );

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    List<dynamic> responseJson = json.decode(response.body);
    return responseJson.map((i) => Breach.fromJson(i)).toList();
  } else if (response.statusCode == 404){
    // If no result found, return empty list.s
    return List();
  } else {
    // If that response was not OK, throw an error.
    throw Exception("Failed to load breach list.");
  }
}

Future<List<Paste>> getPastes(account) async {
  print(pastedAccount + account);
  final response =
  await http.get(
      pastedAccount + account,
      headers: {
        HttpHeaders.userAgentHeader : appTitle
      }
  );

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    List<dynamic> responseJson = json.decode(response.body);
    return responseJson.map((i) => Paste.fromJson(i)).toList();
  } else if (response.statusCode == 404 || response.statusCode == 400){
    // 404 If no result found, return empty list.s
    // 404 not valid email address
    return List();
  } else {
    // If that response was not OK, throw an error.
    throw Exception("Failed to paste list.");
  }
}