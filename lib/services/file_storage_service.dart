//ExternalPackages
import 'dart:io';
import 'package:athan_times/core/logic.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

class FileStorageService {
  Future<String> get _localPath async {
    Debug.printMsg('Fetching local path...');
    final Directory directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final String path = await _localPath;
    Debug.printMsg('Fetching local file...');
    final File file = File("$path/coords.txt");
    if (!await file.exists()) await file.create(recursive: true);
    if (await file.length() < 2) {
      await file.writeAsString('00');
    }
    return file;
  }

  Future<String> readFile() async {
    try {
      final File file = await _localFile;
      Debug.printMsg('Reading local file...');
      String data = await file.readAsString();
      Debug.printMsg('Location read from: ${file.path}');
      return data;
    } catch (e) {
      Debug.printMsg('error reading file: $e');
      Fluttertoast.showToast(msg: "Couldn't retrieve saved coordinates.");
      return '0'; // select cairo by default
    }
  }

  Future<void> writeFile(String data) async {
    Debug.printMsg('Writing to local file...');
    final File file = await _localFile;
    await file.writeAsString(data);
  }
}
