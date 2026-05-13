abstract final class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const matches = '/matches';
  static const standings = '/standings';
  static const matchDetail = '/match/:id';
  static const subscription = '/subscription';

  static String matchDetailPath(int id) => '/match/$id';
}
