//
//  ViewController.m
//  RunLoop
//
//  Created by Xiao on 2017/11/2.
//  Copyright © 2017年 com.xiao.forward. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic,strong) dispatch_source_t timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //来一个队列
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    //创建一个定时器
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    //设置定时器
    dispatch_time_t start = DISPATCH_TIME_NOW;
    dispatch_time_t interval = 1.0 * NSEC_PER_SEC;
    dispatch_source_set_timer(self.timer, start, interval, 0);
    dispatch_source_set_event_handler(self.timer, ^{
        NSLog(@"----%@----%@",[NSRunLoop currentRunLoop],[NSThread currentThread]);
    });
    //启动定时器
    dispatch_resume(self.timer);

}


@end
