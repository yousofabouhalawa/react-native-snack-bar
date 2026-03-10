#import "SnackBarView.h"

#import <React/RCTConversions.h>

#import <react/renderer/components/SnackBarViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/SnackBarViewSpec/Props.h>
#import <react/renderer/components/SnackBarViewSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

static const NSInteger kSnackBarAlignStartOrTop = 0;
static const NSInteger kSnackBarAlignCenter = 1;
static const NSInteger kSnackBarAlignEndOrBottom = 2;

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

  NSLayoutConstraint *_leadingConstraint;
  NSLayoutConstraint *_trailingConstraint;
  NSLayoutConstraint *_centerXConstraint;

  BOOL _isPresented;
  BOOL _visible;
  BOOL _top;
  CGFloat _durationSeconds;
  NSString *_message;
  UIColor *_snackColor;
  UIColor *_snackTextColor;
  NSInteger _horizontalAlignment;
  NSInteger _verticalAlignment;
  UIView *_rootView;
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
    _visible = NO;
    _top = NO;
    _durationSeconds = 3.5;
    _message = @"";
    _snackColor = [UIColor colorWithWhite:1.0 alpha:0.10];
    _snackTextColor = [UIColor colorWithWhite:1.0 alpha:0.96];
    _horizontalAlignment = kSnackBarAlignCenter;
    _verticalAlignment = kSnackBarAlignEndOrBottom;

    _rootView = [[UIView alloc] init];
    _rootView.translatesAutoresizingMaskIntoConstraints = YES;
    _rootView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _rootView.frame = self.bounds;
    _rootView.backgroundColor = UIColor.clearColor;
    _rootView.clipsToBounds = NO;
    self.contentView = _rootView;

    _glassContainer = [[UIView alloc] init];
    _glassContainer.translatesAutoresizingMaskIntoConstraints = NO;
    _glassContainer.clipsToBounds = YES;
    _glassContainer.layer.cornerRadius = 18.0;
    if (@available(iOS 13.0, *)) {
      _glassContainer.layer.cornerCurve = kCACornerCurveContinuous;
    }
    _glassContainer.layer.borderWidth = 1.0;
    _glassContainer.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.22].CGColor;
    _glassContainer.backgroundColor = _snackColor;
    _glassContainer.alpha = 0.0;
    _glassContainer.transform = CGAffineTransformMakeTranslation(0, 24.0);

    UIBlurEffect *blurEffect;
    if (@available(iOS 13.0, *)) {
      blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterial];
    } else {
      blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    }
    _blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    _blurView.translatesAutoresizingMaskIntoConstraints = NO;
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
    [_glassContainer addSubview:_label];

    [_rootView addSubview:_glassContainer];

    [NSLayoutConstraint activateConstraints:@[
      [_blurView.topAnchor constraintEqualToAnchor:_glassContainer.topAnchor],
      [_blurView.bottomAnchor constraintEqualToAnchor:_glassContainer.bottomAnchor],
      [_blurView.leadingAnchor constraintEqualToAnchor:_glassContainer.leadingAnchor],
      [_blurView.trailingAnchor constraintEqualToAnchor:_glassContainer.trailingAnchor],
      [_label.topAnchor constraintEqualToAnchor:_glassContainer.topAnchor constant:12.0],
      [_label.bottomAnchor constraintEqualToAnchor:_glassContainer.bottomAnchor constant:-12.0],
      [_label.leadingAnchor constraintEqualToAnchor:_glassContainer.leadingAnchor constant:16.0],
      [_label.trailingAnchor constraintEqualToAnchor:_glassContainer.trailingAnchor constant:-16.0],
      [_glassContainer.widthAnchor constraintGreaterThanOrEqualToConstant:120.0],
      [_glassContainer.widthAnchor constraintLessThanOrEqualToAnchor:_rootView.widthAnchor constant:-24.0],
      [_glassContainer.heightAnchor constraintGreaterThanOrEqualToConstant:50.0],
    ]];

    _leadingConstraint = [_glassContainer.leadingAnchor constraintEqualToAnchor:_rootView.leadingAnchor constant:12.0];
    _trailingConstraint = [_glassContainer.trailingAnchor constraintEqualToAnchor:_rootView.trailingAnchor constant:-12.0];
    _centerXConstraint = [_glassContainer.centerXAnchor constraintEqualToAnchor:_rootView.centerXAnchor];

    NSLayoutYAxisAnchor *topAnchor;
    NSLayoutYAxisAnchor *bottomAnchor;
    if (@available(iOS 11.0, *)) {
      topAnchor = _rootView.safeAreaLayoutGuide.topAnchor;
      bottomAnchor = _rootView.safeAreaLayoutGuide.bottomAnchor;
    } else {
      topAnchor = _rootView.topAnchor;
      bottomAnchor = _rootView.bottomAnchor;
    }

    _topConstraint = [_glassContainer.topAnchor constraintEqualToAnchor:topAnchor constant:8.0];
    _bottomConstraint = [_glassContainer.bottomAnchor constraintEqualToAnchor:bottomAnchor constant:-8.0];
    _centerYConstraint = [_glassContainer.centerYAnchor constraintEqualToAnchor:_rootView.centerYAnchor];
    _minTopConstraint = [_glassContainer.topAnchor constraintGreaterThanOrEqualToAnchor:topAnchor constant:8.0];
    _maxBottomConstraint = [_glassContainer.bottomAnchor constraintLessThanOrEqualToAnchor:bottomAnchor constant:-8.0];
    _minTopConstraint.active = YES;
    _maxBottomConstraint.active = YES;

    [self updateAlignmentConstraints];
  }

  return self;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  _rootView.frame = self.bounds;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  const auto &oldViewProps = *std::static_pointer_cast<SnackBarViewProps const>(_props);
  const auto &newViewProps = *std::static_pointer_cast<SnackBarViewProps const>(props);

  if (oldViewProps.message != newViewProps.message) {
    NSString *message = newViewProps.message.empty() ? @"" : [NSString stringWithUTF8String:newViewProps.message.c_str()];
    _message = message ?: @"";
    _label.text = _message;
  }

  if (oldViewProps.visible != newViewProps.visible) {
    _visible = newViewProps.visible;
  }

  if (oldViewProps.duration != newViewProps.duration) {
    _durationSeconds = MAX(0.0, ((CGFloat)newViewProps.duration) / 1000.0);
  }

  if (oldViewProps.top != newViewProps.top) {
    _top = newViewProps.top;
    _verticalAlignment = _top ? kSnackBarAlignStartOrTop : kSnackBarAlignEndOrBottom;
    [self updateAlignmentConstraints];
  }

  if (oldViewProps.alignX != newViewProps.alignX) {
    _horizontalAlignment = [self sanitizedAlignmentValue:newViewProps.alignX defaultValue:kSnackBarAlignCenter];
    [self updateAlignmentConstraints];
  }

  if (oldViewProps.alignY != newViewProps.alignY) {
    _verticalAlignment = [self sanitizedAlignmentValue:newViewProps.alignY defaultValue:kSnackBarAlignEndOrBottom];
    _top = (_verticalAlignment == kSnackBarAlignStartOrTop);
    [self updateAlignmentConstraints];
  }

  if (oldViewProps.color != newViewProps.color) {
    UIColor *color = RCTUIColorFromSharedColor(newViewProps.color);
    _snackColor = color ?: [UIColor colorWithWhite:1.0 alpha:0.10];
    _glassContainer.backgroundColor = _snackColor;
  }

  if (oldViewProps.textColor != newViewProps.textColor) {
    UIColor *textColor = RCTUIColorFromSharedColor(newViewProps.textColor);
    _snackTextColor = textColor ?: [UIColor colorWithWhite:1.0 alpha:0.96];
    _label.textColor = _snackTextColor;
  }

  [self applyVisibility:YES];

  [super updateProps:props oldProps:oldProps];
}

