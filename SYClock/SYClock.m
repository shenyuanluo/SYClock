//
//  SYClock.m
//  SYClockExample
//
//  Created by shenyuanluo on 2018/6/6.
//  Copyright © 2018年 http://blog.shenyuanluo.com/ All rights reserved.
//

#import "SYClock.h"
#import <CoreText/CTFont.h>
#import <CoreText/CTStringAttributes.h>

#define TAIL_LEN 10     // 指针尾部长度

@interface SYClock ()

@property (nonatomic, readwrite, strong) CALayer *dialLayer;    // 刻度盘
@property (nonatomic, readwrite, strong) CALayer *secondLayer;  // 秒针
@property (nonatomic, readwrite, strong) CALayer *minuteLayer;  // 分针
@property (nonatomic, readwrite, strong) CALayer *hourLayer;    // 时针
@property (nonatomic, readwrite, assign) CGFloat dialRadius;    // 刻度盘半径
@property (nonatomic, readwrite, assign) CGFloat secondLength;  // 秒针长度
@property (nonatomic, readwrite, assign) CGFloat minuteLength;  // 分针长度
@property (nonatomic, readwrite, assign) CGFloat hourLength;    // 时针长度
@property (nonatomic, readwrite, assign) CGFloat scaleLength;   // 刻度长度 default 10.0
@property (nonatomic, readwrite, assign) CGFloat scaleWidth;    // 刻度宽度 default 1.0
@property (nonatomic, readwrite, assign) CGFloat numberLength;  // 数字长度 default 10.0
@property (nonatomic, readwrite, assign) CGFloat numberWidth;   // 数字宽度 default 1.0

@end

@implementation SYClock

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self addClock];
    }
    return self;
}

- (void)setBounds:(CGRect)bounds
{
    [self setNeedsDisplay];
}

#pragma mark -- 初始化默认参数
- (void)initDefaultParam
{
    self.secondWidth         = 1.0f;
    self.minuteWidth         = 3.0f;
    self.hourWidth           = 4.0f;
    self.dialBorderWidth     = 6.0f;
    self.dialBackgroundColor = [UIColor whiteColor];
    self.dialBorderColor     = [UIColor blackColor];
    self.secondColor         = [UIColor redColor];
    self.minuteColor         = [UIColor greenColor];
    self.hourColor           = [UIColor blueColor];
    self.scaleLineColor      = [UIColor blackColor];
    self.numberColor         = [UIColor blackColor];
    self.quarterNumColor     = [UIColor redColor];
    self.numberFont          = [UIFont systemFontOfSize:17];
    self.quarterNumFont      = [UIFont systemFontOfSize:19];
    self.dialRadius          = MIN(self.bounds.size.width, self.bounds.size.height) * 0.5;
    self.secondLength        = self.dialRadius * 0.9 + TAIL_LEN;
    self.minuteLength        = self.secondLength * 0.9 + TAIL_LEN;
    self.hourLength          = self.secondLength * 0.8 + TAIL_LEN;
    self.scaleLength         = 15;
    self.scaleWidth          = 2;
    self.numberLength        = 20;
    self.numberWidth         = 20;
}

#pragma mark -- 添加时钟
- (void)addClock
{
    [self initDefaultParam];
    
    [self.layer addSublayer:self.dialLayer];
    [self.dialLayer addSublayer:self.hourLayer];
    [self.dialLayer addSublayer:self.minuteLayer];
    [self.dialLayer addSublayer:self.secondLayer];
    
    [self startClock];
}

#pragma mark -- 开启时钟
- (void)startClock
{
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self
                                                      selector:@selector(runningClock)];
    [link addToRunLoop:[NSRunLoop mainRunLoop]
               forMode:NSDefaultRunLoopMode];
}

