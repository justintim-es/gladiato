import 'package:nofifty/exampla.dart';
import 'package:nofifty/transaction_stagnum.dart';
import 'package:tuple/tuple.dart';
import 'package:nofifty/transaction.dart';
import 'package:nofifty/utils.dart';
import 'dart:io';
import 'package:nofifty/obstructionum.dart';
import 'dart:convert';
import 'package:ecdsa/ecdsa.dart';
import 'package:elliptic/elliptic.dart';
import 'package:nofifty/constantes.dart';
import 'package:nofifty/gladiator.dart';
class Pera {
   static EllipticCurve curve() => getP256();
   static Future<bool> isProbationum(String probationum, Directory directory) async {
      List<String> obs = [];
      for (int i = 0; i < directory.listSync().length; i++) {
         await for(String line in Utils.fileAmnis(File(directory.path + Constantes.fileNomen + i.toString() + '.txt'))) {
            obs.add(Obstructionum.fromJson(json.decode(line)).probationem);
         }
      }
      if (obs.contains(probationum)) return true;
      return false;
   }
   static Future<bool> isPublicaClavisDefended(String publicaClavis, Directory directory) async {
      for (int i = 0; i < directory.listSync().length; i++) {
         await for(String line in Utils.fileAmnis(File(directory.path + Constantes.fileNomen + i.toString() + '.txt'))) {
            GladiatorOutput output =
                Obstructionum.fromJson(json.decode(line))
                    .interioreObstructionum.gladiator.output ?? GladiatorOutput([]);
            if (output.rationem.where((e) => e.interioreRationem.publicaClavis.contains(publicaClavis)).isNotEmpty) {
               return false;
            }
         }
      }
      return true;
   }
   static Future<List<String>> maximeDefensiones(String gladiatorId, Directory directory) async {
      List<String> def = [];
      Map<String, BigInt> ours = Map();
      List<Map<String, BigInt>> others = [];
      List<Obstructionum> obss = [];
      for (int i = 0; i < directory.listSync().length; i++) {
         await for (String line in Utils.fileAmnis(File(directory.path + '/caudices_' + i.toString() + '.txt'))) {
            Obstructionum obs = Obstructionum.fromJson(json.decode(line));
            obss.add(obs);
            if (obs.interioreObstructionum.gladiator.id == gladiatorId) {
               ours = await defensiones(gladiatorId, directory);
            } else {
               others.add(await defensiones(obs.interioreObstructionum.gladiator.id, directory));
            }
         }
      }
      Map<String, bool> payedMore = Map();
      for(String key in ours.keys) {
        if(others.any((o) => o.keys.contains(key))) {
          for(Map<String, BigInt> other in others.where((e) => e.keys.contains(key))) {
            if((ours[key] ??= BigInt.zero) > (other[key] ??= BigInt.zero)) {
              payedMore[key] = true;
            }
          }
        } else {
          payedMore[key] = true;
        }
      }
      for(String key in payedMore.keys) {
        def.add(obss.singleWhere((obs) => obs.probationem == key).interioreObstructionum.defensio);
      }
      return def;
   }
   static Future<Map<String, BigInt>> defensiones(String gladiatorId, Directory directory) async {
      List<Obstructionum> obstructionums = [];
      for (int i = 0;  i < directory.listSync().length; i++) {
         await for (String line in Utils.fileAmnis(File(directory.path + '/caudices_' + i.toString() + '.txt'))) {
            obstructionums.add(Obstructionum.fromJson(json.decode(line)));

            // probationems.add(Obstructionum.fromJson(json.decode(line)).probationem);
            // Obstructionum.fromJson(json.decode(line)).interioreObstructionum.liberTransactions.map((e) => e.interioreTransaction.outputs.where((element) => element.publicKey));
         }
      }
      List<String> publicaClavises = [];
      List<String> probationums = [];
      for (Obstructionum obs in obstructionums) {
         probationums.add(obs.probationem);
         if(obs.interioreObstructionum.gladiator.id == gladiatorId) {
            publicaClavises.addAll(obs.interioreObstructionum.gladiator.output?.rationem.map((e) => e.interioreRationem.publicaClavis) ?? []);
         }
      }
      List<TransactionInput> toDerive = [];
      List<Transaction> txsWithOutput = [];
      for (Iterable<Transaction> obs in obstructionums
          .map((o) => o.interioreObstructionum.liberTransactions
          .where((e) => e.interioreTransaction.outputs.any((oschout) => probationums.contains(oschout.publicKey))))) {
         obs.map((e) => e.interioreTransaction.inputs).forEach(toDerive.addAll);
         txsWithOutput.addAll(obs);
      }
      List<String> transactionIds = toDerive.map((to) => to.transactionId).toList();
      List<TransactionOutput> outputs = [];
      for (Iterable<Transaction> obs in obstructionums.map((o) => o.interioreObstructionum.liberTransactions).toList()) {
         obs.where((e) => transactionIds.contains(e.interioreTransaction.id)).map((tx) => tx.interioreTransaction.outputs).forEach(outputs.addAll);
      }
      Map<String, BigInt> maschap = Map();
      for (TransactionOutput oschout in outputs.where((oschout) => publicaClavises.contains(oschout.publicKey))) {
         for(Transaction tx in txsWithOutput) {
            for (TransactionInput ischin in tx.interioreTransaction.inputs) {
               if (Utils.cognoscere(PublicKey.fromHex(Pera.curve(), oschout.publicKey), Signature.fromASN1Hex(ischin.signature), oschout)) {
                  for (TransactionOutput oschoutoschout in tx.interioreTransaction.outputs.where((element) => probationums.contains(element.publicKey))) {
                    BigInt prevValue = maschap[oschoutoschout.publicKey] ?? BigInt.zero;
                    maschap[oschoutoschout.publicKey] = prevValue + oschoutoschout.nof;
                  }
               }
            }
         }
      }
      return maschap;
   }
   //left off
   static Future<Tuple2<InterioreTransaction, InterioreTransaction>> transformFixum(String privatus, Directory directory) async {
        String publica = PrivateKey.fromHex(Pera.curve(), privatus).publicKey.toHex();
        List<Tuple3<int, String, TransactionOutput>> outs = await inconsumptusOutputs(true, publica, directory);
        List<TransactionOutput> outputs = [];
        List<TransactionInput> inputs = [];
        for(Tuple3<int, String, TransactionOutput> out in outs) {
          outputs.add(TransactionOutput(publica, out.item3.nof));
          inputs.add(TransactionInput(out.item1, Utils.signum(PrivateKey.fromHex(Pera.curve(), privatus), out.item3), out.item2));
        }
        return Tuple2<InterioreTransaction, InterioreTransaction>(InterioreTransaction(true, 0, inputs, [], Utils.randomHex(32)), InterioreTransaction(false, 0, [], outputs, Utils.randomHex(32)));
   }
   static Future<List<Tuple3<int, String, TransactionOutput>>> inconsumptusOutputs(bool liber, String publicKey, Directory directory) async {
      List<Tuple3<int, String, TransactionOutput>> outputs = [];
      List<TransactionInput> initibus = [];
      List<Transaction> txs = [];
      for (int i = 0; i < directory.listSync().length; i++) {
         await for (var line in await Utils.fileAmnis(File(directory.path + '/caudices_' + i.toString() + '.txt'))) {
               txs.addAll(
               liber ?
               Obstructionum.fromJson(json.decode(line)).interioreObstructionum.liberTransactions :
               Obstructionum.fromJson(json.decode(line)).interioreObstructionum.fixumTransactions);
         }
      }
      Iterable<List<TransactionInput>> initibuses = txs.map((tx) => tx.interioreTransaction.inputs);
      for (List<TransactionInput> init in initibuses) {
         initibus.addAll(init);
      }
      for(Transaction tx in txs.where((tx) => tx.interioreTransaction.outputs.any((e) => e.publicKey == publicKey))) {
        for (int t = 0; t < tx.interioreTransaction.outputs.length; t++) {
            if(tx.interioreTransaction.outputs[t].publicKey == publicKey) {
              outputs.add(Tuple3<int, String, TransactionOutput>(t, tx.interioreTransaction.id, tx.interioreTransaction.outputs[t]));
            }
        }
      }
      outputs.removeWhere((output) => initibus.any((init) => init.transactionId == output.item2));
      return outputs;
   }
   static Future<BigInt> statera(bool liber, String publicKey, Directory directory) async {
     List<Tuple3<int, String, TransactionOutput>> outputs = await inconsumptusOutputs(liber, publicKey, directory);
     BigInt balance = BigInt.zero;
     for (Tuple3<int, String, TransactionOutput> inOut in outputs) {
        balance += inOut.item3.nof;
     }
     return balance;
   }
   static Future<InterioreTransaction> ardeat(PrivateKey privatus, String publica, String probationum, BigInt value, Directory directory) async {
     List<Tuple3<int, String, TransactionOutput>> outs = await inconsumptusOutputs(true, publica, directory);
     return calculateTransaction(true, 0, privatus, probationum, value, outs);
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
      return calculateTransaction(liber, zeros, privatusClavis, to, value, inOuts);

   }
   static InterioreTransaction calculateTransaction(bool liber, int zeros, PrivateKey privatus, String to, BigInt value, List<Tuple3<int, String, TransactionOutput>> outs) {
     BigInt balance = BigInt.zero;
     for (Tuple3<int, String, TransactionOutput> inOut in outs) {
        balance += inOut.item3.nof;
     }
     if (balance < value) {
        throw ("Insufficient funds");
     }
     BigInt implere = value;
     List<TransactionInput> inputs = [];
     List<TransactionOutput> outputs = [];
     for (Tuple3<int, String, TransactionOutput> inOut in outs) {
        inputs.add(TransactionInput(inOut.item1, Utils.signum(privatus, inOut.item3), inOut.item2));
        if (inOut.item3.nof < implere) {
           outputs.add(TransactionOutput(to, inOut.item3.nof));
           implere -= inOut.item3.nof;
        } else if (inOut.item3.nof > implere) {
           outputs.add(TransactionOutput(to, implere));
           outputs.add(TransactionOutput(privatus.publicKey.toHex(), inOut.item3.nof - implere));
           break;
        } else {
           outputs.add(TransactionOutput(to, implere));
           break;
        }
     }
     return InterioreTransaction(liber, zeros, inputs, outputs, Utils.randomHex(32));
   }

}
