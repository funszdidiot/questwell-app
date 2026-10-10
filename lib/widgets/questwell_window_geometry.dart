import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'questwell_catalog_equipment.dart';
import 'questwell_room_geometry.dart';

/// Authored window registration, independent of equipment and account state.
/// Source coordinates preserve each room's frame, mullions and leading.
abstract final class QuestwellWindowGeometry {
  static const original = 'hearth_environment_v3';
  static const hallowed = 'hallowed_hearth_v1';
  static const hallowedSkins = {
    hallowed,
    'mad_alchemists_lab_v1',
    'guardians_keep_v1',
  };
  static const library = 'enchanted_library_v1';
  static const rooms = [
    original,
    ...hallowedSkins,
    library,
    'woodland_cottage_v1',
    'midnight_harvest_v1',
    'midnight_observatory_v1',
    'alchemists_workshop_v1',
    'astral_sanctuary_v1',
    'emberglass_conservatory_v1',
  ];

  static Size source(String room) {
    if (!rooms.contains(room)) throw ArgumentError.value(room, 'room');
    return room == original
        ? const Size(768, 768)
        : hallowedSkins.contains(room)
            ? const Size(1536, 1024)
            : const Size(1254, 1254);
  }

  /// Exactly the background's BoxFit.cover and Alignment(0, .04).
  static Float64List transform(String room, Size size) =>
      QuestwellRoomGeometry(source(room), size).matrix;

  static final _glassCache = <String, Path>{};
  static Path glass(String room) =>
      _glassCache.putIfAbsent(room, () => _buildGlass(room));

  static Path _buildGlass(String room) {
    if (room == original || hallowedSkins.contains(room)) {
      return QuestwellRainyWindowOverlay.panesFor(hallowedSkins.contains(room));
    }
    final polygons = _panes[room];
    if (polygons == null) throw ArgumentError.value(room, 'room');
    var path = Path();
    for (final polygon in polygons) {
      path.addPolygon([
        for (var i = 0; i < polygon.length; i += 2)
          Offset(polygon[i], polygon[i + 1]),
      ], true);
    }
    if (room == 'alchemists_workshop_v1') {
      final leading = Path();
      for (final line in _workshopLeading) {
        for (var i = 0; i < line.length - 2; i += 2) {
          final a = Offset(line[i], line[i + 1]);
          final b = Offset(line[i + 2], line[i + 3]);
          final delta = b - a;
          final normal = Offset(-delta.dy, delta.dx) / delta.distance * 2.4;
          leading.addPolygon([
            a - normal,
            b - normal,
            b + normal,
            a + normal,
          ], true);
          leading.addOval(Rect.fromCircle(center: a, radius: 2.8));
          leading.addOval(Rect.fromCircle(center: b, radius: 2.8));
        }
      }
      path = Path.combine(PathOperation.difference, path, leading);
    }
    return path;
  }

