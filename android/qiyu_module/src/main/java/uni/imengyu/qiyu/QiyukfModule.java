package uni.imengyu.qiyu;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;

import androidx.annotation.Keep;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.qiyukf.nimlib.sdk.NimIntent;
import com.qiyukf.nimlib.sdk.NotificationFoldStyle;
import com.qiyukf.nimlib.sdk.RequestCallback;
import com.qiyukf.nimlib.sdk.StatusBarNotificationConfig;
import com.qiyukf.nimlib.sdk.msg.constant.NotificationExtraTypeEnum;
import com.qiyukf.nimlib.sdk.msg.model.IMMessage;
import com.qiyukf.unicorn.api.ConsultSource;
import com.qiyukf.unicorn.api.ProductDetail;
import com.qiyukf.unicorn.api.QuickEntry;
import com.qiyukf.unicorn.api.UICustomization;
import com.qiyukf.unicorn.api.Unicorn;
import com.qiyukf.unicorn.api.UnreadCountChangeListener;
import com.qiyukf.unicorn.api.YSFOptions;
import com.qiyukf.unicorn.api.YSFUserInfo;
import com.qiyukf.unicorn.api.customization.action.AlbumAction;
import com.qiyukf.unicorn.api.customization.action.BaseAction;
import com.qiyukf.unicorn.api.customization.action.CameraAction;
import com.qiyukf.unicorn.api.customization.action.ImageAction;
import com.qiyukf.unicorn.api.customization.input.ActionListProvider;
import com.qiyukf.unicorn.api.customization.input.ActionPanelOptions;
import com.qiyukf.unicorn.api.customization.input.InputPanelOptions;
import com.qiyukf.unicorn.api.customization.title_bar.OnTitleBarRightBtnClickListener;
import com.qiyukf.unicorn.api.customization.title_bar.TitleBarConfig;
import com.qiyukf.unicorn.api.lifecycle.SessionLifeCycleOptions;
import com.qiyukf.unicorn.api.msg.MessageService;
import com.qiyukf.unicorn.api.msg.UnicornMessageBuilder;
import com.qiyukf.unicorn.api.pop.OnSessionListChangedListener;
import com.qiyukf.unicorn.api.pop.POPManager;
import com.qiyukf.unicorn.api.pop.Session;
import com.qiyukf.unicorn.api.pop.ShopInfo;
import com.taobao.weex.bridge.JSCallback;
import com.taobao.weex.common.WXModule;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.dcloud.feature.uniapp.annotation.UniJSMethod;
import io.dcloud.feature.uniapp.utils.UniLogUtils;
import io.dcloud.feature.uniapp.utils.UniResourceUtils;

@Keep
public class QiyukfModule extends WXModule {

    //用户信息的相关方法
    //=====================================================

    /**
     * 设置七鱼SDK当前咨询用户的信息
     * @param options 参数
     *                {
     *                    userId: string,
     *                    data: string,
     *                    authToken: string
     *                }
     */
    @Keep
    @UniJSMethod()
    public void setUserInfo(JSONObject options, final JSCallback callback) {
        UniLogUtils.i("setUserInfo!");
        final JSONObject jsonObject = new JSONObject();
        final YSFUserInfo userInfo = new YSFUserInfo();
        userInfo.userId = options.getString("userId");
        userInfo.data = options.getString("data");
        userInfo.authToken = options.getString("authToken");
        Unicorn.setUserInfo(userInfo, new RequestCallback<Void>() {
            @Override
            public void onSuccess(Void unused) {
                jsonObject.put("success", true);
                callback.invoke(jsonObject);
            }
            @Override
            public void onFailed(int i) {
                jsonObject.put("success", false);
                jsonObject.put("code", i);
                jsonObject.put("errMsg", "Failed with code : " + i);
                callback.invoke(jsonObject);
            }
            @Override
            public void onException(Throwable throwable) {
                UniLogUtils.e("setUserInfo failed : " + throwable.toString());
                throwable.printStackTrace();
                jsonObject.put("errMsg", throwable.toString());
                jsonObject.put("success", false);
                jsonObject.put("code", 0);
                callback.invoke(jsonObject);
            }
        });
    }

    /**
     * 清除七鱼SDK当前咨询用户的信息
     */
    @Keep
    @UniJSMethod()
    public void clearUserInfo() {
        Unicorn.logout();
    }

    //全局工具函数
    //=====================================================

    /**
     * 获取七鱼SDK当前是否已初始化
     * @param options 参数
     * @param callback 回调
     */
    @Keep
    @UniJSMethod()
    public void isInit(JSONObject options, final JSCallback callback) {
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("isInit", Unicorn.isInit());
        callback.invoke(jsonObject);
    }

    /**
     * 七鱼消息提醒开关(Android)
     * @param options
     * {
     *     on: boolean 是否开启
     * }
     */
    @Keep
    @UniJSMethod()
    public void toggleNotification(JSONObject options) {
        if(options.containsKey("on"))
            Unicorn.toggleNotification(options.getBoolean("on"));
    }

    /**
     * 清除七鱼SDK缓存
     */
    @Keep
    @UniJSMethod()
    public void clearCache() {
        Unicorn.clearCache();
    }

    //未读数相关方法
    //=====================================================

    /**
     * 七鱼获取总的未读数
     * @param options {}
     * @param callback
     * {
     *     unreadCount: number
     * }
     */
    @Keep
    @UniJSMethod()
    public void getUnreadCount(JSONObject options, final JSCallback callback) {
        if(callback != null) {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("unreadCount", Unicorn.getUnreadCount());
            callback.invoke(jsonObject);
        }
    }

    /**
     * 七鱼平台清除未读数
     * @param options
     * {
     *     shopId: string //商家ID
     * }
     */
    @Keep
    @UniJSMethod()
    public void POPClearUnreadCount(JSONObject options) {
        POPManager.clearUnreadCount(options.getString("shopId"));
    }

    /**
     * 七鱼清除全部未读数（IOS）
     */
    @Keep
    @UniJSMethod()
    public void clearUnreadCount() {}

    //Session的相关方法
    //=====================================================

