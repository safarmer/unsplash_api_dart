import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:unsplash_api_dart/src/unsplash_exception.dart';

import 'models/models.dart';

const String API_URL = "https://api.unsplash.com";
const String API_VERSION = "v1";
const String OAUTH_AUTHORIZE_URL = "https://unsplash.com/oauth/authorize";
const String OAUTH_TOKEN_URL = "https://unsplash.com/oauth/token";

/// An Unsplash Client
class Unsplash {
  Unsplash({
    @required String accessKey,
    String apiUrl = API_URL,
    String apiVersion = API_VERSION,
    this.secret,
    this.callbackUrl,
    this.timeout = 0,
    Dio dio,
    List<Interceptor> interceptors = const [],
  }) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = apiUrl;
    _dio.interceptors.addAll(interceptors);
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options) {
          options.headers['Accept-Version'] = apiVersion;
          options.headers['Authorization'] = 'Client-ID $accessKey';
        },
      ),
    );
  }

  final String secret;
  final String callbackUrl;
  final int timeout;

  final Dio _dio;

  static const GET_PHOTO = '/photos';
  static const SEARCH_PHOTO = '/search/photos';

  /// Returns a list of photos from all of the Unsplash photos.
  Future<List<Photo>> getPhotos({@required String clientId}) async {
    try {
      Response response = await _dio.get<List>(GET_PHOTO);
      return List.from(response.data)
          .map((photo) => Photo.fromMap(photo))
          .toList();
    } on DioError catch (e) {
      if (e.response != null) {
        throw UnsplashException(
          e.response.statusCode,
          'Failed to load photos',
          e.response.statusMessage,
        );
      }

      throw UnsplashException(-1, e.error?.toString(), e.type?.toString());
    }
  }

  /// Returns an individual photo by ID from Unsplash.
  Future<Photo> getPhoto(String id) async {
    try {
      final response = await _dio.get<Map>('$GET_PHOTO/$id');

      return Photo.fromMap(response.data);
    } on DioError catch (e) {
      if (e.response != null) {
        throw UnsplashException(
          e.response.statusCode,
          'Failed to load photo',
          e.response.statusMessage,
        );
      }

      throw UnsplashException(-1, e.error?.toString(), e.type?.toString());
    }
  }

  /// Performs an image search based on the provided [query].
  Future<SearchPhotoResult> search(
    String query, {
    String orientation = PhotoOrientation.PORTRAIT,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _dio.get<Map>(SEARCH_PHOTO, queryParameters: {
        'query': query,
        'page': page,
        'per_page': perPage,
        'orientation': orientation,
      });

      return SearchPhotoResult.fromMap(response.data);
    } on DioError catch (e) {
      if (e.response != null) {
        throw UnsplashException(
          e.response.statusCode,
          'Failed to search photos',
          e.response.statusMessage,
        );
      }

      throw UnsplashException(-1, e.error?.toString(), e.type?.toString());
    }
  }

  /// Sends a request to Unsplash indicating the provided [Photo] has been used
  /// in a way that would be considered downloaded.
  Future<void> download(Photo photo) async {
    try {
      await _dio.get(photo.links.downloadLocation);
    } on DioError catch (e) {
      if (e.response != null) {
        throw UnsplashException(
          e.response.statusCode,
          'Could not mark image as downloaded',
          e.response.statusMessage,
        );
      }

      throw UnsplashException(-1, e.error?.toString(), e.type?.toString());
    }
  }
}

class PhotoOrientation {
  static const String LANDSCAPE = 'landscape';
  static const String PORTRAIT = 'portrait';
  static const String SQUARISH = 'squarish';
}
