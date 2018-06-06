//
//  SYClock.h
//  SYClockExample
//
//  Created by shenyuanluo on 2018/6/6.
//  Copyright © 2018年 http://blog.shenyuanluo.com/ All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYClock : UIView

@property (nonatomic, readwrite, assign) CGFloat secondWidth;           // 秒针宽度 default 1.0
@property (nonatomic, readwrite, assign) CGFloat minuteWidth;           // 分针宽度 default 3.0
@property (nonatomic, readwrite, assign) CGFloat hourWidth;             // 时针宽度 default 4.0
@property (nonatomic, readwrite, assign) CGFloat dialBorderWidth;       // 刻度盘边框大小 default 4
@property (nonatomic, readwrite, strong) UIColor *dialBackgroundColor;  // 刻度盘背景颜色 default whiteColor
@property (nonatomic, readwrite, strong) UIColor *dialBorderColor;      // 刻度盘边框颜色 default blackColor
@property (nonatomic, readwrite, strong) UIColor *secondColor;          // 秒针颜色 default redColor
@property (nonatomic, readwrite, strong) UIColor *minuteColor;          // 分针颜色 default greenColor
@property (nonatomic, readwrite, strong) UIColor *hourColor;            // 时针颜色 default blueColor
@property (nonatomic, readwrite, strong) UIColor *scaleLineColor;       // 刻度线颜色 default blackColor
@property (nonatomic, readwrite, strong) UIColor *numberColor;          // 刻度盘数字字体颜色 default blackColor
@property (nonatomic, readwrite, strong) UIColor *quarterNumColor;      // 刻度盘刻钟数字(3、6、9、12)字体颜色 default redColor
@property (nonatomic, readwrite, strong) UIFont *numberFont;            // 刻度盘数字字体大小 default 17
@property (nonatomic, readwrite, strong) UIFont *quarterNumFont;        // 刻度盘刻钟数字(3、6、9、12)字体大小 default 19


- (instancetype)initWithFrame:(CGRect)frame;

@end
