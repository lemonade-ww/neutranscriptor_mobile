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

class _UploadState extends State<Upload> {
  String server = '';
  String name = '';
  String mp3File = '';
  String midiFile = '';
  String downloadedFile = '';
  double? _progBarValue = 0.0;

  var transcribed = false;
  var transcribing = false;

  List<String> serverList = [
    'http://40.73.3.5:9075',
    'http://192.168.0.102:9075',
    'Debug Only'
  ];

  @override
  void initState() {
    initServer();
    super.initState();
  }

  Future initServer() async {
    final prefs = await SharedPreferences.getInstance();
    if (server == '') {
      setState(() {
        server = serverList[serverList.length - 1];
        prefs.setString('server', server);
      });
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
      launchUrl(Uri.parse(midiFile));
    }
  }

  reset() {
    setState(() {
      transcribing = false;
      transcribed = false;
      _progBarValue = 0;
    });
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
      setState(() {
        _progBarValue = null;
      });
      if (!server.startsWith('Debug')) {
        File mp3FileContent = File(mp3File);
        final stream =
            new ByteStream(DelegatingStream.typed(mp3FileContent.openRead()));
        final length = await mp3FileContent.length();
        String midiFileName =
            mp3File.split("/").last.replaceFirst('.mp3', '.mid');
        String midiFilePath = server + "/static/midi/" + midiFileName;

        try {
          var uri = Uri.parse(server + '/transcription/');
          var request = new MultipartRequest("POST", uri);
          var multipartFile = new MultipartFile('file', stream, length,
              filename: basename(mp3File));

          request.files.add(multipartFile);

          var response = await request.send();
          // showMsg('Estimated time of transcription: $estimatedTime' + 's');

          print('Status code: {$response.statusCode}');
          setMidiFileValue(midiFilePath);
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
        showMsg('Wait for 3 seconds...');
        await Future.delayed(Duration(seconds: 3));
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
                  title: const Text('Select a Server'),
                  children: <Widget>[
                    for (var server in serverList)
                      SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(context, server);
                          setState(() {
                            server = server;
                          });
                          showMsg('Server changed to: $server');
                        },
                        child: prefs.getString('server') == server
                            ? Text(
                                '$server (Current)',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              )
                            : Text(server),
                      ),
                  ],
                ),
              );
              prefs.setString('server', server);
            } else {
              showMsg('Transcription in process. Cannot change the server');
            }
          } catch (e) {
            null;
          }
        },
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: const Icon(Icons.settings_rounded),
      ),
      body: SafeArea(
        child: Container(
          // alignment: Alignment.bottomCenter,
          padding: EdgeInsets.all(16),
          child: Stack(
            children: [
              Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 250,
                        width: 250,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.music_note,
                                color: Colors.white,
                                size: 64,
                              ),
                              SizedBox(height: 16),
                              Text(
                                name.isEmpty
                                    ? 'Pick an MP3 file'
                                    : 'File Loaded:\n$name',
                                style: Theme.of(context).textTheme.labelLarge,
                                textAlign: TextAlign.center,
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
                                  reset();
                                  mp3File = result.files.single.path.toString();
                                  name = result.files.single.name.toString();
                                  showMsg('$name loaded!');
                                }
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        width: 200,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          onPressed: () {
                            if (transcribing) {
                              showMsg('Transcription in process. Please wait.');
                            } else if (transcribed) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Restart Confirmation'),
                                    content:
                                        Text('Transcription finished. Do you really want to restart?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text('Yes'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          reset();
                                          transcribing = true;
                                          uploadMp3FileToServer(mp3File);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else if (mp3File == '') {
                              showMsg('Please pick an MP3 file first!');
                            } else {
                              transcribing = true;
                              uploadMp3FileToServer(mp3File);
                            }
                          },
                          label: Text(
                            'Transcribe',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          icon: Icon(
                            Icons.file_upload,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      if (transcribing && !transcribed)
                        Container(
                          height: 48,
                          width: 48,
                          child: CircularProgressIndicator(
                            value: _progBarValue,
                            color: Colors.white,
                          ),
                        ),
                      if (transcribed)
                        Container(
                            width: 200,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                side: BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              onPressed: downLoadFile,
                              label: Text(
                                'Download',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              icon: Icon(
                                Icons.file_download,
                                color: Colors.white,
                              ),
                            )),
                    ],
                  )),
              Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  'Server: $server',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
