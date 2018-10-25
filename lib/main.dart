import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html_view/flutter_html_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:shimmer/shimmer.dart';

import 'api.dart';
import 'breach.dart';
import 'paste.dart';
import 'constants.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FocusNode _searchFocus = FocusNode();
  final TextEditingController _controller = new TextEditingController();
  final List<String> menuItems = ["About"];
  String _inputEmail;
  List<Breach> _breachList;
  bool _loadingBreachList;
  String _errorInBreachList;
  List<Paste> _pasteList;
  bool _loadingPasteList;
  String _errorInPasteList;

  void _setEmail(email) {
    setState(() {
      _inputEmail = email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Card(
          elevation: 4.0,
          child: Row(
            children: <Widget>[
              InkWell(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                ),
                onTap: () => FocusScope.of(context).requestFocus(_searchFocus),
              ),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(
                      top: 12.0,
                      right: 12.0,
                      bottom: 12.0,
                    ),
                    border: InputBorder.none,
                    hintText: "Enter email",
                  ),
                  onSubmitted: (email) => loadResult(email),
                  focusNode: _searchFocus,
                  controller: _controller,
                ),
              ),
              InkWell(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Icon(
                    Icons.close,
                    color: Colors.grey,
                  ),
                ),
                onTap: () => _controller.clear(),
              ),
              InkWell(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Icon(
                    Icons.info_outline,
                    color: Colors.grey,
                  ),
                ),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutPage()),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Builder(
        builder: (BuildContext context) {
          return Center(
            child: getHomePage(),
          );
        },
      ),
    )
    ;
  }

  Widget getHomePage() {
    if (_inputEmail == null || _inputEmail.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.search, size: 140.0, color: Colors.black26,),
          Text(
            "Enter your email in search bar",
            style: TextStyle(color: Colors.black38),
          ),
          Text(
            "to find breaches",
            style: TextStyle(color: Colors.black38),
          ),
        ],
      );
    }

    List<Widget> homeWidgets = List();
    homeWidgets.add(getResultOverview(_breachList?.length ?? 0, _pasteList?.length ?? 0));
    homeWidgets.addAll(getBreachWidgets());

    if ((!_loadingBreachList && !_loadingPasteList)
        && (_breachList.length ?? 0) == 0
        && (_pasteList.length ?? 0) == 0) {
      homeWidgets.add(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 32.0)),
              Icon(Icons.thumb_up, size: 140.0, color: Colors.black26,),
              Text(
                "All well and good.",
                style: TextStyle(color: Colors.black38),
              ),
            ],
          )
      );
    }

    homeWidgets.add(Center(
        child: Container(
          width: 240.0,
          child: FlatButton(
            padding: EdgeInsets.all(0.0),
            child: Text(
              "Subscribe to access sesitive breach and new breach alert.",
              textAlign: TextAlign.center,
            ),
            onPressed: () => launchURL(context, "https://haveibeenpwned.com/NotifyMe"),
          ),
        )
    ));

    homeWidgets.addAll(getPasteWidgets());

    return ListView(
      children: homeWidgets,
    );
  }

  List<Widget> getBreachWidgets() {
    List<Widget> breachWidgets = List();

    if (_errorInBreachList != null) {
      breachWidgets.add(Text(_errorInBreachList));
      return breachWidgets;
    }

    if (_loadingBreachList || (_breachList?.length ?? 0) > 0) {
      breachWidgets.add(Heading("Breaches"));
      breachWidgets.add(Description("A \"breach\" is an incident where data has been unintentionally exposed to the public."));
    }

    if (_loadingBreachList) {
      breachWidgets.addAll(List.generate(2, (int index) => ShimmerCard()));
      return breachWidgets;
    }
    breachWidgets.addAll(getBreachCards(_breachList));

    return breachWidgets;
  }

  List<Widget> getPasteWidgets() {
    List<Widget> pasteWidgets = List();

    if (_errorInPasteList != null) {
      pasteWidgets.add(Text(_errorInPasteList));
      return pasteWidgets;
    }

    if (_loadingPasteList || (_pasteList?.length ?? 0) > 0) {
      pasteWidgets.add(Heading("Pastes"));
      pasteWidgets.add(Description("A \"paste\" is information that has been published to a publicly facing website designed to share content and is often an early indicator of a data breach."));
    }
    if (_loadingPasteList) {
      pasteWidgets.addAll(List.generate(2, (int index) => ShimmerCard()));
      return pasteWidgets;
    }
    pasteWidgets.addAll(getPasteCards(_pasteList));

    return pasteWidgets;
  }

  Widget getResultOverview(int breachCount, int pasteCount) {
    Column heading = Column(
      children: <Widget>[
        getResultOverviewHeading(breachCount, pasteCount),
        getResultOverviewSubHeading(breachCount, pasteCount),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: getResultOverviewBackground(),
      ),
      child: heading,
      padding: EdgeInsets.all(12.0),
    );
  }

  Color getResultOverviewBackground() {
    int breachCount = _breachList?.length ?? 0;
    int pasteCount = _pasteList?.length ?? 0;

    if ((_loadingBreachList && _loadingPasteList)) {
      return Colors.grey;
    }

    if (breachCount > 0 || pasteCount > 0) {
      return Colors.red;
    }

    return Colors.green;
  }

  Widget getResultOverviewHeading(int breachCount, int pasteCount) {
    int breachCount = _breachList?.length ?? 0;
    int pasteCount = _pasteList?.length ?? 0;

    if (_loadingBreachList || _loadingPasteList) {
      return Shimmer.fromColors(
          baseColor: Colors.white24,
          highlightColor: Colors.white54,
          period: const Duration(milliseconds: 700),
          child: Container(
            margin: EdgeInsets.only(left: 24.0, right: 24.0, bottom: 8.0),
            height: 24.0,
            color: Colors.white,
          )
      );
    }

    if (breachCount > 0 || pasteCount > 0) {
      return ResultTitle("Oh no — pwned!");
    }

    return ResultTitle("Good news — no pwnage found!");
  }

  Widget getResultOverviewSubHeading(int breachCount, int pasteCount) {
    int breachCount = _breachList?.length ?? 0;
    int pasteCount = _pasteList?.length ?? 0;

    if (_loadingBreachList || _loadingPasteList) {
      return Shimmer.fromColors(
          baseColor: Colors.white24,
          highlightColor: Colors.white54,
          period: const Duration(milliseconds: 700),
          child: Container(
            margin: EdgeInsets.only(left: 12.0, right: 12.0,),
            height: 12.0,
            color: Colors.white,
          )
      );
    }

    String pwnedText = "Pwned on $breachCount breached sites";
    String andPasteText = " and found $pasteCount pastes";
    String pasteText = "Found $pasteCount pastes";

    if (breachCount > 0) {
      return ResultSubTitle(pasteCount > 0 ? pwnedText + andPasteText : pwnedText);
    } else if (pasteCount > 0) {
      return ResultSubTitle(pasteText);
    }

    return ResultSubTitle("No breached accounts");
  }

  List<Widget> getBreachCards(List<Breach> breaches) {
    return breaches.map((breach) {
      // Quick hack to parse &quot; - not supported in flutter_html_view
      String breachDescription = breach.description.replaceAll("&quot;", "\"");

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Card(
            child: ExpansionTile(
              title: Row(
                children: <Widget>[
                  Container(
                    child: getLogoImage(breach.name, breach.logoType),
                    width: 60.0,
                    height: 60.0,
                    margin: EdgeInsets.only(right: 12.0),
                    padding: EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    ),
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                breach.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                            Text(
                              breach.breachDate,
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.black26
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: getBreachLabels(breach),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: HtmlText(
                    data: breachDescription,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    bottom: 16.0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Compromised data: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Flexible(
                        child: Text(breach.dataClasses.join(", ")),
                      )
                    ],
                  ),
                )
              ],
            )
        ),
      );
    }).toList();
  }

  List<Widget> getPasteCards(List<Paste> pastes) {
    return pastes.map((paste) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Card(
          child: InkWell(
            onTap: () => launchURL(context, paste.url),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 8.0,
                right: 16.0,
                bottom: 8.0,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(child: Container(
                              margin: EdgeInsets.only(bottom: 6.0, right: 4.0),
                              child: Text(
                                paste.title ?? "No title",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            )),
                            Container(
                              margin: EdgeInsets.only(right: 8.0),
                              child: Text(
                                paste.date?.toString() ?? "",
                                style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.black26
                                )
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              "Email count: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              )
                            ),
                            Text(
                              paste.emailCount.toString(),
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey,)
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget getLogoImage(String name, String logoType) {
    if (logoType == "svg") {
      return SvgPicture.network(
        logoBase + name + "." + logoType,
        width: 50.0,
        height: 50.0,
        fit: BoxFit.contain,
      );
    }

    return CachedNetworkImage(
      imageUrl: logoBase + name + "." + logoType,
      width: 50.0,
      height: 12.0,
      fit: BoxFit.contain,
    );
  }

  List<Widget> getBreachLabels(Breach breach) {
    List<Widget> labels = List();

    if (breach.isSensitive) {
      labels.add(Container(
        margin: EdgeInsets.only(right: 4.0),
        child: Chip(
          labelStyle: TextStyle(
            fontSize: 10.0,
          ),
          backgroundColor: Colors.red,
          label: Text("Sensitive"),
        ),
      ));
    }

    labels.add(Container(
      margin: EdgeInsets.only(right: 4.0),
      child: Chip(
        labelStyle: TextStyle(
          fontSize: 10.0,
          color: breach.isVerified ? Colors.white : Colors.black,
        ),
        backgroundColor: breach.isVerified ? Colors.green : Colors.yellow,
        label: breach.isVerified ? Text("Verified") : Text("Unverified"),
      ),
    ));

    if (breach.isRetired) {
      labels.add(Container(
        margin: EdgeInsets.only(right: 4.0),
        child: Chip(
          labelStyle: TextStyle(
            fontSize: 10.0,
          ),
          backgroundColor: Colors.grey,
          label: Text("Retired"),
        ),
      ));
    }

    if (breach.isSpamList) {
      labels.add(Container(
        margin: EdgeInsets.only(right: 4.0),
        child: Chip(
          labelStyle: TextStyle(
            fontSize: 10.0,
          ),
          backgroundColor: Colors.blueGrey,
          label: Text("Spam List"),
        ),
      ));
    }

    if (breach.isFabricated) {
      labels.add(Chip(
        labelStyle: TextStyle(
          fontSize: 10.0,
        ),
        backgroundColor: Colors.cyan,
        label: Text("Fabricated"),
      ));
    }

    return labels;
  }

  void loadResult(String account) {
    if (account == null || account.isEmpty) {
      _setEmail(null);
    }

    loadBreachList(account);
    loadPasteList(account);
  }

  void loadBreachList(String account) {
    setState(() {
      _inputEmail = account;
      _breachList = null;
      _loadingBreachList = true;
      _errorInBreachList = null;
    });
    getBreaches(account).then((response) {
      setState(() {
        _breachList = response;
        _loadingBreachList = false;
      });
    }).catchError((error) {
      print(error);
      setState(() {
        _inputEmail = account;
        _breachList = null;
        _loadingBreachList = false;
        _errorInBreachList = error.toString();
      });
    });
  }

  void loadPasteList(String account) {
    setState(() {
      _inputEmail = account;
      _pasteList = null;
      _loadingPasteList = true;
      _errorInPasteList = null;
    });
    getPastes(account).then((response) {
      setState(() {
        _pasteList = response;
        _loadingPasteList = false;
      });
    }).catchError((error) {
      print(error);
      setState(() {
        _inputEmail = account;
        _pasteList = null;
        _loadingPasteList = false;
        _errorInPasteList = error.toString();
      });
    });
  }
}

void launchURL(BuildContext context, String url) async {
  try {
    await launch(
      url,
      option: new CustomTabsOption(
          toolbarColor: Theme.of(context).primaryColor,
          enableDefaultShare: true,
          enableUrlBarHiding: true,
          showPageTitle: true,
          animation: new CustomTabsAnimation.slideIn()
      ),
    );
  } catch (e) {
    // An exception is thrown if browser app is not installed on Android device.
    debugPrint(e.toString());
  }
}

class Heading extends StatelessWidget {
  final String text;

  Heading(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 12.0, top: 12.0, right: 12.0, bottom: 4.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class Description extends StatelessWidget {
  final String description;

  Description(this.description);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 12.0, right: 12.0, bottom: 10.0),
      child: Text(
        description,
        style: TextStyle(
          fontSize: 12.0,
          color: Colors.grey,
        ),
      ),
    );
  }
}

class ResultTitle extends StatelessWidget {
  final String data;

  ResultTitle(this.data);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        data,
        style: TextStyle(
          color: Colors.white,
          fontSize: 22.0,
        ),
      ),
    );;
  }
}

