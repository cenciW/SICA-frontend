import 'dart:convert';
import 'package:http/http.dart' as http;

/// Classe que representa a resposta padrão da API
class ApiResponse<T> {
  final T? data;
  final String message;
  final int status;

  ApiResponse({
    this.data,
    required this.message,
    required this.status,
  });

  bool get isSuccess => status == 200 || status == 201;

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    return ApiResponse<T>(
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      message: json['message'] ?? '',
      status: json['status'] ?? 200,
    );
  }
}

/// Exceção customizada para erros da API
class ApiException implements Exception {
  final String message;
  final int? status;

  ApiException(this.message, {this.status});

  @override
  String toString() => message;
}

/// Helper para processar respostas da API
class ApiHelper {
  static const String internalServerError =
      'Erro interno do servidor. Tente novamente mais tarde.';

  /// Codifica o body para JSON
  static String encodeBody(Map<String, dynamic> data) {
    return json.encode(data);
  }

  /// Processa a resposta HTTP e retorna ApiResponse
  static ApiResponse<T> processResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJsonT,
  ) {
    try {
      final body = json.decode(response.body);

      // Verifica se é um erro do NestJS (formato: {statusCode, message, error})
      if (body['status'] != null && response.statusCode >= 400) {
        final message = body['message'] is List
            ? (body['message'] as List).join(', ')
            : body['message']?.toString() ?? 'Erro desconhecido';
        throw ApiException(message, status: body['status']);
      }

      // Formato padrão da API: {data, message, status}
      final apiResponse = ApiResponse<T>.fromJson(body, fromJsonT);

      if (!apiResponse.isSuccess) {
        throw ApiException(apiResponse.message, status: apiResponse.status);
      }

      return apiResponse;
    } catch (e) {
      if (e is ApiException) rethrow;

      // Erro de parsing ou outro erro externo
      throw ApiException(internalServerError, status: response.statusCode);
    }
  }

  /// Processa resposta que retorna uma lista
  static ApiResponse<List<T>> processListResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    try {
      final body = json.decode(response.body);
      final status = body['status'] ?? 200;
      final message = body['message'] ?? '';

      if (status != 200 && status != 201) {
        throw ApiException(message, status: status);
      }

      final List<dynamic> dataList = body['data'] ?? [];
      final List<T> items = dataList.map((item) => fromJsonT(item)).toList();

      return ApiResponse<List<T>>(
        data: items,
        message: message,
        status: status,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(internalServerError, status: response.statusCode);
    }
  }

  /// Verifica se houve erro de conexão/rede
  static ApiException handleNetworkError(dynamic error) {
    return ApiException(internalServerError);
  }
}
