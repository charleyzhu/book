import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'LoadDialog.dart';

class Util {
  static Dio _dio;
  BuildContext _buildContext;

  Util(this._buildContext);

  Dio http() {
    _dio = new Dio();
    // _dio.options.connectTimeout = 10000;

//    var dic = DirectoryUtil.getAppDocPath();
//    _dio.httpClientAdapter = Http2Adapter(
//      ConnectionManager(
//        idleTimeout: 10000,
//        /// Ignore bad certificate
//        onClientCreate: (_, clientSetting) => clientSetting.onBadCertificate = (_) => true,
//      ),
//    );
    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
      // Do something before request is sent
      if (_buildContext != null) {
//        showDialog(
//            context: _buildContext,
//            barrierDismissible: false,
//            builder: (BuildContext context) {
//              return LoadingDialog();
//            });
        showGeneralDialog(
          context: _buildContext,
          barrierLabel: "",
          barrierDismissible: true,
          transitionDuration: Duration(milliseconds: 300),
          pageBuilder: (BuildContext context, Animation animation,
              Animation secondaryAnimation) {
            return LoadingDialog();
          },
        );
      }
      if (SpUtil.haveKey("auth")) {
        options.headers.addAll(({"auth": SpUtil.getString("auth")}));
      }
      return options; //continue
      // If you want to resolve the request with some custom data，
      // you can return a `Response` object or return `dio.resolve(data)`.
      // If you want to reject the request with a error message,
      // you can return a `DioError` object or return `dio.reject(errMsg)`
    }, onResponse: (Response response) async {
      // Do something with response data
      if (_buildContext != null) {
        Navigator.pop(_buildContext);
      }
      return response; // continue
    }, onError: (DioError e) async {
      // Do something with response error
      formatError(e);
      return e; //continue
    }));
    return _dio;
  }

  /*
   * error统一处理
   */
  void formatError(DioError e) {
    if (_buildContext != null) {
      Navigator.pop(_buildContext);
    }
    if (e.type == DioErrorType.CONNECT_TIMEOUT) {
      // It occurs when url is opened timeout.
      BotToast.showText(text: "连接超时");
    } else if (e.type == DioErrorType.SEND_TIMEOUT) {
      // It occurs when url is sent timeout.
      BotToast.showText(text: "请求超时");
    } else if (e.type == DioErrorType.RECEIVE_TIMEOUT) {
      //It occurs when receiving timeout
      BotToast.showText(text: "响应超时");
    } else if (e.type == DioErrorType.RESPONSE) {
      // When the server response, but with a incorrect status, such as 404, 503...
      BotToast.showText(text: "出现异常");
    } else if (e.type == DioErrorType.CANCEL) {
      // When the request is cancelled, dio will throw a error with this type.
      BotToast.showText(text: "请求取消");
    } else {
      //DEFAULT Default error type, Some other Error. In this case, you can read the DioError.error if it is not null.
//      log(e.message);
      BotToast.showText(text: "未知错误");
    }
  }
}

// 必须是顶层函数
_parseAndDecode(String response) {
  return jsonDecode(response);
}

parseJson(String text) {
  return compute(_parseAndDecode, text);
}
