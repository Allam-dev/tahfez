class PaginationParams {
  int limit;
  int offset;

  PaginationParams({this.limit = 20, this.offset = 0});

  Map<String, dynamic> toJson() => {'limit': limit, 'offset': offset};
}
