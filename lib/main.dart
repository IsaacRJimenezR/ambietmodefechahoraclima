import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wear/wear.dart';
import 'package:intl/intl.dart'; //PARA FECHAS Y HORAS EN TIEMPO REAL
import 'package:intl/date_symbol_data_local.dart'; // PARA IDIOMA
import 'package:weather/weather.dart'; //PARA CLIMA EN TIEMPO REAL
import 'package:weather_icons/weather_icons.dart'; // PARA USAR ICONOS METEOROLOGICOS

void main() {
  initializeDateFormatting('es'); // Inicializa el formateo en español
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AmbientMode(
      child: const HomeScreen(title: 'AMBIENTMODE DE FECHA,HORA Y CLIMA'),
      builder: (context, mode, child) {
        return MaterialApp(
          title: 'Wear Hello',
          theme: ThemeData(
            visualDensity: VisualDensity.compact,
            colorScheme: mode == WearMode.active
                ? const ColorScheme.dark(
                    primary: Color(0xFF00B5FF),
                  )
                : const ColorScheme.dark(
                    primary: Color.fromARGB(179, 144, 140, 140),
                    onBackground: Color.fromARGB(168, 152, 144, 144),
                    onSurface: Color.fromARGB(184, 174, 168, 168),
                  ),
          ),
          home: child,
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late Timer timer;
  String formattedDateTime = '';
  String formattedDate = '';
  WeatherFactory weatherFactory = WeatherFactory(
      "ca58d3e5edff31e7c39345a5d0048dea", // SE AGREGA LA API DE openweathermap
      language: Language.SPANISH);
  Weather? currentWeather;

  @override
  void initState() {
    super.initState();
    updateDateTime();
    getCurrentWeather();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      updateDateTime();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void updateDateTime() {
    final DateTime now = DateTime.now();
    // final DateFormat formatter = DateFormat('yyyy-MM-dd', 'es'); //PARA MOSTRAR LA FECHA ENTERA
    final DateFormat dayFormatter = DateFormat('dd', 'es'); //PARA DIA
    final DateFormat monthFormatter = DateFormat('MMMM', 'es'); //PARA MES
    final DateFormat yearFormatter = DateFormat('yyyy', 'es'); // PARA AÑO

    setState(() {
      formattedDateTime = DateFormat.Hm().format(now);
      formattedDate =
          '${dayFormatter.format(now)} de ${monthFormatter.format(now)} de ${yearFormatter.format(now)}';
    });
  }

  Future<void> getCurrentWeather() async {
    Weather? weather =
        await weatherFactory.currentWeatherByLocation(40.7128, -74.0060);
    setState(() {
      currentWeather = weather;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientMode(
        builder: (BuildContext context, dynamic mode, Widget? child) {
          final isAmbientMode = mode == WearMode.ambient;
          final textColor = isAmbientMode
              ? const Color.fromRGBO(186, 243, 0, 1)
              : const Color.fromRGBO(0, 233, 222, 1);
          final backgroundColor = isAmbientMode
              ? const Color.fromRGBO(0, 0, 0, 1)
              : const Color.fromARGB(153, 153, 146, 153);
          final colorHora = isAmbientMode
              ? const Color.fromRGBO(9, 255, 0, 1)
              : const Color.fromARGB(255, 0, 255, 157);
          final colorClima = isAmbientMode
              ? const Color.fromARGB(255, 140, 144, 145)
              : const Color.fromARGB(255, 237, 171, 5);
          final colorIcono = isAmbientMode
              ? const Color.fromARGB(255, 0, 204, 255)
              : const Color.fromARGB(255, 20, 5, 237);
          final colorTipoClima = isAmbientMode
              ? const Color.fromARGB(255, 98, 46, 124)
              : const Color.fromARGB(255, 237, 218, 5);

          return Container(
            color: backgroundColor,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (currentWeather != null)
                    Column(
                      children: [
                        Icon(
                          getWeatherIcon(currentWeather!.weatherDescription!),
                          size: 20,
                          color: colorIcono,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${currentWeather!.temperature?.celsius?.toStringAsFixed(3)}°C", //toStringAsFixed(3) PARA DEFINIR CUANTOS DECIMALES MOSTRAR
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colorClima,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          currentWeather!.weatherDescription!,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorTipoClima,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  Text(
                    formattedDateTime,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: colorHora,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 18,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData getWeatherIcon(String weatherDescription) {
    if (weatherDescription.contains('lluvia')) {
      return WeatherIcons.rain;
    } else if (weatherDescription.contains('nublado')) {
      return WeatherIcons.cloudy;
    } else if (weatherDescription.contains('soleado') ||
        weatherDescription.contains('despejado')) {
      return WeatherIcons.day_sunny;
    } else if (weatherDescription.contains('nieve')) {
      return WeatherIcons.snow;
    } else if (weatherDescription.contains('tormenta')) {
      return WeatherIcons.thunderstorm;
    } else if (weatherDescription.contains('niebla')) {
      return WeatherIcons.fog;
    } else {
      return WeatherIcons.cloudy;
    }
  }
}
