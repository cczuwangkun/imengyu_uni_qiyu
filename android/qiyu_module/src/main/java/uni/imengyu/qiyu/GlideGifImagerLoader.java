package uni.imengyu.qiyu;

import android.content.Context;
import android.widget.ImageView;

import com.bumptech.glide.Glide;

import com.qiyukf.unicorn.api.UnicornGifImageLoader;

import java.io.Serializable;

import uni.imengyu.qiyu.R;

/**
 * Created by andya on 2019/1/17
 * Describe: 加载 gif 图片 ImageLoader demo
 */
public class GlideGifImagerLoader implements UnicornGifImageLoader, Serializable {

    Context context;

    public GlideGifImagerLoader(Context context) {
        this.context = context.getApplicationContext();
    }


    @Override
    public void loadGifImage(String url, ImageView imageView,String imgName) {
        if (url == null || imgName == null) {
            return;
        }
        Glide.with(context).load(url).error(R.drawable.nim_default_img_failed).into(imageView);
    }
}
