import 'package:flutter_dotenv/flutter_dotenv.dart';

String get host {
  return dotenv.env['HOST'] ?? '';
}