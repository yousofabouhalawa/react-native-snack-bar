#import "SnackBarView.h"

#import <React/RCTConvert.h>
#import <React/RCTConversions.h>
#import <UIKit/UIGlassEffect.h>

#import <react/renderer/components/SnackBarViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/SnackBarViewSpec/Props.h>
#import <react/renderer/components/SnackBarViewSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

static const NSInteger kSnackBarAlignStartOrTop = 0;
static const NSInteger kSnackBarAlignCenter = 1;
static const NSInteger kSnackBarAlignEndOrBottom = 2;

static const NSInteger kSnackBarAnimationFade = 1;
static const NSInteger kSnackBarAnimationSlide = 2;

static const NSInteger kSnackBarAppearanceGlass = 0;
static const NSInteger kSnackBarAppearanceSolid = 1;

static const NSInteger kSnackBarGlassStyleClear = 0;
static const NSInteger kSnackBarGlassStyleRegular = 1;

static const CGFloat kSnackBarHorizontalMargin = 16.0;
static const CGFloat kSnackBarVerticalMargin = 12.0;

@implementation SnackBarView {
  UIView *_glassContainer;
  UIVisualEffectView *_blurView;
  UILabel *_label;
  NSTimer *_dismissTimer;

  NSLayoutConstraint *_topConstraint;
  NSLayoutConstraint *_bottomConstraint;
  NSLayoutConstraint *_centerYConstraint;
  NSLayoutConstraint *_minTopConstraint;
  NSLayoutConstraint *_maxBottomConstraint;

  NSLayoutConstraint *_minimumLeadingConstraint;
  NSLayoutConstraint *_maximumTrailingConstraint;
  NSLayoutConstraint *_alignedLeadingConstraint;
  NSLayoutConstraint *_alignedTrailingConstraint;
  NSLayoutConstraint *_centerXConstraint;

  BOOL _isPresented;
  BOOL _isReplacing;
  BOOL _visible;
  CGFloat _durationSeconds;
  CGFloat _animationDurationSeconds;
  NSString *_message;
  UIColor *_snackColor;
  UIColor *_snackTextColor;
  UIColor *_glassTintColor;
  NSInteger _horizontalAlignment;
  NSInteger _verticalAlignment;
  NSInteger _animationStyle;
  NSInteger _appearance;
  NSInteger _glassStyle;
  BOOL _glassInteractive;
  UIView *_rootView;
  NSString *_pendingMessage;
  NSDictionary *_pendingOptions;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<SnackBarViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const SnackBarViewProps>();
    _props = defaultProps;
    _isReplacing = NO;
    _visible = NO;
    _durationSeconds = 3.5;
    _animationDurationSeconds = 0.35;
    _message = @"";
    _snackColor = nil;
    _snackTextColor = [UIColor colorWithWhite:1.0 alpha:0.96];
    _glassTintColor = nil;
    _horizontalAlignment = kSnackBarAlignCenter;
    _verticalAlignment = kSnackBarAlignEndOrBottom;
    _animationStyle = kSnackBarAnimationSlide;
    _appearance = kSnackBarAppearanceGlass;
    _glassStyle = kSnackBarGlassStyleClear;
    _glassInteractive = NO;

    _rootView = [[UIView alloc] init];
    _rootView.translatesAutoresizingMaskIntoConstraints = YES;
    _rootView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _rootView.frame = self.bounds;
    _rootView.backgroundColor = UIColor.clearColor;
    _rootView.clipsToBounds = NO;
    self.contentView = _rootView;

    _glassContainer = [[UIView alloc] init];
    _glassContainer.translatesAutoresizingMaskIntoConstraints = NO;
    _glassContainer.clipsToBounds = NO;
    _glassContainer.layer.cornerRadius = 0.0;
    _glassContainer.layer.borderWidth = 0.0;
    _glassContainer.backgroundColor = UIColor.clearColor;
    _glassContainer.alpha = 0.0;
    _glassContainer.transform = CGAffineTransformMakeTranslation(0, 24.0);

    _blurView = [[UIVisualEffectView alloc] initWithEffect:nil];
    _blurView.translatesAutoresizingMaskIntoConstraints = NO;
    _blurView.clipsToBounds = YES;
    _blurView.layer.cornerRadius = 18.0;
    if (@available(iOS 13.0, *)) {
      _blurView.layer.cornerCurve = kCACornerCurveContinuous;
    }
    [_glassContainer addSubview:_blurView];

    _label = [[UILabel alloc] init];
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    _label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    _label.textColor = _snackTextColor;
    _label.numberOfLines = 0;
    _label.lineBreakMode = NSLineBreakByWordWrapping;
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = _message;
    [_label setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [_label setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_glassContainer addSubview:_label];

    [_rootView addSubview:_glassContainer];

    NSLayoutConstraint *minimumWidthConstraint = [_glassContainer.widthAnchor constraintGreaterThanOrEqualToConstant:120.0];
    minimumWidthConstraint.priority = UILayoutPriorityDefaultHigh;

    [NSLayoutConstraint activateConstraints:@[
      [_blurView.topAnchor constraintEqualToAnchor:_glassContainer.topAnchor],
      [_blurView.bottomAnchor constraintEqualToAnchor:_glassContainer.bottomAnchor],
      [_blurView.leadingAnchor constraintEqualToAnchor:_glassContainer.leadingAnchor],
      [_blurView.trailingAnchor constraintEqualToAnchor:_glassContainer.trailingAnchor],
      [_label.topAnchor constraintEqualToAnchor:_glassContainer.topAnchor constant:12.0],
      [_label.bottomAnchor constraintEqualToAnchor:_glassContainer.bottomAnchor constant:-12.0],
      [_label.leadingAnchor constraintEqualToAnchor:_glassContainer.leadingAnchor constant:16.0],
      [_label.trailingAnchor constraintEqualToAnchor:_glassContainer.trailingAnchor constant:-16.0],
      minimumWidthConstraint,
      [_glassContainer.widthAnchor constraintLessThanOrEqualToAnchor:_rootView.widthAnchor
                                                               constant:-(kSnackBarHorizontalMargin * 2.0)],
      [_glassContainer.heightAnchor constraintGreaterThanOrEqualToConstant:50.0],
    ]];

    _minimumLeadingConstraint = [_glassContainer.leadingAnchor constraintGreaterThanOrEqualToAnchor:_rootView.leadingAnchor
                                                                                           constant:kSnackBarHorizontalMargin];
    _maximumTrailingConstraint = [_glassContainer.trailingAnchor constraintLessThanOrEqualToAnchor:_rootView.trailingAnchor
                                                                                            constant:-kSnackBarHorizontalMargin];
    _alignedLeadingConstraint = [_glassContainer.leadingAnchor constraintEqualToAnchor:_rootView.leadingAnchor
                                                                                constant:kSnackBarHorizontalMargin];
    _alignedTrailingConstraint = [_glassContainer.trailingAnchor constraintEqualToAnchor:_rootView.trailingAnchor
                                                                                   constant:-kSnackBarHorizontalMargin];
    _centerXConstraint = [_glassContainer.centerXAnchor constraintEqualToAnchor:_rootView.centerXAnchor];
    _minimumLeadingConstraint.active = YES;
    _maximumTrailingConstraint.active = YES;

    NSLayoutYAxisAnchor *topAnchor;
    NSLayoutYAxisAnchor *bottomAnchor;
    if (@available(iOS 11.0, *)) {
      topAnchor = _rootView.safeAreaLayoutGuide.topAnchor;
      bottomAnchor = _rootView.safeAreaLayoutGuide.bottomAnchor;
    } else {
      topAnchor = _rootView.topAnchor;
      bottomAnchor = _rootView.bottomAnchor;
    }

    _topConstraint = [_glassContainer.topAnchor constraintEqualToAnchor:topAnchor constant:kSnackBarVerticalMargin];
    _bottomConstraint = [_glassContainer.bottomAnchor constraintEqualToAnchor:bottomAnchor constant:-kSnackBarVerticalMargin];
    _centerYConstraint = [_glassContainer.centerYAnchor constraintEqualToAnchor:_rootView.centerYAnchor];
    _minTopConstraint = [_glassContainer.topAnchor constraintGreaterThanOrEqualToAnchor:topAnchor constant:kSnackBarVerticalMargin];
    _maxBottomConstraint = [_glassContainer.bottomAnchor constraintLessThanOrEqualToAnchor:bottomAnchor constant:-kSnackBarVerticalMargin];
    _minTopConstraint.active = YES;
    _maxBottomConstraint.active = YES;

    [self updateAlignmentConstraints];
    [self updateAppearance];
  }

  return self;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  _rootView.frame = self.bounds;
  if (!_isPresented) {
    [_rootView layoutIfNeeded];
    _glassContainer.transform = [self hiddenTransform];
  }
}

