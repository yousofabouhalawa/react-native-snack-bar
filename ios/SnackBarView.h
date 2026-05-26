#import <React/RCTViewComponentView.h>
#import <UIKit/UIKit.h>

#ifndef SnackBarViewNativeComponent_h
#define SnackBarViewNativeComponent_h

NS_ASSUME_NONNULL_BEGIN

@interface SnackBarView : RCTViewComponentView
- (void)showMessage:(NSString *)message options:(NSDictionary *)options;
- (void)dismissAnimated;
@end

NS_ASSUME_NONNULL_END

#endif /* SnackBarViewNativeComponent_h */
