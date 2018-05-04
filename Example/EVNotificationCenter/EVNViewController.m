//
//  EVNViewController.m
//  EVNotificationCenter
//
//  Created by steve on 04/09/2018.
//  Copyright (c) 2018 steve. All rights reserved.
//

#import "EVNViewController.h"
#import <EVNotificationCenter/EVNotificationCenter.h>
#import "EVNTest.h"

@interface EVNViewController () <NSMachPortDelegate>

@property (nonatomic) NSMutableArray    *notifications;         // 通知队列
@property (nonatomic) NSThread          *notificationThread;    // 期望线程
@property (nonatomic) NSLock            *notificationLock;      // 用于对通知队列加锁的锁对象，避免线程冲突
@property (nonatomic) NSMachPort        *notificationPort;      // 用于向期望线程发送信号的通信端口

@end

@implementation EVNViewController {
    EVNTest *test;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    test = [EVNTest new];
    
    // 初始化
    self.notifications = [[NSMutableArray alloc] init];
    self.notificationLock = [[NSLock alloc] init];
    
    self.notificationThread = [NSThread currentThread];
    self.notificationPort = [[NSMachPort alloc] init];
    self.notificationPort.delegate = self;
    
    // 往当前线程的run loop添加端口源
    // 当Mach消息到达而接收线程的run loop没有运行时，则内核会保存这条消息，直到下一次进入run loop
    [[NSRunLoop currentRunLoop] addPort:self.notificationPort
                                forMode:(__bridge NSString *)kCFRunLoopCommonModes];
    
    [[EVNotificationCenter default] addObserver:self selector:@selector(test) name:@"EVNotificationCenterKey" object:nil];
//    [[EVNotificationCenter default] addObserver:test selector:@selector(hello) name:@"EVNotificationCenterKey" object:nil];
//    NSOperationQueue *queue = [NSOperationQueue currentQueue];
//    [[EVNotificationCenter default] addObserver:self name:@"EVNotificationCenterKey" object:@"block" queue:queue usingBlock:^(NSString *para) {
//        NSLog(@"🍄-%@-🍄%@", para, [NSThread currentThread]);
//    }];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(test) name:@"test" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(test1) name:@"test" object:nil];


}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"remove" style:UIBarButtonItemStylePlain target:self action:@selector(remove)];
}

- (void)remove {
    [[EVNotificationCenter default] removeObserver:test name:@"EVNotificationCenterKey" object:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//     [[EVNotificationCenter default] postNotificationName:@"EVNotificationCenterKey" object:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"test" object:nil];
        [[EVNotificationCenter default] postNotificationName:@"EVNotificationCenterKey" object:nil];
    });
}

- (void)test {
//    sleep(10);
    NSLog(@"🌹🌹🌹🐯🐯%@", [NSThread currentThread]);

}

- (void)test1 {
    NSLog(@"🌹🌹🌹🐯🐯%@ლ(′◉❥◉｀ლ)", [NSThread currentThread]);
}


@end
