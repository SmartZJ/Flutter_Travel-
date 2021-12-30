import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:flutter_trip/dao/home_dao.dart';
import 'package:flutter_trip/model/common_model.dart';
import 'package:flutter_trip/model/home_model.dart';
import 'package:flutter_trip/widget/local_nav.dart';

const APPBAR_SCROLL_OFFSET = 120;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List _imageList = [
    'https://img2.baidu.com/it/u=3551738197,3444677799&fm=26&fmt=auto',
    'https://img2.baidu.com/it/u=441391251,3001957160&fm=26&fmt=auto',
    'https://img0.baidu.com/it/u=1031554062,3956402395&fm=26&fmt=auto',
    'https://img1.baidu.com/it/u=1597616700,2058841459&fm=26&fmt=auto',
    'https://img2.baidu.com/it/u=567662724,1579594286&fm=26&fmt=auto',
    'https://img1.baidu.com/it/u=2626291127,2949687932&fm=26&fmt=auto'
  ];
  double appBarAlpha = 0;
  List<CommonModel> localNavList = [];
  String resultString = "";
  var _textStyle = SystemUiOverlayStyle.light;

  _loadData() async {
    // HomeDao.fetch().then((result){
    //   setState(() {
    //     resultString = json.encode(result);
    //   });
    // }).catchError((e){
    //   setState(() {
    //     resultString = e.toString();
    //   });
    // });

    try {
      HomeModel model = await HomeDao.fetch();
      setState(() {
        localNavList = model.localNavList;
      });
    } catch (e) {
      print(e);
    }
  }

  _onScroll(offset) {
    double alpha = offset / APPBAR_SCROLL_OFFSET;
    if (alpha < 0) {
      alpha = 0;
    } else if (alpha > 1) {
      alpha = 1;
    }
    setState(() {
      appBarAlpha = alpha;
      if (alpha > 0.5) {
        _textStyle = SystemUiOverlayStyle.dark;
      } else {
        _textStyle = SystemUiOverlayStyle.light;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: _textStyle,
      child: Scaffold(
        backgroundColor: Color(0xfff2f2f2),
          body: Stack(
        children: [
          MediaQuery.removePadding(
            removeTop: true,
            context: context,
            child: NotificationListener(
              onNotification: (scrollNotifaction) {
                if (scrollNotifaction is ScrollUpdateNotification &&
                    scrollNotifaction.depth == 0) {
                  _onScroll(scrollNotifaction.metrics.pixels);
                }
                return true;
              },
              child: ListView(
                children: [
                  Container(
                    height: 200,
                    child: Swiper(
                      itemCount: _imageList.length,
                      autoplay: true,
                      itemBuilder: (BuildContext context, int index) {
                        return Image.network(
                          _imageList[index],
                          fit: BoxFit.fill,
                        );
                      },
                      pagination: SwiperPagination(),
                    ),
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(7, 5, 7, 5),
                  child: LocalNav(localNavList: localNavList),)
                ],
              ),
            ),
          ),
          Opacity(
            opacity: appBarAlpha,
            child: Container(
              height: 80,
              decoration: BoxDecoration(color: Colors.white),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text('首页'),
                ),
              ),
            ),
          )
        ],
      )),
    );
  }
}
