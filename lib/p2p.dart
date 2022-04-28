import 'dart:io';
import 'dart:convert';
import 'dart:isolate';
import 'package:nofifty/gladiator.dart';
import 'package:crypto/crypto.dart';
import 'package:hex/hex.dart';
import 'package:nofifty/pera.dart';
import 'package:nofifty/obstructionum.dart';
import 'package:nofifty/constantes.dart';
import 'package:nofifty/utils.dart';
import 'package:nofifty/transaction.dart';
import 'package:ecdsa/ecdsa.dart';
import 'package:elliptic/elliptic.dart';
class P2PMessage {
  String type;
  P2PMessage(this.type);
  P2PMessage.fromJson(Map<String, dynamic> jsoschon):
    type = jsoschon['type'];
  Map<String, dynamic> toJson() => {
    'type': type
  };
}
class SingleSocketP2PMessage extends P2PMessage {
  String socket;
  SingleSocketP2PMessage(this.socket, String type): super(type);
  SingleSocketP2PMessage.fromJson(Map<String, dynamic> jsoschon):
    socket = jsoschon['socket'],
    super.fromJson(jsoschon);
  @override
  Map<String, dynamic> toJson() => {
    'socket': socket,
    'type': type,
  };
}
class ConnectBootnodeP2PMessage extends P2PMessage {
  String socket;
  ConnectBootnodeP2PMessage(this.socket, String type): super(type);
  ConnectBootnodeP2PMessage.fromJson(Map<String, dynamic> jsoschon):
    socket = jsoschon['socket'],
    super.fromJson(jsoschon);
  @override
  Map<String, dynamic> toJson() => {
    'socket': socket,
    'type': type
  };
}
class OnConnectP2PMessage extends P2PMessage {
  List<String> sockets;
  List<Propter> propters;
  List<Transaction> liberTxs;
  List<Transaction> fixumTxs;
  OnConnectP2PMessage(this.sockets, this.propters, this.liberTxs, this.fixumTxs, String type): super(type);
  OnConnectP2PMessage.fromJson(Map<String, dynamic> jsoschon):
    sockets = List<String>.from(jsoschon['sockets']),
    propters = List<Propter>.from(jsoschon['propters'].map((x) => Propter.fromJson(x))),
    liberTxs = List<Transaction>.from(jsoschon['liberTxs'].map((x) => Transaction.fromJson(x))),
    fixumTxs = List<Transaction>.from(jsoschon['fixumTxs'].map((x) => Transaction.fromJson(x))),
    super.fromJson(jsoschon);
  @override
  Map<String, dynamic> toJson() => {
    'sockets': sockets,
    'propters': propters.map((p) => p.toJson()).toList(),
    'liberTxs': liberTxs.map((liber) => liber.toJson()).toList(),
    'fixumTxs': fixumTxs.map((liber) => liber.toJson()).toList(),
    'type': type
  };
}
class SocketsP2PMessage extends P2PMessage {
  List<String> sockets;
  SocketsP2PMessage(this.sockets, String type): super(type);
  SocketsP2PMessage.fromJson(Map<String, dynamic> jsoschon):
    sockets = List<String>.from(jsoschon['sockets']),
    super.fromJson(jsoschon);
  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'sockets': sockets
  };
}
class PropterP2PMessage extends P2PMessage {
  Propter propter;
  PropterP2PMessage(this.propter, String type): super(type);
  PropterP2PMessage.fromJson(Map<String, dynamic> jsoschon):
    propter = Propter.fromJson(jsoschon['propter']),
    super.fromJson(jsoschon);
  @override
  Map<String, dynamic> toJson() => {
    'propter': propter.toJson(),
    'type': type
  };
}
class RemoveProptersP2PMessage extends P2PMessage {
  List<String> ids;
  RemoveProptersP2PMessage(this.ids, String type): super(type);
  RemoveProptersP2PMessage.fromJson(Map<String, dynamic> jsoschon):
    ids = List<String>.from(jsoschon['ids']),
    super.fromJson(jsoschon);
  @override
  Map<String, dynamic> toJson() => {
    'ids': ids,
    'type': type
  };
}
class TransactionP2PMessage extends P2PMessage {
  Transaction tx;
  TransactionP2PMessage(this.tx, String type): super(type);
  TransactionP2PMessage.fromJson(Map<String, dynamic> jsoschon):
    tx = Transaction.fromJson(jsoschon['tx']),
    super.fromJson(jsoschon);
  @override
  Map<String, dynamic> toJson() => {
    'tx': tx.toJson(),
    'type': type
  };
}
class RemoveTransactionsP2PMessage extends P2PMessage {
  List<String> ids;
  RemoveTransactionsP2PMessage(this.ids, String type): super(type);
  RemoveTransactionsP2PMessage.fromJson(Map<String, dynamic> jsoschon):
    ids = List<String>.from(jsoschon['ids']),
    super.fromJson(jsoschon);
  @override
  Map<String, dynamic> toJson() => {
    'ids': ids,
    'type': type
  };
}
class ObstructionumP2PMessage extends P2PMessage {
  Obstructionum obstructionum;
  List<List<String>> hashes;
  ObstructionumP2PMessage(this.obstructionum, this.hashes, String type): super(type);
  ObstructionumP2PMessage.fromJson(Map<String, dynamic> jsoschon):
    obstructionum = Obstructionum.fromJson(jsoschon['obstructionum']),
    hashes = List<List<String>>.from(jsoschon['hashes'].map((x) => List<String>.from(x))),
    super.fromJson(jsoschon);
  @override
  Map<String, dynamic> toJson() => {
    'obstructionum': obstructionum.toJson(),
    'hashes': hashes,
    'type': type
  };
}
class RequestObstructionumP2PMessage extends P2PMessage {
  List<int> numerus;
  RequestObstructionumP2PMessage(this.numerus, String type): super(type);
  RequestObstructionumP2PMessage.fromJson(Map<String, dynamic> jsoschon):
    numerus = List<int>.from(jsoschon['numerus']),
    super.fromJson(jsoschon);
  @override
  Map<String, dynamic> toJson() => {
    'numerus': numerus,
    'type': type
  };
}


