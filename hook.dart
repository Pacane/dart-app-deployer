import 'dart:io';
import 'dart:convert' show JSON;
import 'dart:convert' show UTF8;
import 'package:crypto/crypto.dart' show SHA1, HMAC;

void main() {
    HttpServer.bind("stacktrace.ca" , 3001)
        .then((HttpServer server) {
            print('listening on localhost, port ${server.port}');
            server.listen((HttpRequest request) {
                String signature = request.headers.value("x-hub-signature");
                var b = new HMAC(new SHA1(), UTF8.encode("lolol"));
                UTF8.decodeStream(request).then((r) {
                  b.add(UTF8.encode(r));
                  var result = b.digest;
                  print("sha1=$result");
                });

                print(signature);
//                var body = UTF8.decodeStream(request);
//                body.then((data) {
//                    var decoded = JSON.decode(data);
//                    if (decoded["repository"]["id"] == 26665190) {
//                        print("is a hook");
//                        Process.start("./start-server.sh", []).then((Process process) {
//                          process.stdout
//                              .transform(UTF8.decoder)
//                             .listen((data) => print(data));
//                        });
//                    }
                    request.response.close();
                });
            });
//        }).catchError((e) => print(e.toString()));
}

