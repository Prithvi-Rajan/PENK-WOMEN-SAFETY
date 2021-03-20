package example.com.argus.the_argus;


 import io.flutter.app.FlutterApplication;
 import io.flutter.plugin.common.PluginRegistry;
 import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
 import io.flutter.plugins.GeneratedPluginRegistrant;
 import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService;

 public class Application extends FlutterApplication implements PluginRegistrantCallback {
   @Override
   public void onCreate() {
     super.onCreate();
     FlutterFirebaseMessagingService.setPluginRegistrant(this);

   }

   @Override
   public void registerWith(PluginRegistry registry) {
     GeneratedPluginRegistrant.registerWith(registry);
   }
 }

// import io.flutter.app.FlutterApplication;
// import io.flutter.plugin.common.PluginRegistry;
// import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
// import io.flutter.plugins.GeneratedPluginRegistrant;
// import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService;
// import com.transistorsoft.flutter.backgroundfetch.BackgroundFetchPlugin;
// import com.transistorsoft.flutter.backgroundgeolocation.FLTBackgroundGeolocationPlugin;


// public class Application extends FlutterApplication implements PluginRegistrantCallback {
//     @Override
//     public void onCreate() {
//         super.onCreate();
//         FlutterFirebaseMessagingService.setPluginRegistrant(this);
        
//         FLTBackgroundGeolocationPlugin.setPluginRegistrant(this);
//         BackgroundFetchPlugin.setPluginRegistrant(this);

//     }

//     @Override
//     public void registerWith(PluginRegistry registry) {
//         GeneratedPluginRegistrant.registerWith(registry);
//     }
// }
