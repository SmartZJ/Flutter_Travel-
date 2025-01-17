import 'package:flutter/material.dart';
import 'package:flutter_trip/dao/search_dao.dart';
import 'package:flutter_trip/model/seach_model.dart';
import 'package:flutter_trip/widget/hi_webview.dart';
import 'package:flutter_trip/widget/search_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

const BASE_URL =
    'https://m.ctrip.com/restapi/h5api/globalsearch/search?source=mobileweb&action=mobileweb&keyword=';
const TYPES = [
  'channelgroup',
  'gs',
  'plane',
  'train',
  'cruise',
  'district',
  'food',
  'hotel',
  'huodong',
  'shop',
  'sight',
  'ticket',
  'travelgroup'
];
class SearchPage extends StatefulWidget {
  final bool? hideLeft;
  final String searchUrl;
  final String? keyword;
  final String? hint;

  const SearchPage(
      {Key? key,
      this.hideLeft = true,
      this.searchUrl = BASE_URL,
      this.keyword,
      this.hint})
      : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  SearchModel? searchModel;
  String? keyword;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        _appBar(),
        Expanded(
          flex: 1,
          child: MediaQuery.removePadding(
              removeTop: true,
              context: context,
              child: ListView.builder(
                  itemCount: searchModel?.data?.length ?? 0,
                  itemBuilder: (context, position) {
                    return _item(position);
                  })),
        )
      ],
    ));
  }

  void _onTextChange(String text) {
    keyword = text;
    if (text.length == 0) {
      setState(() {
        searchModel = null;
      });
      return;
    }
    String url = widget.searchUrl + text;
    SearchDao.fetch(url, text).then((model) {
      if (model.keyword == keyword) {
        setState(() {
          searchModel = model;
        });
      }
    }).catchError((e) {
      print(e);
    });
  }

  void _rightClick() {}

  void _speakClick() {}

  _appBar() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0x66000000), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
          child: Container(
            padding: EdgeInsets.only(top: 30),
            decoration: BoxDecoration(color: Colors.white),
            child: SearchBar(
              hideLeft: widget.hideLeft,
              defaultText: widget.keyword,
              hint: widget.hint,
              leftButtonClick: () {
                Navigator.pop(context);
              },
              onChanged: _onTextChange,
              rightButtonClick: _rightClick,
              speakButtonClick: _speakClick,
            ),
          ),
        )
      ],
    );
  }

  Widget _item(int position) {
    if (searchModel == null || searchModel?.data == null) return Text('没有数据');
    SearchItem? item = searchModel?.data![position];
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HiWebView(
                      url: item!.url,
                      title: '详情',
                    )));
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(width: 0.3, color: Colors.grey))),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.all(1),
              child: Image(
                height: 26,
                width: 26,
                image: AssetImage(_typeimage(item!.type)),
              ),
            ),
            Column(
              children: [
                Container(
                  width: 300,
                  child:_title(item),
                ),
                Container(
                  width: 300,
                  margin: EdgeInsets.only(top: 5),
                  child: _subTitle(item),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _typeimage(String? type) {
    if(type == null)return 'iamges/type_travelgroup.png';
    String path = 'travelgroup';
   for(final val in TYPES){
     if(type.contains(val)){
       path = val;
       break;
     }
   }
   return 'images/type_$path.png';
  }

  _title(SearchItem item) {
    if(item==null) return null;
    
    List<TextSpan> spans = [];
    spans.addAll(_keywordTextSpans(item.word,searchModel!.keyword!));
    spans.add(TextSpan(
        text: ' '+(item.districtname??' ')+' '+(item.zonename??' '),
      style: TextStyle(fontSize: 16,color: Colors.grey)
    ));
    return RichText(text: TextSpan(children: spans));
  }

  _subTitle(SearchItem item) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: item.price??'',
            style: TextStyle(fontSize: 16,color: Colors.orange),
          ),
          TextSpan(
            text: ' ' + (item.star??''),
            style: TextStyle(fontSize: 12,color: Colors.grey),
          )
        ],
      ),
    );
  }

  Iterable<TextSpan> _keywordTextSpans(String? word, String keyword) {
    List<TextSpan> spans = [];
    if(word==null||word.length==0)return spans;

    String wordL = word.toLowerCase(), keywordL = keyword.toLowerCase();
    List<String> arr = word.split(keywordL);
    TextStyle normalStyle = TextStyle(fontSize: 16,color: Colors.black87);
    TextStyle keywordStyle = TextStyle(fontSize: 16,color: Colors.orange);

    int preIndex = 0;
    for(int i=0;i<arr.length;i++){
      if(i!=0){
        preIndex = wordL.indexOf(keywordL, preIndex);
        spans.add(TextSpan(
            text: word.substring(preIndex, preIndex + keyword.length),
            style: keywordStyle));
      }
      String val = arr[i];
      if(val !=null && val.length>0){
        spans.add(TextSpan(text: val,style: normalStyle));
      }
    }
    return spans;
  }
}
