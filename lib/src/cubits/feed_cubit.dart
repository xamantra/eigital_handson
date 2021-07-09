import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';

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

  Future<void> loadFeed() async {
    emit(state.copyWith(loading: true));
    var url = Uri.parse('http://feeds.bbci.co.uk/news/world/rss.xml');
    var response = await http.get(url);
    final rss = RssFeed.parse(response.body);
    emit(state.copyWith(loading: false, feed: rss.items));
  }
}
