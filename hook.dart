import 'dart:io';
import 'dart:convert' show JSON;
import 'dart:convert' show UTF8;

void main() {
    HttpServer.bind("stacktrace.ca" , 3001)
        .then((HttpServer server) {
            print('listening on localhost, port ${server.port}');
            server.listen((HttpRequest request) {
                var body = UTF8.decodeStream(request);
                body.then((data) {
                    var decoded = JSON.decode(data);
                    if (decoded["repository"]["id"] == 26665190) {
                        print("is a hook");
                        Process.start("./start-server.sh", []).then((Process process) {
                          process.stdout
                              .transform(UTF8.decoder)
                              .listen((data) => print(data)); 
                        });
                    }
                    request.response.close();
                });
            });
        }).catchError((e) => print(e.toString()));
}

