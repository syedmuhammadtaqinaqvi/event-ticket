package com.eventpass.event_ticket

import android.content.Intent
import android.nfc.NfcAdapter
import android.nfc.cardemulation.CardEmulation
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.eventpass.event_ticket/screen_secure",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "enable" -> {
                    window.setFlags(
                        WindowManager.LayoutParams.FLAG_SECURE,
                        WindowManager.LayoutParams.FLAG_SECURE,
                    )
                    result.success(null)
                }
                "disable" -> {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.eventpass.event_ticket/nfc_entry",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isNfcEnabled" -> {
                    val adapter = NfcAdapter.getDefaultAdapter(this)
                    result.success(adapter != null && adapter.isEnabled)
                }
                "hasNfcHardware" -> {
                    val adapter = NfcAdapter.getDefaultAdapter(this)
                    result.success(adapter != null)
                }
                "isHceRegistered" -> {
                    val adapter = NfcAdapter.getDefaultAdapter(this) ?: run {
                        result.success(false)
                        return@setMethodCallHandler
                    }
                    val emulation = CardEmulation.getInstance(adapter)
                    val registered = emulation.isDefaultServiceForCategory(
                        android.content.ComponentName(this, TicketHceService::class.java),
                        CardEmulation.CATEGORY_OTHER,
                    )
                    result.success(registered)
                }
                "openNfcSettings" -> {
                    startActivity(Intent(Settings.ACTION_NFC_SETTINGS))
                    result.success(null)
                }
                "setEntryPayload" -> {
                    when (val args = call.arguments) {
                        is String -> TicketNfcPayloadHolder.applyEntryPayload(args, "text", null)
                        is Map<*, *> -> {
                            val payload = args["payload"] as? String ?: ""
                            val recordType = args["recordType"] as? String
                            val mimeType = args["mimeType"] as? String
                            TicketNfcPayloadHolder.applyEntryPayload(payload, recordType, mimeType)
                        }
                        else -> TicketNfcPayloadHolder.clear()
                    }
                    TicketNfcType4Protocol.reset()
                    result.success(null)
                }
                "clearEntryPayload" -> {
                    TicketNfcPayloadHolder.clear()
                    TicketNfcType4Protocol.reset()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
