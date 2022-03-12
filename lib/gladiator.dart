import './utils.dart';
import 'dart:convert';
import 'package:hex/hex.dart';
import 'package:crypto/crypto.dart';
import 'dart:isolate';
import 'package:nofifty/constantes.dart';
class InterioreRationem {
  final String publicaClavis;
  BigInt nonce;
  final String id;
  InterioreRationem(this.publicaClavis, this.nonce): id = Utils.randomHex(32);
  InterioreRationem.incipio(this.publicaClavis):
      nonce = BigInt.zero,
      id = Utils.randomHex(32);
  mine() {
    nonce += BigInt.one;
  }
  Map<String, dynamic> toJson() => {
    'publicaClavis': publicaClavis,
    'nonce': nonce.toString(),
    'id': id
  };
  InterioreRationem.fromJson(Map<String, dynamic> jsoschon):
      publicaClavis = jsoschon['publicaClavis'],
      nonce = BigInt.parse(jsoschon['nonce']),
      id = jsoschon['id'];
}
class Propter {
  late String probationem;
  final InterioreRationem interioreRationem;
  Propter(this.probationem, this.interioreRationem);

  Propter.incipio(this.interioreRationem):
      probationem = HEX.encode(sha256.convert(utf8.encode(json.encode(interioreRationem.toJson()))).bytes);
  static void quaestum(List<dynamic> argumentis) {
    InterioreRationem interioreRationem = argumentis[0];
    SendPort mitte = argumentis[1];
    String probationem = '';
    int zeros = 1;
    while (true) {
      do {
        interioreRationem.mine();
        probationem = HEX.encode(sha256.convert(utf8.encode(json.encode(interioreRationem.toJson()))).bytes);
      } while(!probationem.startsWith('0' * zeros));
      zeros += 1;
      mitte.send(Propter(probationem, interioreRationem));
    }
  }
  Map<String, dynamic> toJson() => {
    'probationem': probationem,
    'interioreRationem': interioreRationem.toJson()
  };
  Propter.fromJson(Map<String, dynamic> jsoschon):
      probationem = jsoschon['probationem'],
      interioreRationem = InterioreRationem.fromJson(jsoschon['interioreRationem']);
}


class GladiatorInput {
  final String signature;
  final String gladiatorId;
  GladiatorInput(this.signature, this.gladiatorId);
  Map<String, dynamic> toJson() => {
     'signature': signature,
    'gladiatorId': gladiatorId
  };
  GladiatorInput.fromJson(Map<String, dynamic> jsoschon):
      signature = jsoschon['signature'],
      gladiatorId = jsoschon['gladiatorId'];
}
class GladiatorOutput {
  final List<Propter> rationem;
  final String defensio;
  GladiatorOutput(this.rationem): defensio = Utils.randomHex(1);
  Map<String, dynamic> toJson() => {
    'rationem': rationem.map((r) => r.toJson()).toList(),
    'defensio': defensio
  };
  GladiatorOutput.fromJson(Map<String, dynamic> jsoschon):
    rationem = List<Propter>.from(jsoschon['rationem'].map((r) => Propter.fromJson(r))),
    defensio = jsoschon['defensio'];
}

class Gladiator {
    final GladiatorInput? input;
    final GladiatorOutput? output;
    final String random;
    final String id;
    Gladiator(this.input, this.output, this.random):
        id = HEX.encode(
            sha512.convert(
                utf8.encode(json.encode(input?.toJson())) +
                    utf8.encode(json.encode(output?.toJson())) +
                    utf8.encode(random)).bytes);
    Map<String, dynamic> toJson() => {
      'input': input?.toJson(),
      'output': output?.toJson(),
      'random': random,
      'id': id
    };
    Gladiator.fromJson(Map<String, dynamic> jsoschon):
      input = jsoschon['input'] != null ?  GladiatorInput.fromJson(jsoschon['input']) : null,
      output = jsoschon['output'] != null ? GladiatorOutput.fromJson(jsoschon['output']) : null,
      random = jsoschon['random'],
      id = jsoschon['id'];
      static List<Propter> grab(int difficultas, List<Propter> propters) {
        List<Propter> reditus = [];
        for (int i = 64; i >= difficultas; i--) {
          if(reditus.length < Constantes.perRationesObstructionum) {
            reditus.addAll(propters.where((p) => p.probationem.startsWith('0' * difficultas)));
          } else {
            break;
          }
        }
        return reditus;
      }
}
