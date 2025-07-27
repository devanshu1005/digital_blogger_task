import 'package:flutter/material.dart';
import '../models/video_model.dart';

class VideoProvider with ChangeNotifier {
  final List<VideoModel> _videos = [
    VideoModel(title: "Mux Stream", url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8"),
    VideoModel(title: "Sintel", url: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"),
    // VideoModel(title: "Akamai Live", url: "https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8"),
    // VideoModel(title: "NETtv", url: "https://mojenmoje-live.mncnow.id/live/eds/NETtv-HD/sa_dash_vmx/NETtv-HD.m3u8"),
    // VideoModel(title: "CloudFront", url: "https://d2hxw1celoutbe.cloudfront.net/playlist.m3u8"),
    // VideoModel(title: "TeleQuebec", url: "https://mnmedias.api.telequebec.tv/m3u8/29880.m3u8"),
    // VideoModel(title: "3SAT", url: "https://streaming.3sat.de/hls/live/2013675/de/master.m3u8"),
    VideoModel(title: "Al Jazeera", url: "https://live-hls-web-aje.getaj.net/AJE/01.m3u8"),
    VideoModel(title: "RT News", url: "https://rt-glb.rttv.com/live/rtnews/playlist.m3u8"),
    // VideoModel(title: "TV Org", url: "https://iptv-org.github.io/streams/tv.m3u8"),
  ];

  List<VideoModel> get videos => _videos;
}
