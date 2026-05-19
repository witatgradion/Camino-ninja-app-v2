import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class GalleryScreenArguments {
  GalleryScreenArguments({
    required this.initialIndex,
    this.items = const [],
  });
  final List<GalleryItem> items;
  final int initialIndex;
}

class GalleryItem {
  GalleryItem({
    this.file,
    this.photoUrl,
  });
  final File? file;
  final String? photoUrl;
}

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({
    required this.arguments,
    super.key,
  });
  final GalleryScreenArguments arguments;

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late PageController _pageController;
  late ScrollController _thumbnailController;
  final double _thumbnailSize = 80;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.arguments.initialIndex;
    _pageController =
        PageController(initialPage: widget.arguments.initialIndex);
    _thumbnailController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _scrollToThumbnail(_currentIndex);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  void _selectPhoto(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index);
    _scrollToThumbnail(index);
  }

  void _scrollToThumbnail(int index) {
    const thumbnailWidth = 68.0; // 60 + 8 margin
    final targetOffset = (index * thumbnailWidth) -
        (MediaQuery.of(context).size.width / 2) +
        (thumbnailWidth / 2);

    if (_thumbnailController.hasClients) {
      _thumbnailController.animateTo(
        targetOffset.clamp(0.0, _thumbnailController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Main Photo Display
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                builder: (BuildContext context, int index) {
                  final item = widget.arguments.items[index];
                  final isFile = item.file != null;
                  late final ImageProvider<Object> imageProvider;
                  if (isFile) {
                    imageProvider = FileImage(item.file!);
                  } else {
                    imageProvider = NetworkImage(item.photoUrl ?? '');
                  }
                  return PhotoViewGalleryPageOptions(
                    imageProvider: imageProvider,
                    initialScale: PhotoViewComputedScale.contained,
                    minScale: PhotoViewComputedScale.contained * 0.8,
                    maxScale: PhotoViewComputedScale.covered * 2,
                    heroAttributes: PhotoViewHeroAttributes(tag: index),
                  );
                },
                itemCount: widget.arguments.items.length,
                loadingBuilder: (context, event) => Center(
                  child: CircularProgressIndicator(
                    value: event == null
                        ? 0
                        : event.cumulativeBytesLoaded /
                            (event.expectedTotalBytes ?? 1),
                  ),
                ),
                backgroundDecoration: const BoxDecoration(
                  color: Colors.black,
                ),
                pageController: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  _scrollToThumbnail(index);
                },
              ),
            ),

            // Thumbnail List
            Positioned(
              bottom: 36,
              left: 0,
              right: 0,
              child: Container(
                height: _thumbnailSize,
                color: Colors.transparent,
                child: ListView.separated(
                  controller: _thumbnailController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: widget.arguments.items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 5),
                  itemBuilder: (context, index) {
                    final isSelected = index == _currentIndex;
                    final item = widget.arguments.items[index];
                    final isFile = item.file != null;
                    return GestureDetector(
                      onTap: () => _selectPhoto(index),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 2)
                              : null,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 4,
                              offset: const Offset(4, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AnimatedOpacity(
                            opacity: isSelected ? 1.0 : 0.8,
                            duration: const Duration(milliseconds: 200),
                            child: isFile
                                ? Image.file(
                                    width: _thumbnailSize,
                                    height: _thumbnailSize,
                                    fit: BoxFit.cover,
                                    item.file!,
                                    errorBuilder: (_, __, ___) =>
                                        _buildErrorWidget(context),
                                  )
                                : CachedNetworkImage(
                                    imageUrl: item.photoUrl ?? '',
                                    width: _thumbnailSize,
                                    height: _thumbnailSize,
                                    fit: BoxFit.cover,
                                    memCacheWidth: _thumbnailSize.toInt(),
                                    memCacheHeight: _thumbnailSize.toInt(),
                                    placeholder: (_, __) =>
                                        _buildLoadingWidget(context),
                                    errorWidget: (_, __, ___) =>
                                        _buildErrorWidget(context),
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: SafeArea(
                child: GestureDetector(
                  onTap: () {
                    context.pop();
                  },
                  child: SvgPicture.asset(
                    'assets/ic_close_circle.svg',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Container(
      width: _thumbnailSize,
      height: _thumbnailSize,
      color: Colors.grey[800],
      child: const Icon(
        Icons.error,
        color: Colors.white,
      ),
    );
  }

  Widget _buildLoadingWidget(BuildContext context) {
    return Container(
      width: _thumbnailSize,
      height: _thumbnailSize,
      color: Colors.grey[800],
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
