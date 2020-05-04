import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:sip_ua/sip_ua.dart';

class callScreen extends StatefulWidget {
  final SIPUAHelper SipHelper;
  final String PhoneNumber;


  const callScreen({Key key, this.SipHelper, this.PhoneNumber})
      : super(key: key);

  @override
  _callScreenState createState() => _callScreenState();
}

class _callScreenState extends State<callScreen>
    implements SipUaHelperListener {


  String _timeLabel = '00:00';
  Timer _timer;

  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  MediaStream _localStream;
  MediaStream _remoteStream;

  SIPUAHelper get helper => widget.SipHelper;
  CallStateEnum _callstate = CallStateEnum.NONE;

  void _handelStreams(CallState event) async {
    MediaStream stream = event.stream;

    if (event.originator == 'local') {
      if (_localRenderer != null) {
        _localRenderer.srcObject = stream;
      }
      _localStream = stream;
      _localStream.getAudioTracks()[0].enableSpeakerphone(false);
    }
    if (event.originator == 'remote') {
      if (_remoteRenderer != null) {
        _remoteRenderer.srcObject = stream;
      }
      _remoteStream = stream;
      _remoteStream.getAudioTracks()[0].enableSpeakerphone(false);
    }
  }

  //بخش مربوط به عملیات قطع تماس
  void _handleHangup() {
    helper.hangup();
    _timer.cancel();
  }

  //تنظیم و راه اندازی رندر صوت
  void _initRenderers() async {
    if (_localRenderer != null) {
      await _localRenderer.initialize();
    }
    if (_remoteRenderer != null) {
      await _remoteRenderer.initialize();
    }
  }

  //از بین بردن رندرهای صوت
  void _disposeRenderers() {
    if (_localRenderer != null) {
      _localRenderer.dispose();
      _localRenderer = null;
    }
    if (_remoteRenderer != null) {
      _remoteRenderer.dispose();
      _remoteRenderer = null;
    }
  }

  //ویجت انجام شماره گیری و برقراری تماس
  Widget _handleCall(BuildContext context) {
    var dest = widget.PhoneNumber;
    _startTimer();


    helper.call(dest, true);
    // _preferences.setString('dest', dest);
    return null;
  }

  //ایجاد کننده تایمر تماس
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      Duration duration = Duration(seconds: timer.tick);
      if (mounted) {
        this.setState(() {
          _timeLabel = [duration.inMinutes, duration.inSeconds]
              .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
              .join(':');
        });
      } else {
        _timer.cancel();
      }
    });
  }


  //برگشت به صفحه قبل
  void _backToDialPad() {
    _timer.cancel();
    Timer(Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }


  @override
  void initState() {
    super.initState();

    _initRenderers();
    helper.addSipUaHelperListener(this);
//_startTimer();
  }


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
          appBar: AppBar(
            title: new Text('Call Screen'),
          ),
          body:
          new Container(
            height: MediaQuery
                .of(context)
                .size
                .height,
            width: MediaQuery
                .of(context)
                .size
                .width,
            child: Center(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Text(_timeLabel),
                  RaisedButton(
                    child: new Text('Call ${widget.PhoneNumber}'),
                    color: Colors.green,
                    onPressed: () {
                      _handleCall(context);
                    },
                  ), RaisedButton(
                    child: new Text('End ${widget.PhoneNumber}'),
                    color: Colors.red,
                    onPressed: () {
                      _handleHangup();
                    },

                  ),

                ],
              ),
            ),

          )
      ),
    );
  }

  @override
  void callStateChanged(CallState state) {
    // TODO: implement callStateChanged

    if (state == CallStateEnum.STREAM) {
      _handelStreams(state);
    }
  }

  @override
  void registrationStateChanged(RegistrationState state) {
    // TODO: implement registrationStateChanged
  }

  @override
  void transportStateChanged(TransportState state) {
    // TODO: implement transportStateChanged
  }
}
