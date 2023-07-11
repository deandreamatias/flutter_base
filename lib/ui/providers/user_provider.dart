import 'package:flutter_base/core/auth/domain/use_cases/logout_use_case.dart';
import 'package:flutter_base/core/user/domain/use_cases/get_user_use_case.dart';
import 'package:flutter_base/ui/providers/ui_provider.dart';
import 'package:flutter_base/ui/view_models/user_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get_it/get_it.dart';

part 'user_provider.freezed.dart';

@freezed
class UserState with _$UserState {
  factory UserState({
    UserViewModel? userData,
  }) = _UserState;
}

class UserNotifier extends StateNotifier<UserState> {
  final _userUseCase = GetIt.I.get<GetUserUseCase>();
  final LogoutUseCase _logoutUseCase = GetIt.I.get<LogoutUseCase>();
  late final UiNotifier _uiProvider;

  UserNotifier(StateNotifierProviderRef ref) : super(UserState()) {
    _uiProvider = ref.watch(uiProvider.notifier);
  }

  void setUserVerified() {
    state = state.copyWith(userData: state.userData?.copyWith(verified: true));
  }

  void setUserData(UserViewModel data) {
    state = state.copyWith(userData: data);
  }

  void clearProvider() {
    state = UserState();
  }

  Future<void> getInitialUserData() async {
    final user = await _userUseCase();
    setUserData(user.toViewModel());
  }

  Future<void> logout() async {
    _uiProvider.tryAction(() async {
      await _logoutUseCase();
      clearProvider();
    });
  }
}

final userProvider =
    StateNotifierProvider<UserNotifier, UserState>((ref) => UserNotifier(ref));

final userVerifiedComputedProvider = Provider.autoDispose<bool>(
  (ref) => ref
      .watch(userProvider.select((state) => state.userData?.verified == true)),
);
