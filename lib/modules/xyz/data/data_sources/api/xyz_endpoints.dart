abstract interface class XyzEndpoints {
  static const String getList = 'xyz';
  static const String create = 'xyz';
  static String getOne(String id) => 'xyz/$id';
  static String update(String id) => 'xyz/$id';
  static String delete(String id) => 'xyz/$id';
}