class ResultSubTitle extends StatelessWidget {
  final String data;

  ResultSubTitle(this.data);

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: TextStyle(
        color: Colors.white,
        fontSize: 12.0,
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          child: Row(
            children: <Widget>[
              Shimmer.fromColors(
                baseColor: Colors.grey[300],
                highlightColor: Colors.grey[100],
                child: Container(
                  color: Colors.white,
                  width: 60.0,
                  height: 60.0,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300],
                      highlightColor: Colors.grey[100],
                      child: Container(
                        margin: EdgeInsets.only(
                          left: 12.0,
                          right: 12.0,
                          bottom: 12.0,
                        ),
                        color: Colors.white,
                        height: 18.0,
                      ),
                    ),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300],
                      highlightColor: Colors.grey[100],
                      child: Container(
                        margin: EdgeInsets.only(
                          left: 12.0,
                          right: 12.0
                        ),
                        color: Colors.white,
                        height: 20.0,
                        width: 64.0,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Paragraph extends StatelessWidget {
  final String text;

  Paragraph(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16.0,
        color: Colors.black,
      ),
    );
  }

}

class AboutPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About PwnedOrNot"),
      ),
      body: Container(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: "This is an open source application made using "
                  ),
                  TextSpan(
                    text: "Flutter SDK",
                    style: TextStyle(
                      color: Colors.teal,
                      fontStyle: FontStyle.italic,
                      decoration: TextDecoration.underline
                    ),
                    recognizer: TapGestureRecognizer()..onTap = () {
                      launchURL(context, "https://flutter.io/");
                    }
                  ),
                  TextSpan(
                    text: ", you can checkout source code ",
                  ),
                  TextSpan(
                      text: "here",
                      style: TextStyle(
                        color: Colors.teal,
                        decoration: TextDecoration.underline
                      ),
                      recognizer: TapGestureRecognizer()..onTap = () {
                        launchURL(context, "https://github.com/callingmedic911/pwned_or_not");
                      }
                  ),
                  TextSpan(
                    text: ".",
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 12.0),
            ),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: "It uses "
                  ),
                  TextSpan(
                    text: "haveibeenpwned",
                    style: TextStyle(
                      color: Colors.teal,
                      fontStyle: FontStyle.italic,
                      decoration: TextDecoration.underline
                    ),
                    recognizer: TapGestureRecognizer()..onTap = () {
                      launchURL(context, "https://haveibeenpwned.com");
                    }
                  ),
                  TextSpan(
                    text: " API by Troy Hunt to fetch published breaches "
                        "and pastes. You can check API ", //todo insert link to API
                  ),
                  TextSpan(
                      text: "here",
                      style: TextStyle(
                          color: Colors.teal,
                          decoration: TextDecoration.underline
                      ),
                      recognizer: TapGestureRecognizer()..onTap = () {
                        launchURL(context, "https://haveibeenpwned.com/API/v2");
                      }
                  ),
                  TextSpan(
                    text: ".",
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 12.0),
            ),
            Paragraph(
              "Please note, since API does not provide senstive breach information for obivous "
                  "reasons, you have to subscribe to notification service provided "
                  "haveibenpwned website" //todo insert link to subs
            ),
            Padding(
              padding: EdgeInsets.only(top: 12.0),
            ),
            Paragraph(
              "This app uses following packages:"
            ),
            Padding(
              padding: EdgeInsets.only(top: 12.0),
            ),
            //todo insert link to following packages
            Paragraph("- http"),
            Paragraph("- flutter_html_view"),
            Paragraph("- cached_network_image"),
            Paragraph("- flutter_svg"),
            Paragraph("- flutter_custom_tabs"),
            Paragraph("- shimmer"),
            Padding(
              padding: EdgeInsets.only(top: 16.0),
            ),
            Text(
              "Follow Us",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22.0,
              ),
            ),
            Row(
              children: <Widget>[
                CachedNetworkImage(
                  imageUrl: "https://twitter.com/troyhunt/profile_image?size=original",
                  width: 80.0,
                  height: 80.0,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Troy Hunt"),
                      RaisedButton(
                          color: const Color(0xFF1DA1F2),
                          textColor: Colors.white,
                          child: Text("@troyhunt"),
                          onPressed: () => launchURL(context, "https://twitter.com/troyhunt"),
                          shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0))
                      ),
                    ],
                  ),
                )
              ],
            ),
            Row(
              children: <Widget>[
                CachedNetworkImage(
                  imageUrl: "https://twitter.com/callingmedic911/profile_image?size=original",
                  width: 80.0,
                  height: 80.0,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Aditya Pandey"),
                      RaisedButton(
                          color: const Color(0xFF1DA1F2),
                          textColor: Colors.white,
                          child: Text("@troyhunt"),
                          onPressed: () => launchURL(context, "https://twitter.com/callingmedic911"),
                          shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0))
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

}