- (void)showMessage:(NSString *)message options:(NSDictionary *)options
{
  _pendingMessage = [message copy];
  _pendingOptions = [options copy];

  if (_isReplacing) {
    return;
  }

  if (_isPresented) {
    [self beginImperativeReplacement];
    return;
  }

  [self presentPendingImperativeConfiguration];
}

- (void)dismissAnimated
{
  _pendingMessage = nil;
  _pendingOptions = nil;
  _isReplacing = NO;
  _visible = NO;
  [self applyVisibility:YES];
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  const auto &oldViewProps = *std::static_pointer_cast<SnackBarViewProps const>(_props);
  const auto &newViewProps = *std::static_pointer_cast<SnackBarViewProps const>(props);

  [super updateProps:props oldProps:oldProps];

  BOOL hasNewVisibleContent = newViewProps.visible && !newViewProps.message.empty();
  BOOL shouldReplace = _isPresented && !_isReplacing && oldViewProps.visible && hasNewVisibleContent &&
      [self presentationPropsChangedFrom:oldViewProps to:newViewProps];

  if (shouldReplace) {
    [self beginReplacement];
    return;
  }

  if (_isReplacing) {
    return;
  }

  [self applyConfigurationFromProps:newViewProps];
  [self applyVisibility:YES];
}

