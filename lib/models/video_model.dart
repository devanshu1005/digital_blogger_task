class VideoModel {
  final String title;
  final String url;
  final String? thumbnail;
  final String? description;
  final Duration? duration;
  final bool isLive;
  final VideoQuality defaultQuality;

  const VideoModel({
    required this.title,
    required this.url,
    this.thumbnail,
    this.description,
    this.duration,
    this.isLive = false,
    this.defaultQuality = VideoQuality.auto,
  });

  VideoModel copyWith({
    String? title,
    String? url,
    String? thumbnail,
    String? description,
    Duration? duration,
    bool? isLive,
    VideoQuality? defaultQuality,
  }) {
    return VideoModel(
      title: title ?? this.title,
      url: url ?? this.url,
      thumbnail: thumbnail ?? this.thumbnail,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      isLive: isLive ?? this.isLive,
      defaultQuality: defaultQuality ?? this.defaultQuality,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'thumbnail': thumbnail,
      'description': description,
      'duration': duration?.inSeconds,
      'isLive': isLive,
      'defaultQuality': defaultQuality.name,
    };
  }

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      thumbnail: json['thumbnail'],
      description: json['description'],
      duration: json['duration'] != null 
          ? Duration(seconds: json['duration']) 
          : null,
      isLive: json['isLive'] ?? false,
      defaultQuality: VideoQuality.values.firstWhere(
        (q) => q.name == json['defaultQuality'],
        orElse: () => VideoQuality.auto,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoModel &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          url == other.url;

  @override
  int get hashCode => title.hashCode ^ url.hashCode;
}

enum VideoQuality { 
  auto,
  p144,
  p240,
  p360,
  p480,
  p720,
  p1080,
}

extension VideoQualityExtension on VideoQuality {
  String get displayName {
    switch (this) {
      case VideoQuality.auto:
        return 'Auto';
      case VideoQuality.p144:
        return '144p';
      case VideoQuality.p240:
        return '240p';
      case VideoQuality.p360:
        return '360p';
      case VideoQuality.p480:
        return '480p';
      case VideoQuality.p720:
        return '720p';
      case VideoQuality.p1080:
        return '1080p';
    }
  }
}