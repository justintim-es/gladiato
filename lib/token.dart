import 'package:tuple/tuple.dart';
import 'package:nofifty/utils.dart';
import 'dart:io';
import 'package:nofifty/obstructionum.dart';
class IndiciumInput {

}

class IndiciumOutput {
  BigInt value;
  String publicKey;
  IndiciumOutput(this.value, this.publicKey);
}
class IndiciumTransaction {
  final List<IndiciumInput> indiciumInputs;
  final List<IndiciumOutput> indiciumOutputs;
  IndiciumTransaction(this.indiciumInputs, this.indiciumOutputs);
}


class Indicium {
    final String publicKey;
    final List<IndiciumTransaction> indiciumTransactions;
    Indicium.initialOwner(this.publicKey, BigInt supply, String owner):
      indiciumTransactions = List<IndiciumTransaction>.from([IndiciumTransaction([], List<IndiciumOutput>.from([IndiciumOutput(supply, owner)]))]);
}
class IndiciumOfficium {
  static Future<List<Tuple3<int, String, IndiciumOutput>>> inconsumptusOutputs(String publicKey, Directory directory) async {
     List<Tuple3<int, String, IndiciumOutput>> outputs = [];
     List<IndiciumInput> initibus = [];
     List<IndiciumTransaction> txs = [];
     for (int i = 0; i < directory.listSync().length; i++) {
        await for (var line in await Utils.fileAmnis(File(directory.path + '/caudices_' + i.toString() + '.txt'))) {
              txs.addAll(
              Obstructionum.fromJson(json.decode(line)).interioreObstructionum.liberTransactions :
        }
     }
     Iterable<List<TransactionInput>> initibuses = txs.map((tx) => tx.interioreTransaction.inputs);
     for (List<TransactionInput> init in initibuses) {
        initibus.addAll(init);
     }
     for(Transaction tx in txs.where((tx) => tx.interioreTransaction.outputs.any((e) => e.publicKey == publicKey))) {
       for (int t = 0; t < tx.interioreTransaction.outputs.length; t++) {
           outputs.add(Tuple3<int, String, TransactionOutput>(t, tx.interioreTransaction.id, tx.interioreTransaction.outputs[t]));
       }
     }
     outputs.removeWhere((output) => initibus.any((init) => init.transactionId == output.item2));
     return outputs;
  }
  static Future<InterioreTransaction> novamRem(bool liber, int zeros, String ex, BigInt value, String to, List<Transaction> txStagnum, Directory directory) async {
     PrivateKey privatusClavis = PrivateKey.fromHex(Pera.curve(), ex);
     List<Tuple3<int, String, TransactionOutput>> inOuts = await inconsumptusOutputs(liber, privatusClavis.publicKey.toHex(), directory);
     for (Transaction tx in txStagnum.where((t) => t.interioreTransaction.liber == liber)) {
        inOuts.removeWhere((element) => tx.interioreTransaction.inputs.any((ischin) => ischin.transactionId == element.item2));
        for (int i = 0; i < tx.interioreTransaction.outputs.length; i++) {
           inOuts.add(Tuple3<int, String, TransactionOutput>(i, tx.interioreTransaction.id, tx.interioreTransaction.outputs[i]));
        }
     }
     BigInt balance = BigInt.zero;
     for (Tuple3<int, String, TransactionOutput> inOut in inOuts) {
        balance += inOut.item3.nof;
     }
     if (balance < value) {
        throw ("Insufficient funds");
     }
     BigInt implere = value;
     List<TransactionInput> inputs = [];
     List<TransactionOutput> outputs = [];
     for (Tuple3<int, String, TransactionOutput> inOut in inOuts) {
        inputs.add(TransactionInput(inOut.item1, Utils.signum(privatusClavis, inOut.item3), inOut.item2));
        if (inOut.item3.nof < implere) {
           outputs.add(TransactionOutput(to, inOut.item3.nof));
           implere -= inOut.item3.nof;
        } else if (inOut.item3.nof > implere) {
           outputs.add(TransactionOutput(to, implere));
           outputs.add(TransactionOutput(privatusClavis.publicKey.toHex(), inOut.item3.nof - implere));
           break;
        } else {
           outputs.add(TransactionOutput(to, implere));
           break;
        }
     }
     return InterioreTransaction(liber, zeros, inputs, outputs, Utils.randomHex(32));
  }
}
