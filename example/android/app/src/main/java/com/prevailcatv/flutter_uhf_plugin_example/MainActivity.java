package com.prevailcatv.flutter_uhf_plugin_example;

import android.os.Bundle;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.BroadcastReceiver;
import android.view.KeyEvent;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.JSONMessageCodec;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.BasicMessageChannel.MessageHandler;
import io.flutter.plugin.common.BasicMessageChannel.Reply;

import java.util.HashMap;
import java.util.Map;

public class MainActivity extends FlutterActivity {
  //private static FlutterEngine flutterEngine;
  //private FlutterView flutterView;
  private BasicMessageChannel<Object> messageChannel;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    IntentFilter filter = new IntentFilter();
    filter.addAction("android.rfid.FUN_KEY");
    registerReceiver(keyReceiver, filter);

    messageChannel = new BasicMessageChannel<>(getFlutterView(), "flutter/keyevent", JSONMessageCodec.INSTANCE);
    messageChannel.setMessageHandler(new MessageHandler<Object>() {
      @Override
      public void onMessage(Object o, Reply<Object> reply) {
        reply.reply("");
      }
    });
  }

  //手柄按键监听
  private long startTime = 0;
  private boolean keyUpFlag = true;
  private BroadcastReceiver keyReceiver = new BroadcastReceiver() {
    @Override
    public void onReceive(Context context, Intent intent) {
      int keyCode = intent.getIntExtra("keyCode", 0);
      if (keyCode == 0) {
        keyCode = intent.getIntExtra("keycode", 0);
      }
      boolean keyDown = intent.getBooleanExtra("keydown", false);
      if (keyUpFlag && keyDown && System.currentTimeMillis() - startTime > 500) {
        keyUpFlag = false;
        startTime = System.currentTimeMillis();
        if (keyCode == KeyEvent.KEYCODE_F4) {
          System.out.println("手柄按键按下哦");
          Map<String, Object> message = new HashMap<>();
          message.put("type", "keydown");
          message.put("keymap", "android");
          message.put("flags", 111);
          message.put("plainCodePoint", 111);
          message.put("codePoint", 111);
          message.put("keyCode", 134);
          message.put("scanCode", 111);
          message.put("metaState", 111);
          message.put("source", 111);
          message.put("vendorId", 111);
          message.put("productId", 111);
          message.put("deviceId", 111);
          message.put("repeatCount", 111);
          if (messageChannel != null) {
            messageChannel.send(message);
          }
        }
        return;
      } else if (keyDown) {
        startTime = System.currentTimeMillis();
      } else {
        keyUpFlag = true;
      }
    }
  };
}
