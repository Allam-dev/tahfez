import 'package:tahfez/core/data/models/pagination_params.dart';

class GetXyzListFilter {
  PaginationParams? pagination;

  Map<String, dynamic> toApiJson() {
    return {if (pagination != null) ...pagination!.toJson()};
  }

  Map<String, dynamic> toDbJson() {
    return {};
  }
}
