//
// Created by stran.
//



#import <Foundation/Foundation.h>


@interface FBStep : NSObject

@property(nonatomic, strong) NSObject *target;
@property(nonatomic, strong) NSDate *timestamp;

+ (id)crumbWithTarget:(NSObject *)target;


@end