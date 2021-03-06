//
//  EVNotificationCenter.h
//  EVNotificationCenter
//
//  Created by steve on 09/04/2018.
//

#import <Foundation/Foundation.h>

@interface EVNotificationCenter : NSObject

+ (instancetype) default;


- (void)addObserver:(nonnull id)observer selector:(nonnull SEL)sel name:(nullable NSNotificationName)aName object:(nullable id)object;


- (void)addObserver:(nonnull id)observer selector:(nonnull SEL)sel name:(nullable NSNotificationName)aName queue:(nullable NSOperationQueue *)queue object:(nullable id)object;


- (void)addObserver:(nonnull id)observer name:(nullable NSNotificationName)aName object:(nullable id)object usingBlock:(void(^)(id  _Nullable x))block;


- (void)addObserver:(nonnull id)observer name:(nullable NSNotificationName)aName object:(nullable id)object queue:(nullable NSOperationQueue *)queue usingBlock:(void(^)(id  _Nullable x))block;


- (void)postNotificationName:(nonnull NSNotificationName)aName object:(nullable id)object;


- (void)removeObserver:(nonnull id)observer name:(nullable NSNotificationName)aName object:(nullable id)object;

@end