#pragma mark -- 运行时钟（实时刷新）
- (void)runningClock
{
    NSTimeZone *timeZone          = [NSTimeZone localTimeZone];
    NSCalendar *calendar          = [NSCalendar currentCalendar];
    calendar.timeZone             = timeZone;
    NSDate *currentDate           = [NSDate date];
    NSDateComponents *currentTime = [calendar components:NSCalendarUnitNanosecond|NSCalendarUnitSecond|NSCalendarUnitMinute|NSCalendarUnitHour|NSCalendarUnitTimeZone
                                                fromDate:currentDate];
    CGFloat perSecondAngle     = M_PI * 2 / 60; // 每秒钟旋转的弧度
    CGFloat perMinuteAngle     = M_PI * 2 / 60; // 每分钟旋转的弧度
    CGFloat perHourAngle       = M_PI * 2 / 12; // 每小时旋转的弧度
    CGFloat nanoSecAngle       = perSecondAngle * (CGFloat)(currentTime.nanosecond%1000000000/1000000000.0f);   // 每纳秒（秒针）旋转的弧度
    CGFloat secMinAngle        = perMinuteAngle * (CGFloat)(currentTime.second%60/60.0f);   // 每秒中（分针）旋转的弧度
    CGFloat minHouAngle        = perHourAngle * (CGFloat)(currentTime.minute%60/60.0f);     // 每分钟（时针）旋转的弧度
    CGFloat secondAngle        = perSecondAngle * currentTime.second + nanoSecAngle;    // 秒针旋转弧度
    CGFloat minuteAngle        = perMinuteAngle * currentTime.minute + secMinAngle;     // 分针旋转弧度
    CGFloat hourAngle          = perHourAngle * currentTime.hour + minHouAngle;         // 时针旋转弧度
    CATransform3D identity     = CATransform3DIdentity;
    self.secondLayer.transform = CATransform3DRotate(identity, secondAngle + M_PI, 0, 0, 1);    // 旋转变换
    self.minuteLayer.transform = CATransform3DRotate(identity, minuteAngle + M_PI, 0, 0, 1);
    self.hourLayer.transform   = CATransform3DRotate(identity, hourAngle + M_PI, 0, 0, 1);
}

#pragma mark -- 添加时钟盘刻度
- (void)addLines
{
    for (int i = 0; i < 60; i++)    // 60 个刻度
    {
        CGFloat angle      = (M_PI * 2 / 60) * i;   // 每刻度的弧度
        CGFloat radius     = self.dialRadius - self.scaleLength * 0.5;  // 每个刻度中心点到钟表盘心半径
        CGRect lineBound   = CGRectMake(0, 0, self.scaleLength, self.scaleWidth);
        CALayer *lineLayer = [[CALayer alloc] init];
        if (0 == i%5)   // 特殊刻度处理
        {
            lineBound = CGRectMake(0, 0, self.scaleLength * 1.3, self.scaleWidth * 2.5);
            radius    = self.dialRadius - self.scaleLength * 1.3 * 0.5;
        }
        lineLayer.bounds          = lineBound;
        lineLayer.backgroundColor = self.scaleLineColor.CGColor;
        CGFloat positionX         = self.dialRadius + radius * cos(angle);
        CGFloat positionY         = self.dialRadius + radius * sin(angle);
        lineLayer.position        = CGPointMake(positionX, positionY);
        CATransform3D identity    = CATransform3DIdentity;
        lineLayer.transform       = CATransform3DRotate(identity, angle, 0, 0, 1);  // 旋转变换
        [self.dialLayer addSublayer:lineLayer];
    }
}

