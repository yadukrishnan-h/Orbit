import 'package:isar/isar.dart';

part 'debug_server.g.dart';

@collection
class DebugServer {
  Id id = Isar.autoIncrement;

  late String name;
  late String hostname;
  late int port;
  late String username;
}
