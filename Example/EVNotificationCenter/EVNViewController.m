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
    [[EVNotificationCenter default] addObserverForName:@"EVNotificationCenterKey" object:@"block" queue:nil usingBlock:^(NSString *para) {
        NSLog(@"🍄-%@-🍄", para);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"remove" style:UIBarButtonItemStylePlain target:self action:@selector(remove)];
}

- (void)remove {
    [[EVNotificationCenter default] removeObserver:self name:@"EVNotificationCenterKey" object:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[EVNotificationCenter default] postNotificationName:@"EVNotificationCenterKey" object:nil];
}

- (void)test {
    NSLog(@"🌹🌹🌹🐯🐯");
}

@end
