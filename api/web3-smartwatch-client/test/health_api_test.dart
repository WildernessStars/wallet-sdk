import 'package:test/test.dart';
import 'package:openapi/openapi.dart';

/// tests for HealthApi
void main() {
  final instance = Openapi().getHealthApi();

  group(HealthApi, () {
    // Check server health
    //
    // Returns a simple \"OK\" message if the server is running
    //
    //Future<HealthGet200Response> healthGet() async
    test('test healthGet', () async {
      // TODO
    });
  });
}
