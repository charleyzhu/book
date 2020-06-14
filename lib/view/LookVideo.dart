import 'dart:convert';

import 'package:book/common/LoadDialog.dart';
import 'package:book/common/PicWidget.dart';
import 'package:book/common/common.dart';
import 'package:book/common/util.dart';
import 'package:book/entity/GBook.dart';
import 'package:book/model/ColorModel.dart';
import 'package:book/route/Routes.dart';
import 'package:book/store/Store.dart';
import 'package:book/view/MyControls.dart';
import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LookVideo extends StatefulWidget {
  String id;
  List<dynamic> mcids;
  String cover;
  String name;

  LookVideo(this.id, this.mcids, this.cover, this.name);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LookVideoState();
  }
}

class LookVideoState extends State<LookVideo> with WidgetsBindingObserver {
  ColorModel colorModel;
  VideoPlayerController videoPlayerController;
  String source;
  ChewieController chewieController;
  List<Widget> wds = [];
  bool initOk = false;
  var urlKey;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    urlKey = this.widget.id;
    var widgetsBinding = WidgetsBinding.instance;
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (videoPlayerController != null) {
      videoPlayerController.removeListener(_videoListener);
      videoPlayerController.dispose();
    }

    chewieController.dispose();
    WidgetsBinding.instance.removeObserver(this);

