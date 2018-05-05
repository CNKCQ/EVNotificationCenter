//
//  ENSViewController.m
//  EVNotificationCenter_Example
//
//  Created by steve on 05/05/2018.
//  Copyright © 2018 steve. All rights reserved.
//

#import "ENSViewController.h"

@interface ENSViewController ()<NSMachPortDelegate>

@property (nonatomic, strong) NSMutableArray *array;

@property (nonatomic, strong) NSThread *thread;

@property (nonatomic, strong) NSLock *lock;

@property (nonatomic, strong) NSMachPort *machPort;

@end

@implementation ENSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    self.view.backgroundColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(test:) name:@"test" object:nil];
}

- (void)setup {
    if (!_array) {
        self.array = [NSMutableArray array];
    }
    self.lock = [[NSLock alloc] init];
    self.thread = [NSThread currentThread];
    self.machPort = [[NSMachPort alloc] init];
    [self.machPort setDelegate:self];
    [[NSRunLoop currentRunLoop] addPort:self.machPort forMode:(__bridge NSString *)kCFRunLoopCommonModes];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"test" object:nil];
    });
}

- (void)handleMachMessage:(void *)msg {
    [self.lock lock];
    while ([self.array count] > 0) {
        NSNotification *note = [self.array objectAtIndex:0];
        [self test:note];
        [self.array removeObject:note];
    }
    [self.lock unlock];
}

- (void)test:(NSNotification *)notification {
    if ([NSThread currentThread] == _thread) {
       NSLog(@"🚀%@", [NSThread currentThread]);
    } else {
        [self.lock lock];
        [self.array addObject:notification];
        [self.lock unlock];
        [self.machPort sendBeforeDate:[NSDate date] components:nil from:nil reserved:0];
    }
}

@end
