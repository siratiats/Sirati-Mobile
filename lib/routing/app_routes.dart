/// Named route table (SIRATI-13).
class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const home = '/home';
  static const login = '/login';
  static const register = '/register';
  static const history = '/history';
  static const createCv = '/create-cv';
  static const myCvs = '/mycvs';
  static const education = '/education';
  static const jobNews = '/job-news';
  static const privacy = '/privacy';
  static const settings = '/settings';
  static const notifications = '/notifications';
  static const premium = '/premium';
  static const notFound = '/not-found';

  static const cvPrefix = '/cv/';
  static const analysisPrefix = '/analysis/';
  static const educationItemPrefix = '/education/';

  static String cv(int id) => '$cvPrefix$id';
  static String analysis(int id) => '$analysisPrefix$id';
  static String educationItem(int id) => '$educationItemPrefix$id';
}

class ParsedRoute {
  const ParsedRoute({
    required this.name,
    this.id,
    this.requiresEntitlement = false,
    this.unknown = false,
  });

  final String name;
  final int? id;
  final bool requiresEntitlement;
  final bool unknown;
}
