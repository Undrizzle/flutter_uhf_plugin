package com.prevailcatv.flutter_uhf_plugin;

import android.os.Handler;
import android.os.Looper;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.EventChannel;

import com.handheld.uhfr.UHFRManager;
import com.uhf.api.cls.Reader;
import com.uhf.api.cls.Reader.TAGINFO;

import cn.pda.serialport.Tools;

import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.lang.String;

/** FlutterUhfPlugin */
public class FlutterUhfPlugin implements MethodCallHandler, EventChannel.StreamHandler {
  private static UHFRManager mUhfrManager;
  private boolean loopFlag = false;

  private EventSinkWrapper eventSink;
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    FlutterUhfPlugin flutterUhfPlugin = new FlutterUhfPlugin();
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_uhf_plugin");
    channel.setMethodCallHandler(flutterUhfPlugin);

    final EventChannel eventChannel = new EventChannel(registrar.messenger(), "tidStream");
    eventChannel.setStreamHandler(flutterUhfPlugin);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("initUHF")) {
      result.success(initUFH());
    }  else if (call.method.equals("freeUHF")) {
      result.success(freeUHF());
    } else if (call.method.equals("readSingleTag")) {
      result.success(readSingleTag());
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
    } else if (call.method.equals("stopInventory")) {
      result.success(stopInventory());
    } else if (call.method.equals("startInventoryTag")) {
      result.success(startInventoryTag());
    } else {
      result.notImplemented();
    }
  }

  private boolean initUFH() {
    try {
      mUhfrManager = UHFRManager.getInstance();
    } catch (Exception ex) {
      return false;
    }

    return mUhfrManager != null;
  }

  private boolean freeUHF() {
    boolean result;

    if (mUhfrManager != null) {
      result = mUhfrManager.close();
      mUhfrManager = null;
      return result;
    }

    return false;
  }

  private String readSingleTag() {
    byte[] readBytes = new byte[12];
    Reader.READER_ERR er;
    er = readData(2, 0, 6, readBytes, Tools.HexString2Bytes("00000000"), (short)1000);
    if (er == Reader.READER_ERR.MT_OK_ERR) {
      return Tools.Bytes2HexString(readBytes, readBytes.length);
    } else {
      return "";
    }
  }

  private Reader.READER_ERR readData(int mbank, int startaddr, int len, byte[] rdata, byte[] password, short timeout) {
    return mUhfrManager.getTagData(mbank, startaddr, len, rdata, password, timeout);
  }

  private int getFrequencyMode() {
    int frequency = 0;
    Reader.Region_Conf region = mUhfrManager.getRegion();
   if (region == Reader.Region_Conf.RG_NA) {
      frequency = 1;
    } else if (region == Reader.Region_Conf.RG_NONE) {
      frequency = 2;
    } else if (region == Reader.Region_Conf.RG_KR) {
      frequency = 3;
    } else if (region == Reader.Region_Conf.RG_EU) {
      frequency = 4;
    } else if (region == Reader.Region_Conf.RG_EU2) {
      frequency = 5;
    } else if (region == Reader.Region_Conf.RG_EU3) {
      frequency = 6;
    }

    return frequency;
  }

  private boolean setFrequencyMode(int mode) {
    Reader.Region_Conf region = Reader.Region_Conf.RG_PRC;
    switch (mode) {
      case 0:
        region = Reader.Region_Conf.RG_PRC;
        break;
      case 1:
        region = Reader.Region_Conf.RG_NA;
        break;
      case 2:
        region = Reader.Region_Conf.RG_NONE;
        break;
      case 3:
        region = Reader.Region_Conf.RG_KR;
        break;
      case 4:
        region = Reader.Region_Conf.RG_EU;
        break;
      case 5:
        region = Reader.Region_Conf.RG_EU2;
        break;
      case 6:
        region = Reader.Region_Conf.RG_EU3;
        break;
    }

    Reader.READER_ERR er = mUhfrManager.setRegion(region);
    return er == Reader.READER_ERR.MT_OK_ERR;
  }

  private int getPower() {
    int[] power = mUhfrManager.getPower();
    if (power != null) {
      return power[0];
    } else {
      return 0;
    }
  }

  private boolean setPower(int power) {
    Reader.READER_ERR er = mUhfrManager.setPower(power, 20);
    return er == Reader.READER_ERR.MT_OK_ERR;
  }

  private boolean stopInventory() {
    loopFlag = false;
    return mUhfrManager.stopTagInventory();
  }

  private boolean startInventoryTag() {
    loopFlag = true;
    return true;
  }

  class TagThread extends Thread {
    public void run() {
      List<TAGINFO> res = null;
      final Map<String, String> maps = new HashMap<>();
      String tid;

      while (loopFlag) {
        res = mUhfrManager.tagEpcTidInventoryByTimer((short) 50);
        if (res != null && res.size() > 0) {
          for (TAGINFO tfs: res) {
            tid = Tools.Bytes2HexString(tfs.EmbededData, tfs.EmbededDatalen);
            if (tid != null && tid != "") {
              maps.put("tid", tid);
              maps.put("rssi", String.valueOf(tfs.RSSI));
              sendEvent(maps);
            }
          }
        }
      }
    }
  }

  @Override
  public void onListen(Object o, EventChannel.EventSink eventSink) {
    this.eventSink = new EventSinkWrapper(eventSink);
    new TagThread().start();
  }

  @Override
  public void onCancel(Object o) {
    this.eventSink = null;
  }

  private void sendEvent(Object data) {
    if (eventSink != null) {
      eventSink.success(data);
    }
  }

  private static class EventSinkWrapper implements EventChannel.EventSink {
    private EventChannel.EventSink eventSink;
    private Handler handler;

    EventSinkWrapper(EventChannel.EventSink sink) {
      eventSink = sink;
      handler = new Handler(Looper.getMainLooper());
    }

    @Override
    public void success(final Object result) {
      handler.post(
              new Runnable() {
                @Override
                public void run() {
                  eventSink.success(result);
                }
              }
      );
    }

    @Override
    public void error(final String errorCode, final String errorMessage, final Object errorDetails) {
       handler.post(
               new Runnable() {
                 @Override
                 public void run() {
                   eventSink.error(errorCode, errorMessage, errorDetails);
                 }
               }
       );
    }

    @Override
    public void endOfStream() {
      handler.post(
              new Runnable() {
                @Override
                public void run() {
                  eventSink.endOfStream();
                }
              }
      );
    }
  }
}

