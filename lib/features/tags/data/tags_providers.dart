import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'tags_repository.dart';

final tagsRepositoryProvider =
    Provider<TagsRepository>((_) => TagsRepository());
