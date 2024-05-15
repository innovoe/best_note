import 'dart:async';
import 'package:light_compressor/light_compressor.dart';

class VideoCompressor{
  final String path;
  final String destinationPath;
  final LightCompressor _lightCompressor = LightCompressor();
  VideoCompressor({required this.path, required this.destinationPath});
  Stream<double> get videoCompressUpdate => _lightCompressor.onProgressUpdated;
  Future<bool> compress() async {
    final dynamic response = await _lightCompressor.compressVideo(
      path: path,
      destinationPath: destinationPath,
      videoQuality: VideoQuality.low,
      isMinBitrateCheckEnabled: false
    );
    if(response is OnSuccess){
      return true;
    }else if(response is OnFailure){
      print('Video Compress failed ${response.message}');
      return false;
    }
    return false;
  }
}

// class VideoCompressorOld{
//   XFile source;
//   VideoCompressor({required this.source});
//
//   Future<MediaInfo?> compress() async{
//     try{
//       await VideoCompress.setLogLevel(0);
//       return await VideoCompress.compressVideo(
//           source.path,
//           quality: VideoQuality.LowQuality,
//           includeAudio: true,
//           deleteOrigin: true
//       );
//     }catch(e){
//       print('compression failed $e');
//       VideoCompress.cancelCompression();
//     }
//     return null;
//   }




// }