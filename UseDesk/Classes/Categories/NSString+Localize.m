//
//  NSString+Localize.m
//  UseDesk
//
//  Created by Mark on 17.08.2018.
//

#import "UseDeskSDK.h"
#import "NSString+Localize.h"

@implementation NSString (Localize)

- (NSString *)localized {
    return NSLocalizedStringFromTableInBundle(self, nil, [UseDeskSDK assetBundle], nil);
}

@end
