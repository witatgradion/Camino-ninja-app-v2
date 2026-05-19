import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/albergue_details_nav_scope.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/albergue_details_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/my_reviews/cubit/my_reviews_cubit.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/my_reviews/widget/my_review_item_view.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/custom_tabbar.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:repository/repository.dart';

class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyReviewsCubit()..loadMyReviews(),
      child: BlocBuilder<MyReviewsCubit, MyReviewsState>(
        builder: (context, state) {
          return Scaffold(
            appBar: CaminoNinjaAppBar(
              title: AppLocalizations.of(context).myReviews,
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTabBar<MyReviewsTabMode>(
                  items: MyReviewsTabMode.values,
                  onTap: (tab) {
                    context.read<MyReviewsCubit>().selectTab(tab);
                  },
                  label: (e) => e.label(context),
                  isSelected: (e) => e == state.tabMode,
                ),
                Expanded(
                  child: _MyReviewsBody(state: state),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MyReviewsBody extends StatelessWidget {
  const _MyReviewsBody({required this.state});
  final MyReviewsState state;

  List<AlbergueReviewModel> _reviewsForTab() {
    final isApproved = state.tabMode == MyReviewsTabMode.approved;
    return state.reviews.where((r) {
      final approved = r.status ?? false;
      return isApproved ? approved : !approved;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    switch (state.loadMyReviewsStatus) {
      case LoadMyReviewsStatus.initial:
      case LoadMyReviewsStatus.loading:
        return const Center(
          child: LoadingWidget(size: 70),
        );
      case LoadMyReviewsStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.read<MyReviewsCubit>().loadMyReviews(),
                child: Text(AppLocalizations.of(context).retry),
              ),
            ],
          ),
        );
      case LoadMyReviewsStatus.loaded:
        final reviews = _reviewsForTab();
        if (reviews.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                AppLocalizations.of(context).noResultsFound,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }
        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: reviews.length,
          separatorBuilder: (_, __) => Container(
            height: 1,
            color: context.isDarkMode ? AppColors.gray800 : AppColors.gray200,
          ),
          itemBuilder: (context, index) {
            final review = reviews[index];
            final albergueId = review.albergueId;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: MyReviewItemView(
                review: review,
                onSeeMyCommentTap: () {
                  if (albergueId == null || albergueId <= 0) return;
                  context.push(
                    '/more/albergue-details',
                    extra: AlbergueDetailsScreenArguments(
                      albergueId: albergueId,
                      scrollToReviewId: review.id,
                      navScope: AlbergueDetailsNavScope.moreTab,
                    ),
                  );
                },
              ),
            );
          },
        );
    }
  }
}
