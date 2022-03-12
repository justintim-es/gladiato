import 'dart:convert';
import 'package:ecdsa/ecdsa.dart';
import 'package:elliptic/elliptic.dart';
class ObstructionumNumerus {
  final List<int> numerus;
  Map<String, dynamic> toJson() => {
    'numerus': numerus
  };
  ObstructionumNumerus.fromJson(Map<String, dynamic> jsoschon): numerus = List<int>.from(jsoschon['numerus']);
}
class KeyPair {
  late String private;
  late String public;
  KeyPair() {
    final ec = getP256();
    final key = ec.generatePrivateKey();
    private = key.toHex();
    public = key.publicKey.toHex();
  }
}
class SubmittereRationem {
  final String publicaClavis;
  SubmittereRationem.fromJson(Map<String, dynamic> jsoschon):
  publicaClavis = jsoschon['publicaClavis'];
}
class SubmittereTransaction {
  final String from;
  final String to;
  final BigInt nof;
  SubmittereTransaction(this.from, this.to, this.nof);
  SubmittereTransaction.fromJson(Map<String, dynamic> jsoschon):
      from = jsoschon['from'],
      to = jsoschon['to'],
      nof = BigInt.parse(jsoschon['nof']);
}
class RemoveTransaction {
  final bool liber;
  final String transactionId;
  final String publicaClavis;
  RemoveTransaction(this.liber, this.transactionId, this.publicaClavis);
  RemoveTransaction.fromJson(Map<String, dynamic> jsoschon):
      liber = jsoschon['liber'],
      transactionId = jsoschon['transactionId'],
      publicaClavis = jsoschon['publicaClavis'];
}
class Confussus {
  final String gladiatorId;
  final String privateKey;
  Confussus(this.gladiatorId, this.privateKey);
  Confussus.fromJson(Map<String, dynamic> jsoschon):
  gladiatorId = jsoschon['gladiatorId'],
  privateKey = jsoschon['privateKey'];
}