- (void)prepareForRecycle
{
  [self invalidateDismissTimer];
  _isReplacing = NO;
  _isPresented = NO;
  [self setCompletelyHidden];
  [super prepareForRecycle];
}

- (void)dealloc
{
  [self invalidateDismissTimer];
}

- (void)updateAlignmentConstraints
{
  BOOL alignLeft = (_horizontalAlignment == kSnackBarAlignStartOrTop);
  BOOL alignRight = (_horizontalAlignment == kSnackBarAlignEndOrBottom);
  [NSLayoutConstraint deactivateConstraints:@[
    _alignedLeadingConstraint,
    _alignedTrailingConstraint,
    _centerXConstraint,
  ]];
  if (alignLeft) {
    _alignedLeadingConstraint.active = YES;
  } else if (alignRight) {
    _alignedTrailingConstraint.active = YES;
  } else {
    _centerXConstraint.active = YES;
  }

  _label.textAlignment = alignLeft ? NSTextAlignmentLeft : (alignRight ? NSTextAlignmentRight : NSTextAlignmentCenter);

  BOOL alignTop = (_verticalAlignment == kSnackBarAlignStartOrTop);
  BOOL alignCenter = (_verticalAlignment == kSnackBarAlignCenter);
  _topConstraint.active = alignTop;
  _bottomConstraint.active = (!alignTop && !alignCenter);
  _centerYConstraint.active = alignCenter;
  [_rootView setNeedsLayout];
}

- (BOOL)presentationPropsChangedFrom:(SnackBarViewProps const &)oldViewProps to:(SnackBarViewProps const &)newViewProps
{
  return oldViewProps.message != newViewProps.message || oldViewProps.duration != newViewProps.duration ||
      oldViewProps.animation != newViewProps.animation ||
      oldViewProps.animationDuration != newViewProps.animationDuration ||
      oldViewProps.appearance != newViewProps.appearance ||
      oldViewProps.glassStyle != newViewProps.glassStyle ||
      oldViewProps.glassTintColor != newViewProps.glassTintColor ||
      oldViewProps.glassInteractive != newViewProps.glassInteractive || oldViewProps.alignX != newViewProps.alignX ||
      oldViewProps.alignY != newViewProps.alignY || oldViewProps.color != newViewProps.color ||
      oldViewProps.textColor != newViewProps.textColor;
}

