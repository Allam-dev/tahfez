import 'dart:math';

class RateModel<MAKER> {
  String id;
  double rate;
  String comment;
  MAKER maker;

  RateModel({
    required this.id,
    required this.rate,
    required this.comment,
    required this.maker,
  });

  factory RateModel.fake(String id, MAKER maker) {
    return RateModel(
      id: id,
      rate: Random().nextDouble() * 5,
      comment:
          'comment $id eoifheiowh fioehwfgioehwoigheouwg ioufiopqwdopwid0uw iop uwpqfdpwqufipw pyfioye f pofupeiqyfioq f upofyioqfy poqwufpoyhfioy fpieyfgo fy eiopqwyf ioqy pqwyfioe fpey io',
      maker: maker,
    );
  }

  factory RateModel.fromJson(Map<String, dynamic> json) => RateModel(
    id: json['id'],
    rate: json['rating'],
    comment: json['reviewText'],
    maker: json['maker'],
  );

  Map<String, dynamic> toJson() => {"rating": rate, "reviewText": comment};
}
