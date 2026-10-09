/// Delivery encodings preserve source dimensions and exact alpha.
abstract final class QuestwellHearthAssets {
  static const variants = <String, String>{
    'assets/images/questwell/hearth/amberfall_scenery_candidate_v1.png':
        'assets/images/questwell/hearth/amberfall_scenery_candidate_v1_delivery_v1.webp',
    'assets/images/questwell/hearth/maple_rug_candidate_v1.png':
        'assets/images/questwell/hearth/maple_rug_candidate_v1_delivery_v1.webp',
    'assets/images/questwell/hearth/mooncap_grove_candidate_v1.png':
        'assets/images/questwell/hearth/mooncap_grove_candidate_v1_delivery_v1.webp',
    'assets/images/questwell/hearth/harvest_lanterns_candidate_v1.png':
        'assets/images/questwell/hearth/harvest_lanterns_candidate_v1_delivery_v1.webp',
    'assets/images/questwell/hearth/sages_rest_candidate_v1.png':
        'assets/images/questwell/hearth/sages_rest_candidate_v1_delivery_v1.webp',
    'assets/images/questwell/hearth/moonbrew_side_table_v1.webp':
        'assets/images/questwell/hearth/moonbrew_side_table_v1_delivery_v1.webp',
    'assets/images/questwell/hearth/midnight_visitors_print_v1.webp':
        'assets/images/questwell/hearth/midnight_visitors_print_v1_delivery_v1.webp',
    'assets/images/questwell/hearth/moonlit_woodland.webp':
        'assets/images/questwell/hearth/moonlit_woodland_delivery_v1.webp',
    'assets/images/questwell/hearth/moonweb_rug_v1.webp':
        'assets/images/questwell/hearth/moonweb_rug_v1_delivery_v1.webp',
    'assets/images/questwell/hearth/velvet_batwing_chair_v1.webp':
        'assets/images/questwell/hearth/velvet_batwing_chair_v1_delivery_v1.webp',
    'assets/images/questwell/hearth/witchlight_bookcase_v1.webp':
        'assets/images/questwell/hearth/witchlight_bookcase_v1_delivery_v1.webp',
  };
  static String resolve(String source) => variants[source] ?? source;
}
