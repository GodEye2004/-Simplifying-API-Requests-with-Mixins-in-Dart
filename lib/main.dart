import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'dart:convert';

extension Log on Object {
  void log() => devtools.log(toString());
}

// A simple in-memory cache to store GET responses
class ApiCache {
  static final Map<String, String> _cache = {};

  static String? get(String url) => _cache[url];

  static void set(String url, String response) => _cache[url] = response;

  static void clear() =>
      _cache.clear(); // Optionally, add a method to clear the cache
}

// Mixin for making API calls
mixin CanMakeApiCall {
  String get url;

  @useResult
  Future<String> getString({bool forceRefresh = false}) async {
    try {
      // Check cache first, unless forceRefresh is true
      if (!forceRefresh) {
        final cachedResponse = ApiCache.get(url);
        if (cachedResponse != null) {
          "Cache hit for $url".log();
          return cachedResponse;
        }
      }

      // Make the GET request
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        ApiCache.set(url, response.body); // Cache the response
        return response.body;
      } else {
        return 'Failed to load data: ${response.statusCode}';
      }
    } catch (e) {
      "Error: $e".log(); // Log the error
      return 'Failed to get data due to an error.';
    }
  }
}

// Create a class for consuming the API
@immutable
class GetPeaple with CanMakeApiCall {
  const GetPeaple();

  @override
  String get url =>
      'http://127.0.0.1:5500/apis/peaple.json'; // Replace this with your actual API URL
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _data = "Loading..."; // Placeholder for the fetched data
  bool _isLoading = true; // Flag for loading state
  bool _hasError = false; // Flag for error state

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Function to fetch data and update the UI
  Future<void> _fetchData() async {
    try {
      final response = await const GetPeaple().getString();
      setState(() {
        _data = response;
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _data = "Error fetching data.";
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "API with Caching and Error Handling",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator() // Show loading indicator while fetching data
            : _hasError
                ? Text(
                    _data,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ) // Show error message if fetching fails
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _data, // Display the fetched data
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      title: "API Data Display",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    ),
  );
}
