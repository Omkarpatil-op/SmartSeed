class Level {
  final int id;
  final String name;
  final String icon;
  bool isUnlocked;
  final Point position;
  late int sublevel;
  final int totalSublevels;

  Level({
    required this.id,
    required this.name,
    required this.icon,
    required this.isUnlocked,
    required this.position,
    required this.sublevel,
    required this.totalSublevels,
  });
}

class Point {
  final double dx;
  final double dy;

  Point(this.dx, this.dy);
}