    /**
     * 七鱼获取最近联系商家列表(主动获取会话列表)
     * @param options {}
     * @param callback
     * {
     *     list: {
     *         contactId: string,
     *         content: string,
     *         msgStatus: string,
     *         time: number,
     *         unreadCount: number,
     *     }[]
     * }
     */
    @Keep
    @UniJSMethod()
    public void getSessionList(JSONObject options, final JSCallback callback) {
        JSONObject oo = new JSONObject();
        JSONArray array = new JSONArray();
        for (Session session : POPManager.getSessionList()) {
            String contactId = session.getContactId();
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("contactId", contactId);

            if(contactId != null && !contactId.isEmpty()) {
                ShopInfo shopInfo = POPManager.getShopInfo(contactId);
                if(shopInfo != null) {
                    jsonObject.put("account", shopInfo.getAccount());
                    jsonObject.put("avatar", shopInfo.getAvatar());
                    jsonObject.put("name", shopInfo.getName());
                }
            }

            jsonObject.put("content", session.getContent());
            switch (session.getMsgStatus()) {
                case draft: jsonObject.put("msgStatus", "draft");break;
                case sending: jsonObject.put("msgStatus", "sending");break;
                case success: jsonObject.put("msgStatus", "success");break;
                case fail: jsonObject.put("msgStatus", "fail");break;
                case read: jsonObject.put("msgStatus", "read");break;
                case unread: jsonObject.put("msgStatus", "unread");break;
            }
            jsonObject.put("time", session.getTime());
            jsonObject.put("unreadCount", session.getUnreadCount());
            array.add(jsonObject);
        }
        oo.put("list", array);
        callback.invoke(oo);
    }

    /**
     * 七鱼获取和客服的最后一条聊天消息内容。(Android)
     */
    @Keep
    @UniJSMethod()
    public void POPQueryLastMessage(JSONObject options, final JSCallback callback) {
        IMMessage message = POPManager.queryLastMessage(options.getString("shopId"));
        if(message != null) {
            JSONObject oo = new JSONObject();
            oo.put("fromAccount", message.getFromAccount());
            oo.put("fromNick", message.getFromNick());
            oo.put("time", message.getTime());
            oo.put("content", message.getContent());
            oo.put("isDeleted", message.isDeleted());
            oo.put("isChecked", message.isChecked());
            oo.put("isRemoteRead", message.isRemoteRead());
            switch (message.getStatus()) {
                case draft: oo.put("status", "draft");break;
                case sending: oo.put("status", "sending");break;
                case success: oo.put("status", "success");break;
                case fail: oo.put("status", "fail");break;
                case read: oo.put("status", "read");break;
                case unread: oo.put("status", "unread");break;
            }
            oo.put("sessionId", message.getSessionId());
            oo.put("uuids", message.getUuid());
            oo.put("attachStr", message.getAttachStr());
            callback.invoke(oo);
        } else {

            callback.invoke(null);
        }
    }

    /**
     * 七鱼根据商家ID获取商家信息，如名称，logo(Android)
     */
    @Keep
    @UniJSMethod()
    public void POPGetShopInfo(JSONObject options, final JSCallback callback) {
        ShopInfo shopInfo = POPManager.getShopInfo(options.getString("shopId"));
        if(shopInfo != null) {
            JSONObject oo = new JSONObject();
            oo.put("account", shopInfo.getAccount());
            oo.put("avatar", shopInfo.getAvatar());
            oo.put("name", shopInfo.getName());
            callback.invoke(oo);
        } else {
            callback.invoke(null);
        }
    }

    /**
     * 七鱼获取会话状态 (Android)
     */
    @Keep
    @UniJSMethod()
    public void POPQuerySessionStatus(JSONObject options, final JSCallback callback) {
        JSONObject oo = new JSONObject();
        switch (POPManager.querySessionStatus(options.getString("shopId"))) {
            default:
            case NONE:
                oo.put("status", "NONE");
                break;
            case IN_SESSION:
                oo.put("status", "IN_SESSION");
                break;
            case IN_QUEUE:
                oo.put("status", "IN_QUEUE");
                break;
        }
        callback.invoke(oo);
    }

    /**
     * 删除最近联系商家记录 (Android)
     * @param options
     * {
     *     shopId: string, //商家ID
     *     clearMsgHistory: boolean //是否同时清空消息记录
     * }
     */
    @Keep
    @UniJSMethod()
    public void POPDeleteSession(JSONObject options) {
        POPManager.deleteSession(options.getString("shopId"), options.getBoolean("clearMsgHistory"));
    }

    //消息提醒监听的相关方法
    //=====================================================

    private static int hashMapId = 0;
    private static final Map<Integer, JSCallback> callbackJSOnSessionListChangedListeners = new HashMap<>();
    private static boolean onSessionListChangedListenerAdded = false;
    private static final OnSessionListChangedListener onSessionListChangedListener = new OnSessionListChangedListener() {
        @Override
        public void onSessionUpdate(List<Session> list) {
            JSONObject o = new JSONObject();
            o.put("type", "SessionUpdate");
            o.put("list", list);
            for (Map.Entry<Integer, JSCallback> entry : callbackJSOnSessionListChangedListeners.entrySet())
                entry.getValue().invokeAndKeepAlive(o);
        }
        @Override
        public void onSessionDelete(String s) {
            JSONObject o = new JSONObject();
            o.put("type", "SessionDelete");
            o.put("shopId", s);
            for (Map.Entry<Integer, JSCallback> entry : callbackJSOnSessionListChangedListeners.entrySet())
                entry.getValue().invokeAndKeepAlive(o);
        }
    };

    /**
     * 注册最近联系商家更新监听器（添加、删除、新消息等）
     * @param options {}
     * @param callback
     * {
     *     id: number, //ID，可使用 POPRemoveSessionListChangedListener 删除回调监听。
     *     type: 'AddSuccess'|'SessionUpdate'|'SessionDelete'
     * }
     */
    @Keep
    @UniJSMethod()
    public void POPAddSessionListChangedListener(JSONObject options, final JSCallback callback) {
        callbackJSOnSessionListChangedListeners.put(++hashMapId, callback);

        JSONObject o = new JSONObject();
        o.put("id", hashMapId);
        o.put("type", "AddSuccess");
        callback.invokeAndKeepAlive(o);

        if(!onSessionListChangedListenerAdded) {
            onSessionListChangedListenerAdded = true;
            POPManager.addOnSessionListChangedListener(onSessionListChangedListener, true);
        }
    }
    /**
     * 注销最近联系商家更新监听器（添加、删除、新消息等）
     * @param options
     * {
     *     id: number
     * }
     */
    @Keep
    @UniJSMethod()
    public void POPRemoveSessionListChangedListener(JSONObject options) {
        if(options.containsKey("id")) {
            callbackJSOnSessionListChangedListeners.remove(options.getInteger("id"));

            if (onSessionListChangedListenerAdded && callbackJSOnSessionListChangedListeners.size() == 0) {
                onSessionListChangedListenerAdded = false;
                POPManager.addOnSessionListChangedListener(onSessionListChangedListener, false);
            }
        }
    }

