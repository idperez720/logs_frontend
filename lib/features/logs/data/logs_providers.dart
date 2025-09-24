import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'logs_repository.dart';

final logsRepositoryProvider =
    Provider<LogsRepository>((_) => LogsRepository());
