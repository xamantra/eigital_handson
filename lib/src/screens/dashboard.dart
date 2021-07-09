import 'package:flutter/material.dart';

import 'views/index.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  TabController? tabController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              color: Theme.of(context).primaryColor,
              child: TabBar(
                controller: tabController,
                indicatorColor: Colors.white,
                tabs: [
                  Tab(text: 'Map'),
                  Tab(text: 'Feed'),
                  Tab(text: 'Calculator'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  MapScreenView(),
                  SizedBox(), // TODO: feed view
                  SizedBox(), // TODO: calculator view
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
