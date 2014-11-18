import 'dart:io';
import 'dart:convert' show UTF8;

void main() {
    HttpServer.bind("stacktrace.ca" , 3001)
        .then((HttpServer server) {
            print('listening on localhost, port ${server.port}');
            server.listen((HttpRequest request) {
                var body = UTF8.decodeStream(request);
                body.then((data) {
                    var decoded = UTF8.decode(data);
                    if (decoded["hook_id"] == 3477553) {
                       // Process.start("./start-server.sh", []);
                        print("is a hook");
                    }
//                    print(data);
                    request.response.close();
                });
            });
        }).catchError((e) => print(e.toString()));
}