    saveRecord(videoPlayerController.value.position);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    saveRecord(videoPlayerController.value.position);
  }

  saveRecord(Duration position) {
    if (position == null) {
      return;
    }
    if (SpUtil.haveKey(source)) {
      SpUtil.remove(source);
    }

    SpUtil.putInt(source, position.inMicroseconds);
  }

  @override
  Widget build(BuildContext context) {
    colorModel = Store.value<ColorModel>(context);
    // TODO: implement build
    return Store.connect<ColorModel>(
        builder: (context, ColorModel model, child) => Theme(
              child: wds.isNotEmpty
                  ? Material(
                      child: SafeArea(
                        child: Column(
                          children: <Widget>[
                            initOk
                                ? Chewie(
                                    controller: chewieController,
                                  )
                                : Container(
                                    width: double.infinity,
                                    height: 180,
                                    child: LoadingDialog(),
                                  ),
                            Expanded(
                              child: ListView(
                                shrinkWrap: true,
                                children: wds,
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  : Material(child: LoadingDialog()),
              data: model.theme,
            ));
  }

  getData() async {
    String url = Common.look_m + '${this.widget.id}';
    Response future = await Util(null).http().get(url);
    source = future.data[2];
    videoPlayerController = VideoPlayerController.network(source);
    videoPlayerController.addListener(_videoListener);
    videoPlayerController.initialize().then((_) {
      chewieController = ChewieController(
        customControls: MyControls(this.widget.name),
        videoPlayerController: videoPlayerController,
        aspectRatio: videoPlayerController.value.aspectRatio,
        autoPlay: false,
        allowedScreenSleep: false,
        looping: false,
      );
      if (SpUtil.haveKey(source)) {
        int p = SpUtil.getInt(source);
        chewieController.seekTo(Duration(microseconds: p));
      }
    });

    wds.add(Center(
      child: Wrap(
        runAlignment: WrapAlignment.center,
        spacing: 3, //主轴上子控件的间距
        runSpacing: 5, //交叉轴上子控件之间的间
        children: mItems(this.widget.mcids),
      ),
    ));
    for (var i = 0; i < 2; i++) {
      List list = future.data[i];
      if (list.isNotEmpty) {
        List<GBook> list2 = list.map((f) => GBook.fromJson(f)).toList();
        wds.add(item(i == 0 ? "每日更新" : "喜欢这个视频的人也喜欢···", list2));
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _videoListener() async {
    if (videoPlayerController.value.initialized) {
      if (mounted) {
        setState(() {
          initOk = true;
        });
      }
    }
  }

  void _urlChange(url, name) async {
    saveRecord(videoPlayerController.value.position);

    if (videoPlayerController != null) {
      /// 如果控制器存在，清理掉重新创建
      videoPlayerController.removeListener(_videoListener);
      videoPlayerController.pause();
//      videoPlayerController.dispose();
    }
    setState(() {
      /// 重置组件参数
      initOk = false;
      urlKey = url;
    });
    Response future = await Util(null).http().get(Common.look_m + url);
    videoPlayerController = VideoPlayerController.network(future.data[2]);

    videoPlayerController.addListener(_videoListener);
    videoPlayerController.initialize().then((_) {
      chewieController = ChewieController(
        customControls: MyControls(name),
        videoPlayerController: videoPlayerController,
        aspectRatio: videoPlayerController.value.aspectRatio,
        autoPlay: false,
        allowedScreenSleep: false,
        looping: false,
      );
      if (SpUtil.haveKey(future.data[2])) {
        int p = SpUtil.getInt(future.data[2]);
        chewieController.seekTo(Duration(microseconds: p));
      }
      if (mounted) {
        setState(() {
          initOk = true;
        });
      }
    });
  }

  List<Widget> mItems(List<dynamic> list) {
    List<Widget> wds = [];
    for (var value in list) {
      Map map = Map.castFrom(value);
      wds.add(RaisedButton(
        child: Text(
          map.values.elementAt(0),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        onPressed: () {
          saveRecord(videoPlayerController.value.position);
          _urlChange(map.keys.elementAt(0), map.values.elementAt(0));
//          Navigator.pop(context);
//          FunUtil.saveMoviesRecord(
//              this.widget.cover,
//              this.widget.name,
//              map.keys.elementAt(0),
//              map.values.elementAt(0),
//              jsonEncode(this.widget.mcids));
//          Routes.navigateTo(context, Routes.lookVideo, params: {
//            "id": map.keys.elementAt(0),
//            "mcids": jsonEncode(list),
//            "cover": this.widget.cover,
//            "name": this.widget.name
//          });
        },
        color: map.keys.elementAt(0) == urlKey
            ? colorModel.dark ? Colors.black : Colors.white
            : colorModel.theme.primaryColor,
      ));
    }
    return wds;
  }

  Widget item(String title, List<GBook> bks) {
    return Container(
      child: ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                child: Container(
                  width: 4,
                  height: 20,
//                  color: value.dark
//                      ? value.theme.textTheme.body1.color
//                      : value.theme.primaryColor,
                ),
                padding: EdgeInsets.only(left: 5.0, right: 3.0),
              ),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Container(),
              ),
//              GestureDetector(
//                child: Row(
//                  children: <Widget>[
//                    Text(
//                      "更多",
//                      style: TextStyle(color: Colors.grey),
//                    ),
//                    Icon(
//                      Icons.keyboard_arrow_right,
//                      color: Colors.grey,
//                    )
//                  ],
//                ),
//                onTap: () {
////                  Routes.navigateTo(context, Routes.allTagBook,
////                      params: {"title": title, "bks": jsonEncode(bks)});
//                },
//              )
            ],
          ),
          GridView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(5.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 1.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 0.7),
            children: bks.map((i) => img(i)).toList(),
          )
        ],
      ),
    );
  }

  Widget img(GBook gbk) {
    return GestureDetector(
      child: Column(
        children: <Widget>[
          PicWidget(
            gbk.cover,
            width: (ScreenUtil.getScreenW(context) - 40) / 3,
            height: ((ScreenUtil.getScreenW(context) - 40) / 3) * 1.2,
          ),
          Expanded(
            child: Container(),
          ),
          Text(
            gbk.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
      onTap: () async {
        Navigator.pop(context);
        Routes.navigateTo(context, Routes.vDetail,
            params: {"gbook": jsonEncode(gbk)});
      },
    );
  }
}
