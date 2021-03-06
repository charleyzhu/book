import 'dart:convert';

import 'package:book/common/PicWidget.dart';
import 'package:book/common/RatingBar.dart';
import 'package:book/common/common.dart';
import 'package:book/common/net.dart';
import 'package:book/entity/Book.dart';

import 'package:book/entity/BookInfo.dart';
import 'package:book/event/event.dart';
import 'package:book/model/ColorModel.dart';
import 'package:book/model/ShelfModel.dart';
import 'package:book/route/Routes.dart';
import 'package:book/store/Store.dart';
import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

class BookDetail extends StatefulWidget {
  BookInfo _bookInfo;

  BookDetail(this._bookInfo);

  @override
  State<StatefulWidget> createState() {
    return new _BookDetailState();
  }
}

class _BookDetailState extends State<BookDetail> {
  Book book;
  bool inShelf = false;
  int maxLines = 3;
  int maxLine = 3;
  @override
  void initState() {
    book = new Book(
        0,
        0,
        "",
        "",
        0,
        this.widget._bookInfo.Id,
        '',
        this.widget._bookInfo.Name,
        "",
        this.widget._bookInfo.Author,
        this.widget._bookInfo.Img,
        this.widget._bookInfo.Desc,
        this.widget._bookInfo.LastChapterId,
        this.widget._bookInfo.LastChapter,
        this.widget._bookInfo.LastTime);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ColorModel value = Store.value<ColorModel>(context);
    return Theme(
      child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            elevation: 0,
            actions: <Widget>[
              GestureDetector(
                child: Center(
                  child: Text('书架'),
                ),
                onTap: () {
                  Navigator.of(context).popUntil(ModalRoute.withName('/'));
                  eventBus.fire(new NavEvent(0));
                },
              ),
              SizedBox(
                width: 20,
              )
            ],
          ),
          body: ListView(
            children: <Widget>[
              Row(children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(
                          left: 10.0, top: 5.0, bottom: 10.0),
                      child: PicWidget(book.Img),
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: ScreenUtil.getScreenW(context) - 120,
                      padding: const EdgeInsets.only(left: 20.0, top: 5.0),
                      child: Text(
                        book.Name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 20.0, top: 2.0),
                      child: Text('作者: ${book.Author}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12)),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 20.0, top: 2.0),
                      child: new Text('类型: ' + book.CName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(fontSize: 12)),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 20.0, top: 2.0),
                      child: Text('状态: ${this.widget._bookInfo.BookStatus}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(fontSize: 12)),
                      width: 270,
                    ),
                    Container(
                        padding: const EdgeInsets.only(
                            left: 15.0, top: 2.0, bottom: 10.0),
                        child: Row(
                          children: <Widget>[
                            RatingBar(
                              itemSize: 30,
                              initialRating: this.widget._bookInfo.Rate ?? 1,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding:
                                  EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                print(rating);
                              },
                            ),
                            // RatingBar(
                            //   initialRating: _bookInfo.Rate ?? 0.0,
                            //   minRating: 1,
                            //   direction: Axis.horizontal,
                            //   allowHalfRating: true,
                            //   itemCount: 5,
                            //   itemSize: 25,
                            //   itemPadding:
                            //       EdgeInsets.symmetric(horizontal: 1.0),
                            //   itemBuilder: (context, _) => Icon(
                            //     Icons.star,
                            //     color: Colors.amber,
                            //   ),
                            //   onRatingUpdate: (double value) {},
                            // ),
                            Text('${this.widget._bookInfo.Rate ?? 0.0}分')
                          ],
                        )),
                  ],
                ),
              ]),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                verticalDirection: VerticalDirection.down,
                // textDirection:,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 17.0, top: 5.0),
                    child: Text(
                      '简介',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 17.0, top: 5.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          this.widget._bookInfo.Desc ?? "".trim(),
                          style: TextStyle(
                            fontSize: 12,
                          ),
                          maxLines: maxLine,
                        ),
                        Center(
                            child: GestureDetector(
                          child: Image.asset(
                            maxLine <= 3
                                ? "images/more_info.png"
                                : "images/add_collapse.png",
                            width: 30,
                            height: 30,
                            color: value.dark ? Colors.white : Colors.black,
                          ),
                          onTap: () {
                            if (mounted) {
                              setState(() {
                                maxLine = maxLine > 3 ? 3 : 100;
                              });
                            }
                          },
                        )
//                                child: IconButton(
//                                  padding: EdgeInsets.all(0.0),
//                                  icon: Icon(Icons.expand_more),
//                                  onPressed: (){
//                                    if(mounted){
//                                      setState(() {
//                                    maxLine=maxLine>3?3:100;
//                                      });
//                                    }
//                                  },
//                                ),
                            )
                      ],
                    ),
                  ),
                ],
              ),
              Divider(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                verticalDirection: VerticalDirection.down,
                // textDirection:,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 17.0, top: 15.0),
                    child: new Text(
                      '目录',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    trailing: Icon(Icons.keyboard_arrow_right),
                    leading: Container(
                      width: 70,
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.access_time),
                          SizedBox(
                            width: 5,
                          ),
                          Text('最新')
                        ],
                      ),
                    ),
                    title: Text(
                      this.widget._bookInfo.LastChapter,
                      style: TextStyle(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      //标志是从书的最后一章开始看
                      this.widget._bookInfo.CId = "-1";

                      Routes.navigateTo(
                        context,
                        Routes.read,
                        params: {
                          'read': jsonEncode(book),
                        },
                      );
                    },
                  ),
                  ListTile(
                    // trailing: Icon(Icons.keyboard_arrow_right),
                    leading: Container(
                      width: 70,
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.menu),
                          SizedBox(
                            width: 5,
                          ),
                          Text('目录')
                        ],
                      ),
                    ),
                    title: Text(
                      '共${this.widget._bookInfo.Count?.toString() ?? 0}章',
                      style: TextStyle(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      //标志是从书的最后一章开始看
                      // Routes.navigateTo(
                      //   context,
                      //   Routes.chapters,
                      // );
                      // _bookInfo.CId = "-1";
                      // Routes.navigateTo(
                      //   context,
                      //   Routes.read,
                      //   params: {
                      //     'read': jsonEncode(_bookInfo),
                      //   },
                      // );
                    },
                  ),
                ],
              ),
              Divider(),
              this.widget._bookInfo.SameAuthorBooks != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 17.0, top: 5.0),
                          child: new Text(
                            '${this.widget._bookInfo.Author}  还写过',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    )
                  : Container(),
             this.widget. _bookInfo.SameAuthorBooks != null
                  ? Row(
                      children: [
                        Expanded(
                            child: Container(
                          height: 250,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, i) {
                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.only(
                                          left: 10.0, top: 10.0),
                                      child: PicWidget(
                                       this.widget. _bookInfo.SameAuthorBooks[i].Img,
                                      ),
                                    ),
                                    Container(
                                      width: 97,
                                      padding: const EdgeInsets.only(
                                          left: 10.0, top: 10.0),
                                      child: Text(
                                      this.widget.  _bookInfo.SameAuthorBooks[i].Name,
                                        maxLines: 2,
                                        style: TextStyle(fontSize: 13.0),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () async {
                                  String url = Common.detail +
                                      '/${this.widget._bookInfo.SameAuthorBooks[i].Id}';
                                  Response future =
                                      await Util(context).http().get(url);
                                  var d = future.data['data'];
                                  BookInfo bookInfo = BookInfo.fromJson(d);
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              BookDetail(bookInfo)));
                                },
                              );
                            },
                            itemCount: this.widget._bookInfo.SameAuthorBooks.length,
                          ),
                        ))
                      ],
                    )
                  : Container(),
            ],
          ),
          bottomNavigationBar: Store.connect<ShelfModel>(
              builder: (context, ShelfModel d, child) {
            return BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              unselectedItemColor: value.dark ? Colors.white : null,
              //底部导航栏的创建需要对应的功能标签作为子项，这里我就写了3个，每个子项包含一个图标和一个title。
              items: [
                d.shelf.map((f) => f.Id).toList().contains(this.widget._bookInfo.Id)
                    ? BottomNavigationBarItem(
                        icon: Icon(
                          Icons.clear,
                        ),
                        label: '移除书架',
                      )
                    : BottomNavigationBarItem(
                        icon: Icon(
                          Icons.playlist_add,
                        ),
                        label: '加入书架',
                      ),
                BottomNavigationBarItem(
                  icon: ImageIcon(
                    AssetImage("images/read.png"),
                  ),
                  label: '立即阅读',
                ),
                // BottomNavigationBarItem(
                //   icon: Icon(
                //     Icons.cloud_download,
                //   ),
                //   label: '全本缓存',
                // ),
              ],

              onTap: (int i) {
                switch (i) {
                  case 0:
                    {
                      Store.value<ShelfModel>(context).modifyShelf(book);
                    }
                    break;
                  case 1:
                    {
                      Routes.navigateTo(
                        context,
                        Routes.read,
                        params: {
                          'read': jsonEncode(book),
                        },
                      );
                    }
                    break;
                  // case 2:
                  //   {
                  //     BotToast.showText(text: "开始下载...");
                  //
                  //     var value = Store.value<ReadModel>(context);
                  //     value.book = _bookInfo as Book;
                  //     value.book.UTime = _bookInfo.LastTime;
                  //     value.bookTag = BookTag(0, 0, _bookInfo.Name, 0.0);
                  //     value.downloadAll();
                  //   }
                  //   break;
                }
              },
            );
          })),
      data: Store.value<ColorModel>(context).theme,
    );
  }
}
