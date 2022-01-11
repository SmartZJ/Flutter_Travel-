import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:flutter_trip/dao/home_dao.dart';
import 'package:flutter_trip/model/common_model.dart';
import 'package:flutter_trip/model/grid_nav_model.dart';
import 'package:flutter_trip/model/home_model.dart';
import 'package:flutter_trip/model/sales_box_model.dart';
import 'package:flutter_trip/pages/search_page.dart';
import 'package:flutter_trip/widget/loading_container.dart';
import 'package:flutter_trip/widget/local_nav.dart';
import 'package:flutter_trip/widget/sales_box.dart';
import 'package:flutter_trip/widget/search_bar.dart';

import '../util/navigatorUtil.dart';
import '../widget/grid_nav.dart';
import '../widget/hi_webview.dart';
import '../widget/sub_nav.dart';

const APPBAR_SCROLL_OFFSET = 120;
const SEARCH_BAR_DEFAULT_TEXT = '网红打卡地 景点 酒店 美食';

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
  SalesBoxModel? salesBox;
  bool _loading = true;

  double appBarAlpha = 0;

  var _textStyle = SystemUiOverlayStyle.light;



  Future<Null> _handleRefresh() async {
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
        salesBox = model.salesBox;
        _loading = false;
      });
    } catch (e) {
      print(e);
      _loading = false;
    }
    return null;
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
    _handleRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: _textStyle,
      child: Scaffold(
        backgroundColor: Color(0xfff2f2f2),
        body: LoadingContainer(
            isLoading: _loading,
            child: Stack(
              children: [
                MediaQuery.removePadding(
                  removeTop: true,
                  context: context,
                  child: RefreshIndicator(
                    onRefresh: _handleRefresh,
                    child: NotificationListener(
                      onNotification: (scrollNotifaction) {
                        if (scrollNotifaction is ScrollUpdateNotification &&
                            scrollNotifaction.depth == 0) {
                          //滚动且是列表滚动的时候
                          _onScroll(scrollNotifaction.metrics.pixels);
                        }
                        return false;
                      },
                      child: _listView,
                    ),
                  ),
                ),
               _appBar,
              ],
            )),
      ),
    );
  }

  get _banner=>Container(
    height: 200,
    child: bannerList.length == 0
        ? null
        : Swiper(
      itemCount: bannerList.length,
      autoplay: true,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
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

  get _appBar =>  Column(
    children: <Widget>[
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            //AppBar渐变遮罩背景
            colors: [Color(0x66000000), Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
          height: 80.0,
          decoration: BoxDecoration(
            color: Color.fromARGB((appBarAlpha * 255).toInt(), 255, 255, 255),
          ),
          child: SearchBar(
            searchBarType: appBarAlpha > 0.2
                ? SearchBarType.homeLight
                : SearchBarType.home,
            inputBoxClick: _jumpToSearch,
            speakButtonClick: _jumpToSpeak,
            rightButtonClick: (){},
            defaultText: SEARCH_BAR_DEFAULT_TEXT,
            leftButtonClick: () {},
          ),
        ),
      ),
      Container(
          height: appBarAlpha > 0.2 ? 0.5 : 0,
          decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 0.5)]))
    ],
  );

  get _listView => ListView(
    children: [
      _banner,
      Padding(
        padding: EdgeInsets.fromLTRB(7, 5, 7, 5),
        child: LocalNav(localNavList: localNavList),
      ),
      if(gridNavModel!=null)
      Padding(
        padding: EdgeInsets.fromLTRB(7, 0, 7, 5),
        child: GridNav(gridNavModel: gridNavModel!),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(7, 0, 7, 5),
        child: SubNav(
          subNavList: subNavList,
        ),
      ),
      if (salesBox != null)
      Padding(
        padding: EdgeInsets.fromLTRB(7, 0, 7, 5),
        child: SalesBox(
          salesBox: salesBox!,
        ),
      ),
    ],
  );





  _jumpToSearch() {
    NavigatorUtil.push(
        context,
        SearchPage(
          hint: SEARCH_BAR_DEFAULT_TEXT,
          hideLeft: false,
        ));
  }

  _jumpToSpeak() {
  }
}
