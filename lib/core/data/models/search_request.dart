import 'pagination_params.dart';

class SearchRequest {
  final String query;
  final PaginationParams pagination;

  SearchRequest({required this.query, required this.pagination});

  Map<String, dynamic> toJson() => {
    'keyword': query,
    'limit': pagination.limit,
  };
}
