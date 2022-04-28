import 'dart:math';
import 'dart:io';
import 'package:hex/hex.dart';
import 'dart:convert';
import 'package:nofifty/obstructionum.dart';
import 'package:elliptic/elliptic.dart';
import 'package:nofifty/transaction.dart';
import 'package:ecdsa/ecdsa.dart';
import 'package:nofifty/constantes.dart';
class Utils {
  static final Random _random = Random.secure();

  static String randomHex(int length) {
    var values = List<int>.generate(length, (index) => _random.nextInt(256));
    return HEX.encode(values);
  }
  static Stream<String> fileAmnis(File file) => file.openRead().transform(utf8.decoder).transform(LineSplitter());

  static Future<Obstructionum> priorObstructionum(Directory directory) async =>
      Obstructionum.fromJson(json.decode(await Utils.fileAmnis(File(directory.path + '/caudices_' + (directory.listSync().isNotEmpty ? directory.listSync().length -1 : 0).toString() + '.txt')).last));
  static String signum(PrivateKey privateKey, dynamic output) => signature(privateKey, utf8.encode(json.encode(output.toJson()))).toASN1Hex();


  static bool cognoscere(PublicKey publicaClavis, Signature signature, TransactionOutput txOutput) =>
      verify(publicaClavis, utf8.encode(json.encode(txOutput.toJson())), signature);

  static Future removeDonecObstructionum(Directory directory, List<int> numerus) async {
    final priorObs = await Utils.priorObstructionum(directory);
    final priorNumerus = priorObs.interioreObstructionum.obstructionumNumerus;
    if(numerus.length -1 > directory.listSync().length-1) {
      for(int i = (numerus.length -1); i < directory.listSync().length-1; i++) {
        File('${directory.path}/${Constantes.fileNomen}$i').delete();
      }
    }
    File file = File('${directory.path}/${Constantes.fileNomen}${numerus.length-1}.txt');
    final lines = await Utils.fileAmnis(file).toList();
    lines.removeRange(numerus.last, lines.length);
    print('lines');
    file.writeAsStringSync('');
    var sink = file.openWrite(mode: FileMode.append);
    for (String line in lines) {
      print(line + '\n');
      sink.write(line + '\n');
    }
    sink.close();
  }
  static Future<List<Obstructionum>> getObstructionums(Directory directory) async {
    List<Obstructionum> obs = [];
    for (int i = 0; i < directory.listSync().length; i++) {
      await for (String obstructionum in Utils.fileAmnis(File('${directory.path}${Constantes.fileNomen}$i.txt'))) {
        obs.add(Obstructionum.fromJson(json.decode(obstructionum)));
      }
    }
    return obs;
  }
}