#pragma mark -- 添加时钟盘数字
- (void)addNumbers
{
    for (int i = 0; i < 12; i++)
    {
        CGFloat angle      = (M_PI * 2 / 12) * i;   // 每个数字(小时)的弧度
        CGFloat radius     = self.dialRadius - self.numberLength * 1.5; // 每个数字中心点到钟表盘心半径
        CGRect numberBound = CGRectMake(0, 0, self.numberLength, self.numberWidth);
        CGFloat positionX           = self.dialRadius + radius * cos(angle);
        CGFloat positionY           = self.dialRadius + radius * sin(angle);
        CATextLayer *numberLayer    = [[CATextLayer alloc] init];
        numberLayer.bounds          = numberBound;
        numberLayer.position        = CGPointMake(positionX, positionY);
        numberLayer.alignmentMode   = kCAAlignmentCenter;
        
        NSString *text = [NSString stringWithFormat:@"%d", (i + 3)%12];
        if (9 == i)
        {
            text = @"12";
        }
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
        CFStringRef fontName  = (__bridge CFStringRef)self.numberFont.fontName;
        CGColorRef numColor   = self.numberColor.CGColor;
        if (0 == i%3)   // 特殊数字处理
        {
            numColor  = self.quarterNumColor.CGColor;
            fontName  = (__bridge CFStringRef)self.quarterNumFont.fontName;
        }
        CGFloat fontSize      = self.numberFont.pointSize;
        CTFontRef fontRef     = CTFontCreateWithName(fontName, fontSize, NULL);
        
        NSDictionary *attribs = @{
                                  (__bridge id)kCTForegroundColorAttributeName : (__bridge id)numColor,
                                  (__bridge id)kCTFontAttributeName : (__bridge id)fontRef
                                  };
        [string setAttributes:attribs
                        range:NSMakeRange(0, text.length)];
        CFRelease(fontRef);
        numberLayer.string = string;
        [self.dialLayer addSublayer:numberLayer];
    }
}

#pragma mark - 懒加载
#pragma mark -- 刻度盘
- (CALayer *)dialLayer
{
    if (!_dialLayer)
    {
        _dialLayer                 = [[CALayer alloc] init];
        _dialLayer.bounds          = self.bounds;
        _dialLayer.backgroundColor = [UIColor lightGrayColor].CGColor;
        _dialLayer.position        = CGPointMake(self.dialRadius, self.dialRadius);
        _dialLayer.cornerRadius    = self.dialRadius;       // 圆角半径
        _dialLayer.borderWidth     = self.dialBorderWidth;
        _dialLayer.borderColor     = self.dialBorderColor.CGColor;
        _dialLayer.backgroundColor = self.dialBackgroundColor.CGColor;
        
        [self addLines];
        [self addNumbers];
    }
    return _dialLayer;
}

#pragma mark -- 秒针
- (CALayer *)secondLayer
{
    if (!_secondLayer)
    {
        _secondLayer                 = [[CALayer alloc] init];
        _secondLayer.backgroundColor = self.secondColor.CGColor;
        _secondLayer.bounds          = CGRectMake(0, 0, self.secondWidth, self.secondLength + TAIL_LEN);
        _secondLayer.position        = CGPointMake(self.dialRadius, self.dialRadius);
        _secondLayer.anchorPoint     = CGPointMake(0.5, 2 * TAIL_LEN / self.dialRadius); // 设置描点
        _secondLayer.contentsScale   = [UIScreen mainScreen].scale;
    }
    return _secondLayer;
}

#pragma mark -- 分针
- (CALayer *)minuteLayer
{
    if (!_minuteLayer)
    {
        _minuteLayer                 = [[CALayer alloc] init];
        _minuteLayer.backgroundColor = self.minuteColor.CGColor;
        _minuteLayer.bounds          = CGRectMake(0, 0, self.minuteWidth, self.minuteLength + TAIL_LEN);
        _minuteLayer.position        = CGPointMake(self.dialRadius, self.dialRadius);
        _minuteLayer.anchorPoint     = CGPointMake(0.5, 2 * TAIL_LEN / self.dialRadius); // 设置描点
        _minuteLayer.contentsScale   = [UIScreen mainScreen].scale;
    }
    return _minuteLayer;
}

#pragma mark -- 时针
- (CALayer *)hourLayer
{
    if (!_hourLayer)
    {
        _hourLayer                 = [[CALayer alloc] init];
        _hourLayer.backgroundColor = self.hourColor.CGColor;
        _hourLayer.bounds          = CGRectMake(0, 0, self.hourWidth, self.hourLength + TAIL_LEN);
        _hourLayer.position        = CGPointMake(self.dialRadius, self.dialRadius);
        _hourLayer.anchorPoint     = CGPointMake(0.5, 2 * TAIL_LEN / self.dialRadius);  // 设置描点
        _hourLayer.contentsScale   = [UIScreen mainScreen].scale;
    }
    return _hourLayer;
}

@end
