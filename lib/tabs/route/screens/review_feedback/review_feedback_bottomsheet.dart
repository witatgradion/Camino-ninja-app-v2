import 'dart:async';
import 'dart:io';

import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/review_feedback/cubit/review_feedback_cubit.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/review_feedback/review_feedback_type.dart';
import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/widgets/custom_button.dart';
import 'package:camino_ninja_flutter/widgets/custom_rating_bar.dart';
import 'package:camino_ninja_flutter/widgets/custom_textfield.dart';
import 'package:camino_ninja_flutter/widgets/photo_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

Future<bool?> showReviewFeedbackBottomSheet(
  BuildContext context, {
  required ReviewFeedbackType type,
  int? albergueId,
  int? cityId,
  File? screenshot,
  String galleryRoutePath = '/gallery',
}) {
  return showModalBottomSheet<bool?>(
    context: context,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.9,
      minHeight: MediaQuery.of(context).size.height * 0.9,
    ),
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: context.isDarkMode ? AppColors.gray800 : Colors.white,
    builder: (context) => ReviewFeedbackBottomSheet(
      type: type,
      albergueId: albergueId,
      cityId: cityId,
      screenshot: screenshot,
      galleryRoutePath: galleryRoutePath,
    ),
  );
}

class ReviewFeedbackBottomSheet extends StatefulWidget {
  const ReviewFeedbackBottomSheet({
    required this.type, super.key,
    this.albergueId,
    this.cityId,
    this.screenshot,
    this.galleryRoutePath = '/gallery',
  });
  final ReviewFeedbackType type;
  final int? albergueId;
  final int? cityId;
  final File? screenshot;
  final String galleryRoutePath;

  @override
  State<ReviewFeedbackBottomSheet> createState() =>
      _ReviewFeedbackBottomSheetState();
}

class _ReviewFeedbackBottomSheetState extends State<ReviewFeedbackBottomSheet> {
  final ReviewFeedbackCubit _cubit = ReviewFeedbackCubit();
  StreamSubscription<ReviewFeedbackState>? _subscription;

  @override
  void initState() {
    super.initState();
    _cubit.init(
      widget.type,
      albergueId: widget.albergueId,
      cityId: widget.cityId,
      screenshot: widget.screenshot,
    );
    _subscription = _cubit.stream.listen(_cubitStateListener);
  }

