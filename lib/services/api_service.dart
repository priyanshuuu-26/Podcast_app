import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:webfeed_plus/webfeed_plus.dart';

import '../models/category_model.dart';
import '../models/model.dart';

class ApiService {
  final String _apiKey = "7UYUNBNSP7MKGNVTDUZV";
  final String _apiSecret = "XuHYJS^QkW3b25XVhBu\$JC3Q3S4f7CwVH278eXqm";

  final String _baseUrl = "https://api.podcastindex.org/api/1.0";
  final String _userAgent = "MyPodcastApp/1.0";

  /// This private helper method handles all the repetitive logic for making an API call.
  Future<List<dynamic>> _fetchAndParse(String endpoint) async {
    // 1. Check for an internet connection.
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      throw Exception('No Internet Connection');
    }

    // 2. Generate the required authentication headers.
    final authHeaders = _generateAuthHeaders();
    final response = await http.get(Uri.parse(endpoint), headers: authHeaders);

    // 3. Check the response status and parse the JSON.
    if (response.statusCode == 200) {
      final decodedJson = jsonDecode(response.body);
      // The 'feeds' key is used for podcasts, categories, etc. in this API.
      return decodedJson['feeds'];
    } else {
      throw Exception('Failed to load data from $endpoint. Error: ${response.statusCode}');
    }
  }

  /// Generates the secure authentication headers required by the Podcast Index API.
  Map<String, String> _generateAuthHeaders() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final apiHeaderTime = now.toString();
    final dataToHash = _apiKey + _apiSecret + apiHeaderTime;
    final hash = sha1.convert(utf8.encode(dataToHash));
    final authorization = hash.toString();
    return {
      "User-Agent": _userAgent,
      "X-Auth-Date": apiHeaderTime,
      "X-Auth-Key": _apiKey,
      "Authorization": authorization,
    };
  }


  /// Fetches a list of trending podcasts.
  Future<List<Podcast>> getTrendingPodcasts() async {
    final List<dynamic> body = await _fetchAndParse('$_baseUrl/podcasts/trending');
    return body.map((dynamic item) => Podcast.fromJson(item)).toList();
  }

  /// Searches for podcasts by a given term.
  Future<List<Podcast>> searchPodcasts(String term) async {
    final endpoint = '$_baseUrl/search/byterm?q=${Uri.encodeComponent(term)}';
    final List<dynamic> body = await _fetchAndParse(endpoint);
    return body.map((dynamic item) => Podcast.fromJson(item)).toList();
  }

  /// Fetches the list of all available categories.
  Future<List<Category>> getCategories() async {
    final List<dynamic> body = await _fetchAndParse('$_baseUrl/categories/list');
    return body.map((dynamic item) => Category.fromJson(item)).toList();
  }
  

  /// Fetches an RSS feed and extracts the direct audio URL from the first item.
  Future<String?> getAudioUrlFromRss(String rssUrl) async {
    try {
      final response = await http.get(Uri.parse(rssUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to load RSS feed');
      }
      final feed = RssFeed.parse(response.body);
      return feed.items?.first.enclosure?.url;
    } catch (e) {
      print('Error parsing RSS feed: $e');
      return null;
    }
  }
}