import 'dart:convert';
import 'package:http/http.dart' as http;

// This class is used to make Http requests to the dictionary API and parse the results.
// For our specific usage for this app, when a user enters a word and uses the search feature,
// it'll fetch the definitions for that word and allow the users to pick any of the given definition
// and display them in the UI. (Note: This does not need an API key)
class DictionaryAPI {
  // The base URL for the dictionary API. We will append the word to this URL to fetch its definitions.
  static const _base = 'https://api.dictionaryapi.dev/api/v2/entries/en/';


  // This method takes a word as an input and returns a list of definitions for that word.
  // Parameters:
  // - word: The word for which we want to fetch the definitions.
  // Returns: A Future that resolves to a list of definitions (strings) for the given word.
  static Future<List<String>> fetchDefinitions(String word) async {
    // This checks if the input word is empty or otherwise left blank.
    // Returns an empty list of definitions. If it is not empty, then it will make a request to the API.
    if (word.trim().isEmpty) return [];
    // This makes a request to the dictionary API and parses the response to extract the definitions.
    try {
      final formattedURI = Uri.parse('$_base${Uri.encodeComponent(word.trim())}');
      // We set a timeout of 10 seconds for the API request to prevent hanging if the API is unresponsive.
      final responseFromAPI = await http.get(formattedURI).timeout(const Duration(seconds: 10));
      if (responseFromAPI.statusCode != 200) return [];
      final responseBody = jsonDecode(responseFromAPI.body) as List;
      final defs = <String>[];

      // AI_Prompt(Perplexity): I am trying to use this dictionary API to grab and make a list of definitions to choose from given a word. How would I implement it
      // AI_RESPONSE(Perplexity): Suggested the nested for loop shown below.
      // REFLECTION: Ben - As someone who is familiar with API calls, I was just confused on how to use the data I got from the API and gather it into a list of definitions.
      // As from my understanding of the code generated, we are going through each dictionary entry or word that was inputted by the user, then we gets the word meaning, and then pull
      // all the definitions for that word and only return up to five of the definitions purely to maintain UI complexity.
      // This nested loop is used to build the list of definitions from the API response.
      for (final entry in responseBody) {
        for (final meaning in (entry['meanings'] as List? ?? [])) {
          for (final d in (meaning['definitions'] as List? ?? []).take(2)) {
            final def = d['definition'] as String?;
            if (def != null && def.isNotEmpty) defs.add(def);
          }
        }
      }
      // Returns the list of definitions, but only takes up to the first 5 definitions.
      return defs.take(5).toList();
    } catch (_) {
      // This is used to catch any exceptions that may occur during the API request, such as network errors or JSON parsing errors.
      return [];
    }
  }
}