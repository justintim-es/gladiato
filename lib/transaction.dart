import 'dart:io';
import 'dart:convert';
import 'package:hex/hex.dart';
import 'package:crypto/crypto.dart';
import 'dart:isolate';
import 'package:hex/hex.dart';
import 'package:nofifty/utils.dart';
import 'package:nofifty/obstructionum.dart';
import 'package:elliptic/elliptic.dart';
import 'package:ecdsa/ecdsa.dart';
import 'package:nofifty/pera.dart';
import 'package:nofifty/constantes.dart';
class TransactionInput {
  final int index;
  final String signature;
  final String transactionId;
  TransactionInput(this.index, this.signature, this.transactionId);
  Map<String, dynamic> toJson() => {
    'index': index,
    'signature': signature,
    'transactionId': transactionId
  };
  TransactionInput.fromJson(Map<String, dynamic> jsoschon):
      index = jsoschon['index'],
      signature = jsoschon['signature'],
      transactionId = jsoschon['transactionId'];
}
class TransactionOutput {
  final String publicKey;
  final BigInt nof;
  TransactionOutput(this.publicKey, this.nof);
  Map<String, dynamic> toJson() => {
    'publicKey': publicKey,
    'nof': nof.toString()
  };
  TransactionOutput.fromJson(Map<String, dynamic> jsoschon):
      publicKey = jsoschon['publicKey'],
      nof = BigInt.parse(jsoschon['nof']);
}


class InterioreTransaction {
  final bool liber;
  final int zeros;
  final List<TransactionInput> inputs;
  final List<TransactionOutput> outputs;
  final String random;
  final String id;
  BigInt nonce;
  InterioreTransaction(this.liber, this.zeros, this.inputs, this.outputs, this.random):
        nonce = BigInt.zero,
        id = HEX.encode(
            sha512.convert(
                utf8.encode(json.encode(inputs.map((e) => e.toJson()).toList())) +
                utf8.encode(json.encode(outputs.map((e) => e.toJson()).toList())) +
                utf8.encode(json.encode(random))
            ).bytes
        );
  mine() {
    nonce += BigInt.one;
  }
  Map<String, dynamic> toJson() => {
    'liber': liber,
    'inputs': inputs.map((i) => i.toJson()).toList(),
    'outputs': outputs.map((o) =>  o.toJson()).toList(),
    'random': random,
    'zeros': zeros,
    'id': id,
    'nonce': nonce.toString(),
  };
  InterioreTransaction.fromJson(Map<String, dynamic> jsoschon):
      liber = jsoschon['liber'],
      inputs = List<TransactionInput>.from(jsoschon['inputs'].map((i) => TransactionInput.fromJson(i))),
      outputs = List<TransactionOutput>.from(jsoschon['outputs'].map((o) => TransactionOutput.fromJson(o))),
      random = jsoschon['random'],
      zeros = jsoschon['zeros'],
      id = jsoschon['id'],
      nonce = BigInt.parse(jsoschon['nonce']);
}
class Transaction {
  late String probationem;
  final InterioreTransaction interioreTransaction;
  Transaction(this.probationem, this.interioreTransaction);
  Transaction.fromJson(Map<String, dynamic> jsoschon):
      probationem = jsoschon['probationem'],
      interioreTransaction = InterioreTransaction.fromJson(jsoschon['interioreTransaction']);
  static void quaestum(List<dynamic> argumentis) {
    InterioreTransaction interiore = argumentis[0];
    SendPort mitte = argumentis[1];
    String probationem = '';
    int zeros = 1;
    while (true) {
      do {
        interiore.mine();
        probationem = HEX.encode(sha256.convert(utf8.encode(json.encode(interiore.toJson()))).bytes);
      } while(!probationem.startsWith('0' * zeros));
      zeros += 1;
      mitte.send(Transaction(probationem, interiore));
    }
  }

