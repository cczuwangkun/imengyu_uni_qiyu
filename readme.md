## 简介

这是网易七鱼在线客服SDK的UniApp原生封装插件，支持Android/iOS，支持平台版的很多功能，支持自定义配置等等。

关于SDK的文档，请参考[官方文档](http://qiyukf.com/docs/)。

**注意，本插件只能在App端使用，小程序或者H5请使用七鱼官方的**[Web SDK](http://qiyukf.com/docs/guide/web/)或者[微信小程序SDK](http://qiyukf.com/docs/guide/wechat_sdk/)。

本插件向 UniApp 公开了大部分 API，方便您自由使用相关功能。

如果在插件使用中遇到了问题或者bug，或者有缺少的API, 欢迎向我提出建议，我会尽量修改以满足您的要求。

## 使用说明

请绑定插件至您的项目，然后在插件配置中配置您的**七鱼在线客服appKey**，否则客服功能将无法正常使用。

绑定后请生成一个自定义调试基座，调试时请选择自定义调试基座。

在代码中导入模块，然后调用相关方法，例如：

```js
const qiyukfModule = uni.requireNativePlugin('imengyu-Qiyukf-QiyukfModule')

qiyukfModule.openService({
  staffId: 481473168,
  title: '咨询客服',
  sourceUrl: 'mine',
  sourceTitle: '我的',
}, (res) => {
  console.log(res);
});
```

具体方法说明，见下方 API 文档。

## API 文档

**事先说明：** Android 与 iOS 两个端提供的 API 并不是完全相同的，因为七鱼SDK本身提供的就不一样，插件并没有过度封装成一样的方法，因为这本身没有意义，而且很可能会造成您使用上出现疑问。因此，大部分API与七鱼官方一致，方便您查阅官方文档。Android 与 iOS 两个端的差异需要您在自己的App中分别处理。

所有Android/iOS两个端的差异会在下方说明。

在使用本插件之前请查阅官方SDK文档：[Android](http://qiyukf.com/docs/guide/android/) 和 [iOS](http://qiyukf.com/docs/guide/ios/)。

### 基础

#### CRM对接

* `setUserInfo(data, callback)`

  上报用户信息。

  * **data 参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | userId | string  | 是 | 用户唯一性标识 |
    | data | string  | 是 | JSON 字符串形式，展示在客服端信息 |
    | authToken | string  | 否 | 若企业需校验用户的 AuthToken，在此字段填写，为空则不校验 |

  * **callback 回调参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | success | boolean  | 是 | 表示是否成功 |
    | errMsg | string  | 否 | 错误信息 |
    | code | number  | 否 | 七鱼返回的状态码 |

* `clearUserInfo()`

  注销用户.

#### SDK 方法

* `isInit(options, callback)`

  获取七鱼SDK当前是否已初始化。

  * **options 参数**

    无参数

  * **callback 回调参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | isInit | boolean  | 是 | 当前是否已初始化 |

* `toggleNotification(options)` (Android)

  通知栏消息提醒开关控制。

  默认情况下，只有访客在聊天界面时，才不会有通知栏提醒，其他界面以及 App 在后台时，都会有消息提醒。如果当 App 在前台时，不需要通知栏提醒新消息，可以调用toggleNotification关闭消息提醒，然后在 App 退到后台时，调用toggleNotification重新打开。

  * **options 参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | on | boolean  | 是 | 用户唯一性标识 |

* `clearCache()`

  通知栏消息提醒开关控制。

### 打开客服窗口

* `openService(options, eventBus)`

  打开七鱼SDK客服窗口。

  第一次打开需要指定options参数，第二次调用时如果之前的客服会话未关闭，则参数无效，需要先调用 `closeService` 关闭当前客服会话，再重新打开。

  * **Android** 参数与返回：

    * **options 参数**

      |  属性 | 类型 | 必填  | 说明  |
      |  ----  | ----  | ----  | ----  |
      | staffId | number  | 否 | 客服ID |
      | groupId | number  | 否 | 客服组ID |
      | shopId | number  | 否 | 要咨询的商家 ID 平台电商调用，非平台电商不需要该字段。 |
      | robotFirst | boolean  | 否 | 如果指定了 groupId 或者 staffId 时，该参数有效。表示会先进机器人，之后如果用户转人工服务，再分配给上面指定的groupId 或者 staffId |
      | robotId | number  | 否 | 机器人ID，如果开启了机器人，该参数有效。如果不设置，将连接默认机器人。 机器人ID可以在管理后台的 设置 -> APP接入 中查看。 |
      | faqGroupId | number  | 否 | 机器人热门问题组 ID 如果指定了此参数，且请求客服为机器人客服，则会下发该 ID 对应的热门问题。 热门问题组 ID 可在管理后台查询。 |
      | quickEntryList | `Array<QuickEntry>` | 否 | 人工客服时显示在输入框上方的快捷入口，如“选订单”，点击后可以响应自定义事件。在 `setCustomEventsHandler` 设置自定义事件接收器中会以 QuickEntryClick 事件回调。 |
      | lifeCycleOptions | `LifeCycleOptions`  | 否 | 对用户咨询会话的一些生命周期控制选项。通过这些选项，APP可以自定义是否允许用户主动结束会话， 用户主动退出排队等开关，以及排队过程中用户按返回键的提示语等信息。 默认为 null |
      | productDetail | `ProductDetail` | 否 | 访客发起会话时所带的商品消息信息 |
      | shopEntrance | `ShopEntrance` | 否 | 商家入口信息 如果为 null ，则不显示商家入口 |
      | sessionListEntrance | `SessionListEntrance` | 否 | 会话列表入口信息 如果为 null ，则不显示会话列表入口 |
      | prompt | string  | 否 | 连接专属客服成功时候的提示语 |
      | custom | string  | 否 | 可自定义传入的字符串，比如商品详细信息，用户操作状态等等, 在分配客服时该字段会传递给客服。 |
      | VIPStaffAvatarUrl | string  | 否 | 专属客服头像的 url ，如果配置了该字段，那么与这个客服聊天的消息都会为这个字段 |
      | vipStaffName | string  | 否 | 专属客服的名字 |
      | vipStaffWelcomeMsg | string  | 否 | 专属客服的欢迎语 |
      | vipStaffid | string  | 否 | 专属客服的 id |
      | vipLevel | number  | 否 | 用户VIP等级 0:非VIP（默认） 1-10:VIP等级 11:通用VIP（不显示等级） |
      | robotWelcomeMsgId | string  | 否 | 机器人欢迎语 id ，可以通过该参数配置不同的机器人欢迎语 |
      | leaveMsgTemplateId | string  | 否 | 留言模版 id ，可以通过指定该参数配置不同的留言模版 |
      | forbidUseCleanTopStart | boolean  | 否 | 是否禁止使用 FLAG_ACTIVITY_CLEAR_TOP 去启动客服 Activity，默认为 false |

      * QuickEntry 结构

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | id | number  | 是 | 这个快捷入口ID |
        | title | string  | 是 | 快捷入口标题 |
        | iconUrl | string  | 是 | 快捷入口图标的URL |

      * ShopEntrance 结构

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | logo | string  | 是 | 商家logo url 图片地址 |
        | name | string  | 是 | 商家名称 最多显示三个字符超出将显示“xx...” |

      * SessionListEntrance 结构

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | position | string  | 是 | 入口图片资源id名称。建议为半透明图片，如果不设置将显示默认图片 |
        | imageResId | string  | 是 | 入口位置。目前包含TOP_LEFT和TOP_RIGHT，即屏幕左上角和右上角，如果不设置将默认位于右上角 |

      * LifeCycleOptions 结构

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | canCloseSession | boolean  | 否 | 设置是否允许用户主动结束会话。 设置该选项后，在会话状态下，右上角会有结束会话的入口 |
        | canQuitQueue | boolean  | 是 | 设置是否允许用户主动退出排队。 设置该选项后，在排队状态下，右上角会有退出排队的入口。如果用户通过按返回键退出，会给出提示。 |
        | quitQueuePrompt | string  | 是 | 设置排队状态下，按返回键时给用户的提示语，提示用户是否要退出排队。 注意： 该选项只有在 canQuitQueue 设置为 true 时才有效。 |

      * ProductDetail 结构

        |  属性 | 类型 | 说明  |
        |  ----  | ----  | ----  |
        | title | string  | 设置自定义商品消息的标题，非必填，未填写时不显示，消息传输时不超过100字，超过时自动截断进行传输。 |
        | picture | string  | 设置自定义商品消息的缩略图地址，非必填，未填写时显示默认图片，消息传输时不超过1000字，超过时自动截断进行传输。 |
        | desc | string  | 设置自定义商品消息的摘要，非必填，未填写时不显示，消息传输时不超过300字，超过时自动截断进行传输。 |
        | note | string  | 设置自定义商品消息的备注，非必填，未填写时不显示，消息传输时不超过100字，超过时自动截断进行传输。 |
        | url | string  | 设置自定义商品消息点击后的跳转地址，非必填，未填写时不可点击，消息传输时不超过1000字，超过时自动截断进行传输。 |
        | show | number  | 访客发起会话时，设置自定义商品消息是否显示在访客端，非必填，1为显示，未填写或者填入其他值时不显示在访客端。 |
        | alwaysSend | boolean  | 设置是否每次打开聊天窗口都发送商品消息。（相同的商品信息不会重复发送） |
        | openTemplate | boolean  | 是否开启新模版的展示 |
        | sendByUser | boolean  | 设置商品是否需要手动发送 |
        | actionText | string  | 设置底部发送链接的 text |
        | actionTextColor | string  | 设置发送链接文字的颜色 |
        | isOpenReselect | boolean  | 设置是否展示重新选择按钮 |
        | reselectText | string  | 设置重新选择按钮的文案 |
        | handlerTag | string  | 设置重新选择事件的标志，当点击重新选择按钮的点击事件可能会用到 |
        | ext | string  | 设置扩展字段 |
        | tags | ProductDetailTag[] | 设置快捷入口列表。 |

        * ProductDetailTag 结构

          |  属性 | 类型 | 说明  |
          |  ----  | ----  | ----  |
          |  data | string | 设置传递给iframe页面的数据  |
          |  focusIframe | string | 如果这个url需要跳转到七鱼客服界面中嵌入的iframe标签, 可通过该接口传入对应的标签名  |
          |  data | string | 设置操作入口的显示名字。  |
          |  url | string | 设置点击响应跳转的url地址 |

    * **eventBus 返回**

      |  属性 | 类型 | 必填  | 说明  |
      |  ----  | ----  | ----  | ----  |
      | type | `string` | 是 | 事件类型，见下方  |
      | ... |  | 否 | 不同事件类型有不同参数，见下方 |

      * OpenServiceResult ：调用 openService 返回的结果

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | success | boolean  | 是 | 表示是否成功 |
        | errMsg | string  | 否 | 错误信息 |

      * SessionUpdate ：当前会话更新时发生回调，例如添加、删除、新消息等

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | success | boolean  | 是 | 表示是否成功 |
        | shopId | string  | 是 | 当前会话的商家ID |
        | contactId | string  | 是 | 当前会话的联系ID |
        | content | string  | 是 | 当前会话的最新一条消息内容 |
        | time | string  | 是 | 当前会话的最新一条消息的时间戳 |
        | unreadCount | string  | 是 | 当前会话的商家的未读消息条数 |
        | msgStatus | string | 是 | 当前会话的最新一条消息状态 有这几种状态 draft，sending，success，fail，read，unread |

      * SessionDelete ：当前会话结束删除时发生

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | success | boolean  | 是 | 表示是否成功 |
        | shopId | string  | 是 | 当前会话的商家ID |

  * **iOS** 参数与返回：
  
    * **options 参数**

      |  属性 | 类型 | 必填  | 说明  |
      |  ----  | ----  | ----  | ----  |
      | sourceTitle | string  | 否 | 来源标题 title可对应管理后台“App核心页面列表”中“页面名称”（v5.10.0） |
      | sourceUrl | string  | 否 | 来源链接 urlString可对应管理后台“App核心页面列表”中“页面链接”（v5.10.0） 此处不做链接相关校验，可传任意字符串 |
      | custom | string  | 否 | 来源自定义信息 |
      | shopId | string  | 否 | 如果是平台企业，可以填写目标商家ID，非平台不需要此字段 |
      | groupId | number  | 否 | 访客分流 分组Id |
      | staffId | number  | 否 | 访客分流 客服Id |
      | robotId | number  | 否 | 机器人Id |
      | vipLevel | number  | 否 | vip等级 |
      | commonQuestionTemplateId | number  | 否 | 常见问题 模板Id |
      | robotWelcomeTemplateId | number  | 否 | 机器人欢迎语 模板Id |
      | shuntTemplateId | number  | 否 | 多入口分流 模板Id |
      | title | string  | 否 | 会话窗口标题 |
      | openRobotInShuntMode | boolean  | 否 | 访客分流 是否开启机器人 仅设置staffId/groupId时生效 |
      | commodityInfo | QYCommodityInfo | 否 | 商品信息展示 |
      | canCopyCommodityInfo | boolean  | 否 | 商品消息是否支持长按复制urlString信息，默认为true |
      | staffInfo | QYStaffInfo | 否 | 人工客服信息 |
      | quickEntryList | `Array<QYButtonInfo>` | 否 | 输入区域上方工具栏内的按钮信息 |
      | autoSendInRobot | boolean  | 否 | 机器人自动发送商品信息功能 |
      | messagePageLimit | number  | 否 | 每页消息加载的最大数量，默认为20条 |
      | hideHistoryMessages | boolean  | 否 | 是否收起历史消息，默认为false；若设置为true，进入会话界面时若需创建新会话，则收起历史消息 |
      | historyMessagesTip | string  | 否 | 历史消息提示文案，默认为“——以上为历史消息——”；仅在hideHistoryMessages为true，首次下拉历史消息时展示 |

      * QYCommodityInfo 商品信息结构

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | pictureUrlString | string  | 否 | 商品图片链接，字符数要求小于1000 |
        | title | string  | 否 | 商品标题，字符数要求小于100 |
        | desc | string  | 否 | 商品描述，字符数要求小于300 |
        | note | string  | 否 | 备注信息，可以显示价格，订单号等，字符数要求小于100 |
        | urlString | string  | 否 | 跳转url，字符数要求小于1000 |
        | tagsArray | QYCommodityTag[]  | 否 | 标签数据，数组类型 |
        | tagsString | string  | 否 | 标签数据，字符串类型，与数组类型二选一 |
        | show | boolean  | 否 | 发送时是否在访客端隐藏，默认隐藏 |
        | isPictureLink | boolean  | 否 | 是否仅显示商品图片，默认否 |
        | sendByUser | boolean  | 否 | 是否由访客主动发送，默认否；设置为true，消息下方新增发送按钮 (v4.4.0) |
        | actionText | string  | 否 | 发送按钮文案 |
        | actionTextColor | string  | 否 | 发送按钮文案颜色  |
        | ext | string | 否 | 一般用户不需要填这个字段，这个字段仅供特定用户使 |

        * QYCommodityTag 结构

          |  属性 | 类型 | 必填  | 说明  |
          |  ----  | ----  | ----  | ----  |
          | label | string  | 否 | 标签标题 |
          | url | string  | 否 | 跳转URL |
          | focusIframe | string  | 否 |  |
          | data | string  | 否 |  |

      * QYButtonInfo 结构

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | title | string  | 是 | 标题 |
        | id | number  | 是 | 按钮ID |

      * QYStaffInfo 人工客服信息结构

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | staffId | string  | 否 | 客服ID，限制20字符 |
        | nickName | string  | 否 | 客服昵称，限制20字符 |
        | iconURL | string  | 否 | 客服头像URL |
        | accessTip | string  | 否 | 接入提示，限制50字符 |
        | infoDesc | string  | 否 | 客服信息描述 |

    * **eventBus 返回**

      |  属性 | 类型 | 必填  | 说明  |
      |  ----  | ----  | ----  | ----  |
      | type | `string` | 是 | 事件类型，见下方  |
      | ... |  | 否 | 不同事件类型有不同参数，见下方 |

      * OpenServiceResult ：调用 openService 返回的结果

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | success | boolean  | 是 | 表示是否成功 |
        | errMsg | string  | 否 | 错误信息 |

      * SessionUpdate ：当前会话更新时发生回调，例如添加、删除、新消息等

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | success | boolean  | 是 | 表示是否成功 |
        | shopId | string  | 是 | 当前会话的商家ID |
        | content | string  | 是 | 当前会话的最新一条消息内容 |
        | time | string  | 是 | 当前会话的最新一条消息的时间戳 |
        | unreadCount | string  | 是 | 当前会话的商家的未读消息条数 |

      * SessionDelete ：当前会话结束删除时发生

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | success | boolean  | 是 | 表示是否成功 |
        | shopId | string  | 是 | 当前会话的商家ID |

      * ReceiveMessage ：当前会话有新消息时发生

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | message | QYMessage | 是 | 新消息 |

      * ShopEntranceClick ：点击右上角按钮回调（对于平台电商来说，这里可以考虑放“商铺入口”）

        无特殊参数。

      * SessionListEntranceClick ：点击聊天内容区域的按钮回调（对于平台电商来说，这里可以考虑放置“会话列表入口“）

        无特殊参数。

      * QuickEntryClick ： 工具栏内按钮点击回调定义

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | title | string | 是 | 按钮标题 |
        | id | string | 是 | 按钮ID |
        | actionType | number | 是 | actionType为1表示发送文本消息title，2表示openURL或是自定义行为 |
        | index | number | 是 | index表示该button位置 |

    * QYMessage 结构

      |  属性 | 类型 | 必填  | 说明  |
      |  ----  | ----  | ----  | ----  |
      | type | string | 是 | 消息类型 None未知，Text文字，Image图片，Audio音频，Video视频，File文件， Custom自定义 |
      | text | string | 是 | 消息文本内容 |
      | content | string | 是 | 消息文本内容，同text |
      | time | number | 是 | 消息时间戳 |

* `closeService(options, callback)`

  关闭 `openService` 打开的客服会话。

  * **options 参数**

    无参数

  * **callback 回调参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | success | boolean  | 是 | 表示是否成功 |
    | errMsg | string  | 否 | 错误信息 |

### 发送消息

* `sendProductMessage(options)`

  发送商品信息。

  * **options 参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | shopId | string  | 否 | 如果是平台企业，可以填写目标发送商家ID，非平台不需要此字段 |
    | ... |   | 是 | Android 商品结构请参考 `openService` 的 ProductDetail 结构 |
    | ... |   | 是 | iOS 商品结构请参考 `openService` 的 QYCommodityInfo 结构 |

* `sendMessage(options)`

  手动发送信息。

  * **options 参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | shopId | string  | 否 | 如果是平台企业，可以填写目标发送商家ID，非平台不需要此字段 |
    | type | string | 是 | 不同类型消息参数不同，见下方 |

    * file 发送文件消息

      |  属性 | 类型 | 必填  | 说明  |
      |  ----  | ----  | ----  | ----  |
      | filePath | string  | 是 | 文件路径，请转为绝对路径 |
      | displayName | string  | 否 | 显示名称 IOS 需要传 |

    * text 发送文字消息

      |  属性 | 类型 | 必填  | 说明  |
      |  ----  | ----  | ----  | ----  |
      | text | string  | 是 | 文字 |

    * video 发送视频消息

      |  属性 | 类型 | 必填  | 说明  |
      |  ----  | ----  | ----  | ----  |
      | filePath | string  | 是 | 文件路径，请转为绝对路径 |
      | displayName | string  | 否 | 视频显示名称, IOS 不用传 |
      | width | number  | 否 | 视频显示宽度, IOS 不用传 |
      | height | number  | 否 | 视频显示高度, IOS 不用传 |
      | duration | number  | 否 | 视频时长, IOS 不用传 |

    * image 发送图片消息

      |  属性 | 类型 | 必填  | 说明  |
      |  ----  | ----  | ----  | ----  |
      | filePath | string  | 是 | 文件路径，请转为绝对路径 |
      | displayName | string  | 否 | 图片显示名称, IOS 不用传 |

### 新消息提醒与未读数

#### 未读数

* `getUnreadCount(options, callback)`

  获取总的未读数。

  * **options 参数**

    无参数

  * **callback 回调参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | unreadCount | number  | 是 | 总的未读数 |

* `clearUnreadCount()`

  清除全部未读数。

* `POPClearUnreadCount(options)`

  平台企业清除全部未读数。  
  
  * **options 参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | shopId | string  | 是 | 商家ID |

* `addUnreadCountChangeListener(options, callback)`

  添加未读数变化监听回调。

  添加成功后会回调返回一次count为0，用于接收id。

  * **options 参数**

    无参数

  * **callback 回调参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | count | number  | 是 | 当前未读数 |
    | id | number  | 是 | 当前监听回调的ID，可以使用 removeUnreadCountChangeListener 停止监听 |

* `removeUnreadCountChangeListener(options)`

  移除未读数变化监听回调。

  * **options 参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | id | number  | 是 | addUnreadCountChangeListener 返回的监听回调的ID |

#### 新消息提醒

普通版新消息是通过 addUnreadCountChangeListener 判断未读数是否变化，变化就是有新消息，然后调用 queryLastMessage 获取最后一条消息内容，就可以显示提示框了。

平台版因为要区分不同的会话，您可调用 POPAddSessionListChangedListener 添加商家更新监听器，处理商家状态变化。

关于通知栏新消息的点击处理

* **Android通知栏新消息**的点击处理，参见[官方文档](http://qiyukf.com/docs/guide/android/4-%E6%B6%88%E6%81%AF%E6%8E%A8%E9%80%81.html#%E6%96%B0%E6%B6%88%E6%81%AF%E6%8F%90%E9%86%92)。

  插件封装了官方文档中提供的方法，你可以在 App.vue OnShow 中调用以下方法：

  ```js
  qiyukfModule.checkIntentForMessage((dat) => {
    if(dat.hasExtra) {
      if(dat.messages.length > 0) {
        console.log('点击了新消息!', dat.messages[0]);
        //在这里可以自由处理，例如，重新打开客服窗口

        qiyukfModule.resetIntent(); //处理后需要重置Intent数据，防止重复打开
      }
    }
  });
  ```

  * `checkIntentForMessage(callback)`

    点击通知栏提醒直接跳转到会话窗口检查 (Android)。

    * **callback 回调参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | hasExtra | boolean  | 是 | 表示当前用户是否点击了通知栏 |
    | messageContent | boolean  | 是 | 消息文字 |
    | messages | array  | 否 | 当前消息数组，消息结构与 queryLastMessage 返回的结构一致 |
    | key | string  | 否 |  |

  * `resetIntent()`

    重置检查Intent (Android)。处理后需要重置Intent数据，防止重复打开。

  * `changeNotificationOptions(options)`

    Android 通知栏配置。

    * **options参数**

      |  属性 | 类型 | 必填  | 说明  |
      |  ----  | ----  | ----  | ----  |
      | notificationColor | string  | 否 | 通知颜色 |
      | notificationSound | string  | 否 | 通知声音文件路径 |
      | notificationSmallIconId | string  | 否 | 通知小图标的resId |
      | ring | boolean  | 否 | 是否播放铃声 |
      | showBadge | boolean  | 否 | 是否显示徽章 |
      | hideContent | boolean  | 否 | 是否隐藏消息内容 |
      | downTimeToggle | boolean  | 否 |  |
      | titleOnlyShowAppName | boolean  | 否 | 标题是否只显示应用名称 |
      | downTimeEnableNotification | boolean  | 否 |  |
      | customTitleWhenTeamNameEmpty | string  | 否 |  |
      | downTimeBegin | string  | 否 |  |
      | downTimeEnd | string  | 否 |  |
      | ledARGB | number  | 否 | 呼吸灯的ARGB数值 |
      | ledOnMs | number  | 否 | 呼吸灯亮时间 |
      | ledOffMs | number  | 否 | 呼吸灯灭时间 |
      | notificationFoldStyle | string  | 否 | ALL, CONTACT, EXPAND |
      | notificationExtraType | string  | 否 | MESSAGE, JSON_ARR_STR  |

* **IOS通知栏新消息**的点击处理可以调用 setCustomEventsHandler 设置自定义事件处理，你需要处理 NotificationClick 事件，请参考 setCustomEventsHandler 。

#### 获取最后一条消息

* `queryLastMessage(options, callback)` (Android)

  获取和客服的最后一条聊天消息内容。

  * **options 参数**

    无参数

  * **callback 回调参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | content | string  | 是 | 消息内容 |
    | time | number  | 是 | 消息时间戳 |
    | remoteRead | boolean  | 是 | 远程是否已读 |
    | sessionId | string  | 是 | 消息所属会话ID |
    | fromAccount | string  | 是 | 消息所属账号 |

### 评价

* `openEvaluation(options, callback)` (Android)

  打开评价界面，如果自定义了评价界面会跳转自定义的评价界面，如果没有自定义，则进行七鱼评价界面的流程.

  * **options 参数**

    无参数

  * **callback 回调参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | data | boolean  | 否 | 评价结果对象 |
    | result | number  | 否 | 评价结果状态码 |
    | success | boolean  | 是 | 表示是否成功 |
    | errMsg | string  | 是 | 错误信息 |

* `setCustomEvaluation(options, callback)`

  设置自定义评价接口，只能设置一次，可使用deleteCustomEvaluation删除。

  * **options 参数**

    * Android

      无参数

    * iOS

      |  属性 | 类型 | 必填  | 说明  |
      |  ----  | ----  | ----  | ----  |
      | shopId | string  | 否 | 平台版是你需要请求的商家ID，普通版可以为空 |

  * **callback 回调参数**

    * Android

      |  属性 | 类型 | 必填  | 说明  |
      |  ----  | ----  | ----  | ----  |
      | type | string | 是 | 事件类型，有不同的参数，见下 |
      | success | boolean  | 是 | 表示是否成功 |
      | errMsg | string  | 是 | 错误信息 |

      * EvaluationStateChange 评价状态更改事件

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | state | number  | 是 | 评价状态 0:不可评价,1:可评价,2:评价完成 |

      * EvaluationMessageClick 邀评消息被点击，App 方可以在此方法启动自己的评价界面

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | entry | EvaluationOpenEntry  | 否 | 评价配置数据 |

        * EvaluationOpenEntry 结构

          |  属性 | 类型 | 必填  | 说明  |
          |  ----  | ----  | ----  | ----  |
          | evaluatorScenes | number  | 否 | 评价配置数据 |
          | lastSource | number  | 否 | 评价配置数据 |
          | lastRemark | String  | 否 | 评价配置数据 |
          | exchange | String  | 否 | 评价配置数据 |
          | sessionId | number  | 否 | 评价配置数据 |
          | title | String  | 否 | 评价配置数据 |
          | type | number  | 否 | 评价配置数据 |
          | resolvedEnabled | number  | 否 | 评价配置数据 |
          | resolvedRequired | number  | 否 | 评价配置数据 |
          | evaluationEntryList | `Array<EvaluationOptionEntry>` | 否 | 评价配置数据 |

          * EvaluationOptionEntry 结构

            |  属性 | 类型 | 必填  | 说明  |
            |  ----  | ----  | ----  | ----  |
            | commentRequired | boolean  | 否 | 评价配置数据 |
            | name | string  | 否 | 评价配置数据 |
            | tagList | string[]  | 否 | 评价配置数据 |
            | tagRequired | boolean  | 否 | 评价配置数据 |
            | value | number  | 否 | 评价配置数据 |

    * iOS

      |  属性 | 类型 | 必填  | 说明  |
      |  ----  | ----  | ----  | ----  |
      | type | string | 是 | 事件类型，有不同的参数，见下 |
      | success | boolean  | 是 | 表示是否成功 |
      | errMsg | string  | 是 | 错误信息 |

      * RobotEvaluation 机器人满意度评价事件

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | data | QYEvaluactionData | 是 | 评价数据，包括评价模式、选项及标签、上次评价结果等数据，据此构建评价界面 |

      * Evaluation 人工满意度评价事件

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | data | QYEvaluactionData | 是 | 评价数据，包括评价模式、选项及标签、上次评价结果等数据，据此构建评价界面 |

      * QYEvaluactionData 结构

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | urlString | string | 是 | 评价页面URL，对应“管理后台-评价样式-新页面”填写的字符串 |
        | sessionId | number | 是 | 评价会话ID，提交评价结果时需透传 |
        | optionList | `Arrray<QYEvaluationOptionData>` | 是 | 选项数据 |
        | mode | string | 是 | 评价模式 |
        | resolvedEnabled | boolean | 是 | 是否向访客收集“您的问题是否解决” |
        | resolvedRequired | boolean | 是 | “您的问题是否解决”是否必填 |

        * QYEvaluactionData.mode 枚举
          * QYEvaluationModeTwoLevel 模式一（二级满意度）：满意/不满意
          * QYEvaluationModeThreeLevel 模式二（三级满意度）：满意/一般/不满意
          * QYEvaluationModeFourLevel 模式三（四级满意度）：非常满意/满意/不满意/非常不满意
          * QYEvaluationModeFiveLevel 模式四（五级满意度）：非常满意/满意/一般/不满意/非常不满意

        * QYEvaluationOptionData 结构

          |  属性 | 类型 | 必填  | 说明  |
          |  ----  | ----  | ----  | ----  |
          | option | string | 是 | 选项类型 |
          | name | string | 是 | 选项名称 |
          | score | number | 是 | 选项分值 |
          | tagList | string[] | 是 | 标签 |
          | tagRequired | string | 是 | 标签是否必填 |
          | remarkRequired | string | 是 | 备注是否必填 |

          * QYEvaluationOptionData.option 枚举
            * QYEvaluationOptionVerySatisfied 非常满意
            * QYEvaluationOptionSatisfied  满意
            * QYEvaluationOptionOrdinary 一般
            * QYEvaluationOptionDissatisfied /不满意
            * QYEvaluationOptionVeryDissatisfied 非常不满意

* `deleteCustomEvaluation()`

  删除 setCustomEvaluation 设置的评价接口

* `sendEvaluationResult(options, callback)` (iOS)

  发送人工满意度评价结果.

  * **options 参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | shopId | string  | 否 | 平台版是你需要请求的商家ID，普通版可以为空 |

    * QYEvaluactionResult

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | sessionId | number  | 是 | 评价会话ID，不可为空 |
    | mode | string  | 是 | 评价模式，透传 QYEvaluactionData.mode（提交机器人评价结果时此项必须） |
    | selectOption | QYEvaluationOptionData | 是 | 选中的选项，不可为空 (结构参见setCustomEvaluation) |
    | selectTags | string[]  | 是 | 选中的标签，若selectOption的tagRequired必填，则selectTags不可为空 |
    | remarkString | string  | 是 | 评价备注，若selectOption的remarkRequired必填，则remarkString不可为空 |
    | resolveStatus | string  | 是 | QYEvaluationResolveStatus 是否解决，若resolvedRequired必填，则resolveStatus不可为None |

    * QYEvaluationResolveStatus 枚举
      * QYEvaluationResolveStatusResolved 已解决
      * QYEvaluationResolveStatusUnsolved 未解决

  * **callback 回调参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | state | string  | 否 | 评价结果状态 QYEvaluationState  |
    | result | number  | 否 | 评价结果状态码 |
    | success | boolean  | 是 | 表示是否成功 |
    | errMsg | string  | 是 | 错误信息 |

    * QYEvaluationState 枚举
      * QYEvaluationStateSuccessFirst = 1 成功-首次评价
      * QYEvaluationStateSuccessRevise 成功-修改评价
      * QYEvaluationStateFailParamError 失败-发送参数错误
      * QYEvaluationStateFailNetError 失败-网络错误
      * QYEvaluationStateFailNetTimeout 失败-网络超时
      * QYEvaluationStateFailTimeout 失败-评价超时
      * QYEvaluationStateFailUnknown 失败-未知原因不可评价

* `sendRobotEvaluationResult(options, callback)` (iOS)

  发送机器人满意度评价结果。

  参数，回调 与 `sendEvaluationResult` 基本相同。

* `doCustomEvaluation(options, callback)` (Android)

  自定义评价界面进行评价。

  * **options 参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | shopCode | string | 是 | 商家ID， 在 EvaluationOpenEntry 里面有这个值，只需要回传就可以了 |
    | sessionId | number | 是 | 会话 ID ，在 EvaluationOpenEntry 里面有这个值，只需要回传就可以了 |
    | score | number | 是 | 评分 |
    | remark | string | 是 | 评价内容 |
    | tagList | string[] | 是 | 标签 |
    | name | string | 是 | 评价结果的文案，例如非常满意、满意、不满意等 |

  * **callback 回调参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | type | string | 是 | 事件类型，有不同的参数，见下 |
    | success | boolean  | 是 | 表示是否成功 |
    | errMsg | string  | 是 | 错误信息 |

* `POPOpenEvaluation(options, callback)` (Android)

  平台版打开七鱼SDK评价。

  * **options 参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | key | string  | 是 | createConsultSource 创建的 key |

  * **callback 回调参数**

    同 openEvaluation 返回参数。

### 人工客服

* `requestStaff(options)` (Android)

  普通版请求人工客服。

  * **options 参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | hunmanOnly | boolean  | 否 | 是否只请求人工客服，true 则只请求人工客服 false 则为人工客服和机器人都可以 return 请求是否成功，有可能你当前的状态不需要请求客服，也有可能你已经在人工的状态了，那么也会返回 true |

* `requestStaff(options)`（iOS）

  请求人工客服。

  * **options 参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | shopId | string  | 否 | 平台版是你需要请求的商家ID，普通版可以为空 |

  * **返回参数**

    类型 string。

* `requestStaff2(options)` (Android)

  请求人工客服。

  * **options 参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | shopId | string  | 否 | 要操作的会话平台ID，普通版可以不传 |
    | hunmanOnly | boolean  | 是 | 是否只请求人工客服，true 则只请求人工客服 false 则为人工客服和机器人都可以 return 请求是否成功，有可能你当前的状态不需要请求客服，也有可能你已经在人工的状态了，那么也会返回 true |
    | requestStaffScenes | number  | 是 | 请求客服的当前场景，因为现在请求客服事件可以进行拦截，这个值是与 RequestStaffEntry 中 scenes 中相对应的 |
    | staffId | number  | 是 | staffId |
    | groupId | number  | 是 | groupId |

* `changeHumanStaffWithStaffId(options, callback)`（iOS）

  切换人工客服。

  * **options 参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | shopId | string  | 否 | 平台版是你需要请求的商家ID，普通版可以为空 |
    | closetip | string  | 是 | 关闭客服的提示语 |
    | isHuman | boolean  | 是 | 转接客服是否只请求人工 |
    | staffId | number  | 是 | 想要转接的客服 id |
    | groupId | number  | 是 | 想要转接的分组 id 如果同时设置 staffId 和 groupId 那么以 staffId 为主 |

  * **callback 回调参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | success | boolean  | 是 | 表示是否成功 |
    | errMsg | string  | 是 | 错误信息 |

* `transferStaff(options)` (Android)

  转接客服的接口，在必要的时候可以通过此方法进行客服的转接 方法内部实现是，现结束当前客服的会话，然后在重新连接一下客服。

  * **options 参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | shopId | string  | 否 | 要操作的会话平台ID，普通版可以不传 |
    | closeSessionMsg | string  | 是 | 关闭客服的提示语 |
    | isHuman | boolean  | 是 | 转接客服是否只请求人工 |
    | staffId | number  | 是 | staffId |
    | groupId | number  | 是 | groupId |

* `quitQueue(options)` (Android)

  退出排队的方法。

  * **options 参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | shopId | string  | 否 | 要操作的会话平台ID，普通版可以不传 |

### 多个客服窗口（平台版）

这里插件做了一层封装, 因为平台版有多个聊天会话，如果每次打开都需要传参数，非常麻烦。所以这里有个封装，你可以调用 createConsultSource 先创建一个会话，然后调用 POPOpenService 打开会话，第二次（例如从通知栏点击重新打开聊天），就不需要重新传一遍参数，只需要传入一个key即可，POPOpenService 会重新打开会话窗口。

* `createConsultSource(options)`

  创建会话。

  * **options 参数**

    参数同 openService 的参数。

* `isConsultSourceExists(options, callback)`

  获取一下指定的key会话是否创建。

  * **options 参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | key | string  | 是 | 要检查的key |

  * **callback 返回参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | exists | boolean  | 是 | 是否创建 |

* `deleteConsultSource(options)`

  删除指定的key会话。此操作会直接结束会话。

  * **options 参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | key | string  | 是 | 要检查的key |

* `findConsultSourceKeyByShopId(options, callback)`

  通过shopId操作已创建的会话key。

  * **options 参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | shopId | string  | 是 | 要检查的shopId |

  * **callback 返回参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | key | string  | 是 | 找到的会话key，如果找不到，则返回空 |

* `getOpenedConsultSourceKeys(options, callback)`

  获取创建的会话列表。

  * **options 参数**

    无

  * **callback 返回参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | list | array  | 是 | 列表, 结构参见下方 |

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | key | array  | 是 | 会话key |
    | value | object  | 是 | - |

* `POPOpenService(options, callback)`

  平台版打开七鱼SDK客服窗口。

  * **options 参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | key | string  | 是 | createConsultSource 创建的会话key |

  * **callback 返回参数**

    返回参数同 openService 返回参数。

### 会话列表（平台版）

* `getSessionList(options, callback)`

  获取最近联系商家列表(主动获取会话列表)。

  * **options 参数**

    无

  * **callback 回调参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | list | array  | 是 | 会话列表， 条目结构见下方 |

    * 会话列表条目结构 (Android)

      |  属性 | 类型 | 必填  | 说明  |
      |  ----  | ----  | ----  | ----  |
      | contactId | string | 是 | 联系ID |
      | msgStatus | number | 是 | 消息状态 -1 draft, 0 sending, 1 success, 2 fail, 3 read, 4 unread |
      | unreadCount | number | 是 | 未读数 |
      | content | string | 是 | 最后一条消息内容 |
      | time | number | 是 | 最后一条消息的时间戳 |

    * 会话列表条目结构 (iOS)

      |  属性 | 类型 | 必填  | 说明  |
      |  ----  | ----  | ----  | ----  |
      | contactId | string | 是 | 联系ID |
      | status | number | 是 | 消息状态 -1 draft, 0 sending, 1 success, 2 fail, 3 read, 4 unread |
      | unreadCount | number | 是 | 未读数 |
      | hasTrashWords | boolean | 是 | 是否有垃圾敏感词汇 |
      | content | string | 是 | 最后一条消息内容 |
      | lastMessageText | string | 是 | 最后一条消息内容 |
      | sessionName | string | 是 | 聊天会话名称 |
      | avatarImageUrlString | string | 是 | 聊天头像路径 |
      | time | number | 是 | 最后一条消息的时间戳 |

* `POPAddSessionListChangedListener(options, callback)`

  注册最近联系商家更新监听器（添加、删除、新消息等）

  * **options 参数**

    无参数

  * **callback 回调参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | type | string  | 是 | 事件类型，'AddSuccess'|'SessionUpdate'|'SessionDelete' |
    | id | number  | 是 | 当前监听回调的ID，可以使用 POPRemoveSessionListChangedListener 停止监听 |

    * AddSuccess 添加成功回调
    * SessionUpdate 会话更新回调（添加、新消息等）

      |  属性 | 类型 | 必填  | 说明  |
      |  ----  | ----  | ----  | ----  |
      | list | array | 是 | 当前会话列表，条目结构详细见上方“会话列表条目结构” |

    * SessionDelete 会话删除回调

      |  属性 | 类型 | 必填  | 说明  |
      |  ----  | ----  | ----  | ----  |
      | shopId | string  | 是 | 会话的商家ID |

* `POPRemoveSessionListChangedListener(options)`

  注销最近联系商家更新监听器（添加、删除、新消息等）

  * **options 参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | id | number  | 是 | POPAddSessionListChangedListener返回的ID |

* `POPQueryLastMessage(options, callback)`(Android)

  平台版获取和客服的最后一条聊天消息内容。。

  * **options 参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | shopId | string  | 是 | 商家ID |

  * **callback 回调参数**

    返回消息结构与 queryLastMessage 返回的结构一致。

* `POPGetShopInfo(options, callback)` (Android)

  平台版根据商家ID获取商家信息，如名称，logo。

  * **options 参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | shopId | string  | 是 | 商家ID |

  * **callback 回调参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | account | string  | 是 | 账号 |
    | avatar | string  | 是 | 商家头像URL |
    | name | string  | 是 | 商家名称 |

* `POPQuerySessionStatus(options, callback)` (Android)

  平台版获取会话状态。

  * **options 参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | shopId | string  | 是 | 商家ID |

  * **callback 回调参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | status | string  | 是 | NONE 未知，IN_SESSION 正在聊天，IN_QUEUE 正在排队 |

* `POPDeleteSession(options)` (Android)

  删除最近联系商家记录。

  * **options 参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | shopId | string  | 是 | 商家ID |
    | clearMsgHistory | boolean  | 是 | 是否同时清空消息记录 |

* `POPDeleteRecentSessionByShopId(options)`（IOS）

  七鱼平台删除会话项, 删除会话列表中的会话。

  * **options 参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | shopId | string  | 是 | 商家ID |
    | deleteMessages | boolean  | 是 | 是否同时清空消息记录 |

### 工单

* `openUserWorkSheetActivity(options)`

  自助启动查询工单界面。

  * **options 参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | templateIds | number[] | 是 | 工单模板 id |
    | isOpenUrge | boolean | 是 | 是否打开催单功能 |
    | shopId | string | 是 | 如果是平台版本传递 shopId，如果是非平台可以为空 |
  
  * IOS 将结果以字符串形式返回。

* `presentWorkOrderViewControllerWithTemplateID(options)`（iOS）

  弹出工单页面自助提工单。
  
  * **options 参数**

    |  属性 | 类型 | 必填  | 说明  |
    |  ----  | ----  | ----  | ----  |
    | shopId | string  | 否 | 平台版是你需要请求的商家ID，普通版可以为空 |
    | templateID | number  | 是 | 工单模板 id |

  * **返回参数**

    类型 string。

### 自定义界面

* `changeUICustomization(options)`

  更改界面自定义方法。

  * **options 参数**

    * 以下仅显示参数与类型，具体说明请参考官方文档。

    * Android
      * 请参考[官方文档](http://qiyukf.com/docs/guide/android/5-%E8%87%AA%E5%AE%9A%E4%B9%89%E6%A0%B7%E5%BC%8F.html#%E8%81%8A%E5%A4%A9%E7%AA%97%E5%8F%A3%E8%87%AA%E5%AE%9A%E4%B9%89)。
      * 关于自定义资源。您可以在自己的项目中新建nativeplugins/imengyu-Qiyukf/android/res/drawable，在其中放置自己的图片资源。

      ```js
      {
        msgBackgroundUri: string, 
        msgBackgroundColor: string, 
        msgListViewDividerHeight: number,
        hideLeftAvatar: boolean,
        hideRightAvatar: boolean,
        avatarShape: number,
        leftAvatar: string,
        rightAvatar: string,
        isShowTitleAvatar: boolean,
        tipsTextColor: string,
        tipsTextSize: number,
        msgItemBackgroundLeft: string,
        msgItemBackgroundRight: string,
        msgRobotItemBackgroundLeft: string,
        msgRobotItemBackgroundRight: string,
        audioMsgAnimationLeft: string,
        audioMsgAnimationRight: string,
        textMsgColorLeft: string,
        hyperLinkColorLeft: string,
        textMsgColorRight: string,
        hyperLinkColorRight: string,
        textMsgSize: number,
        inputTextColor: string,
        inputTextSize: number,
        topTipBarBackgroundColor: string,
        topTipBarTextSize: number,
        topTipBarTextColor: string,
        titleBackgroundColor: string,
        titleBarStyle: number,
        buttonBackgroundColorList: string,
        buttonTextColor: string,
        hideAudio: boolean,
        hideAudioWithRobot: boolean,
        hideEmoji: boolean,
        screenOrientation: number,
        hideKeyboardOnEnterConsult: boolean,
        robotBtnBack: string,
        robotBtnTextColor: string,
        inputUpBtnBack: string,
        inputUpBtloadingAnimationDrawablenBack: string,
        editTextHint: string,
        //说明参见 自定义样式 右上角按钮样式自定义
        titleBarConfig: {
          titleBarRightQuitBtnBack: string,
          titleBarRightHumanBtnBack: string,
          titleBarRightEvaluatorBtnBack: string,
          titleBarRightImg: string,
          titleBarRightTextColor: string,
          titleBarRightText: string,
        },
        //说明参见 自定义样式 输入栏区域自定义
        inputPanelOptions: {
          voiceIconResId: string,
          emojiIconResId: string,
          photoIconResId: string,
          moreIconResId: string,
          showActionPanel: boolean,
          actionPanelOptions: {
            backgroundColor: string,
            actionListProvider: [{
              type: 'Image'|'Camera'|'InquireWorkSheet'|'WorkSheet'|'Album'|'Custom',
              templateId?: number, //类型为 WorkSheet 需要填写此工单模板ID
              templateIds?: number[], //类型为 InquireWorkSheet 需要填写此工单模板ID数组
            }],
          },
        },
      }
      ```

      * TitleBarRightBtnClick 将发送全局事件： QiyuTitleBarRightBtnClick。
      * inputPanelOptions 说明参见 [自定义样式 输入栏区域自定义](http://qiyukf.com/docs/guide/android/5-%E8%87%AA%E5%AE%9A%E4%B9%89%E6%A0%B7%E5%BC%8F.html#%E8%BE%93%E5%85%A5%E6%A0%8F%E5%8C%BA%E5%9F%9F%E8%87%AA%E5%AE%9A%E4%B9%89)
      * titleBarConfig 说明参见 [自定义样式 右上角按钮样式自定义](http://qiyukf.com/docs/guide/android/5-%E8%87%AA%E5%AE%9A%E4%B9%89%E6%A0%B7%E5%BC%8F.html#%E5%8F%B3%E4%B8%8A%E8%A7%92%E6%8C%89%E9%92%AE%E6%A0%B7%E5%BC%8F%E8%87%AA%E5%AE%9A%E4%B9%89)
      * inputPanelOptions.actionPanelOptions类型为WorkSheet要填写工单模板ID, 参见 [高级功能 访客自助提工单](http://qiyukf.com/docs/guide/android/9-%E9%AB%98%E7%BA%A7%E5%8A%9F%E8%83%BD.html#%E8%AE%BF%E5%AE%A2%E8%87%AA%E5%8A%A9%E6%8F%90%E5%B7%A5%E5%8D%95)。
      * inputPanelOptions.actionPanelOptions类型为 InquireWorkSheet需要填写工单模板ID, 参见 [高级功能 访客自助查询工单](http://qiyukf.com/docs/guide/android/9-%E9%AB%98%E7%BA%A7%E5%8A%9F%E8%83%BD.html#%E8%AE%BF%E5%AE%A2%E8%87%AA%E5%8A%A9%E6%9F%A5%E8%AF%A2%E5%B7%A5%E5%8D%95)。

    * iOS
      * 请参考[官方文档](http://qiyukf.com/docs/guide/ios/5-%E8%87%AA%E5%AE%9A%E4%B9%89%E6%A0%B7%E5%BC%8F.html)。
      * 图片资源必须是本地路径。

      ```js
      {
        sessionBackground: string,
        themeColor: string,
        customerHeadImage: string,
        rightItemStyleGrayOrWhite: number,
        showCloseSessionEntry: boolean,
        showHeadImage: boolean,
        showTopHeadImage: boolean,
        customerHeadImageUrl: string,
        customerMessageBubbleNormalImage: string,
        customerMessageBubblePressedImage: string,
        customMessageTextColor: string,
        customMessageHyperLinkColor: string,
        customMessageTextFontSize: string,
        serviceHeadImage: string,
        serviceMessageBubbleNormalImage: string,
        serviceMessageBubblePressedImage: string,
        serviceMessageTextColor: string,
        serviceMessageTextFontSize: number,
        serviceMessageHyperLinkColor: string,
        tipMessageTextColor: string,
        tipMessageTextFontSize: number,
        bypassDisplayMode: number,
        sessionMessageSpacing: number,
        headMessageSpacing: number,
        messageButtonTextColor: string,
        messageButtonBackColor: string,
        actionButtonTextColor: string,
        actionButtonBorderColor: string,
        inputTextColor: string,
        inputTextFontSize: number,
        inputTextPlaceholder: string,
        showAudioEntry: boolean,
        showAudioEntryInRobotMode: boolean,
        showEmoticonEntry: boolean,
        showImageEntry: boolean,
        autoShowKeyboard: boolean,
        showShopEntrance: boolean,
        imagePickerColor: string,
        showSessionListEntrance: boolean,
        bottomMargin: number,
        sessionListEntranceImage: string,
        sessionListEntrancePosition: number,
        sessionTipTextColor: string,
        sessionTipTextFontSize: number,
        customInputItems: [
          {
            normalImage?: string,
            selectedImage?: string,
            key: string,
            text: string,
          }
        ],
      }
      ```

      * customInputItems 说明参见 [自定义样式 配置更多按钮](http://qiyukf.com/docs/guide/ios/5-%E8%87%AA%E5%AE%9A%E4%B9%89%E6%A0%B7%E5%BC%8F.html#%E9%85%8D%E7%BD%AE%E6%9B%B4%E5%A4%9A%E6%8C%89%E9%92%AE)
      * customInputItems 的点击事件会在 QiyuCustomInputItemClick 全局事件发送。event.detail.key 是点击的条目key。

* `resetUICustomizationToDefault(options)`

  重置界面自定义至默认。

  * **options 参数**

    无

### 自定义事件

* `setCustomEventsHandler(options, callback)`

  设置自定义事件接收器。

  * **options 参数**

    无

  * **callback 回调参数**

    * Android

      |  属性 | 类型 | 必填  | 说明  |
      |  ----  | ----  | ----  | ----  |
      | type | string  | 是 | 事件类型，见下方 |

      * UrlClick 链接点击事件

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | url | string  | 是 | 链接 |

      * MessageItemClick 消息条目点击事件

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | url | string  | 是 | 链接 |

      * QuickEntryClick 输入栏快捷入口点击事件

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | shopId | string  | 是 | 商家ID |
        | iconUrl | string  | 是 | 图标ID |
        | id | string  | 是 | QuickEntry的ID |
        | name | string  | 是 | QuickEntry的名称 |

      * ShopEntranceClick 商家入口点击事件

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | shopId | string  | 是 | 商家ID |

      * SessionListEntranceClick 最近联系商家入口点击事件

        无特殊参数。

    * iOS

      |  属性 | 类型 | 必填  | 说明  |
      |  ----  | ----  | ----  | ----  |
      | type | string  | 是 | 事件类型，见下方 |

      * LinkClick 链接点击事件

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | linkAddress | string  | 是 | 链接 |

      * BotClick 机器人部分模板消息点击事件

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | target | string  | 是 | - |
        | params | string  | 是 | - |

      * PushMessageClick 七鱼推送消息点击事件

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | linkAddress | string  | 是 | 链接 |

      * ShowBotCustomInfo 机器人自定义信息回调

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | array | string  | 是 | - |

      * CommodityAction 订单卡片按钮点击事件

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | commodityInfo | object  | 是 | 商品信息 |

      * ExtraClick 消息扩展视图点击事件

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | extInfo | string  | 是 | extInfo |

      * NotificationClick 系统消息点击

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | message | object  | 是 | 消息结构 |

      * EventClick 消息内部分点击事件数据透传

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | eventName | string  | 是 |  |
        | eventData | string  | 是 |  |
        | messageId | string  | 是 |  |

      * CustomButtonClick 自定义事件按钮点击事件

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | params | object  | 是 | 参数 |

      * AvatarClick 消息头像点击事件

        |  属性 | 类型 | 必填  | 说明  |
        |  ----  | ----  | ----  | ----  |
        | avatarType | number  | 是 | 头像类型 0人工客服 1机器人客服 2企业 3访客 |
        | accountID | string  | 是 | 账号ID |

* `resetCustomEventsHandlerToDefault(options)`

  删除 setCustomEventsHandler 设置的自定义事件接收器。

  * **options 参数**

    无
