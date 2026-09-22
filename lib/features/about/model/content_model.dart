class ContentModel {
  final String aboutUs;
  final String termsAndConditions;

  ContentModel({
    required this.aboutUs,
    required this.termsAndConditions,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      aboutUs: json['about_us']?.toString() ?? '',
      termsAndConditions: json['terms_and_conditions']?.toString() ?? '',
    );
  }
}
