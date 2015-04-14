library war_builder;

import 'dart:io' as io;
import 'package:archive/archive.dart';

class WarBuilder {
  build(String path) async {
    io.File file = new io.File('$path/config.yaml');
    List<int> bytes = await file.readAsBytes();
    assert(bytes != null);
    assert(bytes.length != 0);
    io.FileStat stats = await file.stat();
    Archive archive = new Archive();
    archive.addFile(new ArchiveFile.noCompress('config.yaml', stats.size, bytes)
      ..mode = stats.mode
      ..lastModTime = stats.modified.millisecond);

    List<int> tar_data = new ZipEncoder().encode(archive, level: Deflate.NO_COMPRESSION);

    await new io.File('output.war').writeAsBytes(tar_data, flush: true);
  }
}
