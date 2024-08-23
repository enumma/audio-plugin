package com.enumma.plugins.audio;

import android.util.Log;

public class AudioPlugin {

    public String echo(String value) {
        Log.i("Echo", value);
        return value;
    }
}
