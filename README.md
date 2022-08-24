<p align="center">
<img src="https://user-images.githubusercontent.com/63902683/186323936-b9773d51-403d-4102-8f2e-b1071c99c33c.png" height="100" alt="Omelette" />
</p>

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis

# Omelette 🍳
Omelette provides helpful wrappers for your response obtained from various data sources. It works well with APIs that support [Etags](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/ETag) and page-based (or offset-based) pagination.

# Architecture
This package is best suited when followed similar architecture as shown in the image.

![Flutter Architecture Diagram](https://user-images.githubusercontent.com/63902683/186157513-ed24692b-5c57-4ef4-96db-b8b630e35896.png)

# RemoteResponse Wrapper
## Usecase
When dealing with API requests that supports [ETag](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/ETag), it becomes necessary to check if the received response is a modified response, an unmodified response or a no connection response. The package provides easy to use wrapper for such scenarios.

### Example
Consider a scenario where you are making a network requests and need to know the response attribute (modified, unmodified or no connection).

```dart
class FeedDTO {}

class SampleRemoteDataSource {
  SampleRemoteDataSource(Dio dio) : _dio = dio;

  final Dio _dio;

  Future<List<FeedDTO>> fetchFeeds() async {
    try {
      final response = await _dio.get('some url path');

      if (response.statusCode == 200) {
        // modified result with new data
        // json deserializaton
      } else if (response.statusCode == 304) {
        // unmodified result
        // load from cache
      } else {
        // Server Error
        throw Exception;
      }
    } on DioError {
      // error handling
    }
  }
}
```
Now, the data repository which will have `SampleRemoteDataSource` as its dependency will be unable to figure out if the received `List<Feed>` is because of status code 200 or 304.
This is where `RemoteResponse` comes into play. Just wrap the return type of the method in the data source file with `RemoteResponse`. In our case, we will get `RemoteResponse<List<Feed>>`.

Internally, `RemoteResponse` is a [freezed](https://pub.dev/packages/freezed) union and contains three redirecting constructors, namely `_NoConnection`, `_NotModified` and `_WithNewData`.

```dart
class FeedDTO {}

class SampleRemoteDataSource {
  SampleRemoteDataSource(Dio dio) : _dio = dio;

  final Dio _dio;

  Future<RemoteResponse<List<FeedDTO>>> fetchFeeds() async {
    try {
      final response = await _dio.get('some url path');

      if (response.statusCode == 200) {
        // modified result
        // json deserializaton
        return RemoteResponse.withNewData(); // pass decoded response and a max page size
      } else if (response.statusCode == 304) {
        // unmodified result
        // load from cache
        return RemoteResponse.notModified(); // pass max page size from pagniation
      } else {
        // Server Error
        throw Exception;
      }
    } on DioError catch (e) {
      if (e.isNoConnectionError) {
        return const RemoteResponse.noConnection();
      } else if (e.response != null) {
        throw Exception();
      } else {
        rethrow;
      }
    }
  }
}

extension DioErrorX on DioError {
  bool get isNoConnectionError =>
      type == DioErrorType.other && error is SocketException;
}
```

- The factory `RemoteResponse.withNewData()` takes in two arguments: a generic type `data`, which is the decoded data from the sever and an integer type `maxPage` which is also a part of the response giving information on how many pages can be fetched.
- The factory `RemoteResponse.unmodified()` accepts a parameter: an integer type `maxPage`.

# Fresh wrapper
`Fresh` is a wrapper around objects being returned from the repository indicating freshness of the data. It can be useful when having to display some alerts or snackbar when the data being returned from the repository is stale (or not fresh).

## Usecase
When the data source returns the data `RemoteResponse<T>`, it is captured by the repository. Now, depending on the type of `RemoteResponse`, we will return freshness of the object to the application layer which will ultimately be consumed by the presentation layer.

```dart
class SampleRepository {
  SampleRepository({required this.dataSource});

  final SampleRemoteDataSource dataSource;

  Future<Fresh<List<Feed>>> fetchFeeds() async {
    final remoteData = await dataSource.fetchFeeds();
    
    return remoteData.when(
          noConnection: () async => Fresh.no(
            // load from cache,
            isNextPageAvailable: // either true or false
          ),
          notModified: (maxPage) async => Fresh.yes(
            // get list,
            isNextPageAvailable: // either true or false,         
          ),
          withNewData: (data, maxPage) async {
            // insert new data in the database.
            return Fresh.yes(
              // new data
              isNextPageAvailable: // either true or false,
            );
         },
      );
   }
}
```

Now, the application can layer can obtain the freshness of the received data which will be passed on to the presentation layer.
