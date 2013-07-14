//
// Created by stran.
//



#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreMotion/CoreMotion.h>
#import "FBFeedback.h"
#import "FBStep.h"

@interface FBFeedback ()

@property(nonatomic, strong) NSString *email;
@property(nonatomic, strong) NSString *subject;
@property(nonatomic, strong) NSDateFormatter *dateFormatter;

@property(nonatomic, strong) NSMutableArray *steps;

@property(nonatomic, strong) CMMotionManager *motionManager;

@end

@implementation FBFeedback {

}

- (void)sendFeedBack {
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    [mailComposer setMailComposeDelegate:self];
    if ([MFMailComposeViewController canSendMail]) {
        [mailComposer setToRecipients:[NSArray arrayWithObjects:self.email, nil]];
        [mailComposer setSubject:self.subject];

        UIImage *image = [self screenshot];
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        [mailComposer addAttachmentData:imageData mimeType:@"image/jpg" fileName:@"screenshot"];

        [mailComposer setMessageBody:[self processHistory] isHTML:YES];

        [mailComposer setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];

        UIViewController *controller = [[UIApplication sharedApplication] keyWindow].rootViewController;
        [controller presentViewController:mailComposer animated:YES completion:nil];
    }
}

- (NSString *)processHistory {
    NSMutableString *output = [NSMutableString new];

    [output appendString:@"<br/><br/><font size=\"1\">"
            "<table width=\"100%\" cellspacing=\"2\" "
            "style=\"border-style:solid;border-width:1px;\">"];
    [output appendString:@"<tr><td colspan=\"2\" align=\"center\">Diagnostics</td></tr>"];

    UIDevice *device = [UIDevice currentDevice];

    NSDictionary *diagnostics = @{
            @"system-model" : device.model,
            @"system-name" : device.systemName,
            @"system-version" : device.systemVersion
    };

    [diagnostics enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [output appendString:@"<tr valign=\"top\"><td>"];
        [output appendString:key];
        [output appendString:@"</td><td>"];
        [output appendString:value];
        [output appendString:@"</td></tr>"];
    }];

    [output appendString:@"<tr><td colspan=\"2\" align=\"center\"><br/>Steps</td></tr>"];

    for (FBStep *event in self.steps) {
        NSString *timestamp = [self.dateFormatter stringFromDate:event.timestamp];
        NSString *description = [event.target.description stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];

        [output appendString:@"<tr valign=\"top\"><td>"];
        [output appendString:timestamp];
        [output appendString:@"</td><td>"];
        [output appendString:description];
        [output appendString:@"</td></tr>"];
    }

    [output appendString:@"</table></font>"];

    return output;
}

+ (void)addEvent:(NSObject *)event {
    FBFeedback *instance = [FBFeedback sharedInstance];
    [instance.steps insertObject:[FBStep crumbWithTarget:event] atIndex:0];
}

+ (void)enableForEmail:(NSString *)email activationGesture:(UIGestureRecognizer *)recognizer {
    FBFeedback *instance = [FBFeedback sharedInstance];

    instance.email = email;
    if (recognizer) {
        [recognizer addTarget:instance action:@selector(sendFeedBack)];
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        window.userInteractionEnabled = YES;

        [window addGestureRecognizer:recognizer];
    } else {
        // TODO add shake detection
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    UIViewController *rootController = [[UIApplication sharedApplication] keyWindow].rootViewController;
    [rootController dismissViewControllerAnimated:YES completion:nil];
}

+ (FBFeedback *)sharedInstance {
    static FBFeedback *_sharedInstance;
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        _sharedInstance = [[self alloc] init];

        _sharedInstance.steps = [[NSMutableArray alloc] initWithCapacity:100];
        _sharedInstance.dateFormatter = [NSDateFormatter new];
        _sharedInstance.dateFormatter.dateFormat = @"HH:mm";

        _sharedInstance.subject = @"Feedback";

    });
    return _sharedInstance;
}

- (UIImage *)screenshot {
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);

    CGContextRef context = UIGraphicsGetCurrentContext();

    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen]) {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);

            // Y-offset for the status bar (if it's showing)
            NSInteger yOffset = [UIApplication sharedApplication].statusBarHidden ? 0 : -20;

            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                    -[window bounds].size.width * [[window layer] anchorPoint].x,
                    -[window bounds].size.height * [[window layer] anchorPoint].y + yOffset);

            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];

            // Restore the context
            CGContextRestoreGState(context);
        }
    }

    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return image;
}

@end