- (void)prepareForRecycle
{
  [self invalidateDismissTimer];
  _isPresented = NO;
  _glassContainer.alpha = 0.0;
  _glassContainer.transform = CGAffineTransformMakeTranslation(0, [self verticalAnimationOffset]);
  [super prepareForRecycle];
}

- (void)dealloc
{
  [self invalidateDismissTimer];
}

- (void)updateAlignmentConstraints
{
  // Keep snack width fixed to viewport minus side margins.
  _leadingConstraint.active = YES;
  _trailingConstraint.active = YES;
  _centerXConstraint.active = NO;

  BOOL alignLeft = (_horizontalAlignment == kSnackBarAlignStartOrTop);
  BOOL alignRight = (_horizontalAlignment == kSnackBarAlignEndOrBottom);
  _label.textAlignment = alignLeft ? NSTextAlignmentLeft : (alignRight ? NSTextAlignmentRight : NSTextAlignmentCenter);

  BOOL alignTop = (_verticalAlignment == kSnackBarAlignStartOrTop);
  BOOL alignCenter = (_verticalAlignment == kSnackBarAlignCenter);
  _topConstraint.active = alignTop;
  _bottomConstraint.active = (!alignTop && !alignCenter);
  _centerYConstraint.active = alignCenter;
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

- (void)animateIn:(BOOL)animated
{
  if (!_isPresented) {
    _glassContainer.transform = CGAffineTransformMakeTranslation(0, [self verticalAnimationOffset]);
    _glassContainer.alpha = 0.0;
  }

  void (^animations)(void) = ^{
    self->_glassContainer.alpha = 1.0;
    self->_glassContainer.transform = CGAffineTransformIdentity;
  };

  if (animated) {
    [UIView animateWithDuration:0.45
                          delay:0.0
         usingSpringWithDamping:0.84
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:animations
                     completion:nil];
  } else {
    animations();
  }

  _isPresented = YES;
}

- (void)animateOut:(BOOL)animated
{
  if (!_isPresented) {
    _glassContainer.alpha = 0.0;
    return;
  }

  CGAffineTransform hiddenTransform = CGAffineTransformMakeTranslation(0, [self verticalAnimationOffset]);
  void (^animations)(void) = ^{
    self->_glassContainer.alpha = 0.0;
    self->_glassContainer.transform = hiddenTransform;
  };

  void (^completion)(BOOL) = ^(BOOL finished) {
    if (finished) {
      self->_isPresented = NO;
    }
  };

  if (animated) {
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
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

- (CGFloat)verticalAnimationOffset
{
  if (_verticalAlignment == kSnackBarAlignStartOrTop) {
    return -24.0;
  }
  if (_verticalAlignment == kSnackBarAlignCenter) {
    return 12.0;
  }
  return 24.0;
}

@end

Class<RCTComponentViewProtocol> SnackBarViewCls(void)
{
  return SnackBarView.class;
}
