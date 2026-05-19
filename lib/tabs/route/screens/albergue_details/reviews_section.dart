import 'package:cached_network_image/cached_network_image.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/albergue_details_nav_scope.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/gallery_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/translate_button.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/date_time_ext.dart';
import 'package:camino_ninja_flutter/utils/string_ext.dart';
import 'package:camino_ninja_flutter/widgets/custom_rating_bar.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:repository/repository.dart';

class ReviewsSection extends StatelessWidget {
  const ReviewsSection({
    required this.reviews,
    required this.totalReviews,
    required this.navScope,
    super.key,
    this.isOffline = false,
    this.isLoadingMore = false,
    this.isLoading = false,
    this.appLocale,
    this.scrollToReviewId,
    this.reviewScrollTargetKey,
    this.reviewHighlightAnimation,
  });
  final List<AlbergueReviewModel> reviews;
  final int totalReviews;
  final bool isOffline;
  final bool isLoadingMore;
  final bool isLoading;
  final String? appLocale;
  final int? scrollToReviewId;
  final GlobalKey? reviewScrollTargetKey;
  final Animation<double>? reviewHighlightAnimation;
  final AlbergueDetailsNavScope navScope;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(
          vertical: 32,
        ),
        child: Center(
          child: LoadingWidget(
            size: 70,
          ),
        ),
      );
    }
    if (isOffline) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          AppLocalizations.of(context).warningOnlineToLoadAlbergueReviews,
          style: context.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    if (reviews.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: 32,
        left: 16,
        right: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${AppLocalizations.of(context).reviews} ($totalReviews):',
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...[
            for (var index = 0; index < reviews.length; index++) ...[
              if (index > 0) const SizedBox(height: 16),
              _reviewListTile(
                context: context,
                review: reviews[index],
              ),
            ],
          ],
          if (isLoadingMore) ...[
            const SizedBox(height: 32),
            const Center(
              child: LoadingWidget(
                size: 70,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _reviewListTile({
    required BuildContext context,
    required AlbergueReviewModel review,
  }) {
    final attachKey = scrollToReviewId != null &&
        reviewScrollTargetKey != null &&
        review.id == scrollToReviewId;
    final item = ReviewItem(
      review: review,
      appLocale: appLocale,
      navScope: navScope,
    );
    if (!attachKey) {
      return item;
    }
    final child = reviewHighlightAnimation != null
        ? AnimatedBuilder(
            animation: reviewHighlightAnimation!,
            child: item,
            builder: (context, decoratedChild) {
              final t = reviewHighlightAnimation!.value;
              final scheme = Theme.of(context).colorScheme;
              final fill = Color.lerp(
                Colors.transparent,
                scheme.primaryContainer.withOpacity(0.45),
                t,
              )!;
              return DecoratedBox(
                decoration: BoxDecoration(color: fill),
                child: decoratedChild,
              );
            },
          )
        : item;
    return KeyedSubtree(
      key: reviewScrollTargetKey,
      child: child,
    );
  }
}

class ReviewItem extends StatefulWidget {
  const ReviewItem({
    required this.review,
    required this.navScope,
    super.key,
    this.appLocale,
  });
  final AlbergueReviewModel review;
  final String? appLocale;
  final AlbergueDetailsNavScope navScope;

  @override
  State<ReviewItem> createState() => _ReviewItemState();
}

class _ReviewItemState extends State<ReviewItem> {
  bool _showTranslated = true;

  @override
  void initState() {
    super.initState();
    final hasTranslated = widget.review.isTranslated == true &&
        (widget.review.translatedComment ?? '').trim().isNotEmpty;
    _showTranslated = hasTranslated;
  }

  String get _displayComment {
    final useTranslated = _showTranslated &&
        (widget.review.translatedComment ?? '').trim().isNotEmpty;
    return useTranslated
        ? (widget.review.translatedComment ?? '')
        : (widget.review.userComment ?? '');
  }

  bool get _showTranslateButton =>
      widget.review.isTranslated == true &&
      (widget.review.translatedComment ?? '').trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_showTranslateButton) ...[
          TranslateButton(
            isTranslated: _showTranslated,
            onTap: () => setState(() => _showTranslated = !_showTranslated),
          ),
          const SizedBox(height: 4),
        ],
        Text(
          (widget.review.name?.trim().isEmpty ?? true)
              ? 'Anonymous'
              : widget.review.name ?? '',
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            CustomRatingBar(
              initialRating: widget.review.userRating?.toDouble() ?? 0,
              enable: false,
            ),
            const SizedBox(width: 4),
            Text(
              widget.review.createdAt?.toHumanReadableDate() ?? '',
              style: context.textTheme.bodySmall,
            ),
          ],
        ),
        if (_displayComment.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            _displayComment,
            style: context.textTheme.bodyMedium,
          ),
        ],
        if (widget.review.images?.isNotEmpty ?? false) ...[
          const SizedBox(height: 8),
          ReviewImages(
            images: widget.review.images ?? [],
            navScope: widget.navScope,
          ),
        ],
      ],
    );
  }
}

class ReviewImages extends StatelessWidget {
  const ReviewImages({
    required this.images,
    required this.navScope,
    super.key,
  });
  final List<AlbergueImageReviewModel> images;
  final AlbergueDetailsNavScope navScope;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (images.isNotEmpty) ...[
          _buildImage(context, images.first),
        ],
        if (images.length > 1) ...[
          const SizedBox(width: 8),
          _buildImage(context, images.last, remaining: images.length - 1),
        ],
      ],
    );
  }

  Widget _buildImage(
    BuildContext context,
    AlbergueImageReviewModel image, {
    int remaining = 0,
  }) {
    const imageWidth = 105;
    const imageHeight = 80;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cachedImage = CachedNetworkImage(
      imageUrl: image.fileKey?.toPhotoUrl() ?? '',
      width: imageWidth.toDouble(),
      height: imageHeight.toDouble(),
      fit: BoxFit.cover,
      memCacheWidth: (imageWidth * dpr).round(),
      placeholder: (_, __) => const ColoredBox(
        color: Color(0x80f2f1f1),
        child: CupertinoActivityIndicator(),
      ),
    );

    if (remaining > 1) {
      return GestureDetector(
        onTap: () => _onImageTap(context, images, images.indexOf(image)),
        child: Stack(
          children: [
            cachedImage,
            Positioned.fill(
              child: ColoredBox(
                color: AppColors.barrierColor,
                child: Center(
                  child: Text(
                    '+$remaining',
                    style: context.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return GestureDetector(
      onTap: () => _onImageTap(context, images, images.indexOf(image)),
      child: cachedImage,
    );
  }

  void _onImageTap(
    BuildContext context,
    List<AlbergueImageReviewModel> images,
    int index,
  ) {
    context.push(
      navScope.galleryPath,
      extra: GalleryScreenArguments(
        items: images.map((e) {
          return GalleryItem(photoUrl: e.fileKey?.toPhotoUrl() ?? '');
        }).toList(),
        initialIndex: index,
      ),
    );
  }
}
