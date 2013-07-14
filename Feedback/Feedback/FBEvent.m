//
// Created by stran.
//



#import "FBEvent.h"

@implementation FBEvent {

}

@synthesize target = _target;
@synthesize timestamp = _timestamp;

+ (id)crumbWithTarget:(NSObject *)target {
    FBEvent *crumb = [FBEvent new];

    crumb.target = target;
    crumb.timestamp = [NSDate date];

    return crumb;
}

@end