class P2P {
  int maxPeers;
  List<String> sockets = [];
  List<Propter> propters = [];
  List<Transaction> liberTxs = [];
  List<Transaction> fixumTxs = [];
  Directory dir;
  SendPort sp;
  List<int> summaNumerus;
  P2P(this.maxPeers, this.dir, this.sp, this.summaNumerus);
  listen(String internalIp, int port) async {
    ServerSocket serverSocket = await ServerSocket.bind(internalIp, port);
    serverSocket.listen((client) {
      client.listen((data) async {
        print(String.fromCharCodes(data).trim());
        print(json.decode(String.fromCharCodes(data).trim()));
        P2PMessage msg = P2PMessage.fromJson(json.decode(String.fromCharCodes(data).trim()));
        if(msg.type == 'connect-bootnode') {
          ConnectBootnodeP2PMessage cbp2pm = ConnectBootnodeP2PMessage.fromJson(json.decode(String.fromCharCodes(data).trim()));
          client.write(json.encode(OnConnectP2PMessage(sockets, propters, liberTxs, fixumTxs, 'on-connect').toJson()));
          client.destroy();
          for(String socket in sockets) {
            Socket s = await Socket.connect(socket.split(':')[0], int.parse(socket.split(':')[1]));
            s.write(json.encode(SingleSocketP2PMessage(cbp2pm.socket, 'single-socket')));
          }
          if(sockets.length < maxPeers && !sockets.contains(cbp2pm.socket) && cbp2pm.socket != '$internalIp:$port') {
            sockets.add(cbp2pm.socket);
          }
        } else if (msg.type == 'single-socket') {
          SingleSocketP2PMessage ssp2pm = SingleSocketP2PMessage.fromJson(json.decode(String.fromCharCodes(data).trim()));
          if(sockets.length < maxPeers && ssp2pm.socket != '$internalIp:$port') {
            sockets.add(ssp2pm.socket);
          }
          client.destroy();
        } else if(msg.type == 'propter') {
          PropterP2PMessage pp2pm = PropterP2PMessage.fromJson(json.decode(String.fromCharCodes(data).trim()));
          if(pp2pm.propter.probationem == HEX.encode(sha256.convert(utf8.encode(json.encode(pp2pm.propter.interioreRationem.toJson()))).bytes)) {
            if(propters.any((p) => p.interioreRationem.id == pp2pm.propter.interioreRationem.id)) {
              propters.removeWhere((p) => p.interioreRationem.id == pp2pm.propter.interioreRationem.id);
            }
            propters.add(pp2pm.propter);
            client.destroy();
          }
        } else if (msg.type == 'remove-propters') {
          RemoveProptersP2PMessage rpp2pm = RemoveProptersP2PMessage.fromJson(json.decode(String.fromCharCodes(data).trim()));
          propters.removeWhere((p) => rpp2pm.ids.any((id) => id == p.interioreRationem.id));
          client.destroy();

        } else if (msg.type == 'liber-tx') {
          TransactionP2PMessage tp2pm = TransactionP2PMessage.fromJson(json.decode(String.fromCharCodes(data).trim()));
          List<Obstructionum> obs = await Obstructionum.getBlocks(dir);
          if (await tp2pm.tx.validateLiber(dir)) {
              if (liberTxs.any((tx) => tx.interioreTransaction.id == tp2pm.tx.interioreTransaction.id)) {
                liberTxs.removeWhere((tx) => tx.interioreTransaction.id == tp2pm.tx.interioreTransaction.id);
              }
              liberTxs.add(tp2pm.tx);
          } else {
            client.write(json.encode(RemoveProptersP2PMessage(List<String>.from([tp2pm.tx.interioreTransaction.id]), 'remove-liber-txs').toJson()));
          }
        } else if (msg.type == 'fixum-tx') {
          TransactionP2PMessage tp2pm = TransactionP2PMessage.fromJson(json.decode(String.fromCharCodes(data).trim()));
          List<Obstructionum> obs = await Obstructionum.getBlocks(dir);
          if (await tp2pm.tx.validateFixum(dir)) {
              if (fixumTxs.any((tx) => tx.interioreTransaction.id == tp2pm.tx.interioreTransaction.id)) {
                fixumTxs.removeWhere((tx) => tx.interioreTransaction.id == tp2pm.tx.interioreTransaction.id);
              }
              fixumTxs.add(tp2pm.tx);
          } else {
            client.write(json.encode(RemoveProptersP2PMessage(List<String>.from([tp2pm.tx.interioreTransaction.id]), 'remove-fixum-txs').toJson()));
          }
        } else if (msg.type == 'remove-liber-txs') {
          RemoveTransactionsP2PMessage rtp2pm = RemoveTransactionsP2PMessage.fromJson(json.decode(String.fromCharCodes(data).trim()));
          liberTxs.removeWhere((l) => rtp2pm.ids.any((id) => id == l.interioreTransaction.id));
          client.destroy();
        } else if (msg.type == 'remove-fixum-txs') {
          RemoveTransactionsP2PMessage rtp2pm = RemoveTransactionsP2PMessage.fromJson(json.decode(String.fromCharCodes(data).trim()));
          fixumTxs.removeWhere((l) => rtp2pm.ids.any((id) => id == l.interioreTransaction.id));
          client.destroy();
        } else if (msg.type == 'obstructionum') {
          ObstructionumP2PMessage op2pm = ObstructionumP2PMessage.fromJson(json.decode(String.fromCharCodes(data).trim()));
          if (dir.listSync().isEmpty && op2pm.obstructionum.interioreObstructionum.generare == Generare.INCIPIO) {
            print('recieved [0]');
            await op2pm.obstructionum.salvareIncipio(dir);
            summaNumerus = [1];
            client.write(json.encode(RequestObstructionumP2PMessage(summaNumerus, 'request-obstructionum').toJson()));
          } else if (dir.listSync().isEmpty && op2pm.obstructionum.interioreObstructionum.generare != Generare.INCIPIO) {
            print('request [0]');
              client.write(json.encode(RequestObstructionumP2PMessage([0], 'request-obstructionum').toJson()));
          } else {
            Obstructionum obs = await Utils.priorObstructionum(dir);
            summaNumerus = obs.interioreObstructionum.obstructionumNumerus;
            if (!op2pm.obstructionum.isProbationem()) {
              print('invalid probationem');
              return;
            }
            if (op2pm.obstructionum.interioreObstructionum.summaObstructionumDifficultas > obs.interioreObstructionum.summaObstructionumDifficultas) {
              List<Obstructionum> obss = await Obstructionum.getBlocks(dir);
              List<String> probationums = obss.map((ob) => ob.probationem).toList();
              if (
                obs.probationem == op2pm.obstructionum.interioreObstructionum.priorProbationem
              ) {
                final difficultas = await Obstructionum.utDifficultas(dir);
                if (
                  op2pm.obstructionum.interioreObstructionum.summaObstructionumDifficultas !=
                  (await Obstructionum.utSummaDifficultas(dir) + BigInt.parse(difficultas.toString()))
                ) {
                  print("licet summa difficultas");
                  return;
                }
                if (op2pm.obstructionum.interioreObstructionum.forumCap != await Obstructionum.accipereForumCap(dir)) {
                  print("Corrumpere forum cap");
                  return;
                }
                List<Transaction> transformInputs = [];
                for (Transaction tx in op2pm.obstructionum.interioreObstructionum.fixumTransactions) {
                  if (tx.probationem == 'transform') {
                    transformInputs.add(tx);
                  } else {
                    if (!await tx.validateFixum(dir) || !tx.validateProbationem()) {
                      print("Corrumpere negotium in obstructionum");
                    }
                  }
                }
                List<Transaction> transformOutputs = [];
                for (Transaction tx in op2pm.obstructionum.interioreObstructionum.liberTransactions) {
                  switch(tx.probationem) {
                    case 'burn': {
                      if (!await tx.validateBurn(dir)) {
                        print("irritum ardeat");
                        return;
                      }
                      break;
                    }
                    case 'transform': {
                      transformOutputs.add(tx);
                      break;
                    }
                    case 'obstructionum praemium': {
                      if (!tx.validateBlockreward()) {
                        print('irritum obstructionum praemium');
                        return;
                      }
                      break;
                    }
                    default: {
                      if (!await tx.validateLiber(dir) || !tx.validateProbationem())  {
                        print("irritum tx");
                        return;
                      };
                      break;
                    }
                  }
                }
                BigInt transformAble = BigInt.zero;
                for (List<TransactionInput> inputs in transformInputs.map((tx) => tx.interioreTransaction.inputs)) {
                  for (TransactionInput input in inputs) {
                      Obstructionum obstructionum = obss.singleWhere((ob) => ob.interioreObstructionum.liberTransactions.any((tx) => tx.interioreTransaction.id == input.transactionId));
                      Transaction tx = obstructionum.interioreObstructionum.liberTransactions.singleWhere((liber) => liber.interioreTransaction.id == input.transactionId);
                      if (!Utils.cognoscere(PublicKey.fromHex(Pera.curve(), tx.interioreTransaction.outputs[input.index].publicKey), Signature.fromCompactHex(input.signature), tx.interioreTransaction.outputs[input.index])) {
                        print("irritum tx");
                        return;
                      } else {
                        transformAble += tx.interioreTransaction.outputs[input.index].gla;
                      }
                  }
                }
                BigInt transformed = BigInt.zero;
                for (List<TransactionOutput> outputs in transformOutputs.map((tx) => tx.interioreTransaction.outputs)) {
                  for (TransactionOutput output in outputs) {
                    transformed += output.gla;
                  }
                }
                if (transformAble != transformed) {
                  print("irritum transform");
                  return;
                }
                if(op2pm.obstructionum.interioreObstructionum.generare == Generare.EFECTUS) {
                  for (Propter propter in op2pm.obstructionum.interioreObstructionum.gladiator.output?.rationem ?? []) {
                    if (!propter.isProbationem()) {
                      print('invalidum probationem pro ratione');
                      return;
                    }
                  }
                  if(op2pm.obstructionum.interioreObstructionum.liberTransactions.where((liber) => liber.probationem == Constantes.txObstructionumPraemium).length != 1) {
                    print("Insufficient obstructionum munera");
                    return;
                  }
                  if (op2pm.obstructionum.interioreObstructionum.liberTransactions.where((liber) => liber.probationem == Constantes.transform).isNotEmpty) {
                    print("Insufficient transforms");
                    return;
                  }
                } else if (op2pm.obstructionum.interioreObstructionum.generare == Generare.CONFUSSUS) {
                  String gladiatorId = op2pm.obstructionum.interioreObstructionum.gladiator.input!.gladiatorId;
                  Obstructionum obs = obss.singleWhere((obs) => obs.interioreObstructionum.gladiator.id == gladiatorId);
                  if(obs.interioreObstructionum.gladiator.output != null) {
                    print("outputs arent liceat ad confossum");
                    return;
                  }
                  List<Defensio> deschef = await Pera.maximeDefensiones(gladiatorId, dir);
                  List<String> defensiones = deschef.map((x) => x.defensio).toList();
                  String totalDefence = obs.interioreObstructionum.gladiator.output?.defensio ?? '';
                  for (String def in defensiones) {
                    totalDefence += def;
                  }
                  if(!op2pm.obstructionum.probationem.contains(totalDefence)) {
                    print('gladiator non defeaten');
                    return;
                  }
                  int ardet = 0;
                  for (String propter in obs.interioreObstructionum.gladiator.output!.rationem.map((x) => x.interioreRationem.publicaClavis)) {
                    final balance = await Pera.statera(true, propter, dir);
                    if (balance > BigInt.zero) {
                      ardet += 1;
                    }
                  }
                  if (op2pm.obstructionum.interioreObstructionum.liberTransactions.where((liber) => liber.probationem == Constantes.ardeat).length != ardet) {
                    print("Insufficiens ardet");
                    return;
                  }
                  if (op2pm.obstructionum.interioreObstructionum.liberTransactions.where((liber) => liber.probationem == Constantes.transform).length != 1) {
                    print("Insufficiens transforms");
                  }
                }
                await op2pm.obstructionum.salvare(dir);
                print('notahaha');
                // sp.send("yupdate miner");

                // obs = await Utils.priorObstructionum(dir);
                if (summaNumerus.last < Constantes.maximeCaudicesFile) {
                  summaNumerus.last + 1;
                } else {
                  summaNumerus.add(0);
                }
                client.write(json.encode(RequestObstructionumP2PMessage(summaNumerus, 'request-obstructionum')));
                client.destroy();
                // await syncBlock(obs);
              } else {
                print('one');
                int idx = 0;
                final reschev = op2pm.hashes.reversed;
                for (List<String> hashes in reschev) {
                  print('two');
                  final reschevh = hashes.reversed;
                  if (probationums.any((reschev.contains))) {
                    print('three');
                    List<int> numerus = [];
                    final ischin = hashes.indexWhere(probationums.contains);
                    print('four');
                    for (Obstructionum o in obss) {
                      print('five');
                      if (o.probationem == op2pm.hashes[ischin]) {
                        numerus = o.interioreObstructionum.obstructionumNumerus;
                        await Utils.removeDonecObstructionum(dir, numerus);
                      }
                    }
                    client.write(json.encode(RequestObstructionumP2PMessage(numerus, 'request-obstructionum')));
                  }
                }
              }
          }
          }
        }
      });
    });
  }
  connect(String bootnode, String me) async {
    sockets.add(bootnode);
    Socket socket = await Socket.connect(bootnode.split(':')[0], int.parse(bootnode.split(':')[1]));
    socket.write(json.encode(ConnectBootnodeP2PMessage(me, 'connect-bootnode').toJson()));
    socket.listen((data) async {
      OnConnectP2PMessage ocp2pm = OnConnectP2PMessage.fromJson(json.decode(String.fromCharCodes(data).trim()));
      if(sockets.length < maxPeers) {
        sockets.addAll(ocp2pm.sockets.take((maxPeers - sockets.length)));
      }
      propters.addAll(ocp2pm.propters);
      liberTxs.addAll(ocp2pm.liberTxs);
      fixumTxs.addAll(ocp2pm.fixumTxs);
    });
  }
  syncPropter(Propter propter) async {
    if(propters.any((p) => p.interioreRationem.id == propter.interioreRationem.id)) {
      propters.removeWhere((p) => p.interioreRationem.id == propter.interioreRationem.id);
    }
    propters.add(propter);
    for (String socket in sockets) {
      Socket soschock = await Socket.connect(socket.split(':')[0], int.parse(socket.split(':')[1]));
      soschock.write(json.encode(PropterP2PMessage(propter, 'propter').toJson()));
    }
  }
  syncLiberTx(Transaction tx) async {
    if (liberTxs.any((t) => t.interioreTransaction.id == tx.interioreTransaction.id)) {
      liberTxs.removeWhere((t) => t.interioreTransaction.id == tx.interioreTransaction.id);
    }
    liberTxs.add(tx);
    for (String socket in sockets) {
      Socket soschock = await Socket.connect(socket.split(':')[0], int.parse(socket.split(':')[1]));
      soschock.write(json.encode(TransactionP2PMessage(tx, 'liber-tx').toJson()));
      soschock.listen((data) async {
        RemoveTransactionsP2PMessage rtp2pm = RemoveTransactionsP2PMessage.fromJson(json.decode(String.fromCharCodes(data).trim()));
        liberTxs.removeWhere((liber) => rtp2pm.ids.contains(liber.interioreTransaction.id));
      });
    }
  }
  syncFixumTx(Transaction tx) async {
    if (fixumTxs.any((t) => t.interioreTransaction.id == tx.interioreTransaction.id)) {
      fixumTxs.removeWhere((t) => t.interioreTransaction.id == tx.interioreTransaction.id);
    }
    fixumTxs.add(tx);
    for (String socket in sockets) {
      Socket soschock = await Socket.connect(socket.split(':')[0], int.parse(socket.split(':')[1]));
      soschock.write(json.encode(TransactionP2PMessage(tx, 'fixum-tx').toJson()));
      soschock.listen((data) async {
        RemoveTransactionsP2PMessage rtp2pm = RemoveTransactionsP2PMessage.fromJson(json.decode(String.fromCharCodes(data).trim()));
        fixumTxs.removeWhere((fixum) => rtp2pm.ids.contains(fixum.interioreTransaction.id));
      });
    }
  }
  removePropters(List<String> ids) async {
    print(ids);
    print('rempropters');
    print(propters);
    propters.removeWhere((p) => ids.any((i) => i == p.interioreRationem.id));
    print(propters);
    for (String socket in sockets) {
      Socket soschock = await Socket.connect(socket.split(':')[0], int.parse(socket.split(':')[1]));
      soschock.write(json.encode(RemoveProptersP2PMessage(ids, 'remove-propters').toJson()));
    }
  }
  removeLiberTxs(List<String> ids) async {
    print(liberTxs);
    liberTxs.removeWhere((l) => ids.any((i) => i == l.interioreTransaction.id));
    print(liberTxs);
    for (String socket in sockets) {
      Socket soschock = await Socket.connect(socket.split(':')[0], int.parse(socket.split(':')[1]));
      soschock.write(json.encode(RemoveTransactionsP2PMessage(ids, 'remove-liber-txs').toJson()));
    }
  }
  removeFixumTxs(List<String> ids) async {
    fixumTxs.removeWhere((f) => ids.contains(f.interioreTransaction.id));
    for (String socket in sockets) {
      Socket soschock = await Socket.connect(socket.split(':')[0], int.parse(socket.split(':')[1]));
      soschock.write(json.encode(RemoveTransactionsP2PMessage(ids, 'remove-fixum-txs').toJson()));
    }
  }
  syncBlock(Obstructionum obs) async {
    for (String socket in sockets) {
      Socket soschock = await Socket.connect(socket.split(':')[0], int.parse(socket.split(':')[1]));
      List<List<String>> hashes = [];
      int idx = 0;
      int total = 0;
      print('okey');
      for (int i = 0; i < dir.listSync().length; i++) {
        hashes.add([]);
        List<String> lines = await Utils.fileAmnis(File('${dir.path}/${Constantes.fileNomen}$i.txt')).toList();
        for (String line in lines) {
          if (total < 100) {
            hashes[idx].add(Obstructionum.fromJson(json.decode(line)).probationem);
            total++;
          }
        }
        idx++;
      }
      print('j');
      print('lines');
      print(hashes);
      print('wrote');
      soschock.write(json.encode(ObstructionumP2PMessage(obs, hashes, 'obstructionum').toJson()));
      soschock.listen((data) async {
        print('listening');
        // List<List<String>> lines = [];
        // for (int i = dir.listSync().length-1; i > -1 ; i--) {
        //   List<String> lines = await Utils.fileAmnis(File('${dir.path}/${Constantes.fileNomen}$i.txt')).toList();
        //   lines.addAll(lines);
        // }
        print(String.fromCharCodes(data).trim());
        RequestObstructionumP2PMessage rop2pm = RequestObstructionumP2PMessage.fromJson(json.decode(String.fromCharCodes(data).trim()));
        print(rop2pm.numerus.length);
        File caudices = File('${dir.path}/${Constantes.fileNomen}${rop2pm.numerus.length-1}.txt');

        // if (await Utils.fileAmnis(caudices).length > rop2pm.numerus.last) {
          if (rop2pm.numerus.last < Constantes.maximeCaudicesFile) {
            String obs = await Utils.fileAmnis(caudices).elementAt(rop2pm.numerus.last);
            Obstructionum obsObs = Obstructionum.fromJson(json.decode(obs));
            soschock.write(json.encode(ObstructionumP2PMessage(obsObs, hashes, 'obstructionum').toJson()));
          } else {
            rop2pm.numerus.add(0);
            String obs = await Utils.fileAmnis(caudices).elementAt(rop2pm.numerus.last);
            Obstructionum obsObs = Obstructionum.fromJson(json.decode(obs));
            soschock.write(json.encode(ObstructionumP2PMessage(obsObs, hashes, 'obstructionum').toJson()));
          }
        // } else {
          // await soschock.close();
        // }
      });
    }
  }
}