    /**
     * 七鱼获取和客服的最后一条聊天消息内容。(Android)
     */
    @Keep
    @UniJSMethod()
    public void queryLastMessage(JSONObject options, final JSCallback callback) {
        callback.invoke(JSONObject.toJSON(Unicorn.queryLastMessage()));
    }

    private static final Map<Integer, JSCallback> callbackJSUnreadCountChangeListeners = new HashMap<>();
    private static boolean unreadCountChangeListenerAdded = false;
    private final UnreadCountChangeListener unreadCountChangeListener = count -> {
        if(callbackJSUnreadCountChangeListeners.size() > 0) {
            JSONObject o = new JSONObject();
            o.put("count", count);
            for (Map.Entry<Integer, JSCallback> entry : callbackJSUnreadCountChangeListeners.entrySet())
                entry.getValue().invokeAndKeepAlive(o);
        }
    };

    /**
     * 七鱼添加未读数变化监听
     * @param callback
     * {
     *     id: number, //ID，可使用 POPRemoveSessionListChangedListener 删除回调监听。
     *     type: 'AddSuccess'|'SessionUpdate'|'SessionDelete'
     * }
     */
    @Keep
    @UniJSMethod()
    public void addUnreadCountChangeListener(JSONObject options, final JSCallback callback) {
        callbackJSUnreadCountChangeListeners.put(++hashMapId, callback);

        if(!unreadCountChangeListenerAdded) {
            unreadCountChangeListenerAdded = true;
            Unicorn.addUnreadCountChangeListener(unreadCountChangeListener, true);
        }
    }
    /**
     * 七鱼移除未读数变化监听
     * @param options
     * {
     *     id: number
     * }
     */
    @Keep
    @UniJSMethod()
    public void removeUnreadCountChangeListener(JSONObject options) {
        if(options.containsKey("id")) {
            callbackJSUnreadCountChangeListeners.remove(options.getInteger("id"));

            if (unreadCountChangeListenerAdded && callbackJSUnreadCountChangeListeners.size() == 0) {
                unreadCountChangeListenerAdded = false;
                Unicorn.addUnreadCountChangeListener(unreadCountChangeListener, false);
            }
        }
    }

    //发送消息的相关方法
    //=====================================================

    /**
     * 发送商品信息
     * @param options
     * {
     *     title: string,
     *     note: string,
     *     url: string,
     *     desc: string,
     *     picture: string,
     *     shopId?: number,
     * }
     */
    @Keep
    @UniJSMethod()
    public void sendProductMessage(JSONObject options) {

        ProductDetail.Builder productDetail = new ProductDetail.Builder();

        if(options.containsKey("actionText")) productDetail.setActionText(options.getString("actionText"));
        if(options.containsKey("actionTextColor")) productDetail.setActionTextColor(UniResourceUtils.getColor(options.getString("actionTextColor")));
        if(options.containsKey("alwaysSend")) productDetail.setAlwaysSend(options.getBoolean("alwaysSend"));
        if(options.containsKey("desc")) productDetail.setDesc(options.getString("desc"));
        if(options.containsKey("ext")) productDetail.setExt(options.getString("ext"));
        if(options.containsKey("handlerTag")) productDetail.setHandlerTag(options.getString("handlerTag"));
        if(options.containsKey("picture")) productDetail.setPicture(options.getString("picture"));
        if(options.containsKey("sendByUser")) productDetail.setSendByUser(options.getBoolean("sendByUser"));
        if(options.containsKey("title")) productDetail.setTitle(options.getString("title"));
        if(options.containsKey("note")) productDetail.setNote(options.getString("note"));
        if(options.containsKey("url")) productDetail.setUrl(options.getString("url"));
        if(options.containsKey("reselectText")) productDetail.setReselectText(options.getString("reselectText"));
        if(options.containsKey("isOpenReselect")) productDetail.setIsOpenReselect(options.getBoolean("isOpenReselect"));

        if(options.containsKey("shopId"))
            MessageService.sendProductMessage(productDetail.build());
        else
            MessageService.sendProductMessage(options.getString("shopId"), productDetail.build());
    }

    /**
     * 发送消息
     * @param options
     * {
     *      type: 'text'|'image'|'video'|'file',
     *      filePath: string, //要发送的图片或者视频文件路径
     *      displayName: string, //要发送的图片或者视频显示名称
     *      width?: number, //发送视频时的视频宽度
     *      height?: number, //发送视频时的视频高度
     *      duration?: number, //发送视频时的视频时长，ms
     *      local?: boolean, //是否发送至本地
     *      isNotify?: boolean, //发送至本地时是否通知
     *      isSaveDB?: boolean, //发送至本地时是否保存至数据库
     * }
     */
    @Keep
    @UniJSMethod()
    public void sendMessage(JSONObject options) {
        String shopId;

        if(options.containsKey("shopId"))
            shopId = options.getString("shopId");
        else
            shopId = UnicornMessageBuilder.getSessionId();
        IMMessage message = null;
        switch (options.getString("type")) {
            case "file":
                message = UnicornMessageBuilder.buildFileMessage(shopId, options.getString("filePath"));
                break;
            case "text":
                message = UnicornMessageBuilder.buildTextMessage(shopId, options.getString("text"));
                break;
            case "video":
                message = UnicornMessageBuilder.buildVideoMessage(shopId,
                        new File(options.getString("filePath")),
                        options.getLong("duration"),
                        options.getInteger("width"),
                        options.getInteger("height"),
                        options.getString("displayName"));
                break;
            case "image":
                message = UnicornMessageBuilder.buildImageMessage(shopId, new File(options.getString("filePath")), options.getString("displayName"));
                break;
        }
        if(message != null) {
            if(!options.containsKey("local") || options.getBoolean("local"))
                MessageService.sendMessage(message);
            else
                MessageService.saveMessageToLocal(message, options.getBoolean("isNotify"), options.getBoolean("isSaveDB"));
        }
    }

    //检查Intent的相关方法
    //=====================================================

    /**
     * 点击通知栏提醒直接跳转到会话窗口检查 (Android)
     * @param callback
     * {
     *      hasExtra: boolean,
     *      messageContent?: string,
     *      messages?: object,
     *      key?: string,
     * }
     */
    @Keep
    @UniJSMethod()
    public void checkIntentForMessage(final JSCallback callback) {
        JSONObject result = new JSONObject();
        Activity activity = (Activity)mWXSDKInstance.getContext();
        Intent intent = activity.getIntent();
        if (intent.hasExtra(NimIntent.EXTRA_NOTIFY_CONTENT)) {
            String messageContent = intent.getStringExtra(NimIntent.EXTRA_NOTIFY_SESSION_CONTENT);
            String key = intent.getStringExtra(NimIntent.EXTRA_BROADCAST_MSG);
            ArrayList<IMMessage> messages = (ArrayList<IMMessage>) intent.getSerializableExtra(NimIntent.EXTRA_NOTIFY_CONTENT);

            result.put("hasExtra", true);
            result.put("messageContent", messageContent);
            result.put("messages", JSONArray.toJSON(messages));
            result.put("key", key);

        } else {
            result.put("hasExtra", false);
        }
        callback.invoke(result);
    }
    /**
     * 重置检查Intent (Android)
     */
    @Keep
    @UniJSMethod()
    public void resetIntent() {
        Activity activity = (Activity)mWXSDKInstance.getContext();
        activity.setIntent(new Intent());
    }

