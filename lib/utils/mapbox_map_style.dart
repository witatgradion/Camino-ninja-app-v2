class MapboxMapStyle {
  static const String light =
      'mapbox://styles/caminoninja/cmowf6vla000901r0655w8mbr';

  // Original dark map style URI. Runtime dark map is temporarily disabled —
  // `dark` aliases `light` so existing `isDark ? dark : light` call sites
  // resolve to light. To re-enable dark mode, change the `dark` assignment
  // below to reference `darkUri`.
  static const String darkUri =
      'mapbox://styles/caminoninja/cmowf4f45001901r5ar8600lp';
  static const String dark = light;

  static const String satellite =
      'mapbox://styles/caminoninja/cmowf7ymx001701s33cfh9vvb';
}
