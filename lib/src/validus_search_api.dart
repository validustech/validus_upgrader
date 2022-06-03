/*
 * Copyright (c) 2018-2021 Larry Aasen. All rights reserved.
 */

import 'dart:async';
import 'dart:convert';
import 'package:version/version.dart';
import 'package:http/http.dart' as http;

class ValidusSearchAPI {
  /// Provide an HTTP Client that can be replaced for mock testing.
  http.Client? client = http.Client();

  bool debugEnabled = false;

  /// Look up by AWS S3 url
  Future<Map?> lookupByAws(String url) async {
    if (debugEnabled) {
      print('upgrader: download: $url');
    }

    try {
      final response = await client!.get(Uri.parse(url));
      if (debugEnabled) {
        print('upgrader: response statusCode: ${response.statusCode}');
      }

      final decodedResults = _decodeResults(response.body);
      return decodedResults;
    } catch (e) {
      print('upgrader: lookupByAws exception: $e');
      return null;
    }
  }

  Map? _decodeResults(String jsonResponse) {
    if (jsonResponse.isNotEmpty) {
      final decodedResults = json.decode(jsonResponse);
      if (decodedResults is Map) {
        final resultCount = decodedResults['resultCount'];
        if (resultCount == 0) {
          if (debugEnabled) {
            print(
                'upgrader.ValidusSearchAPI: results are empty: $decodedResults');
          }
        }
        return decodedResults;
      }
    }
    return null;
  }
}

class ValidusVersionResult {
  static Version? minAppVersion(Map response, {String tagName = 'mav'}) {
    Version? version;
    try {
      final mav = response['minVersion'];
      // Verify version string using class Version
      version = mav != null ? Version.parse(mav) : null;
    } on Exception catch (e) {
      print('upgrader.ITunesResults.minAppVersion : $e');
    }
    return version;
  }

  /// Return field version from iTunes results.
  static String? version(Map response) {
    String? value;
    try {
      value = response['storeVersion'];
    } catch (e) {
      print('upgrader.ValidusVersionResult.storeVersion: $e');
    }
    return value;
  }

  /// Return field version from Aws config.
  static String? appStoreListingURL(Map response) {
    String? value;
    try {
      value = response['appStoreUrl'];
    } catch (e) {
      print('upgrader.ValidusVersionResult.appStoreUrl: $e');
    }
    return value;
  }
}
