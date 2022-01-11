import 'package:flutter/material.dart';

import '../pages/home_page.dart';
import '../pages/my_page.dart';
import '../pages/search_page.dart';
import '../pages/travel_page.dart';

class TabNavigator extends StatefulWidget {
  const TabNavigator({Key? key}) : super(key: key);

  @override
  _TabNavigatorState createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<TabNavigator> {
  final _defaultColor = Colors.grey;
  final _activeColor = Colors.blueAccent;
  int _currentIndex = 0;
  final _controller = PageController(
    initialPage: 0,
  );

  BottomNavigationBarItem _bottomItem(String title,IconData icon){
    return BottomNavigationBarItem(icon: Icon(icon),label: title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        onPageChanged: (index){
          setState(() {
            _currentIndex = index;
          });
        },
        controller: _controller,
        children: const [
          HomePage(),
          SearchPage(hideLeft: true,hint: '输入想要搜索的内容',),
          TravelPage(),
          MyPage()],
      ),
      bottomNavigationBar: Theme(
          data: ThemeData(
            brightness: Brightness.light,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index){
            _controller.jumpToPage(index);
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          items: [
            _bottomItem('首页', Icons.home),
            _bottomItem('搜索', Icons.search),
            _bottomItem('旅拍', Icons.camera_alt),
            _bottomItem('我的', Icons.person),
          ],
          selectedItemColor: _activeColor,
          unselectedItemColor: _defaultColor,
        ),
      )
    );
  }
}
