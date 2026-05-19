import 'package:cached_network_image/cached_network_image.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/albergue_details_nav_scope.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/gallery_screen.dart';
import 'package:camino_ninja_flutter/utils/string_ext.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:storage/storage.dart';

class AlbergueImages extends StatelessWidget {
  const AlbergueImages({
    required this.images,
    required this.navScope,
    super.key,
  });

  final List<ImageEntity> images;
  final AlbergueDetailsNavScope navScope;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const crossAxisCount = 3;
        const spacing = 5.0;
        final itemWidth =
            (constraints.maxWidth - (crossAxisCount - 1) * spacing) /
                crossAxisCount;

        return Wrap(
          alignment: WrapAlignment.center,
          spacing: spacing,
          runSpacing: spacing,
          children: images.mapIndexed((index, image) {
            return GestureDetector(
              onTap: () {
                context.push(
                  navScope.galleryPath,
                  extra: GalleryScreenArguments(
                    items: images.map((e) {
                      return GalleryItem(photoUrl: e.fileName.toPhotoUrl());
                    }).toList(),
                    initialIndex: index,
                  ),
                );
              },
              child: RepaintBoundary(
                child: SizedBox(
                  width: itemWidth,
                  height: itemWidth,
                  child: CachedNetworkImage(
                    imageUrl: image.fileName.toPhotoUrl(),
                    fit: BoxFit.cover,
                    memCacheWidth: itemWidth.toInt(),
                    memCacheHeight: itemWidth.toInt(),
                    maxWidthDiskCache: (itemWidth * 2).toInt(),
                    maxHeightDiskCache: (itemWidth * 2).toInt(),
                    placeholder: (context, url) => const ColoredBox(
                      color: Color(0x80f2f1f1),
                      child: CupertinoActivityIndicator(),
                    ),
                    errorWidget: (context, url, error) => const ColoredBox(
                      color: Color(0x80f2f1f1),
                      child: Icon(
                        Icons.error,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
