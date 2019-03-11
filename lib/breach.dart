class Breach {
  final String name;
  final String title;
  final String description;
  final bool isVerified;
  final bool isFabricated;
  final bool isSensitive;
  final bool isRetired;
  final bool isSpamList;
<<<<<<< HEAD
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
=======
  final String logoType;
  final List<String> dataClasses;
  final String breachDate;

  Breach({this.name, this.title, this.description, this.isVerified,
    this.isFabricated, this.isSensitive, this.isRetired, this.isSpamList,
    this.logoType, this.dataClasses, this.breachDate});
>>>>>>> 84e1d376e86c7930777a9c29757763cc8e81dafe

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
<<<<<<< HEAD
      logoPath: json['LogoPath'],
=======
      logoType: json['LogoType'],
>>>>>>> 84e1d376e86c7930777a9c29757763cc8e81dafe
      dataClasses: List.from(json["DataClasses"]),
      breachDate: json["BreachDate"],
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> 84e1d376e86c7930777a9c29757763cc8e81dafe
