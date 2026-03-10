#import "SnackBarView.h"

#import <React/RCTConversions.h>

#import <react/renderer/components/SnackBarViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/SnackBarViewSpec/Props.h>
#import <react/renderer/components/SnackBarViewSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

@implementation SnackBarView {
    UIView * _view;
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

    _view = [[UIView alloc] init];

    self.contentView = _view;
  }

  return self;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
    const auto &oldViewProps = *std::static_pointer_cast<SnackBarViewProps const>(_props);
    const auto &newViewProps = *std::static_pointer_cast<SnackBarViewProps const>(props);

    if (oldViewProps.color != newViewProps.color) {
        [_view setBackgroundColor: RCTUIColorFromSharedColor(newViewProps.color)];
    }

    [super updateProps:props oldProps:oldProps];
}

@end
