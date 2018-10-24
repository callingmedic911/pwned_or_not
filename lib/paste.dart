class Paste {
  final String title;
  final String date;
  final int emailCount;
  final String url;

  Paste({this.title, this.date, this.emailCount, this.url});

  factory Paste.fromJson(Map<String, dynamic> json) {
    String parsedDate = json["Date"];
    String url = getUrl(json["Source"], json["Id"]);

    return Paste(
      title: json["Title"],
      date: parsedDate?.substring(0, parsedDate?.indexOf("T")),
      emailCount: json["EmailCount"],
      url: url,
    );
  }

  static String getUrl(String source, String id) {
    switch (source) {
      case "Pastebin":
        return "https://pastebin.com/" + id;
      case "Pastie":
        return "http://pastie.org/" + id;
      case "Slexy":
        return "https://slexy.org/view/" + id;
      case "Ghostbin":
        return "https://ghostbin.com/paste" + id;
      case "QuickLeak":
        return "";
      case "JustPaste":
        return "https://justpaste.it/" + id;
      case "AdHocUrl":
        return id;
      case "QuickLeak":
      case "":
      default:
        return "";
    }
  }
}