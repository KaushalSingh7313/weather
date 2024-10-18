
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// Weather Service
class WeatherService {
  final String apiKey = '2a4ed92a819d38574aa9dbaadd77c8b9'; // Replace with your API key
  final String apiUrl = 'https://api.openweathermap.org/data/2.5/weather'; // Use https

  Future<Map<String, dynamic>> fetchWeather(String city) async {
    final response = await http.get(Uri.parse('$apiUrl?q=$city&appid=$apiKey&units=metric'));

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data: ${response.body}');
    }
  }
}

// Weather Provider
class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _weatherData;
  String _errorMessage = '';

  Map<String, dynamic>? get weatherData => _weatherData;
  String get errorMessage => _errorMessage;

  Future<void> getWeather(String city) async {
    try {
      _weatherData = await _weatherService.fetchWeather(city);
      _errorMessage = '';
    } catch (e) {
      _weatherData = null;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }
}

// Main Application
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => WeatherProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Column(
        children: [
          // Display the image
          Container(
            width: 300,
            height: 400,
            child: Image.asset(
              'assets/images/k.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  onSubmitted: (city) {
                    weatherProvider.getWeather(city);
                  },
                  decoration: InputDecoration(
                    labelText: 'Enter City',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 30),
                weatherProvider.weatherData != null
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'City: ${weatherProvider.weatherData!['name']}',
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      'Temperature: ${weatherProvider.weatherData!['main']['temp']} °C',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Weather: ${weatherProvider.weatherData!['weather'][0]['description']}',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                )
                    : Text(
                  weatherProvider.errorMessage.isEmpty
                      ? 'Enter a city to get weather'
                      : weatherProvider.errorMessage,
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}








