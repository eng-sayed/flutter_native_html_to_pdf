import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'file_utils.dart';
import 'flutter_native_html_to_pdf_platform_interface.dart';

/// An implementation of [FlutterNativeHtmlToPdfPlatform] that uses method channels.
class MethodChannelFlutterNativeHtmlToPdf
    extends FlutterNativeHtmlToPdfPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_native_html_to_pdf');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<File?> convertHtmlToPdf({
    required String html,
 required String targetDirectory, required String targetName
  }) async {
    final temporaryCreatedHtmlFile =
        await FileUtils.createFileWithStringContent(html, "$targetDirectory/$targetName.html");
    final generatedPdfFilePath =
        await _convertFromHtmlFilePath(temporaryCreatedHtmlFile.path);
    final generatedPdfFile =
        FileUtils.copyAndDeleteOriginalFile(generatedPdfFilePath, targetDirectory,targetName);
    temporaryCreatedHtmlFile.delete();

    return generatedPdfFile;
  }

  /// Assumes the invokeMethod call will return successfully
  Future<String> _convertFromHtmlFilePath(String htmlFilePath) async {
    final result = await methodChannel.invokeMethod(
        'convertHtmlToPdf', <String, dynamic>{'htmlFilePath': htmlFilePath});
    return result as String;
  }
}
