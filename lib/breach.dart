class Breach {
  final String name;
  final String title;
  final String description;
  final bool isVerified;
  final bool isFabricated;
  final bool isSensitive;
  final bool isRetired;
  final bool isSpamList;
  final String logoPath;
  final List<String> dataClasses;
  final String breachDate;

  Breach(
      {this.name,
      this.title,
      this.description,
      this.isVerified,
      this.isFabricated,
      this.isSensitive,
      this.isRetired,
      this.isSpamList,
      this.logoPath,
      this.dataClasses,
      this.breachDate});

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
      logoPath: json['LogoPath'],
      dataClasses: List.from(json["DataClasses"]),
      breachDate: json["BreachDate"],
    );
  }
}
