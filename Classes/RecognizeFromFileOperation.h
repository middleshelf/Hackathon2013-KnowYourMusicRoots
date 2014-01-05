//
//  RecognizeFromFileOperation.h
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2011. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchByOperation.h"

@interface RecognizeFromFileOperation : SearchByOperation {

}
//+ (RecognizeFromPCMOperation*) recognizeFromPCMOperation:(GNConfig*)config;
+ (RecognizeFromFileOperation*) recognizeFromFileOperation:(GNConfig*)config;
@end
