import 'package:freezed_annotation/freezed_annotation.dart';

part 'remote_response.freezed.dart';

@freezed

/// RemoteResponse wrapper for objects received from remote datasource.
class RemoteResponse<T> with _$RemoteResponse<T> {
  /// No connection remote response
  ///
  /// Generally takes place when `SocketException` is thrown.
  const factory RemoteResponse.noConnection() = _NoConnection<T>;

  /// Unmodified remote response.
  ///
  /// Usually such response contains status code of 304.
  const factory RemoteResponse.notModified({
    required int maxPage,
  }) = _NotModified<T>;

  /// Remote response with latest data.
  ///
  /// Such response contains status code of 200.
  const factory RemoteResponse.withNewData(
    T data, {
    required int maxPage,
  }) = _WithNewData<T>;
}
