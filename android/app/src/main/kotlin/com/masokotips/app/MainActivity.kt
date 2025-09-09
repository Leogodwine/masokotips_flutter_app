package com.masokotips.app

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Support for 16 KB memory page sizes (required for Android 15+)
        System.loadLibrary("masokotips")
    }
    
    companion object {
        init {
            System.loadLibrary("masokotips")
        }
    }
    
    external fun stringFromJNI(): String
}



