import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:flutter_trip/dao/home_dao.dart';
import 'package:flutter_trip/model/common_model.dart';
import 'package:flutter_trip/model/grid_nav_model.dart';
import 'package:flutter_trip/model/home_model.dart';
import 'package:flutter_trip/model/sales_box_model.dart';
import 'package:flutter_trip/widget/local_nav.dart';

import '../util/navigatorUtil.dart';
import '../widget/grid_nav.dart';
import '../widget/hi_webview.dart';
import '../widget/sub_nav.dart';

const APPBAR_SCROLL_OFFSET = 120;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CommonModel> bannerList = [];
  List<CommonModel> subNavList = [];
  List<CommonModel> localNavList = [];
  GridNavModel? gridNavModel;
  SalesBoxModel? salesBoxModel;
  bool _loading = true;

  double appBarAlpha = 0;

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
        subNavList = model.subNavList;
        gridNavModel = model.gridNav;
        bannerList = model.bannerList;
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
                      //滚动且是列表滚动的时候
                      _onScroll(scrollNotifaction.metrics.pixels);
                    }
                    return true;
                  },
                  child: ListView(
                    children: [

                     _banner,
                      Padding(
                        padding: EdgeInsets.fromLTRB(7, 5, 7, 5),
                        child: LocalNav(localNavList: localNavList),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(7, 0, 7, 5),
                        child:  gridNavModel==null?null:GridNav(gridNavModel: gridNavModel!),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(7, 0, 7, 5),
                        child:  subNavList==null?null:SubNav(subNavList: subNavList,),
                      ),

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

  Widget get _banner{
    return  Container(
      height: 200,
      child: bannerList.length==0?null:Swiper(
        index: 0,
        itemCount: bannerList.length,
        autoplay: true,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: (){
              CommonModel model = bannerList[index];
              NavigatorUtil.push(
                  context,
                  HiWebView(
                      url: model.url,
                      title: model.title,
                      hideAppBar: model.hideAppBar));
            },
            child: Image.network(
              bannerList[index].icon!,
              fit: BoxFit.fill,
            ),
          );
        },
        pagination: SwiperPagination(),
        controller: SwiperController(),
      ),
    );
  }

}
