import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../cubits/index.dart';

class FeedScreenView extends StatefulWidget {
  const FeedScreenView({Key? key}) : super(key: key);

  @override
  _FeedScreenViewState createState() => _FeedScreenViewState();
}

class _FeedScreenViewState extends State<FeedScreenView> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    feedCubit(context).loadFeed();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedCubit, FeedCubitState>(
      bloc: feedCubit(context),
      builder: (context, snapshot) {
        if (snapshot.loading) {
          return Center(
            child: SizedBox(
              height: 64,
              width: 64,
              child: CircularProgressIndicator(),
            ),
          );
        }
        return ListView.builder(
          itemCount: snapshot.feed.length,
          itemBuilder: (context, index) {
            final item = snapshot.feed[index];
            return ListTile(
              title: Text(item.title ?? ''),
              subtitle: Text(item.description ?? ''),
              onTap: () {
                try {
                  launch(item.link ?? '');
                } catch (e) {
                  print(e);
                }
              },
              minVerticalPadding: 18,
            );
          },
        );
      },
    );
  }
}
