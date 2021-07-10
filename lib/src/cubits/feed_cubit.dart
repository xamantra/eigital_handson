import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webfeed/webfeed.dart';

import '../services/index.dart';

class FeedCubitState {
  final bool loading;
  final List<RssItem> feed;

  FeedCubitState([
    this.loading = false,
    this.feed = const [],
  ]);

  FeedCubitState copyWith({
    bool? loading,
    List<RssItem>? feed,
  }) {
    return FeedCubitState(
      loading ?? this.loading,
      feed ?? this.feed,
    );
  }
}

class FeedCubit extends Cubit<FeedCubitState> {
  FeedCubit() : super(FeedCubitState());

  final api = ApiService();

  Future<void> loadFeed() async {
    emit(state.copyWith(loading: true));
    final rss = await api.getRss();
    emit(state.copyWith(loading: false, feed: rss.items));
  }
}
