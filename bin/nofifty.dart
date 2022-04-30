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
import 'package:nofifty/errors.dart';
import 'package:nofifty/ws.dart';
import 'package:collection/collection.dart';
void main(List<String> arguments) async {
    var parser = ArgParser();
    parser.addOption('publica-clavis');
    parser.addOption('bootnode');
    parser.addOption('max-pares', defaultsTo: '50');
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
    final maxPares = aschargs['max-pares'];
    if(publicaClavis == null) {
        KeyPair kp = KeyPair();
        print('Quaeso te condite privatis ac publicis clavis');
        print('privatis clavis: ${kp.private}');
        print('publica clavis: ${kp.public}');
        exit(0);
    }
    Directory principalisDirectory = await Directory(directory).create( recursive: true );
    print(principalisDirectory.listSync().length);
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
    ReceivePort rp = ReceivePort();
    P2P p2p = P2P(int.parse(maxPares), principalisDirectory, rp.sendPort, [0]);
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
                "message": "Publica clavis iam defendi",
                "english": "Public key is already defended"
            }));
        }
        for (Propter prop in p2p.propters) {
          if (prop.interioreRationem.publicaClavis == submittereRationem.publicaClavis) {
            return Response.forbidden(json.encode({
                "message": "publica clavem iam in piscinam",
                "english": "Public key is already in pool"
            }));
          }
        }
        ReceivePort acciperePortus = ReceivePort();
        InterioreRationem interioreRationem = InterioreRationem(submittereRationem.publicaClavis, BigInt.zero);
        propterIsolates[interioreRationem.id] = await Isolate.spawn(Propter.quaestum, List<dynamic>.from([interioreRationem, acciperePortus.sendPort]));
        acciperePortus.listen((propter) {
            print('listentriggeredrationem');
            p2p.syncPropter(propter);
        });
        return Response.ok(json.encode({
          "propterIdentitatis": interioreRationem.id
        }));
    });
    app.get('/rationem/<identitatis>', (Request request, String identitatis) async {
      List<Obstructionum> obs = [];
      for (int i = 0; i < principalisDirectory.listSync().length; i++) {
        await for (String obstructionum in Utils.fileAmnis(File('${principalisDirectory.path}${Constantes.fileNomen}$i.txt'))) {
          obs.add(Obstructionum.fromJson(json.decode(obstructionum)));
        }
      }
      for (InterioreObstructionum interiore in obs.map((o) => o.interioreObstructionum)) {
        for (Propter propter in interiore.gladiator.output?.rationem ?? []) {
          if (propter.interioreRationem.id == identitatis) {
            PropterInfo propterInfo = PropterInfo(true, interiore.indicatione, interiore.obstructionumNumerus, interiore.gladiator.output!.defensio);
            return Response.ok(json.encode({
                "data": propterInfo.toJson(),
                "scriptum": interiore.gladiator.toJson(),
                "gladiatorId": interiore.gladiator.id
            }));
          }
        }
      }
      for (Propter propter in p2p.propters) {
        if (propter.interioreRationem.id == identitatis) {
          PropterInfo propterInfo = PropterInfo(false, null, null, null);
          return Response.ok(json.encode({
            "data": propterInfo.toJson(),
            "scriptum": propter.toJson()
          }));
        }
      }
      return Response.notFound(json.encode({
        "code": 0,
        "message": "Propter not found"
      }));
    });
    app.get('/novus-propter', (Request request) {
        KeyPair kp = KeyPair();
        return Response.ok(json.encode({
          "publicaClavis": kp.public,
          "privatusClavis": kp.private
        }));
    });
    app.get('/defenditur/<publica>', (Request request, String publica) async {
        if (!await Pera.isPublicaClavisDefended(publica, principalisDirectory)) {
          return Response.ok(json.encode({
            "defenditur": true,
            "message": "publica clavis defenditur"
          }));
        } else {
          return Response.ok(json.encode({
            "defenditur": false,
             "message": "publica clavis non defenditur"
          }));
        }
    });
    app.get('/rationem-stagnum', (Request request) async {
      return Response.ok(json.encode(p2p.propters));
    });
    Map<String, Isolate> liberTxIsolates = Map();
    app.post('/submittere-liber-transaction', (Request request) async {
        try {
          final SubmittereTransaction unCalcTx = SubmittereTransaction.fromJson(json.decode(await request.readAsString()));
          PrivateKey pk = PrivateKey.fromHex(Pera.curve(), unCalcTx.from);
          if (pk.publicKey.toHex() == unCalcTx.to) {
            return Response.forbidden(json.encode(Error(code: 2, message: "potest mittere pecuniam publicam clavem", english: "can not send money to the same public key" ).toJson()));
          }
          if (await Pera.isPublicaClavisDefended(unCalcTx.to, principalisDirectory) && !await Pera.isProbationum(unCalcTx.to, principalisDirectory)) {
              return Response.forbidden(json.encode(Error(
                  code: 0,
                  message: "accipientis non defenditur",
                   english: "public key is not defended"
              ).toJson()));
          }
          final InterioreTransaction tx =
          await Pera.novamRem(true, 0, unCalcTx.from, unCalcTx.gla, unCalcTx.to, p2p.liberTxs, principalisDirectory);
          ReceivePort acciperePortus = ReceivePort();
          liberTxIsolates[tx.id] = await Isolate.spawn(Transaction.quaestum, List<dynamic>.from([tx, acciperePortus.sendPort]));
          acciperePortus.listen((transaction) {
              p2p.syncLiberTx(transaction);
          });
          return Response.ok(json.encode({
            "transactionIdentitatis": tx.id
          }));
        } on Error catch (err) {
          return Response.forbidden(json.encode(err.toJson()));
        }
    });
    Map<String, Isolate> fixumTxIsolates = Map();
    app.post('/submittere-fixum-transaction', (Request request) async {
      final SubmittereTransaction unCalcTx = SubmittereTransaction.fromJson(json.decode(await request.readAsString()));
      PrivateKey pk = PrivateKey.fromHex(Pera.curve(), unCalcTx.from);
      if (pk.publicKey.toHex() == unCalcTx.to) {
        return Response.ok(json.encode({
          "message": "potest mittere pecuniam publicam clavem",
          "english": "can not send money to the same public key"
        }));
      }
      final InterioreTransaction tx = await Pera.novamRem(false, 0, unCalcTx.from, unCalcTx.gla, unCalcTx.to, p2p.fixumTxs, principalisDirectory);
      ReceivePort acciperePortus = ReceivePort();
      fixumTxIsolates[tx.id] = await Isolate.spawn(Transaction.quaestum, List<dynamic>.from([tx, acciperePortus.sendPort]));
      acciperePortus.listen((transaction) {
          p2p.syncFixumTx(transaction);
      });
      return Response.ok("");
    });
    app.get('/transaction/<identitatis>', (Request request, String identitatis) async {
        List<Obstructionum> obs = [];
        for (int i = 0; i < principalisDirectory.listSync().length; i++) {
          await for (String obstructionum in Utils.fileAmnis(File('${principalisDirectory.path}${Constantes.fileNomen}$i.txt'))) {
            obs.add(Obstructionum.fromJson(json.decode(obstructionum)));
          }
        }
        for (InterioreObstructionum interiore in obs.map((o) => o.interioreObstructionum)) {
          for (Transaction tx in interiore.liberTransactions) {
            if (tx.interioreTransaction.id == identitatis) {
              TransactionInfo txInfo = TransactionInfo(true, interiore.indicatione, interiore.obstructionumNumerus);
              return Response.ok(json.encode({
                  "data": txInfo.toJson(),
                  "scriptum": tx.toJson()
              }));
            }
          }
          for (Transaction tx in interiore.fixumTransactions) {
            if (tx.interioreTransaction.id == identitatis) {
              TransactionInfo txInfo = TransactionInfo(false, interiore.indicatione, interiore.obstructionumNumerus);
              return Response.ok(json.encode({
                "data": txInfo.toJson(),
                "scriptum": tx.toJson()
              }));
            }
          }
        }
        for (Transaction tx in p2p.liberTxs) {
          if (tx.interioreTransaction.id == identitatis) {
            TransactionInfo txInfo = TransactionInfo(false, null, null);
            return Response.ok(json.encode({
              "data": txInfo.toJson(),
              "scriptum": tx.toJson()
            }));
          }
        }
        for (Transaction tx in p2p.fixumTxs) {
          if (tx.interioreTransaction.id == identitatis) {
            TransactionInfo txInfo = TransactionInfo(false, null, null);
            return Response.ok(json.encode({
              "data": txInfo.toJson(),
              "scriptum": tx.toJson()
            }));
          }
        }
        return Response.notFound(json.encode({
          "code": 0,
          "message": "Transaction not found"
        }));
    });
    app.get('/peers', (Request request) async {
      return Response.ok(json.encode(p2p.sockets));
    });
    app.get('/liber-transaction-stagnum', (Request request) async {
       return Response.ok(json.encode(p2p.liberTxs.map((e) => e.toJson()).toList()));
    });
    app.get('/defensiones/<gladiatorId>', (Request request, String gladiatorId) async {
        List<Defensio> def = await Pera.maximeDefensiones(gladiatorId, principalisDirectory);
        return Response.ok(json.encode(def.map((x) => x.toJson()).toList()));
    });
    app.get('/your-bid-defensio/<probationem>/<gladiatorId>', (Request request, String probationem, String gladiatorId) async {
        final yourBid = await Pera.yourBid(probationem, gladiatorId, principalisDirectory);
        return Response.ok(json.encode({
          "defensio": await Pera.basisDefensione(probationem, principalisDirectory),
          "yourBid": yourBid.toString(),
          "probationem": probationem
        }));
    });
    app.get('/summa-bid-defensio/<probationem>', (Request request, String probationem) async {
      try {
        BigInt summaBid = await Pera.summaBid(probationem, principalisDirectory);
        return Response.ok(json.encode({
          "defensio": await Pera.basisDefensione(probationem, principalisDirectory),
          "summaBid": summaBid.toString(),
          "probationem": probationem
        }));
      } on Error catch (err) {
        return Response.forbidden(json.encode(err.toJson()));
      }
    });
    app.get('/liber-statera/<publica>', (Request request, String publica) async {
      BigInt statera = await Pera.statera(true, publica, principalisDirectory);
      return Response.ok(json.encode({
        "statera": statera.toString()
      }));
    });
    app.get('/fixum-statera/<publica>', (Request request, String publica) async {
      BigInt statera = await Pera.statera(false, publica, principalisDirectory);
      return Response.ok(json.encode({
        "statera": statera.toString()
      }));
    });
    List<Isolate> efectusThreads = [];
    app.post('/mine-efectus', (Request request) async {
        if (!File('${principalisDirectory.path}/${Constantes.fileNomen}0.txt').existsSync()) {
          return Response.ok(json.encode({
              "message": "Still waiting on incipio block"
          }));
        }
        Obstructionum priorObstructionum = await Utils.priorObstructionum(principalisDirectory);
        ReceivePort acciperePortus = ReceivePort();
        List<Propter> propters = [];
        propters.addAll(Gladiator.grab(priorObstructionum.interioreObstructionum.propterDifficultas, p2p.propters));
        List<Transaction> liberTxs = [];
        liberTxs.add(Transaction(Constantes.txObstructionumPraemium, InterioreTransaction(true, [], [TransactionOutput(publicaClavis, Constantes.obstructionumPraemium)], Utils.randomHex(32))));
        print('${liberTxs.map((x) => x.toJson())}\n');
        liberTxs.addAll(Transaction.grab(priorObstructionum.interioreObstructionum.liberDifficultas, p2p.liberTxs));
        print('${liberTxs.map((x) => x.toJson())}\n');
        List<Transaction> fixumTxs = [];
        fixumTxs.addAll(Transaction.grab(priorObstructionum.interioreObstructionum.fixumDifficultas, p2p.fixumTxs));
        final obstructionumDifficultas = await Obstructionum.utDifficultas(principalisDirectory);
        // rp.listen((data) async {
        //   Obstructionum priorObstructionum = await Utils.priorObstructionum(principalisDirectory);
        //   List<Propter> propters = [];
        //   propters.addAll(Gladiator.grab(priorObstructionum.interioreObstructionum.propterDifficultas, p2p.propters));
        //   List<Transaction> liberTxs = [];
        //   liberTxs.add(Transaction(Constantes.txObstructionumPraemium, InterioreTransaction(true, 0, [], [TransactionOutput(publicaClavis, Constantes.obstructionumPraemium)], Utils.randomHex(32))));
        //   print('${liberTxs.map((x) => x.toJson())}\n');
        //   liberTxs.addAll(Transaction.grab(priorObstructionum.interioreObstructionum.liberDifficultas, p2p.liberTxs));
        //   print('${liberTxs.map((x) => x.toJson())}\n');
        //   List<Transaction> fixumTxs = [];
        //   fixumTxs.addAll(Transaction.grab(priorObstructionum.interioreObstructionum.fixumDifficultas, p2p.fixumTxs));
        //   final obstructionumDifficultas = await Obstructionum.utDifficultas(principalisDirectory);
        //   List<Isolate> newThreads = [];
        //   int idx = 0;
        //     for (Isolate thread in efectusThreads) {
        //       thread.kill();
        //       efectusThreads.remove(thread);
        //       InterioreObstructionum interiore = InterioreObstructionum.efectus(
        //           obstructionumDifficultas: obstructionumDifficultas,
        //           forumCap: await Obstructionum.accipereForumCap(principalisDirectory),
        //           propterDifficultas: Obstructionum.acciperePropterDifficultas(priorObstructionum),
        //           liberDifficultas: Obstructionum.accipereLiberDifficultas(priorObstructionum),
        //           fixumDifficultas: Obstructionum.accipereFixumDifficultas(priorObstructionum),
        //           summaObstructionumDifficultas: await Obstructionum.utSummaDifficultas(principalisDirectory) + BigInt.parse(obstructionumDifficultas.toString()),
        //           obstructionumNumerus: await Obstructionum.utObstructionumNumerus(principalisDirectory),
        //           producentis: publicaClavis,
        //           priorProbationem: priorObstructionum.probationem,
        //           gladiator: Gladiator(null, GladiatorOutput(propters), Utils.randomHex(32)),
        //           liberTransactions: liberTxs,
        //           fixumTransactions: fixumTxs
        //       );
        //       newThreads.add(await Isolate.spawn(Obstructionum.efectus, List<dynamic>.from([interiore, acciperePortus.sendPort])));
        //       if(idx == efectusThreads.length) {
        //         newThreads.forEach(efectusThreads.add);
        //       }
        //       idx++;
        //     }
        // });
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
        efectusThreads.add(await Isolate.spawn(Obstructionum.efectus, List<dynamic>.from([interiore, acciperePortus.sendPort])));
        acciperePortus.listen((nuntius) async {
            Obstructionum obstructionum = nuntius;
            obstructionum.interioreObstructionum.gladiator.output?.rationem.map((r) => r.interioreRationem.id).forEach((id) => propterIsolates[id]?.kill(priority: Isolate.immediate));
            obstructionum.interioreObstructionum.liberTransactions.map((e) => e.interioreTransaction.id).forEach((id) => liberTxIsolates[id]?.kill(priority: Isolate.immediate));
            obstructionum.interioreObstructionum.fixumTransactions.map((e) => e.interioreTransaction.id).forEach((id) => fixumTxIsolates[id]?.kill(priority: Isolate.immediate));
            p2p.removePropters(obstructionum.interioreObstructionum.gladiator.output?.rationem.map((r) => r.interioreRationem.id).toList() ?? []);
            p2p.removeLiberTxs(obstructionum.interioreObstructionum.liberTransactions.map((l) => l.interioreTransaction.id).toList());
            p2p.removeFixumTxs(obstructionum.interioreObstructionum.fixumTransactions.map((f) => f.interioreTransaction.id).toList());
            p2p.syncBlock(obstructionum);
            await obstructionum.salvare(principalisDirectory);
            // rp.sendPort.send("update miner");
        });
        return Response.ok("");
    });
    app.post('/probationems', (Request request) async {
      final Probationems prop = Probationems.fromJson(json.decode(await request.readAsString()));
      List<Obstructionum> obs = await Utils.getObstructionums(principalisDirectory);
      int start = 0;
      int end = 0;
      for (int i = 0; i < obs.length; i++) {
        if (ListEquality().equals(obs[i].interioreObstructionum.obstructionumNumerus, prop.firstIndex)) {
          start = i;
        }
        if (ListEquality().equals(obs[i].interioreObstructionum.obstructionumNumerus, prop.lastIndex)) {
          end = i;
        }
      }
      return Response.ok(json.encode(obs.map((o) => o.probationem).toList().getRange(start, end).toList()));
    });
    app.get('/obstructionum-numerus', (Request request) async {
        final Obstructionum obs = await Utils.priorObstructionum(principalisDirectory);
        return Response.ok(json.encode({
          "numerus": obs.interioreObstructionum.obstructionumNumerus
        }));
    });
    app.get('/efectus-miner-threads', (Request request) async {
        return Response.ok(json.encode({
          'threads': efectusThreads.length
        }));
    });
    app.delete('/stop-efectus-miner', (Request request) async {
      efectusThreads = [];
      rp.close();
      return Response.ok(json.encode({
        'message': 'Succesfully stopped efectus miner'
      }));
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
      List<Defensio> deschef = await Pera.maximeDefensiones(gladiatorToAttack.id, principalisDirectory);
      List<String> toCrack = deschef.map((e) => e.defensio).toList();
      toCrack.add(gladiatorToAttack.output!.defensio);
      final obstructionumDifficultas = await Obstructionum.utDifficultas(principalisDirectory);
      InterioreObstructionum interiore = InterioreObstructionum.confussus(
        obstructionumDifficultas: obstructionumDifficultas,
        forumCap: await Obstructionum.accipereForumCap(principalisDirectory),
        summaObstructionumDifficultas: await Obstructionum.utSummaDifficultas(principalisDirectory) + BigInt.parse(obstructionumDifficultas.toString()),
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
      acciperePortus.listen((nuntius) async {
          Obstructionum obstructionum = nuntius;
          print(obstructionum.toJson());
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
