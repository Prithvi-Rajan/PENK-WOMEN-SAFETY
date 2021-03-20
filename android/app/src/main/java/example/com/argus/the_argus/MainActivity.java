package example.com.argus.the_argus;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
//  private Intent forService;
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

//    forService = new Intent(MainActivity.this, VolumeButton.class);
//    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
//
//      new MethodChannel(getFlutterView(), "example.com.argus.the_argus").setMethodCallHandler(new MethodChannel.MethodCallHandler() {
//        @Override
//        public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
//          if (methodCall.method.equals("StartService")){
//            String data = startForegroundService(forService).toString();
//
//          }
//        }
//      });
//
//    }

  }
}
