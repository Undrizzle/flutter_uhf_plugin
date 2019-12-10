#import "FlutterUhfPlugin.h"
#import <flutter_uhf_plugin/flutter_uhf_plugin-Swift.h>

@implementation FlutterUhfPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterUhfPlugin registerWithRegistrar:registrar];
}
@end
