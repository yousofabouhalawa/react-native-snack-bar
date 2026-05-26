#import "SnackBarView.h"

#import <React/RCTBridgeModule.h>
#import <React/RCTUtils.h>

@interface SnackBarModule : NSObject <RCTBridgeModule>
@property(nonatomic, strong) SnackBarView *snackBarView;
@end

@implementation SnackBarModule

RCT_EXPORT_MODULE(SnackBar)

+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

RCT_EXPORT_METHOD(show : (NSString *)message options : (NSDictionary *)options)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    UIWindow *window = RCTKeyWindow();
    UIView *hostView = RCTPresentedViewController().view ?: window.rootViewController.view ?: window;
    if (hostView == nil) {
      return;
    }

    if (self.snackBarView == nil) {
      self.snackBarView = [[SnackBarView alloc] initWithFrame:hostView.bounds];
      self.snackBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
      self.snackBarView.userInteractionEnabled = NO;
    }

    if (self.snackBarView.superview != hostView) {
      [self.snackBarView removeFromSuperview];
      self.snackBarView.frame = hostView.bounds;
      [hostView addSubview:self.snackBarView];
    } else {
      [hostView bringSubviewToFront:self.snackBarView];
    }

    [self.snackBarView showMessage:message options:options];
  });
}

RCT_EXPORT_METHOD(dismiss)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.snackBarView dismissAnimated];
  });
}

@end
