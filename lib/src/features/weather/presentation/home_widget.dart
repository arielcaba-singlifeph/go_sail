
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../application/forecast_tile_provider.dart';
import '../../../shared/services/position_provider.dart';

class GoSail extends StatefulWidget {
  const GoSail({super.key});

  @override
  State<GoSail> createState() => MapSampleState();
}

class MapSampleState extends State<GoSail> {

  TileOverlay? _tileOverlay;
  late Future _getCurrentLocationFuture;
  final LatLng _defaultPosition = const LatLng(0, 0);
  LatLng? _initialPosition;
  DateTime _forecastDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _getCurrentLocationFuture = _getInitialPosition();
  }

  _initTiles(DateTime date) async {
    final String overlayId = date.millisecondsSinceEpoch.toString();

    final TileOverlay tileOverlay = TileOverlay(
      tileOverlayId: TileOverlayId(overlayId),
      tileProvider: ForecastTileProvider(
        dateTime: date,
        mapType: 'WND',
        opacity: 0.4,
      ),
    );
    setState(() {
      _tileOverlay = tileOverlay;
    });
  }

  _getInitialPosition() async {
    try {
      PostitionProvider positionProv = PostitionProvider();
      Position position = await positionProv.determinePosition();
      double lat = position.latitude;
      double long = position.longitude;

      LatLng location = LatLng(lat, long);
      setState(() {
        _initialPosition = location;
      });
    } catch (e) {
      print(e);
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _getCurrentLocationFuture,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              } else {
                return Stack(
              alignment: Alignment.center,
                children: [
                  GoogleMap(
                    zoomControlsEnabled: false,
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition (
                      target: _initialPosition ?? _defaultPosition,
                      zoom: 8,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      setState(() {
                      });
                      _initTiles(_forecastDate);          
                    },
                    tileOverlays:
                        _tileOverlay == null ? {} : <TileOverlay>{_tileOverlay!},
                  ),
                  Positioned(
                    bottom: 30,
                    child: SizedBox(
                      height: 70,
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            left: 30,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _forecastDate =
                                      _forecastDate.subtract(const Duration(hours: 3));
                                });
                                _initTiles(_forecastDate);
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(20),
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Center(
                            child: Card(
                              elevation: 4,
                              shadowColor: Colors.black,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  'Forecast Date:\n${DateFormat('yyyy-MM-dd ha').format(_forecastDate)}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 30,
                            child: ElevatedButton(
                              onPressed:
                                  _forecastDate.difference(DateTime.now()).inDays >= 10
                                      ? null
                                      : () {
                                          setState(() {
                                            _forecastDate = _forecastDate
                                                .add(const Duration(hours: 3));
                                          });
                                          _initTiles(_forecastDate);
                                        },
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(20),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
              }

            default:
              return const Text('Unhandle State');
          }
        }
      ),
    );
  }
}