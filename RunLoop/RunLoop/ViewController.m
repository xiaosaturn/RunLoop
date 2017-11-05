//
//  ViewController.m
//  RunLoop
//
//  Created by Xiao on 2017/11/2.
//  Copyright © 2017年 com.xiao.forward. All rights reserved.
//

#import "ViewController.h"

//定义一个Block
typedef void(^RunLoopBlock)(void);

static NSString *IDENTIFIER = @"IDENTIFIER";
static CGFloat CELL_HEIGHT = 135.f;

@interface ViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableV;
@property (nonatomic,strong) dispatch_source_t timer;
@property (nonatomic,strong) NSTimer *timer2;

//装任务的数组
@property (nonatomic,strong) NSMutableArray *tasks;

//最大任务数
@property (nonatomic,assign) NSUInteger maxQueueLength;
@end

@implementation ViewController

- (void)timerMethod{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tasks = [NSMutableArray array];
    _maxQueueLength = 18;
    
    [self addRunLoopObserver];
    
    self.tableV = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableV.delegate = self;
    self.tableV.dataSource = self;
    
    [self.tableV registerClass:[UITableViewCell class] forCellReuseIdentifier:IDENTIFIER];
    [self.view addSubview:self.tableV];
    
    _timer2 = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(timerMethod) userInfo:nil repeats:YES];
}

+ (void)addlabel:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 300, 25)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor redColor];
    label.text = [NSString stringWithFormat:@"%zd - Drawing index is top priority",indexPath.row];
    label.font = [UIFont boldSystemFontOfSize:13];
    label.tag = 4;
    [cell.contentView addSubview:label];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(5,99, 300, 25)];
    label2.lineBreakMode = NSLineBreakByWordWrapping;
    label2.numberOfLines = 0;
    label2.backgroundColor = [UIColor clearColor];
    label2.textColor = [UIColor colorWithRed:0 green:100.f/255 blue:0 alpha:1];
    label2.text = [NSString stringWithFormat:@"%zd - Drawing large image is low priority. Should be distributed into different run loop passes.",indexPath.row];
    label2.font = [UIFont boldSystemFontOfSize:13];
    label2.tag = 5;
    [cell.contentView addSubview:label2];
}

+ (void)addImage1With:(UITableViewCell *)cell{
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(5, 20, 85, 85)];
    imageV.tag = 1;
    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"1024" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:path1];
    imageV.contentMode = UIViewContentModeScaleAspectFit;
    imageV.image = image;
    [UIView transitionWithView:cell.contentView duration:0.3 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [cell.contentView addSubview:imageV];
    } completion:nil];
}

+ (void)addImage2With:(UITableViewCell *)cell{
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(95, 20, 85, 85)];
    imageV.tag = 1;
    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"1024" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:path1];
    imageV.contentMode = UIViewContentModeScaleAspectFit;
    imageV.image = image;
    [UIView transitionWithView:cell.contentView duration:0.3 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [cell.contentView addSubview:imageV];
    } completion:nil];
}

+ (void)addImage3With:(UITableViewCell *)cell{
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(185, 20, 85, 85)];
    imageV.tag = 1;
    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"1024" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:path1];
    imageV.contentMode = UIViewContentModeScaleAspectFit;
    imageV.image = image;
    [UIView transitionWithView:cell.contentView duration:0.3 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [cell.contentView addSubview:imageV];
    } completion:nil];
}

#pragma mark delegate datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1000;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
//    if(!cell){
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:IDENTIFIER];
//    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    for(NSInteger i=1;i<=5;i++){
        [[cell.contentView viewWithTag:1] removeFromSuperview];
        [[cell.contentView viewWithTag:4] removeFromSuperview];
        [[cell.contentView viewWithTag:5] removeFromSuperview];
    }
    
    [ViewController addlabel:cell indexPath:indexPath];
    
    [self addTask:^{
        [ViewController addImage1With:cell];
    }];
    [self addTask:^{
        [ViewController addImage2With:cell];
    }];
    [self addTask:^{
        [ViewController addImage3With:cell];
    }];
    
    return cell;
}

#pragma mark runloop
//添加任务的代码
- (void)addTask:(RunLoopBlock)task{
    [self.tasks addObject:task];
    if(self.tasks.count > self.maxQueueLength){
        [self.tasks removeObjectAtIndex:0];
    }
}

//以下都是C代码
static void callBack(CFRunLoopObserverRef observer,CFRunLoopActivity activity,void *info){
    //取出任务执行
    ViewController *vc = (__bridge ViewController *)info;
    
    if(vc.tasks.count == 0){
        return;
    }
    
    RunLoopBlock task = vc.tasks.firstObject;
    task();
    [vc.tasks removeObjectAtIndex:0];
}

- (void)addRunLoopObserver{
    //拿到当前的RunLoop
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    
    //定义一个上下文
    CFRunLoopObserverContext context = {
        0,
        (__bridge void *)(self),
        &CFRetain,
        &CFRelease,
        NULL
    };
    
    //定义一个观察者
    static CFRunLoopObserverRef defaultModeObserver;
    
    //创建一个观察者
    defaultModeObserver = CFRunLoopObserverCreate(NULL, kCFRunLoopAfterWaiting, YES, 0, &callBack, &context);
    
    //添加RunLoop观察者
    CFRunLoopAddObserver(runloop, defaultModeObserver, kCFRunLoopCommonModes);
    
    //释放内存
    CFRelease(defaultModeObserver);
}

- (void)gcdUse{
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
