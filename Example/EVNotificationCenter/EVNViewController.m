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

@interface EVNViewController ()

@end

@implementation EVNViewController {
    EVNTest *test;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    test = [EVNTest new];
    
    [[EVNotificationCenter default] addObserver:self selector:@selector(test) name:@"EVNotificationCenterKey" object:nil];
//    [[EVNotificationCenter default] addObserver:test selector:@selector(hello) name:@"EVNotificationCenterKey" object:nil];
//    NSOperationQueue *queue = [NSOperationQueue currentQueue];
//    [[EVNotificationCenter default] addObserver:self name:@"EVNotificationCenterKey" object:@"block" queue:queue usingBlock:^(NSString *para) {
//        NSLog(@"🍄-%@-🍄%@", para, [NSThread currentThread]);
//    }];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(test) name:@"test" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(test1) name:@"test" object:nil];


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
