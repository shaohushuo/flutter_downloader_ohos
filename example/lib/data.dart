class DownloadItems {
  static const images = [
    DownloadItem(
      name: 'Arches National Park',
      url:
          'https://images.pexels.com/photos/26690031/pexels-photo-26690031.jpeg',
    ),
    DownloadItem(
      name: 'Canyonlands National Park',
      url:
          'https://images.pexels.com/photos/23495788/pexels-photo-23495788.jpeg',
    ),
    DownloadItem(
      name: 'Death Valley National Park',
      url:
          'https://images.pexels.com/photos/27675493/pexels-photo-27675493.jpeg',
    ),
  ];

  static const videos = [
    DownloadItem(
      name: 'Big Buck Bunny',
      url:
          'https://videos.pexels.com/video-files/17880140/17880140-uhd_1440_2560_60fps.mp4',
    ),
    DownloadItem(
      name: 'Elephant Dream',
      url:
          'https://videos.pexels.com/video-files/20500768/20500768-uhd_1440_2560_30fps.mp4',
    ),
  ];
}

class DownloadItem {
  const DownloadItem({required this.name, required this.url});

  final String name;
  final String url;
}
