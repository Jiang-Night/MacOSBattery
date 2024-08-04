#import "SMCBridge.h"
#import "Battery-Swift.h" // 确保替换为你的项目名称

@implementation SMCBridge

+ (instancetype)sharedInstance {
    static SMCBridge *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (double)getValueForKey:(NSString *)key {
    return [[SMC shared] getValue:key];
}

@end
