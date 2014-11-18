import 'dart:io';
import 'dart:convert' show JSON, UTF8, Encoding;
import 'dart:convert' show UTF8;
import 'package:crypto/crypto.dart' show SHA1, HMAC;

void main() {
    HttpServer.bind("localhost" , 3001)
        .then((HttpServer server) {
            print('listening on localhost, port ${server.port}');
            server.listen((HttpRequest request) {
                String signature = request.headers.value("x-hub-signature");
                var b = new HMAC(new SHA1(), UTF8.encode("lolol"));
                request.listen((data) {
                  b.add(data);
                  var result = UTF8.decode(b.digest);
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

