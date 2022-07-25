import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'player_widget.dart';

class Upload extends StatefulWidget {
  @override
  _UploadState createState() => _UploadState();
}

const kUrl = 'http://40.73.3.5:8080/';

class _UploadState extends State<Upload> {
  String mp3File = '';
  String name = '';
  String midiFile = '';
  String downloadedFile = '';
  double? _progBarValue = 0.0;

  var pressed = false;
  var transcribed = false;

  @override
  void initState() {
    super.initState();
  }

  Future setProgressBarValue(double value) async {
    setState(() {
      _progBarValue = value;
    });
  }

  Future setMidiFileValue(String value) async {
    setState(() {
      midiFile = value;
    });
  }

  Future downLoadFile() async {
    if (midiFile != '') {
      print("MIDI file: " + midiFile);
      launchUrl(Uri.parse(midiFile));
    }
  }

  @override
  Widget build(BuildContext context) {
    uploadMp3FileToServer(String mp3File) async {
      setState(() {
        _progBarValue = null;
      });
      print("attempting to connect to server......");
      File mp3FileContent = File(mp3File);
      var stream =
          new ByteStream(DelegatingStream.typed(mp3FileContent.openRead()));
      var length = await mp3FileContent.length();
      print('length: $length');
      final estimatedTime = length ~/ 40000;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Estimated time of transcription: $estimatedTime' + 's')));

      var uri = Uri.parse(kUrl + '/transcript/');
      var request = new MultipartRequest("POST", uri);
      var multipartFile = new MultipartFile('file', stream, length,
          filename: basename(mp3File));

      request.files.add(multipartFile);
      var response = await request.send();
      print('status code: {$response.statusCode}');

      // await Future.delayed(Duration(seconds: 5));

      setMidiFileValue(kUrl +
          "/static/midi/" +
          mp3File.split("/").last.replaceFirst('.mp3', '.mid'));
      setState(() {
        _progBarValue = 1;
        transcribed = true;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Transciption finished!')));
      });
    }

    // implement build
    return Scaffold(
      // backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text("NeuTranscriptor"),
        elevation: 0,

        // titleTextStyle: Theme.of(context).textTheme,
      ),
      body: SafeArea(
        child: Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.all(16),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 250,
                    width: 250,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.all(10)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(6.0),
                            child: Icon(
                              Icons.music_note,
                              color: Colors.white,
                              size: 64,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(6.0),
                            child: Text(
                              'Pick an MP3 file',
                              style: Theme.of(context).textTheme.button,
                            ),
                          ),
                        ],
                      ),
                      onPressed: () async {
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['mp3'],
                        );
                        setState(() {
                          if (result != null) {
                            pressed = false;
                            transcribed = false;
                            mp3File = result.files.single.path.toString();
                            name = result.files.single.name.toString();
                            _progBarValue = 0;
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$name loaded!')));
                          }
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton.icon(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.all(10)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (mp3File != '') {
                          pressed = true;
                          uploadMp3FileToServer(mp3File);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please pick an MP3 file first!'),
                            ),
                          );
                        }
                      },
                      label: Text(
                        'Transcribe',
                        style: Theme.of(context).textTheme.button,
                      ),
                      icon: Icon(
                        Icons.file_upload,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  if (pressed && !transcribed)
                    CircularProgressIndicator(
                      value: _progBarValue,
                      color: Colors.white,
                    ),
                  if (transcribed)
                    SizedBox(
                      width: 200,
                      child: ElevatedButton.icon(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              EdgeInsets.all(10)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        onPressed: downLoadFile,
                        label: Text(
                          'Download',
                          style: Theme.of(context).textTheme.button,
                        ),
                        icon: Icon(
                          Icons.file_download,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            )),
      ),
    );
  }
}
