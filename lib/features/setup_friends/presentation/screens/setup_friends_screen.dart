import 'package:flutter/material.dart';
import '../cubits/setup_friends_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/layouts/setup_friends_layout.dart';
import 'package:social_app/features/setup_friends/domain/useCases/setup_friends_useCase.dart';
import 'package:social_app/features/setup_friends/presentation/states/setup_friends_state.dart';
import 'package:social_app/features/setup_friends/data/repositories_impl/firestore_setup_friends_repository.dart';


class AddNewFriendsScreen extends StatelessWidget {
  const AddNewFriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = FirestoreSetupFriendsRepository();
    final useCase = SetupFriendsUseCase(repository: repository);
    return BlocProvider(create: (context) =>
    SetupFriendsCubit(useCases: useCase)
      ..getSuggestsUsers(),
        child: BlocBuilder<SetupFriendsCubit, SetupFriendsState>(
            builder: (context, state) {
              state.when(onInitial: onInitial, onLoading: onLoading, onLoaded: onLoaded, onError: onError)
              return AddNewFriendsLayout();
            }
        )
    );
  }
}

