package com.prevailcatv.flutter_uhf_plugin;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import android.text.TextUtils;

import com.rscja.deviceapi.RFIDWithUHF;
import com.rscja.deviceapi.RFIDWithUHF.BankEnum;
import com.rscja.deviceapi.entity.SimpleRFIDEntity;

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
      result.success(freeUHF());
    } else if (call.method.equals("readSignleTag")) {
      result.success(readSingleTag());
    } else if (call.method.equals("readData")) {
      String accessPwd = call.argument("accessPwd");
      String bank = call.argument("bank");
      String ptr = call.argument("ptr");
      String cnt = call.argument("cnt");
      result.success(readData(accessPwd, bank, ptr, cnt));
    } else if (call.method.equals("readDataWithQT")) {
      String accessPwd = call.argument("accessPwd");
      String bank = call.argument("bank");
      String ptr = call.argument("ptr");
      String cnt = call.argument("cnt");
      result.success(readDataWithQT(accessPwd, bank, ptr, cnt));
    } else if (call.method.equals("getFrequencyMode")) {
      result.success(getFrequencyMode());
    } else if (call.method.equals("setFrequencyMode")) {
      int mode = call.argument("mode");
      result.success(setFrequencyMode(mode));
    } else if (call.method.equals("getPower")) {
      result.success(getPower());
    } else if (call.method.equals("setPower")) {
      int power = call.argument("power");
      result.success(setPower(power));
    } else if (call.method.equals("getPwm")) {
      result.success(getPwm());
    } else if (call.method.equals("setPwm")) {
      int workTime = call.argument("workTime");
      int waitTime = call.argument("waitTime");
      result.success(setPwm(workTime, waitTime));
    } else if (call.method.equals("stopInventory")) {
      result.success(stopInventory());
    } else if (call.method.equals("startInventoryTag")) {
      int flag = call.argument("flag");
      int initQ = call.argument("initQ");
      result.success(startInventoryTag(flag, initQ));
    } else if (call.method.equals("continuousRead")) {
      result.success(continuousRead());
    } else {
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
    String[] strData = mReader.inventorySingleTag();
    return strData[1];
  }

  private String readData(String accessPwd, String bank, String ptr, String cnt) {
    SimpleRFIDEntity entity = mReader.readData(accessPwd,
            BankEnum.valueOf(bank),
            Integer.parseInt(ptr),
            Integer.parseInt(cnt));

    if (entity != null) {
      return entity.getData();
    } else {
      return "";
    }
  }

  private String readDataWithQT(String accessPwd, String bank, String ptr, String cnt) {
    SimpleRFIDEntity entity = mReader.readDataWithQT(accessPwd,
            BankEnum.valueOf(bank),
            Integer.parseInt(ptr),
            Integer.parseInt(cnt));

    if (entity != null) {
      return entity.getData();
    } else {
      return "";
    }
  }

  private int getFrequencyMode() {
    return mReader.getFrequencyMode();
  }

  private boolean setFrequencyMode(int mode) {
    return mReader.setFrequencyMode((byte)mode);
  }

  private int getPower() {
    return mReader.getPower();
  }

  private boolean setPower(int power) {
    return mReader.setPower(power);
  }

  private int[] getPwm() {
    return mReader.getPwm();
  }

  private boolean setPwm(int workTime, int waitTime) {
    return mReader.setPwm(workTime, waitTime);
  }

  private boolean stopInventory() {
    return mReader.stopInventory();
  }

  private boolean startInventoryTag(int flag, int initQ) {
    return mReader.startInventoryTag(flag, initQ);
  }

  private String[] continuousRead() {
    return mReader.readTagFromBuffer();
  }
}
