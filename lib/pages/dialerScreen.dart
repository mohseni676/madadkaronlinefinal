import 'package:flutter/material.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:madadkaronline/style/theme.dart' as Theme;
import 'package:sip_ua/sip_ua.dart';


class DialerPage extends StatefulWidget {
  @override
  _DialerPageState createState() => _DialerPageState();
}

class _DialerPageState extends State<DialerPage>
    implements SipUaHelperListener {
  String _password = 'alimohseni@62';
  String _wsUri = 'ws://vs.sharifngo.com:8088/ws';
  String _sipUri = '4009@vs.sharifngo.com';
  String _displayName = '4009';
  String _authorizationUser = '4009';
  TextEditingController _controller = new TextEditingController();

  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

//  double _localVideoHeight;
//  double _localVideoWidth;
//  EdgeInsetsGeometry _localVideoMargin;
  MediaStream _localStream;
  MediaStream _remoteStream;

  String _RegistrationState = '';
  String _PhoneState = '';

  RegistrationState _registrationState;
  CallStateEnum _callstate = CallStateEnum.NONE;
  SIPUAHelper helper = SIPUAHelper();
  bool isRegistered = false;

  Future<List<HamisInfo>> GetHamis() async {

  }

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

  void _handleHangup() {
    helper.hangup();
  }

  void _handleAccept() {
    helper.answer();
  }

  void _initRenderers() async {
    if (_localRenderer != null) {
      await _localRenderer.initialize();
    }
    if (_remoteRenderer != null) {
      await _remoteRenderer.initialize();
    }
  }

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

  Widget _handleCall(BuildContext context) {
    var dest = _controller.text;
    if (dest == null || dest.isEmpty) {
      showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('شماره خالی.'),
            content: Text('لطفا یک شماره یا داخلی را وارد کنید'),
            actions: <Widget>[
              FlatButton(
                child: Text('قبول'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return null;
    }

    helper.call(dest, true);
    // _preferences.setString('dest', dest);
    return null;
  }

  handleSave(BuildContext context) {
    UaSettings settings = UaSettings();

    settings.webSocketUrl = _wsUri;
    settings.uri = _sipUri;
    settings.authorizationUser = _authorizationUser;
    settings.password = _password;
    settings.displayName = _displayName;
    //settings.webSocketExtraHeaders = _wsExtraHeaders;

    helper.start(settings);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _registrationState = helper.registerState;
    helper.addSipUaHelperListener(this);
    handleSave(context);
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    helper.removeSipUaHelperListener(this);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: new Scaffold(
        appBar: AppBar(
            title: new Row(
              children: <Widget>[
                new Text('وضعیت خط تلفن'),
                new Icon(
                  isRegistered ? Icons.phone_android : Icons.phonelink_erase,
                  color: isRegistered ? Colors.greenAccent : Colors.black26,
                ),
              ],
            )
        ),
        body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height >= 775.0
                ? MediaQuery.of(context).size.height
                : 775.0,
            decoration: new BoxDecoration(
              gradient: new LinearGradient(
                  colors: [
                    Theme.Colors.loginGradientStart,
                    Theme.Colors.loginGradientEnd
                  ],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(1.0, 1.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp),
            ),
            child: new Center(
                child: new Container(
              height: 400,
              width: 400,
              child: new Card(
                color: Colors.white60,
                child: new Container(
                  height: MediaQuery.of(context).size.height >= 235.0
                      ? MediaQuery.of(context).size.height
                      : 235.0,
                  padding: EdgeInsets.all(15),
                  child: Column(
                    //mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Text('شماره تماس'),
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                      ),
                      new TextField(
                        controller: _controller,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            prefixIcon: Icon(FontAwesomeIcons.phoneSquare)),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                      ),
                      new MaterialButton(
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Text('شماره گیری'),
                              Padding(
                                padding: EdgeInsets.only(left: 35),
                              ),
                              new Icon(
                                FontAwesomeIcons.phoneAlt,
                                color: Colors.white,
                              )
                            ],
                          ),
                          color: Colors.greenAccent,
                          padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                          onPressed: () {
                            FocusScopeNode currentFocus =
                                FocusScope.of(context);

                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                            _handleCall(context);
                          }),
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                      ),
                      new MaterialButton(
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Text('قطع تماس'),
                              Padding(
                                padding: EdgeInsets.only(left: 35),
                              ),
                              new Icon(
                                FontAwesomeIcons.phoneSquareAlt,
                                color: Colors.white,
                              )
                            ],
                          ),
                          color: Colors.greenAccent,
                          padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                          onPressed: () {
                            _handleHangup();
                          }),
                      new Text('${_registrationState.state}'),
                      new Text('${_PhoneState}')
                    ],
                  ),
                ),
              ),
            ))),
      ),
    );
  }

  @override
  void callStateChanged(CallState state) {
    setState(() {
      _callstate = state.state;
    });
    // TODO: implement callStateChanged
    if (state.state == CallStateEnum.STREAM) {
      _handelStreams(state);
    }
    switch (state.state) {
      case CallStateEnum.STREAM:
        {
          setState(() {
            _PhoneState = 'تماس برقرار است';
          });
          break;
        }
      case CallStateEnum.CALL_INITIATION:
      case CallStateEnum.PROGRESS:
        {
          setState(() {
            _PhoneState = 'در حال برقراری تماس';
          });
          break;
        }
      case CallStateEnum.ENDED:
        {
          setState(() {
            _PhoneState = 'تماس پایان یافت';
          });
          break;
        }
      case CallStateEnum.CONFIRMED:
      case CallStateEnum.ACCEPTED:
        {
          _PhoneState = 'تماس پاسخ داده شده است';
          break;
        }

      default:
        {
          setState(() {
            _PhoneState = '';
          });
        }
    }
  }

  @override
  void registrationStateChanged(RegistrationState state) {
    setState(() {
      _registrationState = state;
      if (_registrationState.state == RegistrationStateEnum.REGISTERED)
        setState(() {
          isRegistered = true;
        });
      else if (_registrationState.state == RegistrationStateEnum.UNREGISTERED)
        setState(() {
          isRegistered = false;
        });
    });
  }

  @override
  void transportStateChanged(TransportState state) {
    // TODO: implement transportStateChanged
  }
}
