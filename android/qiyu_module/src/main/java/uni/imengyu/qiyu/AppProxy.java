package uni.imengyu.qiyu;

import android.app.Application;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.util.Log;

import androidx.annotation.Keep;
import com.qiyukf.unicorn.api.Unicorn;

import io.dcloud.feature.uniapp.UniAppHookProxy;
import io.dcloud.feature.uniapp.utils.UniLogUtils;

@Keep
public class AppProxy implements UniAppHookProxy {

    private static final String TAG = "AppProxy";
    private static Context appContext;
    private QiyukfInit qiyukfInit = null;

    public static Context getAppContext() { return appContext; }

    private String qiyukfQiyuID = "";

    private String getQiyuIDFromMeta() {
        if(qiyukfQiyuID.equals("")) {
            try {
                ApplicationInfo info = appContext.getPackageManager().getApplicationInfo(appContext.getPackageName(), PackageManager.GET_META_DATA);
                qiyukfQiyuID = info.metaData.getString("ImengyuQiyukf_APPID");
            } catch (PackageManager.NameNotFoundException e) {
                UniLogUtils.e("未配置 Qiyukf_APPID ，无法正常使用七鱼客服功能！");
            }
        }
        return qiyukfQiyuID;
    }
    private void initQiyukef() {
        if(qiyukfInit == null)
            qiyukfInit = new QiyukfInit();
    }

    @Override
    public void onSubProcessCreate(Application application) {
        appContext = application;
        initQiyukef();
        Unicorn.init(application, getQiyuIDFromMeta(), qiyukfInit.ysfOptions(application), new GlideImageLoader(application));
        Log.d(TAG, "onCreate: Unicorn.init");
    }
    @Override
    public void onCreate(Application application) {
        appContext = application;
        initQiyukef();
        Unicorn.init(application, getQiyuIDFromMeta(), qiyukfInit.ysfOptions(application), new GlideImageLoader(application));
        Log.d(TAG, "onCreate: Unicorn.init");
    }
}
