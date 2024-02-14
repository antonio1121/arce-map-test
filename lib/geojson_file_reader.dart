import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class GeojsonFileReader {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {

      final file = await _localFile;
      return File('assets/geojson/Projected_Sec49_Headstones.geojson');
  }

  Future<String> readFile() async {
    try{
      final file = await _localFile;
      return await file.readAsString();
    } catch(e) {
      return "Error";
    }
  }
}