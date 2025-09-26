 
import 'package:simple_dependency_injection/simple.dart';

class AnyE {
  String message;
  AnyE(this.message);

  @override
  String toString() {
    return message;
  }
}

class AnyT {
  String message;
  AnyT(this.message);

  @override
  String toString() {
    return message;
  }
}

void main() {
  var simple = Simple();

  simple.addSingleton<AnyT>(() => AnyT("message AnyT"));

  simple.addSingleton<AnyE>(() => AnyE("message AnyE"));

  print(simple.get<AnyE>().toString());
  //OUTPUT: message AnyE

  print(simple.get<AnyT>().toString());
  //OUTPUT: message AnyT

  simple.update<AnyT>(() => AnyT("updated message AnyT"));

  print(simple.get<AnyT>().toString());
  //OUTPUT: updated message AnyT

  simple.reset(); //clean all of memory
}
