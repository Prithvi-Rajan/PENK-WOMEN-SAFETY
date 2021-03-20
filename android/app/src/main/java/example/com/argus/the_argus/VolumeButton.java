package example.com.argus.the_argus;

import android.app.NotificationManager;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;
import android.view.KeyEvent;
import android.widget.Toast;

import java.time.Duration;

import androidx.core.app.NotificationCompat;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;

public class VolumeButton extends Service {
    public VolumeButton() {
    }

    @Override
    public void onCreate() {
        super.onCreate();

        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            NotificationManager manager = getSystemService(NotificationManager.class);
            NotificationCompat. Builder builder = new NotificationCompat.Builder(this, "Button listener").setContentText("Running in the Background").setContentTitle("Argus");

        startForeground(101, builder.build());
        }
    }

    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if ((keyCode == KeyEvent.KEYCODE_VOLUME_DOWN)){

        }
        return true;
    }


    @Override
    public IBinder onBind(Intent intent) {
        // TODO: Return the communication channel to the service.
        throw new UnsupportedOperationException("Not yet implemented");
    }
}
