// lib/features/home/state/home_controller.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeState {
  final String content;
  final Set<String> selectedTagIds;
  final bool menuOpen;
  const HomeState({
    this.content = '',
    this.selectedTagIds = const {},
    this.menuOpen = false,
  });

  HomeState copyWith({
    String? content,
    Set<String>? selectedTagIds,
    bool? menuOpen,
  }) =>
      HomeState(
        content: content ?? this.content,
        selectedTagIds: selectedTagIds ?? this.selectedTagIds,
        menuOpen: menuOpen ?? this.menuOpen,
      );
}

class HomeController extends StateNotifier<HomeState> {
  HomeController() : super(const HomeState());

  void setContent(String v) {
    if (v == state.content) return; // <-- avoid redundant updates
    state = state.copyWith(content: v);
  }

  void toggleMenu() => state = state.copyWith(menuOpen: !state.menuOpen);
  void closeMenu() => state = state.copyWith(menuOpen: false);

  void setSelectedTags(Iterable<String> ids) =>
      state = state.copyWith(selectedTagIds: ids.toSet());
  void addTag(String id) =>
      state = state.copyWith(selectedTagIds: {...state.selectedTagIds, id});
  void removeTag(String id) {
    final s = {...state.selectedTagIds}..remove(id);
    state = state.copyWith(selectedTagIds: s);
  }

  void clearComposer() => state = state.copyWith(content: '');
}

final homeControllerProvider =
    StateNotifierProvider<HomeController, HomeState>((_) => HomeController());
