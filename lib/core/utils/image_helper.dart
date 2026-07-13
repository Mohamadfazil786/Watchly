import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class ImageHelper {
  static ImageProvider? getAvatarImage(String path) {
    if (path.isEmpty) return null;
    if (path.startsWith('data:image/') && path.contains(';base64,')) {
      try {
        final base64String = path.split(';base64,').last;
        return MemoryImage(base64Decode(base64String));
      } catch (_) {
        return null;
      }
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    return FileImage(File(path));
  }
}
