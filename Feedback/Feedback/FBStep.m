//
// Created by stran.
//



#import "FBStep.h"

@implementation FBStep {

}

@synthesize target = _target;
@synthesize timestamp = _timestamp;

+ (id)crumbWithTarget:(NSObject *)target {
    FBStep *crumb = [FBStep new];

    crumb.target = target;
    crumb.timestamp = [NSDate date];

    return crumb;
}

@end