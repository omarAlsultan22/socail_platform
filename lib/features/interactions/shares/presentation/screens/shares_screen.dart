import '../cubits/shares_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/service _locator.dart';
import '../../../presentation/layouts/user_row_builder.dart';
import '../../../../../core/presentation/widgets/states/initial_state_widget.dart';
import '../../../../../core/presentation/widgets/states/loading_state_widget.dart';
import 'package:social_app/features/interactions/shares/presentation/states/shares_state.dart';


class SharesScreen extends StatelessWidget {
  final String docId;
  final String? userId;

  const SharesScreen({
    super.key,
    this.userId,
    required this.docId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) =>
        sl<SharesCubit>()
          ..listenToShares(docId),
        child: BlocBuilder<SharesCubit, SharesState>(
            builder: (context, state) {
              final cubit = SharesCubit.get(context);
              return state.when(
                  onInitial: () =>
                      InitialStateWidget(text: 'No shares found'),
                  onLoading: () => LoadingStateWidget(),
                  onLoaded: (data) =>
                      UserRowBuilder(
                          userId: userId,
                          userRowList: data.sharesList
                      ),
                  onError: (failure) =>
                      failure.buildErrorWidget(
                          onRetry: () => cubit.listenToShares(docId)
                      )
              );
            }
        )
    );
  }
}