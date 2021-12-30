import 'package:flutter/material.dart';
import 'package:flutter_trip/model/common_model.dart';

import 'hi_webview.dart';

class SubNav extends StatelessWidget {
  final List<CommonModel> subNavList;

  const SubNav({Key? key, required this.subNavList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(6)),
      child: Padding(
        padding: EdgeInsets.all(7),
        child: _items(context),
      ),
    );
  }

  _items(BuildContext context) {
    if (subNavList == null) return null;
    List<Widget> items = [];
    subNavList.forEach((model) {
      items.add(_item(context, model));
    });
    //计算出第一行展示的数量
    int separte = (subNavList.length / 2 + 0.5).toInt();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: items.sublist(0, separte),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: items.sublist(separte, subNavList.length),
          ),
        ),
      ],
    );
  }

  Widget _item(context, CommonModel model) {
    return Expanded(
      flex: 1,
        child: GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HiWebView(
                      url: model.url,
                      statusBarColor: model.statusBarColor,
                      hideAppBar: model.hideAppBar,
                    )));
      },
      child: Column(
        children: [
          Image.network(
            model.icon!,
            width: 18,
            height: 18,
          ),
          Padding(
            padding: EdgeInsets.only(top: 3),
            child: Text(
              model.title!,
              style: TextStyle(fontSize: 12),
            ),
          )
        ],
      ),
    ));
  }
}