- (void)applyConfigurationFromProps:(SnackBarViewProps const &)viewProps
{
  NSString *message = viewProps.message.empty() ? @"" : [NSString stringWithUTF8String:viewProps.message.c_str()];
  _message = message ?: @"";
  _label.text = _message;
  _visible = viewProps.visible;
  _durationSeconds = MAX(0.0, ((CGFloat)viewProps.duration) / 1000.0);
  _animationDurationSeconds = MAX(0.0, ((CGFloat)viewProps.animationDuration) / 1000.0);
  _animationStyle = [self sanitizedAnimationValue:viewProps.animation];
  _appearance = [self sanitizedAppearanceValue:viewProps.appearance];
  _glassStyle = [self sanitizedGlassStyleValue:viewProps.glassStyle];
  _glassTintColor = RCTUIColorFromSharedColor(viewProps.glassTintColor);
  _glassInteractive = viewProps.glassInteractive;
  _horizontalAlignment = [self sanitizedAlignmentValue:viewProps.alignX defaultValue:kSnackBarAlignCenter];
  _verticalAlignment = [self sanitizedAlignmentValue:viewProps.alignY defaultValue:kSnackBarAlignEndOrBottom];
  _snackColor = RCTUIColorFromSharedColor(viewProps.color);
  UIColor *textColor = RCTUIColorFromSharedColor(viewProps.textColor);
  _snackTextColor = textColor ?: [UIColor colorWithWhite:1.0 alpha:0.96];
  _label.textColor = _snackTextColor;
  [self updateAlignmentConstraints];
  [self updateAppearance];
}

- (void)applyConfigurationForMessage:(NSString *)message options:(NSDictionary *)options
{
  _message = [message copy] ?: @"";
  _label.text = _message;
  _visible = YES;
  _durationSeconds = MAX(0.0, [RCTConvert CGFloat:options[@"duration"]] / 1000.0);
  _animationDurationSeconds = MAX(0.0, [RCTConvert CGFloat:options[@"animationDuration"]] / 1000.0);
  _animationStyle = [self sanitizedAnimationValue:[RCTConvert NSInteger:options[@"animation"]]];
  _appearance = [self sanitizedAppearanceValue:[RCTConvert NSInteger:options[@"appearance"]]];
  _glassStyle = [self sanitizedGlassStyleValue:[RCTConvert NSInteger:options[@"glassStyle"]]];
  _glassTintColor = options[@"glassTintColor"] ? [RCTConvert UIColor:options[@"glassTintColor"]] : nil;
  _glassInteractive = [RCTConvert BOOL:options[@"glassInteractive"]];
  _horizontalAlignment = kSnackBarAlignCenter;
  _verticalAlignment = kSnackBarAlignEndOrBottom;
  _snackColor = options[@"color"] ? [RCTConvert UIColor:options[@"color"]] : nil;
  UIColor *textColor = options[@"textColor"] ? [RCTConvert UIColor:options[@"textColor"]] : nil;
  _snackTextColor = textColor ?: [UIColor colorWithWhite:1.0 alpha:0.96];
  _label.textColor = _snackTextColor;
  [self updateAlignmentConstraints];
  [self updateAppearance];
}

