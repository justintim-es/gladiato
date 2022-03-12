enum Variabilis {
  NUMERUS,
  PUBLICACLAVIS,
  LITTERA
}
enum Actus {
  INCREMENTO,
  DECREMENTUM,
  DIVISUS,
  MODULUS,
}


class Conditor {
  List<Map<String, Variabilis>> params;
  List<Map<Actus, List<Variabilis>>> actuses;
  Conditor(this.params, this.actuses);
}
class CaptiosusApi {
  final Conditor conditor;
  CaptiosusApi(this.conditor);
}
