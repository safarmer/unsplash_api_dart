import 'package:test/test.dart';
import 'package:unsplash_api_dart/unsplash_api_dart.dart';

const String accessKey = '';

void main() {
  final Unsplash unsplash = Unsplash(accessKey: accessKey);

  test('Get Photos', () async {
    List<Photo> data = await unsplash.getPhotos(
      clientId: accessKey,
    );
    expect(data.length, 10);
  });

  test('Get One Photo', () async {
    Photo photo = await unsplash.getPhoto('dQ_b1I6xm3Q');
    expect(photo.id, 'dQ_b1I6xm3Q');
  });

  test('Search android wallpaper', () async {
    SearchPhotoResult result = await unsplash.search('android');
    expect(result.results.length, 10);
  });
}