  @override
  void dispose() {
    final screenshot = widget.screenshot;
    if (screenshot != null) {
      unawaited(_deleteScreenshot(screenshot));
    }
    _cubit.close();
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _deleteScreenshot(File screenshot) async {
    try {
      await screenshot.delete();
    } catch (e) {
      AppLogger.e(
        'Error deleting screenshot',
        tag: 'ReviewFeedbackBottomSheet',
        error: e,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;

    return BlocProvider(
      create: (context) => _cubit,
      child: BlocBuilder<ReviewFeedbackCubit, ReviewFeedbackState>(
        builder: (context, state) {
          return SafeArea(
            bottom: false,
            child: GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: Container(
                padding: EdgeInsets.only(
                  top: 16,
                  left: 16,
                  right: 16,
                  bottom: context.getBottomPadding(
                    context,
                    additionalPadding: 8,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.pop();
                          },
                          child: SvgPicture.asset(
                            'assets/ic_close.svg',
                            color: isDarkMode
                                ? AppColors.primary80
                                : AppColors.primary40,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.only(bottom: 40),
                                child: Column(
                                  children: [
                                    Text(
                                      widget.type.title(context),
                                      style: context.textTheme.titleMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    if (widget.type.showDescription) ...[
                                      const SizedBox(height: 12),
                                      Text(
                                        widget.type.description(context),
                                        style: context.textTheme.bodyLarge,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                    if (widget.type.showRating) ...[
                                      const SizedBox(height: 40),
                                      CustomRatingBar(
                                        initialRating: 0,
                                        size: 36,
                                        itemPadding: const EdgeInsets.symmetric(
                                            horizontal: 8,),
                                        onRatingUpdate: _cubit.setRating,
                                        errorText: state.ratingInvalid
                                            ? AppLocalizations.of(context)
                                                .warningRateBeforeSubmitReview
                                            : null,
                                      ),
                                    ],
                                    const SizedBox(height: 32),
                                    ..._buildNameField(state),
                                    if (widget.type.showEmail &&
                                        !state.isLoggedIn) ...[
                                      CustomTextField(
                                        textInputAction: TextInputAction.next,
                                        hintText:
                                            '${AppLocalizations.of(context).email} (${AppLocalizations.of(context).optional})',
                                        onChanged: _cubit.setEmail,
                                        errorText: state.isEmailInvalid
                                            ? AppLocalizations.of(context)
                                                .emailInvalidInlineError
                                            : null,
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                    if (widget.type ==
                                        ReviewFeedbackType
                                            .missingAccommodation) ...[
                                      CustomTextField(
                                        textInputAction: TextInputAction.next,
                                        hintText:
                                            '${AppLocalizations.of(context).accommodationAddress} (${AppLocalizations.of(context).required})',
                                        onChanged: _cubit.setAddress,
                                        maxLines: 3,
                                        errorText: state.isAddressEmpty
                                            ? AppLocalizations.of(context)
                                                .thisFieldIsRequired
                                            : null,
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                    CustomTextField(
                                      textInputAction: TextInputAction.done,
                                      hintText:
                                          '${widget.type.feedbackLabel(context)} (${AppLocalizations.of(context).required})',
                                      maxLines: 3,
                                      onChanged: _cubit.setFeedback,
                                      errorText: state.isFeedbackEmpty
                                          ? widget.type
                                              .feedbackEmptyError(context)
                                          : null,
                                    ),
                                    const SizedBox(height: 16),
                                    PhotoPicker(
                                      onChange: _cubit.setAttachments,
                                      initialFiles: widget.screenshot != null
                                          ? [widget.screenshot!]
                                          : null,
                                      galleryRoutePath: widget.galleryRoutePath,
                                    ),
                                    if (widget.type.showIncludeDbDump) ...[
                                      const SizedBox(height: 8),
                                      // Privacy invariant: this checkbox MUST
                                      // default to unchecked. The subtitle
                                      // names what we redact ("Plan names
                                      // and notes are excluded for your
                                      // privacy.") — it's the user's
                                      // informed-consent surface, so do not
                                      // change the wording without a strong
                                      // reason.
                                      CheckboxListTile(
                                        contentPadding: EdgeInsets.zero,
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        value: state.includeDbDump,
                                        onChanged: (value) {
                                          _cubit.setIncludeDbDump(
                                            value ?? false,
                                          );
                                        },
                                        title: Text(
                                          AppLocalizations.of(context)
                                              .includeDbDumpTitle,
                                          style: context.textTheme.bodyLarge
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        subtitle: Text(
                                          AppLocalizations.of(context)
                                              .includeDbDumpSubtitle,
                                          style: context.textTheme.bodyMedium,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: CustomButton(
                                text: AppLocalizations.of(context).submit,
                                isLoading: state.submitStatus ==
                                    SubmitReviewFeedbackStatus.submitting,
                                onTap: _cubit.submit,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _cubitStateListener(ReviewFeedbackState event) {
    if (event.submitStatus == SubmitReviewFeedbackStatus.submitted) {
      context.pop(true);
    }
    if (event.submitStatus == SubmitReviewFeedbackStatus.error) {
      context.pop(false);
    }
  }

  List<Widget> _buildNameField(ReviewFeedbackState state) {
    if (widget.type == ReviewFeedbackType.missingAccommodation) {
      return [
        CustomTextField(
          textInputAction: TextInputAction.next,
          hintText:
              '${AppLocalizations.of(context).accommodationName} (${AppLocalizations.of(context).required})',
          onChanged: _cubit.setName,
          errorText: state.isNameEmpty
              ? AppLocalizations.of(context).thisFieldIsRequired
              : null,
        ),
        const SizedBox(height: 16),
      ];
    }

    if (!widget.type.showName || state.isLoggedIn) return [];

    return [
      CustomTextField(
        textInputAction: TextInputAction.next,
        hintText: widget.type.nameLabel(context),
        onChanged: _cubit.setName,
      ),
      const SizedBox(height: 16),
    ];
  }
}
