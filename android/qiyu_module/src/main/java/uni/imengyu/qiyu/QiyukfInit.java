package uni.imengyu.qiyu;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;

import com.qiyukf.nimlib.sdk.NotificationFoldStyle;
import com.qiyukf.nimlib.sdk.StatusBarNotificationConfig;
import com.qiyukf.nimlib.sdk.msg.constant.NotificationExtraTypeEnum;
import com.qiyukf.unicorn.api.OnBotEventListener;
import com.qiyukf.unicorn.api.QuickEntry;
import com.qiyukf.unicorn.api.QuickEntryListener;
import com.qiyukf.unicorn.api.YSFOptions;
import com.qiyukf.unicorn.api.pop.OnShopEventListener;

import io.dcloud.PandoraEntryActivity;

public class QiyukfInit {

    private static QiyukfInit instance;

    public QiyukfInit() {
        instance = this;
    }

    //单例
    public static QiyukfInit getInstance() {
        return instance;
    }

    //事件接口

    public interface OnUrlClickedListener {
        void onUrlClicked(String url);
    }
    public interface OnQuickEntryListener {
        void onClick(String shopId, QuickEntry quickEntry);
    }
    public interface OnShopEntranceClickListener {
        void onShopEntranceClick(String shopId);
    }
    public interface OnSessionListEntranceClickListener {
        void onSessionListEntranceClick();
    }

    private OnUrlClickedListener onUrlClickListener;
    private OnUrlClickedListener onMessageItemClickListener;
    private OnQuickEntryListener onQuickEntryListener;
    private OnShopEntranceClickListener onShopEntranceClickListener;
    private OnSessionListEntranceClickListener onSessionListEntranceClickListener;


    public void setOnUrlClickListener(OnUrlClickedListener onUrlClickListener) {
        this.onUrlClickListener = onUrlClickListener;
    }
    public void setOnMessageItemClickListener(OnUrlClickedListener onMessageItemClickListener) {
        this.onMessageItemClickListener = onMessageItemClickListener;
    }
    public void setOnQuickEntryListener(OnQuickEntryListener onQuickEntryListener) {
        this.onQuickEntryListener = onQuickEntryListener;
    }
    public void setOnShopEntranceClickListener(OnShopEntranceClickListener onShopEntranceClickListener) {
        this.onShopEntranceClickListener = onShopEntranceClickListener;
    }
    public void setOnSessionListEntranceClickListener(OnSessionListEntranceClickListener onSessionListEntranceClickListener) {
        this.onSessionListEntranceClickListener = onSessionListEntranceClickListener;
    }

    /**
     * 获取自定义初始化参数
     */
    public static YSFOptions getOptions() {
        return options;
    }

    //自定义初始化参数
    private static YSFOptions options = new YSFOptions();

    public YSFOptions ysfOptions(Context context) {
        if(options == null) {
            options.statusBarNotificationConfig = new StatusBarNotificationConfig();
            options.gifImageLoader = new GlideGifImagerLoader(context);
            options.statusBarNotificationConfig = new StatusBarNotificationConfig();
            options.statusBarNotificationConfig.notificationSmallIconId = R.drawable.qiyu_notify_icon;
            options.statusBarNotificationConfig.notificationFoldStyle = NotificationFoldStyle.ALL;
            options.statusBarNotificationConfig.notificationExtraType = NotificationExtraTypeEnum.MESSAGE;
            options.statusBarNotificationConfig.notificationEntrance = PandoraEntryActivity.class;
            options.onBotEventListener = new OnBotEventListener() {
                @Override
                public boolean onUrlClick(Context context, String url) {
                    if (onUrlClickListener != null)
                        onUrlClickListener.onUrlClicked(url);
                    else {
                        Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
                        context.startActivity(intent);
                    }
                    return true;
                }
            };
            options.onMessageItemClickListener = (context1, url) -> {
                if (onMessageItemClickListener != null)
                    onMessageItemClickListener.onUrlClicked(url);
            };
            options.quickEntryListener = new QuickEntryListener() {
                @Override
                public void onClick(Context context, String shopId, QuickEntry quickEntry) {
                    if (onQuickEntryListener != null)
                        onQuickEntryListener.onClick(shopId, quickEntry);
                }
            };
            options.onShopEventListener = new OnShopEventListener() {
                @Override
                public boolean onShopEntranceClick(Context context, String shopId) {
                    if (onShopEntranceClickListener != null)
                        onShopEntranceClickListener.onShopEntranceClick(shopId);
                    return true;
                }

                @Override
                public boolean onSessionListEntranceClick(Context context) {
                    if (onSessionListEntranceClickListener != null)
                        onSessionListEntranceClickListener.onSessionListEntranceClick();
                    return true;
                }
            };
        }
        return options;
    }
}
