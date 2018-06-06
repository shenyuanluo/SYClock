//
//  ViewController.m
//  SYClockExample
//
//  Created by shenyuanluo on 2018/6/6.
//  Copyright © 2018年 http://blog.shenyuanluo.com/ All rights reserved.
//

#import "ViewController.h"
#import "SYClock.h"

@interface ViewController ()

@property (nonatomic, readwrite, strong) SYClock *clock;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clock = [[SYClock alloc] initWithFrame:CGRectMake(100, 100, self.view.bounds.size.width * 0.85, self.view.bounds.size.width * 0.85)];
    self.clock.center = self.view.center;
    [self.view addSubview:self.clock];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