- (void)updateAppearance
{
  if (_appearance == kSnackBarAppearanceSolid) {
    _glassContainer.clipsToBounds = YES;
    _glassContainer.layer.cornerRadius = 18.0;
    if (@available(iOS 13.0, *)) {
      _glassContainer.layer.cornerCurve = kCACornerCurveContinuous;
    }
    _blurView.clipsToBounds = NO;
    _blurView.layer.cornerRadius = 0.0;
    _blurView.effect = nil;
    _glassContainer.backgroundColor = _snackColor ?: [UIColor colorWithWhite:0.10 alpha:0.95];
    return;
  }

  _glassContainer.clipsToBounds = NO;
  _glassContainer.layer.cornerRadius = 0.0;
  _blurView.clipsToBounds = YES;
  _blurView.layer.cornerRadius = 18.0;
  if (@available(iOS 13.0, *)) {
    _blurView.layer.cornerCurve = kCACornerCurveContinuous;
  }
  _glassContainer.backgroundColor = UIColor.clearColor;
  UIColor *tintColor = _glassTintColor ?: _snackColor;

  if (@available(iOS 26.0, *)) {
    UIGlassEffectStyle style = _glassStyle == kSnackBarGlassStyleRegular ? UIGlassEffectStyleRegular
                                                                         : UIGlassEffectStyleClear;
    UIGlassEffect *glassEffect = [UIGlassEffect effectWithStyle:style];
    glassEffect.tintColor = tintColor;
    glassEffect.interactive = _glassInteractive;
    _blurView.effect = glassEffect;
    return;
  }

  if (@available(iOS 13.0, *)) {
    _blurView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterial];
  } else {
    _blurView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
  }
  _glassContainer.backgroundColor = tintColor ? [tintColor colorWithAlphaComponent:0.16] : UIColor.clearColor;
}

- (void)applyVisibility:(BOOL)animated
{
  [self invalidateDismissTimer];

  if (!_visible || _message.length == 0) {
    [self animateOut:animated];
    return;
  }

  [self animateIn:animated];
  [self scheduleDismissIfNeeded];
}

- (void)beginReplacement
{
  [self invalidateDismissTimer];
  _isReplacing = YES;
  [self animateOut:YES
        completion:^(BOOL finished) {
          if (!finished || !self->_isReplacing) {
            return;
          }

          self->_isPresented = NO;
          [self setCompletelyHidden];
          const auto &latestViewProps = *std::static_pointer_cast<SnackBarViewProps const>(self->_props);
          [self applyConfigurationFromProps:latestViewProps];
          self->_isReplacing = NO;
          [self applyVisibility:YES];
        }];
}

- (void)beginImperativeReplacement
{
  [self invalidateDismissTimer];
  _isReplacing = YES;
  [self animateOut:YES
        completion:^(BOOL finished) {
          if (!finished || !self->_isReplacing) {
            return;
          }

          self->_isPresented = NO;
          [self setCompletelyHidden];
          self->_isReplacing = NO;
          [self presentPendingImperativeConfiguration];
        }];
}

- (void)presentPendingImperativeConfiguration
{
  NSString *message = _pendingMessage;
  NSDictionary *options = _pendingOptions;
  _pendingMessage = nil;
  _pendingOptions = nil;
  if (message.length == 0 || options == nil) {
    return;
  }

  [self applyConfigurationForMessage:message options:options];
  [self applyVisibility:YES];
}

- (void)animateIn:(BOOL)animated
{
  if (!_isPresented) {
    _glassContainer.transform = [self hiddenTransform];
    _glassContainer.alpha = 1.0;
    _label.alpha = 1.0;
    if (_animationStyle == kSnackBarAnimationFade) {
      _glassContainer.alpha = 0.0;
    }
  }

  void (^animations)(void) = ^{
    self->_glassContainer.alpha = 1.0;
    self->_label.alpha = 1.0;
    self->_glassContainer.transform = CGAffineTransformIdentity;
  };

  if ([self shouldAnimate:animated]) {
    [self animateWithDuration:_animationDurationSeconds showing:YES animations:animations completion:nil];
  } else {
    animations();
  }

  _isPresented = YES;
}

- (void)animateOut:(BOOL)animated
{
  [self animateOut:animated completion:nil];
}