  static const _panes = <String, List<List<double>>>{
    'enchanted_library_v1': [
      [1183, 252, 1186, 210, 1195, 176, 1209, 147, 1223, 130, 1223, 240],
      [1238, 118, 1254, 105, 1254, 230, 1238, 235],
      [1183, 273, 1223, 258, 1223, 362, 1183, 369],
      [1238, 253, 1254, 248, 1254, 358, 1238, 360],
      [1183, 387, 1223, 380, 1223, 484, 1183, 485],
      [1238, 378, 1254, 375, 1254, 483, 1238, 484],
      [1183, 501, 1223, 501, 1223, 605, 1183, 602],
      [1238, 501, 1254, 501, 1254, 608, 1238, 607],
    ],
    'woodland_cottage_v1': [
      [1177, 251, 1178, 217, 1187, 184, 1201, 156, 1224, 129, 1224, 239],
      [1238, 119, 1254, 108, 1254, 230, 1238, 234],
      [1177, 276, 1224, 259, 1224, 362, 1177, 370],
      [1238, 256, 1254, 251, 1254, 356, 1238, 360],
      [1177, 391, 1224, 379, 1224, 482, 1177, 484],
      [1238, 377, 1254, 373, 1254, 481, 1238, 482],
      [1177, 502, 1224, 502, 1224, 612, 1177, 607],
      [1238, 501, 1254, 500, 1254, 615, 1238, 613],
    ],
    'midnight_harvest_v1': [
      [1178, 251, 1180, 211, 1190, 182, 1205, 153, 1224, 132, 1224, 239],
      [1238, 115, 1254, 105, 1254, 230, 1238, 234],
      [1178, 276, 1224, 259, 1224, 362, 1178, 370],
      [1238, 255, 1254, 252, 1254, 357, 1238, 360],
      [1178, 391, 1224, 379, 1224, 482, 1178, 484],
      [1238, 376, 1254, 373, 1254, 481, 1238, 482],
      [1178, 502, 1224, 502, 1224, 612, 1178, 607],
      [1238, 501, 1254, 500, 1254, 615, 1238, 613],
    ],
    'midnight_observatory_v1': [
      [1168, 194, 1176, 174, 1189, 140, 1212, 158],
      [1196, 128, 1210, 115, 1230, 105, 1230, 147, 1220, 151],
      [1246, 100, 1254, 96, 1254, 137, 1246, 140],
      [
        1161,
        380,
        1161,
        290,
        1165,
        288,
        1165,
        274,
        1161,
        273,
        1164,
        236,
        1177,
        212,
        1196,
        184,
        1230,
        169,
        1230,
        361,
      ],
      [1246, 165, 1254, 161, 1254, 352, 1246, 355],
      [1161, 399, 1230, 382, 1230, 486, 1161, 493],
      [1246, 373, 1254, 371, 1254, 484, 1246, 485],
      [1161, 511, 1230, 504, 1230, 626, 1161, 618],
      [1246, 503, 1254, 502, 1254, 629, 1246, 628],
    ],
    'astral_sanctuary_v1': [
      [1168, 156, 1183, 123, 1203, 94, 1219, 77, 1219, 131],
      [1235, 66, 1254, 55, 1254, 121, 1235, 128],
      [
        1157,
        258,
        1159,
        238,
        1165,
        209,
        1178,
        183,
        1193,
        166,
        1219,
        150,
        1219,
        239,
      ],
      [1235, 145, 1254, 138, 1254, 229, 1235, 234],
      [1157, 278, 1219, 260, 1219, 363, 1157, 375],
      [1235, 253, 1254, 247, 1254, 354, 1235, 357],
      [1157, 395, 1219, 382, 1219, 645, 1157, 640],
      [1235, 379, 1254, 375, 1254, 648, 1235, 646],
    ],
    'emberglass_conservatory_v1': [
      [1179, 261, 1181, 217, 1191, 183, 1208, 152, 1224, 131, 1224, 246],
      [1238, 110, 1254, 103, 1254, 237, 1238, 242],
      [1179, 281, 1224, 266, 1224, 374, 1179, 382],
      [1238, 261, 1254, 257, 1254, 366, 1238, 370],
      [1179, 404, 1224, 394, 1224, 628, 1179, 623],
      [1238, 391, 1254, 387, 1254, 633, 1238, 630],
    ],
    'alchemists_workshop_v1': [
      [1180, 249, 1183, 213, 1195, 179, 1211, 150, 1224, 135, 1224, 238],
      [1238, 122, 1254, 112, 1254, 232, 1238, 235],
      [1180, 271, 1224, 260, 1224, 365, 1180, 374],
      [1238, 255, 1254, 249, 1254, 360, 1238, 362],
      [1180, 389, 1224, 380, 1224, 484, 1180, 484],
      [1238, 377, 1254, 372, 1254, 483, 1238, 483],
      [1180, 501, 1224, 501, 1224, 603, 1180, 600],
      [1238, 501, 1254, 500, 1254, 608, 1238, 605],
    ],
  };

  // Diamond leading follows the source image rather than a synthesized grid.
  static const _workshopLeading = <List<double>>[
    [1200, 136, 1225, 158],
    [1194, 157, 1218, 173, 1226, 181],
    [1183, 181, 1203, 203, 1222, 226, 1227, 234],
    [1175, 221, 1197, 251],
    [1175, 253, 1185, 237, 1203, 203, 1224, 164],
    [1200, 251, 1222, 226, 1227, 213],
    [1235, 150, 1245, 121, 1254, 106],
    [1235, 115, 1245, 121, 1254, 134],
    [1235, 159, 1254, 183],
    [1235, 237, 1241, 221, 1254, 195],
    [1235, 213, 1241, 221, 1254, 244],
    [1180, 269, 1190, 287, 1199, 304, 1215, 329, 1227, 344],
    [1176, 294, 1184, 316, 1199, 334, 1225, 361],
    [1177, 340, 1185, 356, 1200, 376],
    [1177, 363, 1185, 356, 1199, 334, 1215, 310, 1227, 291],
    [1178, 321, 1199, 280, 1214, 261],
    [1200, 263, 1214, 282, 1227, 300],
    [1235, 289, 1254, 255],
    [1235, 289, 1254, 313],
    [1235, 336, 1243, 341, 1254, 356],
    [1235, 364, 1243, 341, 1254, 321],
    [1177, 396, 1185, 401, 1196, 418, 1210, 438, 1227, 463],
    [1177, 426, 1190, 435, 1200, 453, 1215, 469, 1227, 490],
    [1177, 463, 1190, 481],
    [1177, 461, 1188, 441, 1200, 414, 1214, 382],
    [1184, 490, 1200, 453, 1216, 428, 1227, 411],
    [1183, 399, 1191, 379],
    [1235, 377, 1254, 403],
    [1235, 436, 1246, 422, 1254, 408],
    [1235, 434, 1254, 464],
    [1235, 485, 1254, 454],
    [1180, 507, 1190, 526, 1206, 549, 1227, 577],
    [1176, 551, 1185, 568, 1195, 586, 1210, 608],
    [1210, 500, 1227, 530],
    [1180, 542, 1190, 526, 1207, 501],
    [1180, 591, 1195, 568, 1210, 539, 1227, 510],
    [1199, 606, 1220, 571, 1227, 559],
    [1235, 506, 1254, 534],
    [1235, 562, 1254, 532],
    [1235, 558, 1254, 588],
    [1235, 607, 1254, 583],
  ];
}
