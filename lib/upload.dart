import 'package:async/async.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';

class Upload extends StatefulWidget {
  @override
  _UploadState createState() => _UploadState();
}

// const kUrl = 'http://40.73.3.5:8080/';

class _UploadState extends State<Upload> {
  String server = '';
  String name = '';
  String mp3File = '';
  String midiFile = '';
  String downloadedFile = '';
  double? _progBarValue = 0.0;

  var transcribed = false;
  var transcribing = false;

  List<String> serverList = ['http://40.73.3.5:8080/', 'No server'];

  @override
  void initState() {
    initServer();
    super.initState();
  }

  Future initServer() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('server') == '') {
      server = serverList[0];
      prefs.setString('server', server);
    }
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
    void showMsg(String text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            text,
            style: TextStyle(fontFamily: 'Raleway'),
          ),
          duration: Duration(milliseconds: 2000),

          // behavior: SnackBarBehavior.floating,
        ),
      );
    }

    uploadMp3FileToServer(String mp3File) async {
      File mp3FileContent = File(mp3File);
      final stream =
          new ByteStream(DelegatingStream.typed(mp3FileContent.openRead()));
      final length = await mp3FileContent.length();

      final estimatedTime = length ~/ 40000;

      setState(() {
        _progBarValue = null;
      });
      if (server.startsWith('http')) {
        try {
          var uri = Uri.parse(server + '/transcript/');
          var request = new MultipartRequest("POST", uri);
          var multipartFile = new MultipartFile('file', stream, length,
              filename: basename(mp3File));

          request.files.add(multipartFile);

          var response = await request.send();
          showMsg('Estimated time of transcription: $estimatedTime' + 's');

          print('Status code: {$response.statusCode}');
          setMidiFileValue(server +
              "/static/midi/" +
              mp3File.split("/").last.replaceFirst('.mp3', '.mid'));
          transcribed = true;
          transcribing = false;
          showMsg('Transciption finished!');
        } catch (e) {
          showMsg('Transcription failed: ${e.toString()}');
          transcribing = false;
          setState(() {
            _progBarValue = null;
          });
        }
      } else {
        showMsg('Wait for 5 seconds...');
        await Future.delayed(Duration(seconds: 5));
        transcribed = true;
        transcribing = false;
        showMsg('Transciption finished!');
      }
      setState(() {
        _progBarValue = 1;
      });
    }

    // implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("NeuTranscriptor"),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        titleTextStyle: TextStyle(
          fontFamily: 'Raleway',
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            if (!transcribing) {
              final prefs = await SharedPreferences.getInstance();
              server = await showDialog(
                context: context,
                builder: (_) => SimpleDialog(
                  title: const Text('Select a webservice'),
                  children: <Widget>[
                    SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(context, serverList[0]);
                          showMsg('Webservice changed to: ${serverList[0]}');
                        },
                        child: prefs.getString('server') == serverList[0]
                            ? Text(serverList[0] + ' (current)')
                            : Text(serverList[0])),
                    SimpleDialogOption(
                      onPressed: () {
                        Navigator.pop(context, serverList[1]);
                        showMsg('Webservice changed to: ${serverList[1]}');
                      },
                      child: prefs.getString('server') == serverList[1]
                          ? Text(serverList[1] + ' (current)')
                          : Text(serverList[1]),
                    ),
                  ],
                ),
              );

              prefs.setString('server', server);
            } else {
              showMsg('Transcription in process. Can\'t change the webservice');
            }
          } catch (e) {
            null;
          }
        },
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: const Icon(Icons.dns_rounded),
      ),
      body: SafeArea(
        child: Container(
          // alignment: Alignment.bottomCenter,
          padding: EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 250,
                  width: 250,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.all(10)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
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
                      setState(
                        () {
                          if (result != null) {
                            // transcribing = false;
                            transcribed = false;
                            mp3File = result.files.single.path.toString();
                            name = result.files.single.name.toString();
                            _progBarValue = 0;
                            showMsg('$name loaded!');
                          }
                        },
                      );
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
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
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
                      if (transcribing) {
                        showMsg('Transcription in process. Please wait.');
                      } else if (transcribed) {
                        showMsg('Transcription finished!');
                      } else if (mp3File == '') {
                        showMsg('Please pick an MP3 file first!');
                      } else {
                        transcribing = true;
                        uploadMp3FileToServer(mp3File);
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
                if (transcribing)
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
          ),
        ),
      ),
    );
  }
}
