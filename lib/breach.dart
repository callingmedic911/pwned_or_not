class Breach {
  final String name;
  final String title;
  final String description;
  final bool isVerified;
  final bool isFabricated;
  final bool isSensitive;
  final bool isRetired;
  final bool isSpamList;
  final String logoType;
  final List<String> dataClasses;
  final String breachDate;

  Breach({this.name, this.title, this.description, this.isVerified,
    this.isFabricated, this.isSensitive, this.isRetired, this.isSpamList,
    this.logoType, this.dataClasses, this.breachDate});

  factory Breach.fromJson(Map<String, dynamic> json) {
    return Breach(
      name: json['Name'],
      title: json['Title'],
      description: json['Description'],
      isVerified: json['IsVerified'],
      isFabricated: json['IsFabricated'],
      isSensitive: json['IsSensitive'],
      isRetired: json['IsRetired'],
      isSpamList: json['IsSpamList'],
      logoType: json['LogoType'],
      dataClasses: List.from(json["DataClasses"]),
      breachDate: json["BreachDate"],
    );
  }
}