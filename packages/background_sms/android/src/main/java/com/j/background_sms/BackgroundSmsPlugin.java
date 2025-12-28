package com.j.background_sms;

import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.telephony.SmsManager;
import android.util.Log;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.UUID;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** BackgroundSmsPlugin */
public class BackgroundSmsPlugin implements FlutterPlugin, MethodCallHandler {
    private static final String TAG = "BackgroundSmsPlugin";
    private MethodChannel channel;
    private Context context;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "background_sms");
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext();
        Log.d(TAG, "Plugin attached to engine");
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("sendSms")) {
            String num = call.argument("phone");
            String msg = call.argument("msg");
            Integer simSlot = call.argument("simSlot");
            sendSMS(num, msg, simSlot, result);
        } else if (call.method.equals("isSupportMultiSim")) {
            isSupportCustomSim(result);
        } else {
            result.notImplemented();
        }
    }

    private void isSupportCustomSim(Result result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            result.success(true);
        } else {
            result.success(false);
        }
    }

    private void sendSMS(String num, String msg, Integer simSlot, Result result) {
        Log.d(TAG, "Attempting to send SMS to: " + num);
        Log.d(TAG, "Android version: " + Build.VERSION.SDK_INT);
        Log.d(TAG, "Manufacturer: " + Build.MANUFACTURER);

        try {
            SmsManager smsManager = null;

            // Try to get SmsManager with enhanced error handling
            try {
                if (simSlot == null) {
                    Log.d(TAG, "Getting default SmsManager");
                    smsManager = SmsManager.getDefault();
                } else {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        Log.d(TAG, "Getting SmsManager for subscription: " + simSlot);
                        smsManager = SmsManager.getSmsManagerForSubscriptionId(simSlot);
                    } else {
                        Log.d(TAG, "API < O, using default SmsManager");
                        smsManager = SmsManager.getDefault();
                    }
                }
            } catch (Exception e) {
                Log.e(TAG, "Error getting SmsManager: " + e.getMessage(), e);
                result.error("Failed", "Error getting SmsManager: " + e.getMessage(), e.toString());
                return;
            }

            if (smsManager == null) {
                Log.e(TAG, "SmsManager is null!");
                result.error("Failed", "SmsManager is null", "");
                return;
            }

            Log.d(TAG, "SmsManager obtained successfully, sending message");

            // For longer messages, divide into parts
            ArrayList<String> parts = smsManager.divideMessage(msg);
            if (parts.size() > 1) {
                Log.d(TAG, "Message divided into " + parts.size() + " parts");
                smsManager.sendMultipartTextMessage(num, null, parts, null, null);
            } else {
                smsManager.sendTextMessage(num, null, msg, null, null);
            }

            Log.d(TAG, "SMS sent successfully");
            result.success("Sent");
        } catch (SecurityException se) {
            Log.e(TAG, "SecurityException - Permission denied: " + se.getMessage(), se);
            result.error("Failed", "Permission denied: " + se.getMessage(), se.toString());
        } catch (Exception ex) {
            Log.e(TAG, "Exception sending SMS: " + ex.getMessage(), ex);
            ex.printStackTrace();
            result.error("Failed", "Sms Not Sent: " + ex.getMessage(), ex.toString());
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        context = null;
    }
}
