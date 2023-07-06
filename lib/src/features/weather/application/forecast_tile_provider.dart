import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:weather/weather.dart';
import 'package:logging/logging.dart';

class ForecastTileProvider implements TileProvider {
  final String mapType;
  final DateTime dateTime;
  int tileSize = 256;
  final double opacity;
  final log = Logger('ForecastTileProvider');

  String key = '4d00c0dcc542b7157239e31b42d70d87';
  late WeatherFactory ws;
  double? lat, lon;
  
  void main() {
    Logger.root.level = Level.ALL; // defaults to Level.INFO
    Logger.root.onRecord.listen((record) {
      // ignore: avoid_print
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
    ws = WeatherFactory(key);
  }

  ForecastTileProvider({
    required this.mapType,
    required this.dateTime,
    required this.opacity,
  });

  @override
  Future<Tile> getTile(int x, int y, int? zoom) async {
    Uint8List tileBytes = Uint8List(0);
    try {
      final date = dateTime.millisecondsSinceEpoch ~/ 1000;
      final url =
          "http://maps.openweathermap.org/maps/2.0/weather/$mapType/$zoom/$x/$y?date=$date&opacity=$opacity&fill_bound=true&appid=9de243494c0b295cca9337e1e96b00e2";
      if (TilesCache.tiles.containsKey(url)) {
        tileBytes = TilesCache.tiles[url]!;
      } else {
        final uri = Uri.parse(url);

        final ByteData imageData = await NetworkAssetBundle(uri).load("");
        tileBytes = imageData.buffer.asUint8List();
        TilesCache.tiles[url] = tileBytes;
      }
    } catch (e) {
      log.severe(e.toString());
    }
    log.info("Successfully get tiles");
    return Tile(tileSize, tileSize, tileBytes);
  }
}

class TilesCache {
  static Map<String, Uint8List> tiles = {};
}