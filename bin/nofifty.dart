import 'dart:io';
import 'package:args/args.dart';
import 'package:nofifty/obstructionum.dart';
import 'package:nofifty/gladiator.dart';
import 'package:nofifty/transaction.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'dart:isolate';
import 'package:nofifty/utils.dart';
import 'dart:convert';
import 'package:nofifty/exampla.dart';
import 'package:nofifty/constantes.dart';
import 'package:nofifty/pera.dart';
import 'package:test/expect.dart';
import 'package:ecdsa/ecdsa.dart';
import 'package:elliptic/elliptic.dart';
import 'package:tuple/tuple.dart';
import 'package:nofifty/p2p.dart';
void main(List<String> arguments) async {
    var parser = ArgParser();
    parser.addOption('publica-clavis');
    parser.addOption('bootnode');
    parser.addOption('p2p-portus', defaultsTo: '5151');
    parser.addOption('rpc-portus', defaultsTo: '1515');
    parser.addOption('internum-ip', mandatory: true);
    parser.addOption('external-ip', mandatory: true);
    parser.addOption('novus', help: 'Do you want to start a new chain?', mandatory: true);
    parser.addOption('directory', help: 'where should we save the blocks', mandatory: true);
    ReceivePort receivePort = ReceivePort();
    var aschargs = parser.parse(arguments);
    final publicaClavis = aschargs['publica-clavis'];
    final String? bootnode = aschargs['bootnode'];
    final String isNew = aschargs['novus'];
    final directory = aschargs['directory'];
    final rpcPortus = aschargs['rpc-portus'];
    final p2pPortus = aschargs['p2p-portus'];
    final internum_ip = aschargs['internum-ip'];
    final externalIp = aschargs['external-ip'];
    if(publicaClavis == null) {
        KeyPair kp = KeyPair();
        print('Quaeso te condite privatis ac publicis clavis');
        print('privatis clavis: ${kp.private}');
        print('publica clavis: ${kp.public}');
        exit(0);
    }
    Directory principalisDirectory = await Directory(directory).create( recursive: true );
    if(isNew == 'true' && principalisDirectory.listSync().isEmpty) {
      final obstructionum = Obstructionum.incipio(InterioreObstructionum.incipio(producentis: publicaClavis));
      await obstructionum.salvareIncipio(principalisDirectory);
    }
    List<int> highestBlock = [];
    File highest = File('${principalisDirectory.path}/caudices_${principalisDirectory.listSync().length-1}.txt');
    for(int i = 0; i < principalisDirectory.listSync().length; i++) {
      if (i == principalisDirectory.listSync().length-1) {
        highestBlock.add(highest.lengthSync());
      } else {
        highestBlock.add(Constantes.maximeCaudicesFile);
      }
    }
    print(p2pPortus);
    P2P p2p = P2P(2, principalisDirectory);
    p2p.listen(internum_ip, int.parse(p2pPortus));
    if(bootnode != null) {
      p2p.connect(bootnode, '$externalIp:$p2pPortus');
    }
    var app = Router();
    app.post('/obstructionum', (Request request) async {
        final ObstructionumNumerus obstructionumNumerus = ObstructionumNumerus.fromJson(json.decode(await request.readAsString()));
        File file = File(principalisDirectory.path + '/caudices_' + (obstructionumNumerus.numerus.length-1).toString() + '.txt');
        return Response.ok(await Utils.fileAmnis(file).elementAt(obstructionumNumerus.numerus[obstructionumNumerus.numerus.length-1]));
    });
    Map<String, Isolate> propterIsolates = Map();
    app.post('/submittere-rationem', (Request request) async {
        final SubmittereRationem submittereRationem = SubmittereRationem.fromJson(json.decode(await request.readAsString()));
        if(!await Pera.isPublicaClavisDefended(submittereRationem.publicaClavis, principalisDirectory)) {
            return Response.forbidden(json.encode({
                "message": "Publica clavis iam defendi"
            }));
        }
        ReceivePort acciperePortus = ReceivePort();
        InterioreRationem interioreRationem = InterioreRationem(submittereRationem.publicaClavis, BigInt.zero);
        propterIsolates[interioreRationem.id] = await Isolate.spawn(Propter.quaestum, List<dynamic>.from([interioreRationem, acciperePortus.sendPort]));
        acciperePortus.listen((propter) {
            p2p.syncPropter(propter);
        });
        return Response.ok("");
    });
    app.get('/rationem-stagnum', (Request request) async {
      return Response.ok(json.encode(p2p.propters));
    });
    Map<String, Isolate> liberTxIsolates = Map();
    app.post('/submittere-libre-transaction', (Request request) async {
        final SubmittereTransaction unCalcTx = SubmittereTransaction.fromJson(json.decode(await request.readAsString()));
        if (await Pera.isPublicaClavisDefended(unCalcTx.to, principalisDirectory) && !await Pera.isProbationum(unCalcTx.to, principalisDirectory)) {
            return Response.forbidden(json.encode({
                "message": "accipientis non defenditur"
            }));
        }
        final InterioreTransaction tx = await Pera.novamRem(true, 0, unCalcTx.from, unCalcTx.nof, unCalcTx.to, p2p.liberTxs, principalisDirectory);
        ReceivePort acciperePortus = ReceivePort();
        liberTxIsolates[tx.id] = await Isolate.spawn(Transaction.quaestum, List<dynamic>.from([tx, acciperePortus.sendPort]));
        acciperePortus.listen((transaction) {
            p2p.syncLiberTx(transaction);
        });
        return Response.ok("");
    });
    Map<String, Isolate> fixumTxIsolates = Map();
    app.post('/submittere-fixum-transaction', (Request request) async {
      final SubmittereTransaction unCalcTx = SubmittereTransaction.fromJson(json.decode(await request.readAsString()));
      final InterioreTransaction tx = await Pera.novamRem(false, 0, unCalcTx.from, unCalcTx.nof, unCalcTx.to, p2p.fixumTxs, principalisDirectory);
      ReceivePort acciperePortus = ReceivePort();
      fixumTxIsolates[tx.id] = await Isolate.spawn(Transaction.quaestum, List<dynamic>.from([tx, acciperePortus.sendPort]));
      acciperePortus.listen((transaction) {
          p2p.syncFixumTx(transaction);
      });
      return Response.ok("");
    });
    app.get('/peers', (Request request) async {
      return Response.ok(json.encode(p2p.sockets));
    });
    app.get('/libre-transaction-stagnum', (Request request) async {
       return Response.ok(json.encode(p2p.liberTxs.map((e) => e.toJson()).toList()));
    });
    app.get('/defensiones/<gladiatorId>', (Request request, String gladiatorId) async {
        List<String> def = await Pera.maximeDefensiones(gladiatorId, principalisDirectory);
        return Response.ok(json.encode(def));
    });
    app.get('/liber-statera/<publica>', (Request request, String publica) async {
      BigInt balance = await Pera.statera(true, publica, principalisDirectory);
      return Response.ok(json.encode({
        "balance": balance.toString()
      }));
    });
    app.post('/mine-efectus', (Request request) async {
        Obstructionum priorObstructionum = await Utils.priorObstructionum(principalisDirectory);
        ReceivePort acciperePortus = ReceivePort();

        List<Propter> propters = [];
        for (int i = 64; i > 0; i--) {
          if (p2p.propters.any((r) => r.probationem.startsWith('0' * i))) {
            if (propters.length < Constantes.perRationesObstructionum) {
              propters.addAll(p2p.propters.where((r) => r.probationem.startsWith('0' * i)));
            } else {
              break;
            }
          }
        }
        List<Transaction> liberTxs = [];
        liberTxs.add(Transaction(Constantes.txObstructionumPraemium, InterioreTransaction(true, 0, [], [TransactionOutput(publicaClavis, Constantes.obstructionumPraemium)], Utils.randomHex(32))));
        print('${liberTxs.map((x) => x.toJson())}\n');
        liberTxs.addAll(Transaction.grab(priorObstructionum.interioreObstructionum.liberDifficultas, p2p.liberTxs));
        print('${liberTxs.map((x) => x.toJson())}\n');
        List<Transaction> fixumTxs = [];
        fixumTxs.addAll(Transaction.grab(priorObstructionum.interioreObstructionum.fixumDifficultas, p2p.fixumTxs));
        final obstructionumDifficultas = await Obstructionum.utDifficultas(principalisDirectory);
        InterioreObstructionum interiore = InterioreObstructionum.efectus(
            obstructionumDifficultas: obstructionumDifficultas,
            forumCap: await Obstructionum.accipereForumCap(principalisDirectory),
            propterDifficultas: Obstructionum.acciperePropterDifficultas(priorObstructionum),
            liberDifficultas: Obstructionum.accipereLiberDifficultas(priorObstructionum),
            fixumDifficultas: Obstructionum.accipereFixumDifficultas(priorObstructionum),
            summaObstructionumDifficultas: await Obstructionum.utSummaDifficultas(principalisDirectory) + BigInt.parse(obstructionumDifficultas.toString()),
            obstructionumNumerus: await Obstructionum.utObstructionumNumerus(principalisDirectory),
            producentis: publicaClavis,
            priorProbationem: priorObstructionum.probationem,
            gladiator: Gladiator(null, GladiatorOutput(propters), Utils.randomHex(32)),
            liberTransactions: liberTxs,
            fixumTransactions: fixumTxs
        );
        await Isolate.spawn(Obstructionum.efectus, List<dynamic>.from([interiore, acciperePortus.sendPort]));
        acciperePortus.listen((nuntius) async {
            Obstructionum obstructionum = nuntius;
            obstructionum.interioreObstructionum.gladiator.output?.rationem.map((r) => r.interioreRationem.id).forEach((id) => propterIsolates[id]?.kill());
            obstructionum.interioreObstructionum.liberTransactions.map((e) => e.interioreTransaction.id).forEach((id) => liberTxIsolates[id]?.kill());
            obstructionum.interioreObstructionum.fixumTransactions.map((e) => e.interioreTransaction.id).forEach((id) => fixumTxIsolates[id]?.kill());
            p2p.removePropters(obstructionum.interioreObstructionum.gladiator.output?.rationem.map((r) => r.interioreRationem.id).toList() ?? []);
            p2p.removeLiberTxs(obstructionum.interioreObstructionum.liberTransactions.map((l) => l.interioreTransaction.id).toList());
            p2p.removeFixumTxs(obstructionum.interioreObstructionum.fixumTransactions.map((f) => f.interioreTransaction.id).toList());
            p2p.syncBlock(obstructionum);
            await obstructionum.salvare(principalisDirectory);
        });
        return Response.ok("");
    });
    app.post('/mine-confussus', (Request request) async {
      Confussus conf = Confussus.fromJson(json.decode(await request.readAsString()));
      Obstructionum priorObstructionum = await Utils.priorObstructionum(principalisDirectory);
      Gladiator gladiatorToAttack = await Obstructionum.grabGladiator(conf.gladiatorId, principalisDirectory);
      List<Transaction> liberTxs = p2p.liberTxs;
      for (String acc in gladiatorToAttack.output!.rationem.map((e) => e.interioreRationem.publicaClavis)) {
        final balance = await Pera.statera(true, acc, principalisDirectory);
        if (balance > BigInt.zero) {
          liberTxs.add(Transaction.burn(await Pera.ardeat(PrivateKey.fromHex(Pera.curve(), conf.privateKey), acc, priorObstructionum.probationem, balance, principalisDirectory)));
        }
      }
      Tuple2<InterioreTransaction, InterioreTransaction> transform = await Pera.transformFixum(conf.privateKey, principalisDirectory);
      liberTxs.add(Transaction(Constantes.transform, transform.item1));
      List<Transaction> fixumTxs = p2p.fixumTxs;
      fixumTxs.add(Transaction(Constantes.transform, transform.item2));
      for (int i = 64; i > 0; i--) {

      }
      String toCrack = gladiatorToAttack.output!.defensio;
      for (String def in await Pera.maximeDefensiones(gladiatorToAttack.id, principalisDirectory)) {
        toCrack += def;
      }
      InterioreObstructionum interiore = InterioreObstructionum.confussus(
        obstructionumDifficultas: await Obstructionum.utDifficultas(principalisDirectory),
        forumCap: await Obstructionum.accipereForumCap(principalisDirectory),
        summaObstructionumDifficultas: await Obstructionum.utSummaDifficultas(principalisDirectory),
        obstructionumNumerus: await Obstructionum.utObstructionumNumerus(principalisDirectory),
        propterDifficultas: Obstructionum.acciperePropterDifficultas(priorObstructionum),
        liberDifficultas: Obstructionum.accipereLiberDifficultas(priorObstructionum),
        fixumDifficultas: Obstructionum.accipereFixumDifficultas(priorObstructionum),
        producentis: publicaClavis,
        priorProbationem: priorObstructionum.probationem,
        gladiator: Gladiator(GladiatorInput(Utils.signum(PrivateKey.fromHex(Pera.curve(), conf.privateKey), gladiatorToAttack), conf.gladiatorId), null, Utils.randomHex(32)),
        liberTransactions: liberTxs,
        fixumTransactions: fixumTxs
      );
      ReceivePort acciperePortus = ReceivePort();
      await Isolate.spawn(Obstructionum.confussus, List<dynamic>.from([interiore, toCrack, acciperePortus.sendPort]));
      GladiatorOutput go = interiore.gladiator.output ?? GladiatorOutput([]);
      acciperePortus.listen((nuntius) async {
          Obstructionum obstructionum = nuntius;
          obstructionum.interioreObstructionum.gladiator.output?.rationem.map((r) => r.interioreRationem.id).forEach((id) => propterIsolates[id]?.kill());
          obstructionum.interioreObstructionum.liberTransactions.map((e) => e.interioreTransaction.id).forEach((id) => liberTxIsolates[id]?.kill());
          obstructionum.interioreObstructionum.fixumTransactions.map((e) => e.interioreTransaction.id).forEach((id) => fixumTxIsolates[id]?.kill());
          p2p.removePropters(obstructionum.interioreObstructionum.gladiator.output?.rationem.map((r) => r.interioreRationem.id).toList() ?? []);
          p2p.removeLiberTxs(obstructionum.interioreObstructionum.liberTransactions.map((l) => l.interioreTransaction.id).toList());
          p2p.removeFixumTxs(obstructionum.interioreObstructionum.fixumTransactions.map((f) => f.interioreTransaction.id).toList());
          p2p.syncBlock(obstructionum);
          await obstructionum.salvare(principalisDirectory);
      });
      return Response.ok("");
    });
    var server = await io.serve(app, internum_ip, int.parse(rpcPortus));
}
