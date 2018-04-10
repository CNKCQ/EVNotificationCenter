//
//  EVNotificationCenter.m
//  EVNotificationCenter
//
//  Created by steve on 09/04/2018.
//

#import "EVNotificationCenter.h"
#import <pthread/pthread.h>

@implementation ObserverModel

@end

@implementation EVNote

@end


@interface EVNotificationCenter()

@property (nonatomic, strong) NSMutableDictionary<NSString *, EVNote *> *store;

@end

@implementation EVNotificationCenter {
    pthread_mutexattr_t attr;
    pthread_mutex_t mutex;
}

+ (instancetype) default {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _store = [NSMutableDictionary dictionary];
        pthread_mutexattr_init(&attr);
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_NORMAL);  // 定义锁的属性
        pthread_mutex_init(&mutex, &attr); // 创建锁
    }
    return self;
}

- (void)addObserver:(nonnull id)observer selector:(nonnull SEL)sel name:(nullable NSNotificationName)aName object:(nullable id)object {
    @autoreleasepool {
        pthread_mutex_lock(&mutex); // 申请锁
        EVNote *note = [self.store objectForKey:aName];
        if (!note) {
            note = [[EVNote alloc] init];
            note.observers = [NSMutableArray array];
        }
        ObserverModel *observerModel = [[ObserverModel alloc] init];
        observerModel.target = observer;
        observerModel.sel = sel;
        observerModel.object = object;
        [note.observers addObject:observerModel];
        [self.store setObject:note forKey:aName];
        pthread_mutex_unlock(&mutex); // 释放锁
    }
}

- (void)addObserverForName:(nullable NSNotificationName)aName object:(nullable id)object queue:(nullable NSOperationQueue *)queue usingBlock:(void(^)(id))block{
    @autoreleasepool {
        pthread_mutex_lock(&mutex); // 申请锁
        EVNote *note = [self.store objectForKey:aName];
        if (!note) {
            note = [[EVNote alloc] init];
            note.observers = [NSMutableArray array];
        }
        ObserverModel *observerModel = [[ObserverModel alloc] init];
        observerModel.target = object;
        observerModel.block = block;
        observerModel.object = object;
        observerModel.operationQueue = queue;
        [note.observers addObject:observerModel];
        [self.store setObject:note forKey:aName];
        pthread_mutex_unlock(&mutex); // 释放锁
    }
}

- (void)postNotificationName:(nonnull NSNotificationName)aName object:(nullable id)object {
    EVNote *note = (EVNote *)[self.store valueForKey:aName];
    [[note.observers copy] enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(ObserverModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ([obj.target respondsToSelector:obj.sel]) {
            [obj.target performSelector:obj.sel withObject:obj.object];
        }
        if (obj.block) {
            if (obj.operationQueue) {
                NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                    obj.block(obj.object);
                }];
                NSOperationQueue *operationQueue = obj.operationQueue;
                [operationQueue addOperation:operation];
            } else {
               obj.block(obj.object);
            }
        }
#pragma clang diagnostic pop
    }];
}

- (void)removeObserver:(nonnull id)observer name:(nullable NSNotificationName)aName object:(nullable id)object {
    __block EVNote *note = (EVNote *)[self.store valueForKey:aName];
    pthread_mutex_lock(&mutex); // 申请锁
    [note.observers enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(ObserverModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ([obj.target isEqual:observer]) {
            [note.observers removeObject:obj];
        }
#pragma clang diagnostic pop
    }];
    pthread_mutex_unlock(&mutex); // 释放锁
}

@end
