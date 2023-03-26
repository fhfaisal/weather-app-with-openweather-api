import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Position? position;
  Map<String, dynamic> weatherMap = {};
  Map<String, dynamic> forecastMap = {};
  dynamic newTime;

  @override
  void initState() {
    super.initState();
    determinePosition().then((_) => getWeatherData());
  }

  determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    position = await Geolocator.getCurrentPosition();
  }
  getWeatherData() async {
    try {
      var weather = await http.get(Uri.parse(
          "https://api.openweathermap.org/data/2.5/weather?lat=${position?.latitude}&lon=${position?.longitude}&appid=dd293968f6bc0aa3bc16e50cf9069458"));
      var forecast = await http.get(Uri.parse(
          "https://api.openweathermap.org/data/2.5/forecast?lat=${position?.latitude}&lon=${position?.longitude}&appid=dd293968f6bc0aa3bc16e50cf9069458"));
      setState(() {
        weatherMap = Map<String, dynamic>.from(jsonDecode(weather.body));
        forecastMap = Map<String, dynamic>.from(jsonDecode(forecast.body));
      });
    } catch (e) {
      print(e);
      // handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(
                      "https://w0.peakpx.com/wallpaper/244/691/HD-wallpaper-oppo-mountains-winter-abej-beograd-mount.jpg"),
                  fit: BoxFit.fitHeight),
            ),
            child: Column(
              children: [
                Expanded(
                    child: CurrentWeather(weatherMap: weatherMap)),
                Expanded(
                    child: ForecastData(forecastMap: forecastMap)),
              ],
            )),
      ),
    );
  }
}
class CurrentWeather extends StatelessWidget {
  const CurrentWeather({
    super.key,
    required this.weatherMap,
  });

  final Map<String, dynamic> weatherMap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          width: double.infinity,
          color: Colors.white.withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Last update: ${Jiffy.now().jm as String}"),
              Text("Date: ${Jiffy.now().yMMMd as String}"),
            ],
          ),
        ),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 20,),
            width: double.infinity,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    "${weatherMap["name"] ?? ''}",
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Image.network(
                    "https://openweathermap.org/img/wn/${weatherMap!["weather"][0]["icon"]}@2x.png"),
                Text(
                  "${(weatherMap["main"]["temp"] - 273).toInt() ?? ''}°C",
                  style: const TextStyle(
                    fontSize: 70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "${weatherMap["weather"][0]["main"] ?? ''}",
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Max: ${(weatherMap["main"]["temp_max"] - 273).toInt() ?? ''}°C",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Min: ${(weatherMap["main"]["temp_min"] - 273).toInt() ?? ''}°C",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                    margin: EdgeInsets.symmetric(vertical: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "🌅 Sunrise ${Jiffy.parseFromMillisecondsSinceEpoch(weatherMap!["sys"]["sunrise"] * 1000).jm as String}",
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          "🌇 Sunset ${Jiffy.parseFromMillisecondsSinceEpoch(weatherMap!["sys"]["sunset"] * 1000).jm as String}",
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    )),
              ],
            )),
        // Container(
        //   child: Image(image: AssetImage("images/house.png"),fit: BoxFit.cover,),
        // )
      ],
    );
  }
}
class ForecastData extends StatelessWidget {
  const ForecastData({
    super.key,
    required this.forecastMap,
  });

  final Map<String, dynamic> forecastMap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30),
          )),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Forecast",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                width: double.infinity,
                height: 250,
                child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 120,
                        child: Card(
                          color: Color(0xff48319D).withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(50))),
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 30, horizontal: 10),
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          vertical: 10),
                                  child: Text(
                                    " ${Jiffy.parse(forecastMap!["list"][index]["dt_txt"]).jm}",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                                Container(
                                  height: 50,
                                  child: Image(
                                      image: NetworkImage(
                                          "https://openweathermap.org/img/wn/${forecastMap!["list"][index]["weather"][0]["icon"]}@2x.png")),
                                ),
                                Column( crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: Text(
                                        "${(forecastMap["list"][index]["weather"][0]["description"])}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "Min: ${(forecastMap["list"][index]["main"]["temp_min"] - 273).toInt() ?? ''}°C",
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "Max: ${(forecastMap["list"][index]["main"]["temp_max"] - 273).toInt() ?? ''}°C",
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        width: 30,
                      );
                    },
                    itemCount: forecastMap!.length)),
          ],
        ),
      ),
    );
  }
}
