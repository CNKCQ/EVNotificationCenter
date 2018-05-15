//
//  EVNotificationCenter.m
//  EVNotificationCenter
//
//  Created by steve on 09/04/2018.
//

#import "EVNotificationCenter.h"
#import <pthread/pthread.h>


@interface ObserverModel : NSObject

@property (nonatomic, weak, nullable) id target;

@property (nonatomic, assign) SEL sel;

@property (nonatomic, weak, nullable) id object;

@property (nonatomic, copy) void(^block)(id);

@property (nonatomic, strong, nullable) NSOperationQueue *operationQueue;

@end

@interface EVNote : NSObject

@property (nonatomic, strong) NSMutableSet<ObserverModel *> *observers;

@end

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
    [self addObserver:observer selector:sel name:aName queue:[NSOperationQueue currentQueue] object:object];
}

- (void)addObserver:(nonnull id)observer selector:(nonnull SEL)sel name:(nullable NSNotificationName)aName queue:(nullable NSOperationQueue *)queue object:(nullable id)object {
    pthread_mutex_lock(&mutex); // 申请锁
    EVNote *note = [self.store objectForKey:aName];
    if (!note) {
        note = [[EVNote alloc] init];
        note.observers = [NSMutableSet set];
    }
    ObserverModel *observerModel = [[ObserverModel alloc] init];
    observerModel.target = observer;
    observerModel.sel = sel;
    observerModel.object = object;
    observerModel.operationQueue = queue;
    [note.observers addObject:observerModel];
    [self.store setObject:note forKey:aName];
    pthread_mutex_unlock(&mutex); // 释放锁
}

- (void)addObserver:(nonnull id)observer name:(nullable NSNotificationName)aName object:(nullable id)object usingBlock:(void(^)(id  _Nullable x))block{
    [self addObserver:observer name:aName object:object queue:[NSOperationQueue currentQueue] usingBlock:block];
}

- (void)addObserver:(nonnull id)observer name:(nullable NSNotificationName)aName object:(nullable id)object queue:(nullable NSOperationQueue *)queue usingBlock:(void(^)(id  _Nullable x))block {
    pthread_mutex_lock(&mutex); // 申请锁
    EVNote *note = [self.store objectForKey:aName];
    if (!note) {
        note = [[EVNote alloc] init];
        note.observers = [NSMutableSet set];
    }
    ObserverModel *observerModel = [[ObserverModel alloc] init];
    observerModel.target = observer;
    observerModel.block = block;
    observerModel.object = object;
    observerModel.operationQueue = queue;
    [note.observers addObject:observerModel];
    [self.store setObject:note forKey:aName];
    pthread_mutex_unlock(&mutex); // 释放锁
}

- (void)postNotificationName:(nonnull NSNotificationName)aName object:(nullable id)object {
    EVNote *note = (EVNote *)[self.store valueForKey:aName];
    [[note.observers copy] enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(ObserverModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.target respondsToSelector:obj.sel]) {
            if (obj.operationQueue) {
                NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:obj.target selector:obj.sel object:obj.object];
                NSOperationQueue *operationQueue = obj.operationQueue;
                [operationQueue addOperation:operation];
            } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [obj.target performSelector:obj.sel withObject:obj.object];
#pragma clang diagnostic pop
            }
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
    }];
}

- (void)removeObserver:(nonnull id)observer name:(nullable NSNotificationName)aName object:(nullable id)object {
    EVNote *note = (EVNote *)[self.store valueForKey:aName];
    pthread_mutex_lock(&mutex); // 申请锁
    NSMutableSet<ObserverModel *> *tempSet = [NSMutableSet setWithSet:note.observers];
    [[note.observers copy] enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(ObserverModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.target isEqual:observer]) {
            [tempSet removeObject:obj];
        }
    }];
    note.observers = tempSet;
    pthread_mutex_unlock(&mutex); // 释放锁
}

@end