  Transaction.burn(this.interioreTransaction): probationem = Constantes.ardeat;
  bool validateBlockreward() {
    if (interioreTransaction.outputs.length != 1) {
      return false;
    }
    if (interioreTransaction.outputs[0].nof != Constantes.obstructionumPraemium) {
      return false;
    }
    if (interioreTransaction.inputs.isNotEmpty) {
      return false;
    }
    return true;
  }
  Future<bool> validateBurn(Directory dir) async {
    List<Obstructionum> obs = await Obstructionum.getBlocks(dir);
    BigInt spendable = BigInt.zero;
    Obstructionum obstructionum =
    obs.singleWhere((ob) => ob.interioreObstructionum.liberTransactions.any((liber) => liber.interioreTransaction.id == interioreTransaction.id));
    for (TransactionInput input in obstructionum.interioreObstructionum.liberTransactions.singleWhere((liber) => liber.interioreTransaction.id == interioreTransaction.id).interioreTransaction.inputs) {
      Obstructionum prevObs = obs.singleWhere((ob) => ob.interioreObstructionum.liberTransactions.any((liber) => liber.interioreTransaction.id == input.transactionId));
      TransactionOutput output = prevObs.interioreObstructionum.liberTransactions.singleWhere((liber) => liber.interioreTransaction.id == input.transactionId).interioreTransaction.outputs[input.index];
      spendable += output.nof;
      if (!Utils.cognoscere(PublicKey.fromHex(Pera.curve(), obstructionum.interioreObstructionum.producentis), Signature.fromCompactHex(input.signature), output)) {
        return false;
      }
    }
    BigInt isSpended = BigInt.zero;
    for (TransactionOutput output in obstructionum.interioreObstructionum.liberTransactions.singleWhere((liber) => liber.interioreTransaction.id == interioreTransaction.id).interioreTransaction.outputs) {
      isSpended += output.nof;
    }
    if (spendable > isSpended) {
      return false;
    }
    return true;
  }
  // Future<bool> validateTransform(Directory dir) async {
  //   List<Obstructionum> obs = await Obstructionum.getBlocks(dir);
  //   BigInt spendable = BigInt.zero;
  //   for (TransactionInput input in interioreTransaction.inputs) {
  //     Obstructionum referObstructionum = obs.singleWhere((o) => o.interioreObstructionum.liberTransactions.any((liber) => liber.interioreTransaction.id == input.transactionId));
  //     Transaction tx = referObstructionum.interioreObstructionum.liberTransactions.singleWhere((liber) => liber.interioreTransaction.id == input.transactionId);
  //     for (TransactionOutput output in tx.interioreTransaction.outputs) {
  //       if (!Utils.cognoscere(PublicKey.fromHex(Pera.curve(), output.publicKey), Signature.fromCompactHex(input.signature), output)) {
  //         return false;
  //       }
  //       spendable += output.nof;
  //     }
  //   }
  //   BigInt spended = BigInt.zero;
  //   for(TransactionOutput output in interioreTransaction.outputs) {
  //     spended += output.nof;
  //   }
  //   if (spendable != spended) {
  //     return false;
  //   }
  //   return true;
  // }
  Future<bool> validateLiber(Directory dir) async {
    List<Obstructionum> obs = await Obstructionum.getBlocks(dir);
    BigInt spendable = BigInt.zero;
    for (TransactionInput input in interioreTransaction.inputs) {
      Obstructionum referObstructionum = obs.singleWhere((o) => o.interioreObstructionum.liberTransactions.any((liber) => liber.interioreTransaction.id == input.transactionId));
      Transaction tx = referObstructionum.interioreObstructionum.liberTransactions.singleWhere((liber) => liber.interioreTransaction.id == input.transactionId);
        if (!Utils.cognoscere(PublicKey.fromHex(Pera.curve(), tx.interioreTransaction.outputs[input.index].publicKey), Signature.fromASN1Hex(input.signature), tx.interioreTransaction.outputs[input.index])) {
          print('non subscribere');
          return false;
        }
        final inconsumptus = await Pera.inconsumptusOutputs(true, tx.interioreTransaction.outputs[input.index].publicKey, dir);
        final outputs = inconsumptus.map((x) => x.item3);
        if (!outputs.contains(tx.interioreTransaction.outputs[input.index])) {
          print('output iam signatum');
          return false;
        }
        spendable += tx.interioreTransaction.outputs[input.index].nof;
    }
    BigInt spended = BigInt.zero;
    for(TransactionOutput output in interioreTransaction.outputs) {
      spended += output.nof;
    }
    if (spendable != spended) {
      print('insf');
      return false;
    }
    return true;
  }
  Future<bool> validateFixum(Directory dir) async {
    List<Obstructionum> obs = await Obstructionum.getBlocks(dir);
    BigInt spendable = BigInt.zero;
    for (TransactionInput input in interioreTransaction.inputs) {
      Obstructionum referObstructionum = obs.singleWhere((o) => o.interioreObstructionum.fixumTransactions.any((fixum) => fixum.interioreTransaction.id == input.transactionId));
      Transaction tx = referObstructionum.interioreObstructionum.fixumTransactions.singleWhere((fixum) => fixum.interioreTransaction.id == input.transactionId);
      if (!Utils.cognoscere(PublicKey.fromHex(Pera.curve(), tx.interioreTransaction.outputs[input.index].publicKey), Signature.fromCompactHex(input.signature), tx.interioreTransaction.outputs[input.index])) {
        return false;
      }
      final inconsumptus = await Pera.inconsumptusOutputs(true, tx.interioreTransaction.outputs[input.index].publicKey, dir);
      final outputs = inconsumptus.map((x) => x.item3);
      if (!outputs.contains(tx.interioreTransaction.outputs[input.index])) {
        print('output iam signatum');
        return false;
      }
      spendable += tx.interioreTransaction.outputs[input.index].nof;

    }
    BigInt spended = BigInt.zero;
    for(TransactionOutput output in interioreTransaction.outputs) {
      spended += output.nof;
    }
    if (spendable != spended) {
      return false;
    }
    return true;
  }

  Map<String, dynamic> toJson() => {
    'probationem': probationem,
    'interioreTransaction': interioreTransaction.toJson()
  };
  static List<Transaction> grab(int difficultas, List<Transaction> txs) {
    List<Transaction> reditus = [];
    for (int i = 64; i >= difficultas; i--) {
      if (txs.any((tx) => tx.probationem.startsWith('0' * i))) {
        if (reditus.length < Constantes.txCaudice) {
          reditus.addAll(txs.where((tx) => tx.probationem.startsWith('0' * i) && !reditus.contains(tx)));
        } else {
          break;
        }
      }
    }
    return reditus;
  }
  bool validateProbationem() {
    if (probationem != HEX.encode(sha256.convert(utf8.encode(json.encode(interioreTransaction.toJson()))).bytes)) {
      return false;
    }
    return true;
  }
}
