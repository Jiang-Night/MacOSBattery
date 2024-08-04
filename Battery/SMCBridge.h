//
//  SMCBridge.h
//  Battery
//
//  Created by 江晚 on 2024/8/4.
//

#ifndef SMCBridge_h
#define SMCBridge_h

#import <Foundation/Foundation.h>

@interface SMCBridge : NSObject
+ (instancetype)sharedInstance;
- (double)getValueForKey:(NSString *)key;
@end

#endif /* SMCBridge_h */