    //聊天窗口的相关方法
    //=====================================================

    private interface OnSessionUpdateListener {
        void onSessionUpdate(ConsultInstance instance, Session session);
    }
    private interface OnSessionDeleteListener {
        void onSessionDelete(ConsultInstance instance, String shopId);
    }

    private static class ConsultInstance {
        public ConsultSource ConsultSource;
        public String title;
        public String shopId;
        public OnSessionUpdateListener onSessionUpdateListener;
        public OnSessionDeleteListener onSessionDeleteListener;
        public OnSessionListChangedListener onSessionListChangedListener = new OnSessionListChangedListener() {
            @Override
            public void onSessionUpdate(List<Session> list) {
                if(shopId == null || onSessionUpdateListener == null)
                    return;
                for (int i = 0; i < list.size(); i++) {
                    Session session = list.get(i);
                    if(shopId.equals(session.getContactId())) {
                        onSessionUpdateListener.onSessionUpdate(ConsultInstance.this, session);
                        break;
                    }
                }
            }
            @Override
            public void onSessionDelete(String s) {
                if(s.equals(shopId)) {
                    if(onSessionDeleteListener != null)
                        onSessionDeleteListener.onSessionDelete(ConsultInstance.this, s);
                    POPManager.addOnSessionListChangedListener(this, false);
                    openedConsultSource.remove(shopId);
                }
            }
        };

        public ConsultInstance() {
            POPManager.addOnSessionListChangedListener(onSessionListChangedListener, true);
        }
    }

    private static final Map<String, ConsultInstance> openedConsultSource = new HashMap<>();

    /**
     * 通过 shopId 查找已打开的ConsultSource标识
     * @param options
     *            {
     *                shopId: string, //商户ID
     *            }
     */
    @Keep
    @UniJSMethod()
    public void findConsultSourceKeyByShopId(JSONObject options, final JSCallback callback) {
        String shopId = options.getString("shopId");
        JSONObject oo = new JSONObject();
        for (String key : openedConsultSource.keySet()) {
            ConsultInstance consultInstance = openedConsultSource.get(key);
            if(consultInstance != null && shopId.equals(consultInstance.shopId)) {
                oo.put("key", key);
                oo.put("value", JSON.toJSON(consultInstance));
                callback.invoke(oo);
                return;
            }
        }
        oo.put("key", "");
        callback.invoke(oo);
    }

    /**
     * 获取所有已打开的ConsultSource标识
     * @param options {}
     */
    @Keep
    @UniJSMethod()
    public void getOpenedConsultSourceKeys(JSONObject options, final JSCallback callback) {
        JSONObject oo = new JSONObject();
        JSONArray o = new JSONArray();
        for (String key : openedConsultSource.keySet()) {
            ConsultInstance consultInstance = openedConsultSource.get(key);
            if(consultInstance != null) {
                JSONObject o1 = new JSONObject();
                o1.put("key", key);
                o1.put("value", JSON.toJSON(consultInstance));
                o.add(o1);
            }
        }
        oo.put("list", o);
        callback.invoke(oo);
    }

    /**
     * 创建七鱼ConsultSource
     * @param options 参数:
     *                {
     *                    key: string, //标识
     *                    staffId: number, //客服ID
     *                    groupId: number, //客服组ID
     *                    shopId: string, //商家ID
     *                    robotFirst: boolean, //先由机器人接待
     *                    faqGroupId: number, //商家ID
     *                    quickEntryList: {
     *                        {
     *                            id: number, //快捷入口ID
     *                            title: string, //快捷入口文字
     *                            iconUrl: string, //快捷入口图标URL
     *                        }
     *                    }[], //快捷入口
     *                    lifeCycleOptions: {
     *                        canCloseSession: boolean,
     *                        canQuitQueue: boolean,
     *                        quitQueuePrompt: string,
     *                    },
     *                    commodityInfo: {
     *
     *                    },
     *                    prompt: string, //弹出文字
     *                    custom: string,
     *                    VIPStaffAvatarUrl: string,
     *                    vipStaffName: string,
     *                    vipStaffWelcomeMsg: string,
     *                    vipLevel: string,
     *                    vipStaffid: string,
     *                    title: string,
     *                    sourceUrl: string,
     *                    sourceTitle: string,
     *                }
     */
    @Keep
    @UniJSMethod()
    public String createConsultSource(JSONObject options) {

        String title = "咨询客服";
        String sourceUrl = "";
        String sourceTitle = "";
        String key = options.getString("key");

        if(openedConsultSource.containsKey(key))
            return "ConsultSource Key" + key + " exists!";

        if(options.containsKey("sourceUrl")) sourceUrl = options.getString("sourceUrl");
        if(options.containsKey("sourceTitle")) sourceTitle = options.getString("sourceTitle");
        if(options.containsKey("title")) title = options.getString("title");

        ConsultSource source = new ConsultSource(sourceUrl, sourceTitle, key);

        if(options.containsKey("staffId")) source.staffId = options.getInteger("staffId");
        if(options.containsKey("groupId")) source.groupId = options.getInteger("groupId");
        if(options.containsKey("shopId")) source.shopId = options.getString("shopId");
        if(options.containsKey("robotId")) source.vipLevel = options.getInteger("robotId");
        if(options.containsKey("faqGroupId")) source.vipLevel = options.getInteger("faqGroupId");

        if(options.containsKey("quickEntryList")) {
            source.quickEntryList = new ArrayList<>();

            JSONArray quickEntryList = options.getJSONArray("quickEntryList");
            for (int i = 0; i < quickEntryList.size(); i++) {
                JSONObject o = quickEntryList.getJSONObject(i);
                source.quickEntryList.add(new QuickEntry(o.getInteger("id"), o.getString("title"), o.getString("iconUrl")));
            }
        }

        if(options.containsKey("lifeCycleOptions")) {
            JSONObject lifeCycleOptionsJson = options.getJSONObject("lifeCycleOptions");
            SessionLifeCycleOptions lifeCycleOptions = new SessionLifeCycleOptions();

            if(lifeCycleOptionsJson.containsKey("canCloseSession"))
                lifeCycleOptions.setCanCloseSession(lifeCycleOptionsJson.getBoolean("canCloseSession"));
            if(lifeCycleOptionsJson.containsKey("canQuitQueue"))
                lifeCycleOptions.setCanQuitQueue(lifeCycleOptionsJson.getBoolean("canQuitQueue"));
            if(lifeCycleOptionsJson.containsKey("quitQueuePrompt"))
                lifeCycleOptions.setQuitQueuePrompt(lifeCycleOptionsJson.getString("quitQueuePrompt"));
            source.sessionLifeCycleOptions = lifeCycleOptions;
        }

        if(options.containsKey("prompt")) source.prompt = options.getString("prompt");
        if(options.containsKey("custom")) source.custom = options.getString("custom");
        if(options.containsKey("VIPStaffAvatarUrl")) source.VIPStaffAvatarUrl = options.getString("VIPStaffAvatarUrl");
        if(options.containsKey("vipStaffName")) source.vipStaffName = options.getString("vipStaffName");
        if(options.containsKey("vipStaffWelcomeMsg")) source.prompt = options.getString("vipStaffWelcomeMsg");
        if(options.containsKey("vipLevel")) source.vipLevel = options.getInteger("vipLevel");
        if(options.containsKey("vipStaffid")) source.vipStaffid = options.getString("vipStaffid");

        if(options.containsKey("robotFirst")) source.robotFirst = options.getBoolean("robotFirst");
        if(options.containsKey("robotWelcomeMsgId")) source.robotWelcomeMsgId = options.getString("robotWelcomeMsgId");
        if(options.containsKey("leaveMsgTemplateId")) source.robotWelcomeMsgId = options.getString("leaveMsgTemplateId");

        ConsultInstance instance = new ConsultInstance();
        instance.title = title;
        instance.ConsultSource = source;
        instance.shopId = source.shopId;

        openedConsultSource.put(key, instance);
        return "success";
    }

