package com.prevailcatv.flutter_uhf_plugin;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import android.text.TextUtils;

import com.rscja.deviceapi.RFIDWithUHF;

/** FlutterUhfPlugin */
public class FlutterUhfPlugin implements MethodCallHandler {
  public RFIDWithUHF mReader;
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_uhf_plugin");
    channel.setMethodCallHandler(new FlutterUhfPlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("initUHF")) {
      result.success(initUFH());
    }  else if (call.method.equals("freeUHF")) {
      result.sucess(freeUHF());
    } else if (call.method.equals("readSignleTag")) {
      result.success(readSingleTag());
    }
    else {
      result.notImplemented();
    }
  }

  private Boolean initUFH() {
    try {
      mReader = RFIDWithUHF.getInstance();
    } catch (Exception ex) {
      return false;
    }

    if (mReader != null) {
      return mReader.init();
    }

    return false;
  }

  private Boolean freeUHF() {
    if (mReader != null) {
      return mReader.free();
    }

    return false;
  }

  private String readSingleTag() {
    String strUII = mReader.inventorySingleTag();
    if (!TextUtils.isEmpty(strUII)) {
      String strEPC = mReader.convertUiiToEPC(strUII);
      return strEPC;
    } else {
      return "";
    }
  }
}
