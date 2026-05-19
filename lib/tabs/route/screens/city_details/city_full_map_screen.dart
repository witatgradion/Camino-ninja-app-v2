import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/albergue_details_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/gallery_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/city_details/albergue_marker_preview_panel.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/city_details/city_albergues_map.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/string_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

typedef _PreviewState = ({
  AlbergueEntity? albergue,
  List<ImageEntity> images,
});

class CityFullMapScreenArguments {
  CityFullMapScreenArguments({
    required this.routePoints,
    required this.albergues,
    this.fallbackTarget,
    this.altRoutePoints,
    this.city,
    this.routeId,
  });

  final CityEntity? city;
  final LatLng? fallbackTarget;
  final List<LatLng> routePoints;
  final List<AltRoutePointEntity>? altRoutePoints;
  final List<AlbergueEntity> albergues;
  final int? routeId;
}

class CityFullMapScreen extends StatefulWidget {
  const CityFullMapScreen({
    required this.arguments,
    super.key,
  });
  final CityFullMapScreenArguments arguments;

  @override
  State<CityFullMapScreen> createState() => _CityFullMapScreenState();
}

class _CityFullMapScreenState extends State<CityFullMapScreen> {
  final ValueNotifier<_PreviewState> _preview =
      ValueNotifier<_PreviewState>((albergue: null, images: const []));

  final Map<int, List<ImageEntity>> _imagesCache = {};

  @override
  void dispose() {
    _preview.dispose();
    super.dispose();
  }

  Future<void> _ensureImages(AlbergueEntity albergue) async {
    final cached = _imagesCache[albergue.id];
    if (cached != null) {
      if (_preview.value.albergue?.id == albergue.id) {
        _preview.value = (albergue: albergue, images: cached);
      }
      return;
    }
    try {
      final imgs = await GetIt.instance<Repository>()
          .getAlbergueImagesByAlbergueId(albergue.id);
      if (!mounted) return;
      _imagesCache[albergue.id] = imgs;
      // Race guard: only publish if the user hasn't switched markers since.
      if (_preview.value.albergue?.id != albergue.id) return;
      _preview.value = (albergue: albergue, images: imgs);
    } catch (_) {
      if (!mounted) return;
      _imagesCache[albergue.id] = const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final topPadding = MediaQuery.of(context).padding.top + 16;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Stack(
          children: [
            CityAlberguesMap(
              zoomEnabled: true,
              scrollEnabled: true,
              city: widget.arguments.city,
              fallbackTarget: widget.arguments.fallbackTarget,
              routePoints: widget.arguments.routePoints,
              altRoutePoints: widget.arguments.altRoutePoints,
              locations: widget.arguments.albergues
                  .map(
                    (albergue) => AlbergueLocation(
                      name: albergue.name,
                      albergueId: albergue.id,
                      latLng: LatLng(
                        albergue.latitude!,
                        albergue.longitude!,
                      ),
                      albergue: albergue,
                    ),
                  )
                  .toList(),
              onMarkerTap: (location) {
                final albergue = location.albergue;
                if (albergue == null) return;
                // Show panel immediately with whatever we have cached
                // (or no images).
                _preview.value = (
                  albergue: albergue,
                  images: _imagesCache[albergue.id] ?? const [],
                );
                // Lazy-fetch in the background; a no-op if already cached.
                _ensureImages(albergue);
              },
            ),
            Positioned(
              top: topPadding,
              left: 12,
              child: _FloatingBackButton(isDark: isDark),
            ),
            ValueListenableBuilder<_PreviewState>(
              valueListenable: _preview,
              builder: (context, preview, _) {
                final albergue = preview.albergue;
                if (albergue == null) return const SizedBox.shrink();
                return Positioned(
                  left: 12,
                  right: 12,
                  bottom: 16,
                  child: AlberguePreviewPanel(
                    albergue: albergue,
                    images: preview.images,
                    routeId: widget.arguments.routeId,
                    onCancel: () =>
                        _preview.value = (albergue: null, images: const []),
                    onImageTap: (index) {
                      context.push(
                        '/gallery',
                        extra: GalleryScreenArguments(
                          items: preview.images
                              .map(
                                (e) => GalleryItem(
                                  photoUrl: e.fileName.toPhotoUrl(),
                                ),
                              )
                              .toList(),
                          initialIndex: index,
                        ),
                      );
                    },
                    onViewDetail: () {
                      final selected = _preview.value.albergue;
                      if (selected == null) return;
                      _preview.value = (albergue: null, images: const []);
                      context.push(
                        '/albergue-details',
                        extra: AlbergueDetailsScreenArguments(
                          albergueId: selected.id,
                          cityId: widget.arguments.city?.id,
                          routeId: widget.arguments.routeId,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingBackButton extends StatelessWidget {
  const _FloatingBackButton({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isDark ? AppColors.primary20 : AppColors.primary40;
    final iconColor = isDark ? AppColors.primary80 : Colors.white;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(4, 4),
          ),
        ],
        shape: BoxShape.circle,
      ),
      child: Material(
        color: backgroundColor,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Navigator.of(context).pop(),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: SvgPicture.asset(
              'assets/ic_chervon_left.svg',
              width: 24,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}