    /**
     * 获取七鱼ConsultSource是否存在
     * @param options
     *            {
     *                key: string, //标识
     *            }
     */
    @Keep
    @UniJSMethod()
    public void isConsultSourceExists(JSONObject options, final JSCallback callback) {
        String key = options.getString("key");
        JSONObject oo = new JSONObject();
        oo.put("exists", openedConsultSource.containsKey(key));
        callback.invoke(oo);
    }

    /**
     * 删除已经创建的ConsultSource
     * @param options
     *            {
     *                key: string, //标识
     *            }
     */
    @Keep
    @UniJSMethod()
    public void deleteConsultSource(JSONObject options) {
        String key = options.getString("key");
        if(openedConsultSource.containsKey(key)) {
            ConsultInstance consultInstance = openedConsultSource.get("key");
            if(consultInstance.shopId != null && !"".equals(consultInstance.shopId))
                POPManager.deleteSession(consultInstance.shopId, false);
            openedConsultSource.remove(key);
        }
    }

    /**
     * 普通版打开七鱼SDK客服窗口
     * @param options 参数同 createConsultSource
     * @param eventBus 回调
     */
    @Keep
    @UniJSMethod()
    public void openService(JSONObject options, final JSCallback eventBus) {
        options.put("key", "InternalCs");

        if(!openedConsultSource.containsKey("InternalCs"))
            createConsultSource(options);

        POPOpenService(options, eventBus);
    }

