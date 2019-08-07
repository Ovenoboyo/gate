package com.pearl.shell.myapplication;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

public class CustomCardLayout extends RelativeLayout {

    LayoutInflater mInflater;
    TextView TitleView, DescView;

    ImageView IconView;
    public CustomCardLayout(Context context) {
        this(context, null, 0);

    }

    public CustomCardLayout(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public CustomCardLayout(Context context, AttributeSet attrs, int defStyle)
    {
        super(context, attrs, defStyle);
        mInflater = LayoutInflater.from(context);

        final TypedArray a = context.obtainStyledAttributes(
                attrs, R.styleable.CustomCardLayout);


        View v = mInflater.inflate(R.layout.aboutphone_cards, this, true);
        String Title = a.getString(R.styleable.CustomCardLayout_Title);
        String Desc = a.getString(R.styleable.CustomCardLayout_Desc);
        int icon = a.getResourceId(R.styleable.CustomCardLayout_Icon, R.drawable.ic_device_name);

        TitleView = v.findViewById(R.id.title);
        TitleView.setText(Title);
        DescView = v.findViewById(R.id.desc);
        DescView.setText(Desc);
        IconView = v.findViewById(R.id.top_icon);
        IconView.setImageResource(icon);
    }

    public TextView getTitleView() {
        return TitleView;
    }

    public TextView getDescView() {
        return DescView;
    }

    public ImageView getIconView() {
        return IconView;
    }

}
