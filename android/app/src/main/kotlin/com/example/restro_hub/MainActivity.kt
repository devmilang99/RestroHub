package com.example.restro_hub

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import android.widget.Toast

class MainActivity : FlutterActivity(), PrinterApi {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        PrinterApi.setUp(flutterEngine.dartExecutor.binaryMessenger, this)
    }

    override fun isPrinterConnected(): Boolean {
        // Mock implementation of printer connection check
        return true
    }

    override fun printReceipt(orderData: Map<String, String>) {
        // Mock implementation of printing receipt
        val orderId = orderData["orderId"] ?: "Unknown"
        Toast.makeText(this, "Printing Receipt for Order: $orderId", Toast.LENGTH_SHORT).show()
    }
}