    /**
     * 平台版打开七鱼SDK客服窗口
     * @param options 参数:
     *                {
     *                    key: string, //createConsultSource创建的key
     *                }
     * @param eventBus 回调
     */
    @Keep
    @UniJSMethod()
    public void POPOpenService(JSONObject options, final JSCallback eventBus) {
        UniLogUtils.i("openService!");

        try {
            if (options.containsKey("key")) {
                String key = options.getString("key");
                ConsultInstance consultInstance = openedConsultSource.get(key);
                if (consultInstance != null) {

                    Unicorn.openServiceActivity(AppProxy.getAppContext(), consultInstance.title, consultInstance.ConsultSource);

                    //创建事件
                    QiyukfInit instance = QiyukfInit.getInstance();
                    instance.setOnUrlClickListener(url -> {
                        JSONObject result = new JSONObject();
                        result.put("type", "UrlClick");
                        result.put("url", url);
                        result.put("success", true);
                        eventBus.invokeAndKeepAlive(result);
                    });
                    instance.setOnMessageItemClickListener(url -> {
                        JSONObject result = new JSONObject();
                        result.put("type", "MessageItemClick");
                        result.put("url", url);
                        result.put("success", true);
                        eventBus.invokeAndKeepAlive(result);
                    });
                    instance.setOnQuickEntryListener((shopId, quickEntry) -> {
                        JSONObject result = new JSONObject();
                        result.put("type", "QuickEntryClick");
                        result.put("shopId", shopId);
                        result.put("iconUrl", quickEntry.getIconUrl());
                        result.put("id", quickEntry.getId());
                        result.put("name", quickEntry.getName());
                        result.put("success", true);
                        eventBus.invokeAndKeepAlive(result);
                    });
                    instance.setOnShopEntranceClickListener((shopId) -> {
                        JSONObject result = new JSONObject();
                        result.put("type", "ShopEntranceClick");
                        result.put("shopId", shopId);
                        result.put("success", true);
                        eventBus.invokeAndKeepAlive(result);
                    });
                    instance.setOnSessionListEntranceClickListener(() -> {
                        JSONObject result = new JSONObject();
                        result.put("type", "SessionListEntranceClick");
                        result.put("success", true);
                        eventBus.invokeAndKeepAlive(result);
                    });
                    consultInstance.onSessionUpdateListener = (instance1, session) -> {
                        JSONObject result = new JSONObject();
                        result.put("type", "SessionUpdate");
                        result.put("shopId", instance1.shopId);
                        result.put("contactId", session.getContactId());
                        result.put("content", session.getContent());
                        switch (session.getMsgStatus()) {
                            case draft:
                                result.put("msgStatus", "draft");
                                break;
                            case sending:
                                result.put("msgStatus", "sending:");
                                break;
                            case success:
                                result.put("msgStatus", "success");
                                break;
                            case fail:
                                result.put("msgStatus", "fail");
                                break;
                            case read:
                                result.put("msgStatus", "read");
                                break;
                            case unread:
                                result.put("msgStatus", "unread");
                                break;
                        }
                        result.put("time", session.getTime());
                        result.put("unreadCount", session.getUnreadCount());
                        result.put("success", true);
                        eventBus.invokeAndKeepAlive(result);
                    };
                    consultInstance.onSessionDeleteListener = (instance1, shopId) -> {
                        JSONObject result = new JSONObject();
                        result.put("type", "SessionDelete");
                        result.put("shopId", shopId);
                        result.put("success", true);
                        eventBus.invokeAndKeepAlive(result);
                    };

                    JSONObject result = new JSONObject();
                    result.put("type", "OpenServiceResult");
                    result.put("success", true);
                    eventBus.invokeAndKeepAlive(result);

                } else {
                    JSONObject result = new JSONObject();
                    result.put("type", "OpenServiceResult");
                    result.put("errMsg", "Not found " + key + ", use createConsultSource create it first");
                    result.put("success", false);
                    eventBus.invoke(result);
                }

            } else {
                JSONObject result = new JSONObject();
                result.put("type", "OpenServiceResult");
                result.put("success", false);
                result.put("errMsg", "Param key must provide");
                eventBus.invoke(result);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            JSONObject result = new JSONObject();
            result.put("type", "OpenServiceResult");
            result.put("success", false);
            result.put("errMsg", "Exception: " + e.getLocalizedMessage());
            eventBus.invoke(result);
        }
    }

    //自定义的相关方法
    //=====================================================

    /**
     * 更改界面自定义方法
     * 参考http://qiyukf.com/docs/guide/android/5-%E8%87%AA%E5%AE%9A%E4%B9%89%E6%A0%B7%E5%BC%8F.html#%E8%81%8A%E5%A4%A9%E7%AA%97%E5%8F%A3%E8%87%AA%E5%AE%9A%E4%B9%89
     * @param options {}
     */
    @Keep
    @UniJSMethod()
    public void changeUICustomization(JSONObject options) {
        YSFOptions ysfOptions = QiyukfInit.getOptions();
        UICustomization uiCustomization = ysfOptions.uiCustomization;

        if(options.containsKey("msgBackgroundUri"))
            uiCustomization.msgBackgroundUri = options.getString("msgBackgroundUri");
        if(options.containsKey("msgBackgroundColor"))
            uiCustomization.msgBackgroundColor = UniResourceUtils.getColor(options.getString("msgBackgroundColor"));
        if(options.containsKey("msgListViewDividerHeight"))
            uiCustomization.msgListViewDividerHeight = options.getInteger("msgListViewDividerHeight");
        if(options.containsKey("hideLeftAvatar"))
            uiCustomization.hideLeftAvatar = options.getBoolean("hideLeftAvatar");
        if(options.containsKey("hideRightAvatar"))
            uiCustomization.hideRightAvatar = options.getBoolean("hideRightAvatar");
        if(options.containsKey("avatarShape"))
            uiCustomization.avatarShape = options.getInteger("avatarShape");
        if(options.containsKey("leftAvatar"))
            uiCustomization.leftAvatar = options.getString("leftAvatar");
        if(options.containsKey("rightAvatar"))
            uiCustomization.rightAvatar = options.getString("rightAvatar");
        if(options.containsKey("isShowTitleAvatar"))
            uiCustomization.isShowTitleAvatar = options.getBoolean("isShowTitleAvatar");
        if(options.containsKey("tipsTextColor"))
            uiCustomization.tipsTextColor = UniResourceUtils.getColor(options.getString("tipsTextColor"));
        if(options.containsKey("tipsTextSize"))
            uiCustomization.tipsTextSize = options.getFloat("tipsTextSize");

        if(options.containsKey("msgItemBackgroundLeft"))
            uiCustomization.msgItemBackgroundLeft = MResource.getIdByName(AppProxy.getAppContext(),"drawable", options.getString("msgItemBackgroundLeft"));
        else
            uiCustomization.msgItemBackgroundLeft = 0;
        if(options.containsKey("msgItemBackgroundRight"))
            uiCustomization.msgItemBackgroundRight = MResource.getIdByName(AppProxy.getAppContext(),"drawable", options.getString("msgItemBackgroundRight"));
        else
            uiCustomization.msgItemBackgroundRight = 0;
        if(options.containsKey("msgRobotItemBackgroundLeft"))
            uiCustomization.msgRobotItemBackgroundLeft = MResource.getIdByName(AppProxy.getAppContext(),"drawable", options.getString("msgRobotItemBackgroundLeft"));
        else
            uiCustomization.msgRobotItemBackgroundLeft = 0;
        if(options.containsKey("msgRobotItemBackgroundRight"))
            uiCustomization.msgRobotItemBackgroundRight = MResource.getIdByName(AppProxy.getAppContext(),"drawable", options.getString("msgRobotItemBackgroundRight"));
        else
            uiCustomization.msgRobotItemBackgroundRight = 0;
        if(options.containsKey("audioMsgAnimationLeft"))
            uiCustomization.audioMsgAnimationLeft = MResource.getIdByName(AppProxy.getAppContext(),"drawable", options.getString("audioMsgAnimationLeft"));
        else
            uiCustomization.audioMsgAnimationLeft = 0;
        if(options.containsKey("audioMsgAnimationRight"))
            uiCustomization.audioMsgAnimationRight = MResource.getIdByName(AppProxy.getAppContext(),"drawable", options.getString("audioMsgAnimationRight"));
        else
            uiCustomization.audioMsgAnimationRight = 0;

        if(options.containsKey("textMsgColorLeft"))
            uiCustomization.textMsgColorLeft = UniResourceUtils.getColor(options.getString("textMsgColorLeft"));
        if(options.containsKey("hyperLinkColorLeft"))
            uiCustomization.hyperLinkColorLeft = UniResourceUtils.getColor(options.getString("hyperLinkColorLeft"));
        if(options.containsKey("textMsgColorRight"))
            uiCustomization.textMsgColorRight = UniResourceUtils.getColor(options.getString("textMsgColorRight"));
        if(options.containsKey("hyperLinkColorRight"))
            uiCustomization.hyperLinkColorRight = UniResourceUtils.getColor(options.getString("hyperLinkColorRight"));
        if(options.containsKey("textMsgSize"))
            uiCustomization.textMsgSize = options.getFloat("textMsgSize");
        if(options.containsKey("inputTextColor"))
            uiCustomization.inputTextColor = UniResourceUtils.getColor(options.getString("inputTextColor"));
        if(options.containsKey("inputTextSize"))
            uiCustomization.textMsgSize = options.getFloat("inputTextSize");
        if(options.containsKey("topTipBarBackgroundColor"))
            uiCustomization.topTipBarBackgroundColor = UniResourceUtils.getColor(options.getString("topTipBarBackgroundColor"));
        if(options.containsKey("topTipBarTextSize"))
            uiCustomization.topTipBarTextSize = options.getFloat("topTipBarTextSize");
        if(options.containsKey("topTipBarTextColor"))
            uiCustomization.topTipBarTextColor = UniResourceUtils.getColor(options.getString("topTipBarTextColor"));
        if(options.containsKey("titleBackgroundColor"))
            uiCustomization.titleBackgroundColor = UniResourceUtils.getColor(options.getString("titleBackgroundColor"));
        if(options.containsKey("titleBarStyle"))
            uiCustomization.titleBarStyle = options.getInteger("titleBarStyle");
        if(options.containsKey("titleCenter"))
            uiCustomization.titleCenter = options.getBoolean("titleCenter");
        if(options.containsKey("buttonTextColor"))
            uiCustomization.buttonBackgroundColorList = MResource.getIdByName(AppProxy.getAppContext(),"drawable", options.getString("buttonBackgroundColorList"));
        else
            uiCustomization.buttonBackgroundColorList = 0;
        if(options.containsKey("buttonTextColor"))
            uiCustomization.buttonTextColor = UniResourceUtils.getColor(options.getString("buttonTextColor"));
        if(options.containsKey("hideAudio"))
            uiCustomization.hideAudio = options.getBoolean("hideAudio");
        if(options.containsKey("hideAudioWithRobot"))
            uiCustomization.hideAudioWithRobot = options.getBoolean("hideAudioWithRobot");
        if(options.containsKey("hideEmoji"))
            uiCustomization.hideEmoji = options.getBoolean("hideEmoji");
        if(options.containsKey("screenOrientation"))
            uiCustomization.screenOrientation = options.getInteger("screenOrientation");
        if(options.containsKey("hideKeyboardOnEnterConsult"))
            uiCustomization.hideKeyboardOnEnterConsult = options.getBoolean("hideKeyboardOnEnterConsult");
        if(options.containsKey("robotBtnBack"))
            uiCustomization.robotBtnBack = MResource.getIdByName(AppProxy.getAppContext(),"drawable", options.getString("robotBtnBack"));
        else
            uiCustomization.robotBtnBack = 0;
        if(options.containsKey("robotBtnTextColor"))
            uiCustomization.robotBtnTextColor = UniResourceUtils.getColor(options.getString("robotBtnTextColor"));
        if(options.containsKey("inputUpBtnBack"))
            uiCustomization.inputUpBtnBack = MResource.getIdByName(AppProxy.getAppContext(),"drawable", options.getString("inputUpBtnBack"));
        else
            uiCustomization.inputUpBtnBack = 0;
        if(options.containsKey("inputUpBtnTextColor"))
            uiCustomization.inputUpBtnTextColor = UniResourceUtils.getColor(options.getString("inputUpBtnTextColor"));
        if(options.containsKey("loadingAnimationDrawable"))
            uiCustomization.loadingAnimationDrawable = MResource.getIdByName(AppProxy.getAppContext(),"drawable", options.getString("loadingAnimationDrawable"));
        else
            uiCustomization.loadingAnimationDrawable = 0;
        if(options.containsKey("editTextHint"))
            uiCustomization.editTextHint = options.getString("editTextHint");

        if(options.containsKey("titleBarConfig")) {
            TitleBarConfig titleBarConfig = new TitleBarConfig();
            JSONObject titleBarConfigJson = options.getJSONObject("titleBarConfig");

            if(titleBarConfigJson.containsKey("titleBarRightQuitBtnBack"))
                titleBarConfig.titleBarRightQuitBtnBack = MResource.getIdByName(AppProxy.getAppContext(),"drawable", titleBarConfigJson.getString("titleBarRightQuitBtnBack"));
            if(titleBarConfigJson.containsKey("titleBarRightHumanBtnBack"))
                titleBarConfig.titleBarRightHumanBtnBack = MResource.getIdByName(AppProxy.getAppContext(),"drawable", titleBarConfigJson.getString("titleBarRightHumanBtnBack"));
            if(titleBarConfigJson.containsKey("titleBarRightEvaluatorBtnBack"))
                titleBarConfig.titleBarRightEvaluatorBtnBack = MResource.getIdByName(AppProxy.getAppContext(),"drawable", titleBarConfigJson.getString("titleBarRightEvaluatorBtnBack"));
            if(titleBarConfigJson.containsKey("titleBarRightImg"))
                titleBarConfig.titleBarRightImg = MResource.getIdByName(AppProxy.getAppContext(),"drawable", titleBarConfigJson.getString("titleBarRightImg"));
            if(titleBarConfigJson.containsKey("titleBarRightTextColor"))
                titleBarConfig.titleBarRightTextColor = UniResourceUtils.getColor(titleBarConfigJson.getString("titleBarRightTextColor"));
            if(titleBarConfigJson.containsKey("titleBarRightText"))
                titleBarConfig.titleBarRightText = titleBarConfigJson.getString("titleBarRightText");

            titleBarConfig.onTitleBarRightBtnClickListener = new OnTitleBarRightBtnClickListener() {
                @Override
                public void onClick(Activity activity) {
                    Map<String, Object> params = new HashMap<>();
                    Map<String, Object> detail = new HashMap<>();
                    params.put("detail", detail);
                    mUniSDKInstance.fireGlobalEventCallback("QiyuTitleBarRightBtnClick", params);
                }
            };



            ysfOptions.titleBarConfig = titleBarConfig;
        }

        if(options.containsKey("inputPanelOptions")) {

            InputPanelOptions inputPanelOptions = new InputPanelOptions();
            JSONObject inputPanelOptionsJson = options.getJSONObject("inputPanelOptions");

            if(inputPanelOptionsJson.containsKey("voiceIconResId"))
                inputPanelOptions.voiceIconResId = MResource.getIdByName(AppProxy.getAppContext(),"drawable", inputPanelOptionsJson.getString("voiceIconResId"));
            else
                inputPanelOptions.voiceIconResId = 0;
            if(inputPanelOptionsJson.containsKey("emojiIconResId"))
                inputPanelOptions.emojiIconResId = MResource.getIdByName(AppProxy.getAppContext(),"drawable", inputPanelOptionsJson.getString("emojiIconResId"));
            else
                inputPanelOptions.emojiIconResId = 0;
            if(inputPanelOptionsJson.containsKey("photoIconResId"))
                inputPanelOptions.photoIconResId = MResource.getIdByName(AppProxy.getAppContext(),"drawable", inputPanelOptionsJson.getString("photoIconResId"));
            else
                inputPanelOptions.photoIconResId = 0;
            if(inputPanelOptionsJson.containsKey("moreIconResId"))
                inputPanelOptions.moreIconResId = MResource.getIdByName(AppProxy.getAppContext(),"drawable", inputPanelOptionsJson.getString("moreIconResId"));
            else
                inputPanelOptions.moreIconResId = 0;
            if(inputPanelOptionsJson.containsKey("showActionPanel"))
                inputPanelOptions.showActionPanel = inputPanelOptionsJson.getBoolean("showActionPanel");

            if(options.containsKey("actionPanelOptions")) {

                ActionPanelOptions actionPanelOptions = inputPanelOptions.actionPanelOptions;
                JSONObject actionPanelOptionsJson = options.getJSONObject("inputPanelOptions");

                if(actionPanelOptionsJson.containsKey("backgroundColor"))
                    actionPanelOptions.backgroundColor = UniResourceUtils.getColor(options.getString("backgroundColor"));
                if(actionPanelOptionsJson.containsKey("actionListProvider")) {

                    JSONArray arr = actionPanelOptionsJson.getJSONArray("actionListProvider");
                    actionPanelOptions.actionListProvider = new ActionListProvider() {
                        @Override
                        public List<BaseAction> getActionList() {
                            List<BaseAction> list = new ArrayList<>();
                            for (int i = 0; i < arr.size(); i++) {
                                JSONObject o = arr.getJSONObject(i);
                                switch (o.getString("type")) {
                                    case "Image":
                                        list.add(new ImageAction(
                                                MResource.getIdByName(AppProxy.getAppContext(), "drawable", o.getString("iconResId")),
                                                MResource.getIdByName(AppProxy.getAppContext(), "string", o.getString("titleId"))
                                        ));
                                        break;
                                    case "Camera":
                                        list.add(new CameraAction(
                                                MResource.getIdByName(AppProxy.getAppContext(), "drawable", o.getString("iconResId")),
                                                MResource.getIdByName(AppProxy.getAppContext(), "string", o.getString("titleId"))
                                        ));
                                        break;
                                    case "Album":
                                        list.add(new AlbumAction(
                                                MResource.getIdByName(AppProxy.getAppContext(), "drawable", o.getString("iconResId")),
                                                MResource.getIdByName(AppProxy.getAppContext(), "string", o.getString("titleId"))
                                        ));
                                        break;
                                    case "Custom":
                                        list.add(new BaseAction(
                                                MResource.getIdByName(AppProxy.getAppContext(), "drawable", o.getString("iconResId")),
                                                MResource.getIdByName(AppProxy.getAppContext(), "string", o.getString("titleId"))) {
                                            @Override
                                            public void onClick() {
                                                Map<String, Object> params = new HashMap<>();
                                                Map<String, Object> detail = new HashMap<>();
                                                detail.put("key", o.getString("key"));
                                                params.put("detail", detail);
                                                mUniSDKInstance.fireGlobalEventCallback("QiyuActionListCustomActionClick", params);
                                            }
                                        });
                                        break;
                                }
                            }
                            return list;
                        }
                    };
                } else {
                    actionPanelOptions.actionListProvider = null;
                }

            } else {
                inputPanelOptions.actionPanelOptions = null;
            }

            ysfOptions.inputPanelOptions = inputPanelOptions;
        }

    }

    /**
     * 更改通知相关方法 （Android）
     * @param options {}
     */
    public void changeNotificationOptions(JSONObject options) {
        YSFOptions ysfOptions = QiyukfInit.getOptions();
        StatusBarNotificationConfig statusBarNotificationConfig = ysfOptions.statusBarNotificationConfig;

        if(options.containsKey("notificationColor"))
            statusBarNotificationConfig.notificationColor = UniResourceUtils.getColor(options.getString("notificationColor"));
        if(options.containsKey("notificationColor"))
            statusBarNotificationConfig.notificationSound = options.getString("notificationSound");
        if(options.containsKey("notificationSmallIconId"))
            statusBarNotificationConfig.notificationSmallIconId = MResource.getIdByName(AppProxy.getAppContext(), "drawable", options.getString("notificationSmallIconId"));
        if(options.containsKey("ring"))
            statusBarNotificationConfig.ring = options.getBoolean("ring");
        if(options.containsKey("showBadge"))
            statusBarNotificationConfig.showBadge = options.getBoolean("showBadge");
        if(options.containsKey("hideContent"))
            statusBarNotificationConfig.hideContent = options.getBoolean("hideContent");
        if(options.containsKey("downTimeToggle"))
            statusBarNotificationConfig.downTimeToggle = options.getBoolean("downTimeToggle");
        if(options.containsKey("titleOnlyShowAppName"))
            statusBarNotificationConfig.titleOnlyShowAppName = options.getBoolean("titleOnlyShowAppName");
        if(options.containsKey("downTimeEnableNotification"))
            statusBarNotificationConfig.downTimeEnableNotification = options.getBoolean("downTimeEnableNotification");
        if(options.containsKey("customTitleWhenTeamNameEmpty"))
            statusBarNotificationConfig.customTitleWhenTeamNameEmpty = options.getString("customTitleWhenTeamNameEmpty");
        if(options.containsKey("downTimeBegin"))
            statusBarNotificationConfig.downTimeBegin = options.getString("downTimeBegin");
        if(options.containsKey("downTimeEnd"))
            statusBarNotificationConfig.downTimeEnd = options.getString("downTimeEnd");
        if(options.containsKey("ledARGB"))
            statusBarNotificationConfig.ledARGB = options.getInteger("ledARGB");
        if(options.containsKey("ledOnMs"))
            statusBarNotificationConfig.ledOnMs = options.getInteger("ledOnMs");
        if(options.containsKey("ledOffMs"))
            statusBarNotificationConfig.ledOffMs = options.getInteger("ledOffMs");
        if(options.containsKey("notificationFoldStyle")) {
            switch (options.getString("notificationFoldStyle")) {
                case "ALL":
                    statusBarNotificationConfig.notificationFoldStyle = NotificationFoldStyle.ALL;
                    break;
                case "CONTACT":
                    statusBarNotificationConfig.notificationFoldStyle = NotificationFoldStyle.CONTACT;
                    break;
                case "EXPAND":
                    statusBarNotificationConfig.notificationFoldStyle = NotificationFoldStyle.EXPAND;
                    break;
            }
        }
        if(options.containsKey("notificationExtraType")) {
            switch (options.getString("notificationExtraType")) {
                case "MESSAGE":
                    statusBarNotificationConfig.notificationExtraType = NotificationExtraTypeEnum.MESSAGE;
                    break;
                case "JSON_ARR_STR":
                    statusBarNotificationConfig.notificationExtraType = NotificationExtraTypeEnum.JSON_ARR_STR;
                    break;
            }
        }
    }




}
