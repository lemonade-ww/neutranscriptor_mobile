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

      // var uri = Uri.parse(kUrl + '/transcript/');
      // var request = new MultipartRequest("POST", uri);
      // var multipartFile = new MultipartFile('file', stream, length,
      //     filename: basename(mp3File));

      // request.files.add(multipartFile);
      // var response = await request.send();
      // print('status code: {$response.statusCode}');

      await Future.delayed(Duration(seconds: 1));

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
      ),
      body: SafeArea(
        child: Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.all(16),
            child: Center(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 16),
                  ElevatedButton.icon(
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
                          _progBarValue = 0;
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('File loaded! $mp3File')));
                        }
                      });
                    },
                    label: Text(
                      'Pick a MP3 file',
                      style: Theme.of(context).textTheme.button,
                    ),
                    icon: Icon(
                      Icons.music_note,
                      color: Colors.white,
                    ),
                  ),
                  if (mp3File != '')
                    Column(
                      children: [
                        // SizedBox(height: 16),
                        // PlayerWidget(
                        //   url: mp3File,
                        // ),
                        SizedBox(height: 16),
                        Divider(
                          height: 6,
                          thickness: 2,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            pressed = true;
                            uploadMp3FileToServer(mp3File);
                          },
                          label: Text(
                            'Upload & transcribe',
                            style: Theme.of(context).textTheme.button,
                          ),
                          icon: Icon(
                            Icons.file_upload,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  if (pressed)
                    Column(
                      children: [
                        CircularProgressIndicator(
                          value: _progBarValue,
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  if (transcribed)
                    Column(
                      children: [
                        Divider(
                          height: 6,
                          thickness: 2,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
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
                      ],
                    ),
                ],
              ),
            )),
      ),
    );
  }
}