// import 'dart:io';
// import 'dart:convert';
// import 'package:nofifty/gladiator.dart';
//
//
// class P2PMessage {
//   String type;
//   P2PMessage(this.type);
//   P2PMessage.fromJson(Map<String, dynamic> jsoschon):
//     type = jsoschon['type'];
//   Map<String, dynamic> toJson() => {
//     'type': type
//   };
// }
// class PropterP2PMessage extends P2PMessage {
//   Propter propter;
//   PropterP2PMessage(String type, this.propter): super(type);
//   PropterP2PMessage.fromJson(Map<String, dynamic> jsoschon):
//     propter = Propter.fromJson(jsoschon['propter']),
//     super.fromJson(jsoschon);
// }
// class SocketsP2PMessage extends P2PMessage {
//   List<String> sockets;
//   bool broadcast;
//   SocketsP2PMessage(this.broadcast, String type, this.sockets): super(type);
//   SocketsP2PMessage.fromJson(Map<String, dynamic> jsoschon):
//     sockets = List<String>.from(jsoschon['sockets']),
//     broadcast = jsoschon['broadcast'],
//     super.fromJson(jsoschon);
//   Map<String, dynamic> toJson() => {
//     'type': type,
//     'broadcast': broadcast,
//     'sockets': sockets
//   };
// }
//
// class P2P {
//   String listenIp;
//   int listenPort;
//   String externalIp;
//   late ServerSocket serverSocket;
//   final List<String> sockets = [];
//   final List<Propter> propters = [];
//   P2P(this.listenIp, this.listenPort, this.externalIp);
//
//   connect(String bootnode) async {
//     final Socket socket = await Socket.connect(bootnode.split(':')[0], int.parse(bootnode.split(':')[1]));
//     sockets.add(bootnode);
//     List<String> sendSockets = sockets;
//     sendSockets.add('$externalIp:$listenPort');
//     socket.write(json.encode(SocketsP2PMessage(true, 'socket', sendSockets).toJson()));
//   }
//   listen() async {
//     ServerSocket serverSocket = await ServerSocket.bind(listenIp, listenPort);
//     serverSocket.listen((client) {
//       client.listen((data) async {
//         print('data');
//         print(String.fromCharCodes(data).trim());
//         P2PMessage msg = P2PMessage.fromJson(json.decode(String.fromCharCodes(data).trim()));
//         if(msg.type == 'socket') {
//           final s = SocketsP2PMessage.fromJson(json.decode(String.fromCharCodes(data).trim()));
//           print(s.toJson());
//           sockets.addAll(s.sockets.where((ss) => !sockets.contains(ss) && ss != '$externalIp:$listenPort'));
//           print(sockets);
//           for (String soschock in sockets) {
//             if(s.broadcast) {
//               final Socket socket = await Socket.connect(soschock.split(':')[0], int.parse(soschock.split(':')[1]));
//               socket.write(json.encode(SocketsP2PMessage(false, 'socket', sockets).toJson()));
//             }
//           }
//           //client.destroy();
//         } else if (msg is PropterP2PMessage) {
//           propters.removeWhere((p) => p.interioreRationem.id == msg.propter.interioreRationem.id);
//           propters.add(msg.propter);
//           client.destroy();
//         }
//       });
//     });
//   }
//   syncPropter(Propter propter) async {
//     propters.removeWhere((p) => p.interioreRationem.id == propter.interioreRationem.id);
//     propters.add(propter);
//     for (String socket in sockets) {
//       Socket soschock = await Socket.connect(socket.split(':')[0], int.parse(socket.split(':')[1]));
//       soschock.write(json.encode(PropterP2PMessage('propter', propter).toJson()));
//     }
//   }
// }
