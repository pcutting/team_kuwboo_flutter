import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_client.dart';

/// Media endpoints backed by S3 presigned-URL uploads. See
/// `apps/api/src/modules/media/media.controller.ts`.
///
/// Flow:
///   1. [requestPresignedUrl] — client asks backend for an S3 PUT URL.
///   2. [uploadFile] — client PUTs the bytes directly to S3 (no auth).
///   3. [confirm] — backend verifies the object exists and marks it READY.
///
/// Callers that want a one-shot API can use [uploadAndConfirm].
class MediaApi {
  MediaApi(this._client, {Dio? rawDio}) : _rawDio = rawDio ?? Dio();

  final KuwbooApiClient _client;

  /// Bare Dio for the raw S3 PUT — no auth interceptor, no base URL.
  final Dio _rawDio;

  /// Step 1: ask the backend for a presigned S3 upload URL.
  ///
  /// Throws [ArgumentError] if the request would fail client-side validation
  /// (size cap, content-type whitelist). Validating up-front saves a round
  /// trip to the backend which would return a 400.
  Future<PresignedUrlResponse> requestPresignedUrl(
    PresignedUrlRequestDto dto,
  ) async {
    final validationError = MediaLimits.validate(
      type: dto.type,
      contentType: dto.contentType,
      sizeBytes: dto.sizeBytes,
    );
    if (validationError != null) {
      throw ArgumentError(validationError);
    }

    final response = await _client.dio.post(
      '/media/presigned-url',
      data: dto.toJson(),
    );
    return _client.unwrap(response, PresignedUrlResponse.fromJson);
  }

  /// Step 2: PUT raw bytes to S3 using the presigned URL.
  ///
  /// This is NOT a Kuwboo API call — the presigned URL signs `Content-Type`,
  /// so the header must match exactly what was supplied to
  /// [requestPresignedUrl] or S3 will reject the request with 403.
  Future<void> uploadFile(
    String presignedUrl,
    Uint8List bytes,
    String contentType,
  ) async {
    await _rawDio.put<void>(
      presignedUrl,
      data: Stream.fromIterable([bytes]),
      options: Options(
        headers: {
          Headers.contentTypeHeader: contentType,
          Headers.contentLengthHeader: bytes.length,
        },
      ),
    );
  }

  /// Step 3: tell the backend the upload is complete. Backend HEADs S3,
  /// sets status to READY, and returns the hydrated [Media].
  Future<Media> confirm(String mediaId) async {
    final response = await _client.dio.post('/media/$mediaId/confirm');
    return _client.unwrap(response, Media.fromJson);
  }

  /// Convenience composition of presign → PUT → confirm. Prefer this
  /// from UI code unless you need progress reporting on the raw PUT.
  Future<Media> uploadAndConfirm({
    required String fileName,
    required String contentType,
    required MediaType type,
    required Uint8List bytes,
  }) async {
    final presign = await requestPresignedUrl(
      PresignedUrlRequestDto(
        fileName: fileName,
        contentType: contentType,
        type: type,
        sizeBytes: bytes.length,
      ),
    );
    await uploadFile(presign.uploadUrl, bytes, contentType);
    return confirm(presign.mediaId);
  }
}
