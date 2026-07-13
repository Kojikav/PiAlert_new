import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/gempa_model.dart';

class BmkgService {
  static const _baseUrl = 'https://data.bmkg.go.id/DataMKG/TEWS';

  Future<GempaModel> getGempaTerbaru() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/autogempa.json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return GempaModel.fromJson(data['Infogempa']['gempa']);
      }
      throw Exception('Gagal memuat data gempa terbaru');
    } catch (e) {
      debugPrint('Error fetching gempa terbaru: $e');
      rethrow;
    }
  }

  Future<List<GempaModel>> getGempaTerkini() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/gempaterkini.json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = data['Infogempa']['gempa'] as List;
        return list.map((e) => GempaModel.fromJson(e)).toList();
      }
      throw Exception('Gagal memuat data gempa terkini');
    } catch (e) {
      debugPrint('Error fetching gempa terkini: $e');
      rethrow;
    }
  }

  Future<List<GempaModel>> getGempaDirasakan() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/gempadirasakan.json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = data['Infogempa']['gempa'] as List;
        return list.map((e) => GempaModel.fromJson(e)).toList();
      }
      throw Exception('Gagal memuat data gempa dirasakan');
    } catch (e) {
      debugPrint('Error fetching gempa dirasakan: $e');
      rethrow;
    }
  }
}
