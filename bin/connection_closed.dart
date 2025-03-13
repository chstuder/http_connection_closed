import 'dart:convert';
import 'dart:io';

void main() async {
  startServer();

  await _keepCallingServer();
}

void startServer() async {
  var server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080)
    ..idleTimeout = Duration(milliseconds: 250);
  print('Server running on http://${server.address.host}:${server.port}');

  await for (HttpRequest request in server) {
    if (request.method == 'GET' && request.uri.path == '/hello') {
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'message': 'Hello from server!'}));
      await request.response.close();
    } else {
      request.response
        ..statusCode = HttpStatus.notFound
        ..write('Not Found');
      await request.response.close();
    }
  }
}

Future<void> _keepCallingServer() async {
  final client = HttpClient()..idleTimeout = Duration(seconds: 15);
  for (var i = 0; i < 200; i++) {
    try {
      print('${DateTime.now()} Request now');
      final request = await client.get('localhost', 8080, '/hello');
      final response = await request.close();

      if (response.statusCode == HttpStatus.ok) {
        var responseBody = await response.transform(utf8.decoder).join();
        print('${DateTime.now()} Response from server: $responseBody');
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
    }
    await Future<void>.delayed(const Duration(milliseconds: 485));
  }
}