- (void)animateOut:(BOOL)animated completion:(void (^__nullable)(BOOL finished))additionalCompletion
{
  if (!_isPresented) {
    [self setCompletelyHidden];
    if (additionalCompletion) {
      additionalCompletion(YES);
    }
    return;
  }

  CGAffineTransform hiddenTransform = [self hiddenTransform];
  CGFloat hiddenSurfaceAlpha = _animationStyle == kSnackBarAnimationFade ? 0.0 : 1.0;
  void (^animations)(void) = ^{
    self->_glassContainer.alpha = hiddenSurfaceAlpha;
    self->_label.alpha = 1.0;
    self->_glassContainer.transform = hiddenTransform;
  };

  void (^completion)(BOOL) = ^(BOOL finished) {
    if (finished && !self->_visible && !self->_isReplacing) {
      self->_isPresented = NO;
      [self setCompletelyHidden];
    }
    if (additionalCompletion) {
      additionalCompletion(finished);
    }
  };

  if ([self shouldAnimate:animated]) {
    [self animateWithDuration:(_animationDurationSeconds * 0.75)
                      showing:NO
                   animations:animations
                   completion:completion];
  } else {
    animations();
    completion(YES);
  }
}

- (void)scheduleDismissIfNeeded
{
  if (_durationSeconds <= 0) {
    return;
  }

  _dismissTimer = [NSTimer scheduledTimerWithTimeInterval:_durationSeconds
                                                    target:self
                                                  selector:@selector(handleDismissTimer)
                                                  userInfo:nil
                                                   repeats:NO];
}

- (void)invalidateDismissTimer
{
  [_dismissTimer invalidate];
  _dismissTimer = nil;
}

- (void)handleDismissTimer
{
  _visible = NO;
  [self animateOut:YES];
}

- (NSInteger)sanitizedAlignmentValue:(NSInteger)value defaultValue:(NSInteger)defaultValue
{
  if (value == kSnackBarAlignStartOrTop || value == kSnackBarAlignCenter || value == kSnackBarAlignEndOrBottom) {
    return value;
  }
  return defaultValue;
}

- (NSInteger)sanitizedAnimationValue:(NSInteger)value
{
  return value == kSnackBarAnimationFade ? kSnackBarAnimationFade : kSnackBarAnimationSlide;
}

- (NSInteger)sanitizedAppearanceValue:(NSInteger)value
{
  return value == kSnackBarAppearanceSolid ? kSnackBarAppearanceSolid : kSnackBarAppearanceGlass;
}

- (NSInteger)sanitizedGlassStyleValue:(NSInteger)value
{
  return value == kSnackBarGlassStyleRegular ? kSnackBarGlassStyleRegular : kSnackBarGlassStyleClear;
}

- (BOOL)shouldAnimate:(BOOL)animated
{
  return animated && _animationDurationSeconds > 0.0;
}

- (void)animateWithDuration:(NSTimeInterval)duration
                    showing:(BOOL)showing
                 animations:(void (^)(void))animations
                 completion:(void (^__nullable)(BOOL finished))completion
{
  CGFloat damping = showing ? 0.82 : 0.90;
  CGFloat velocity = showing ? 0.20 : 0.0;
  UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction |
      UIViewAnimationOptionCurveEaseInOut;
  [UIView animateWithDuration:duration
                        delay:0.0
       usingSpringWithDamping:damping
        initialSpringVelocity:velocity
                      options:options
                   animations:animations
                   completion:completion];
}

- (CGAffineTransform)hiddenTransform
{
  if (_animationStyle == kSnackBarAnimationSlide) {
    return CGAffineTransformMakeTranslation(0, [self offscreenBottomAnimationOffset]);
  }
  return CGAffineTransformIdentity;
}

- (void)setCompletelyHidden
{
  _glassContainer.alpha = 0.0;
  _label.alpha = 1.0;
  _glassContainer.transform = [self hiddenTransform];
}

- (CGFloat)offscreenBottomAnimationOffset
{
  [_rootView layoutIfNeeded];
  CGFloat offset = CGRectGetHeight(_rootView.bounds) - CGRectGetMinY(_glassContainer.frame) + kSnackBarVerticalMargin;
  CGFloat minimumOffset = CGRectGetHeight(_glassContainer.bounds) + kSnackBarVerticalMargin;
  return MAX(offset, minimumOffset);
}

@end

Class<RCTComponentViewProtocol> SnackBarViewCls(void)
{
  return SnackBarView.class;
}
