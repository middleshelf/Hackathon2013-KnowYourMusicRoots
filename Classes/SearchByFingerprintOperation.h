//
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2010. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SearchByOperation.h"

@interface SearchByFingerprintOperation : SearchByOperation {
}

+ (SearchByFingerprintOperation*) searchByFingerprintOperation:(GNConfig*)config;

- (NSString*) loadFingerprint;

@end
