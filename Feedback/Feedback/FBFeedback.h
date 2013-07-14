//
// Created by stran.
//



#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>


@interface FBFeedback : NSObject
<MFMailComposeViewControllerDelegate>

+ (void)addEvent:(NSObject *)event;

+ (void)enableForEmail:(NSString *)email activationGesture:(UIGestureRecognizer *)recognizer;

@end