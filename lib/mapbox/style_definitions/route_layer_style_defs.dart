class RouteLayerStyleDefs {
  RouteLayerStyleDefs._();

  static const Map<String, dynamic> lineLayer = {
    'line-join': 'round',
    'line-cap': 'round',
    'line-color': [
      'case',
      [
        'boolean',
        ['feature-state', 'highlighted'],
        false,
      ],
      ['get', 'selectedColor'],
      ['get', 'baseColor'],
    ],
    'line-width': [
      'case',
      [
        'boolean',
        ['feature-state', 'highlighted'],
        false,
      ],
      5.0,
      3.0,
    ],
    'line-sort-key': [
      'case',
      [
        'boolean',
        ['feature-state', 'highlighted'],
        false,
      ],
      2,
      ['get', 'baseSortKey'],
    ],
  };

  static const Map<String, dynamic> labelLayer = {
    'text-field': ['get', 'label'],
    'text-size': 13,
    'text-font': ['Open Sans Bold', 'Arial Unicode MS Bold'],
    'text-allow-overlap': false,
    'text-ignore-placement': false,
    'text-padding': 12,
    'text-max-width': 12,
    'symbol-sort-key': [
      'case',
      [
        'boolean',
        ['feature-state', 'highlighted'],
        false,
      ],
      99999,
      ['get', 'baseSortKey'],
    ],
    'text-color': [
      'case',
      [
        'boolean',
        ['feature-state', 'highlighted'],
        false,
      ],
      ['get', 'selectedTextColor'],
      ['get', 'baseTextColor'],
    ],
    'text-halo-color': [
      'case',
      [
        'boolean',
        ['feature-state', 'highlighted'],
        false,
      ],
      ['get', 'selectedHaloColor'],
      ['get', 'baseHaloColor'],
    ],
    'text-halo-width': 3,
    'text-halo-blur': 0,
  };
}
