import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        iconTheme: IconThemeData(
          color: Color(0xFF2d2d59),
        ),
        textTheme: GoogleFonts.ubuntuTextTheme(
          Theme.of(context).textTheme.apply(
                bodyColor: Color(0xFF2d2d59),
                displayColor: Color(0xFF2d2d59),
              ), // If this is not set, then ThemeData.light().textTheme is used.
        ),
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map hourlyWeatherData = {};
  List<Widget> hourlyWidget = [];
  void initState() {
    super.initState();
    _determinePosition().then((value) {
      latitude = value.latitude;
      longitude = value.longitude;
      timeParser(1647770400);
      getOneCall().then((value) {
        hourlyWeatherData = value;
        print(hourlyWeatherData);
        for (int i = 0; i < 24; i++) {
          hourlyWidget.add(Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 160,
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                  color: Colors.white.withOpacity(0.2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Center(
                        child: Text(
                            timeParser(hourlyWeatherData["hourly"][i]["dt"])
                                .toString()
                                .replaceAll("-", ".")
                                .substring(11, 16))),
                    Center(
                        child: Text(
                      hourlyWeatherData["hourly"][i]["temp"]
                              .round()
                              .toString() +
                          '°',
                      style:
                          TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                    )),
                  ],
                ),
              ),
            ],
          ));
          hourlyWidget.add(SizedBox(
            width: 10,
          ));
        }
      });
      getWeather().then((value) {
        print(value['name']);
        setState(() {
          cityName = value['name'];
          temperature = value['main']['temp'].toString();
          humidity = value['main']['humidity'].toString();
          windSpeed = value['wind']['speed'].toString();
          weatherIcon = value['weather'][0]['description'].toString();
          if (weatherIcon == 'clear sky') {
            setState(() {
              startColor = colorReturner(backGroundColors['sunny'][0]);
              endColor = colorReturner(backGroundColors['sunny'][1]);
            });

          }


          else if (weatherIcon == 'few clouds') {
            setState(() {
              startColor = colorReturner(backGroundColors['cloudy'][0]);
              endColor = colorReturner(backGroundColors['cloudy'][1]);
            });

          } else if (weatherIcon == 'broken clouds') {
            setState(() {
              startColor = colorReturner(backGroundColors['cloudy'][0]);
              endColor = colorReturner(backGroundColors['cloudy'][1]);
            });

          } else if (weatherIcon == 'scattered clouds') {
            setState(() {
              startColor = colorReturner(backGroundColors['cloudy'][0]);
              endColor = colorReturner(backGroundColors['cloudy'][1]);
            });

          } else if (weatherIcon == 'shower rain') {
            setState(() {
              startColor = colorReturner(backGroundColors['rainy'][0]);
              endColor = colorReturner(backGroundColors['rainy'][1]);
            });

          } else if (weatherIcon == 'rain') {
            setState(() {
              startColor = colorReturner(backGroundColors['rainy'][0]);
              endColor = colorReturner(backGroundColors['rainy'][1]);
            });

          } else if (weatherIcon == 'thunderstorm') {
            setState(() {
              startColor = colorReturner(backGroundColors['rainy'][0]);
              endColor = colorReturner(backGroundColors['rainy'][1]);
            });

          } else if (weatherIcon == 'snow') {
            setState(() {
              startColor = colorReturner(backGroundColors['rainy'][0]);
              endColor = colorReturner(backGroundColors['rainy'][1]);
            });

          } else if (weatherIcon == 'mist') {
            setState(() {
              startColor = colorReturner(backGroundColors['rainy'][0]);
              endColor = colorReturner(backGroundColors['rainy'][1]);
            });

          } else {
            setState(() {
              startColor = colorReturner(backGroundColors['rainy'][0]);
              endColor = colorReturner(backGroundColors['rainy'][1]);
            });

          }
        });
      });
    });
  }

  refresher() async {
    await getOneCall().then((value) {
      hourlyWeatherData = value;
      List<Widget> temporary = [];
      for (int i = 0; i < 24; i++) {
        temporary.add(Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 160,
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
                color: Colors.white.withOpacity(0.2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(
                      child: Text(
                          timeParser(hourlyWeatherData["hourly"][i]["dt"])
                              .toString()
                              .replaceAll("-", ".")
                              .substring(11, 16))),
                  Center(
                      child: Text(
                    hourlyWeatherData["hourly"][i]["temp"].round().toString() +
                        '°',
                    style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                  )),
                ],
              ),
            ),
          ],
        ));
        temporary.add(SizedBox(
          width: 10,
        ));
      }
      setState(() {
        hourlyWidget = temporary;
      });
    });
  }

  Future getWeather() async {
    var response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=${latitude}&lon=${longitude}&appid=5e6543768b3934f0b3a82c8756a843ba&units=metric'));
    print('Response status: ${response.statusCode}');
    if (response.statusCode == 200) {}
    print(response.request!.url);
    print('Response body: ${response.body}');
    Map weatherData = jsonDecode(response.body);
    return weatherData;
  }

  Future getOneCall() async {
    var response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/onecall?lat=${latitude}&lon=${longitude}&appid=5e6543768b3934f0b3a82c8756a843ba&units=metric'));
    print('Response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      setState(() {
        loading = false;
      });
    }
    print(response.request!.url);
    print('Response body: ${response.body}');
    Map oneCall = jsonDecode(response.body);
    return oneCall;
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

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
    return await Geolocator.getCurrentPosition();
  }

  bool loading = true;
  double? latitude;
  double? longitude;
  String cityName = '';
  String windSpeed = '';
  String humidity = '';
  String temperature = '';
  String weatherIcon = '';

  Map backGroundColors = {
    'rainy': ['5AB4D7', '5AE4FE'],
    'sunny': ['fae076', 'febd92'],
    'cloudy': ['73F0E9', '6EF9E1'],
  };

  Color startColor = Color(0xFFfae076);
  Color endColor = Color(0xFFfebd92);

  timeParser(int value) {
    return DateTime.fromMillisecondsSinceEpoch(value * 1000).toLocal();
  }

  Color colorReturner(String txt) {
    return Color(int.parse('0XFF' + txt));
  }

  Widget returnImage(String condition) {
    if (condition == 'clear sky') {
      setState(() {
        startColor = colorReturner(backGroundColors['sunny'][0]);
        endColor = colorReturner(backGroundColors['sunny'][1]);
      });
      return SvgPicture.asset('assets/clear-day.svg',
        height: 200,
      );
    } else if (condition == 'few clouds') {
      setState(() {
        startColor = colorReturner(backGroundColors['cloudy'][0]);
        endColor = colorReturner(backGroundColors['cloudy'][1]);
      });
      return SvgPicture.asset('assets/cloudy.svg',
        height: 200,
      );
    } else if (condition == 'broken clouds') {
      setState(() {
        startColor = colorReturner(backGroundColors['cloudy'][0]);
        endColor = colorReturner(backGroundColors['cloudy'][1]);
      });
      return SvgPicture.asset('assets/partly-cloudy-day.svg',
      height: 200,
      );
      /*
      return Image.asset(
        'assets/ic_broken_clouds.png',
        height: 200,
      );
      */

    } else if (condition == 'scattered clouds') {
      setState(() {
        startColor = colorReturner(backGroundColors['cloudy'][0]);
        endColor = colorReturner(backGroundColors['cloudy'][1]);
      });
      return SvgPicture.asset('assets/partly-cloudy-day.svg',
        height: 200,
      );
    } else if (condition == 'shower rain') {
      setState(() {
        startColor = colorReturner(backGroundColors['rainy'][0]);
        endColor = colorReturner(backGroundColors['rainy'][1]);
      });
      return SvgPicture.asset('assets/shower-rain.svg',
        height: 200,
      );
    } else if (condition == 'rain') {
      setState(() {
        startColor = colorReturner(backGroundColors['rainy'][0]);
        endColor = colorReturner(backGroundColors['rainy'][1]);
      });
      return SvgPicture.asset('assets/hail.svg',
        height: 200,
      );
    } else if (condition == 'thunderstorm') {
      setState(() {
        startColor = colorReturner(backGroundColors['rainy'][0]);
        endColor = colorReturner(backGroundColors['rainy'][1]);
      });
      return SvgPicture.asset('assets/thunderstorms.svg',
        height: 200,
      );
    } else if (condition == 'snow') {
      setState(() {
        startColor = colorReturner(backGroundColors['rainy'][0]);
        endColor = colorReturner(backGroundColors['rainy'][1]);
      });
      return SvgPicture.asset('assets/partly-cloudy-day-sleet.svg',
        height: 200,
      );
    } else if (condition == 'mist') {
      setState(() {
        startColor = colorReturner(backGroundColors['rainy'][0]);
        endColor = colorReturner(backGroundColors['rainy'][1]);
      });
      return SvgPicture.asset('assets/partly-cloudy-day-sleet.svg',
        height: 200,
      );
    } else {
      setState(() {
        startColor = colorReturner(backGroundColors['rainy'][0]);
        endColor = colorReturner(backGroundColors['rainy'][1]);
      });
      return SvgPicture.asset(
        'assets/overcast.svg',
        height: 200,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    endColor,
                    startColor,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  tileMode: TileMode.mirror),
            ),
            child: loading
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.orange,
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(40, 80, 40, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () async {
                            _determinePosition().then((value) {
                              setState(() {
                                loading = false;
                              });
                              latitude = value.latitude;
                              longitude = value.longitude;
                              getWeather().then((value) {
                                print(value['name']);
                                setState(() {
                                  cityName = value['name'];
                                  temperature =
                                      value['main']['temp'].toString();
                                  humidity =
                                      value['main']['humidity'].toString();
                                  windSpeed = value['wind']['speed'].toString();
                                  weatherIcon = value['weather'][0]
                                          ['description']
                                      .toString();
                                  refresher();
                                });
                              });
                            });

                            await refresher();
                          },
                          child: Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.locationDot,
                                size: 30,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                cityName == '' ? 'Konum Seç' : cityName,
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 35,
                        ),
                        returnImage(weatherIcon),
                        Text(
                          weatherIcon,
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(
                          height: 35,
                        ),
                        Text(
                          '${double.parse(temperature).round()}°',
                          style: TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 35,
                        ),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(FontAwesomeIcons.wind),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                windSpeed.toString() + ' km/h',
                                style: TextStyle(fontSize: 17),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              FaIcon(FontAwesomeIcons.droplet),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                '% ' + humidity.toString(),
                                style: TextStyle(fontSize: 17),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 35,
                        ),
                        Expanded(
                          child: ListView(
                            shrinkWrap: true,
                            children: hourlyWidget as List<Widget>,
                            scrollDirection: Axis.horizontal,
                            physics: BouncingScrollPhysics(),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
