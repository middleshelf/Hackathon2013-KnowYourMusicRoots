//
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2010. All rights reserved.
//

#import "RecognizeFromPCMOperation.h"

#import <GracenoteMusicID/GNConfig.h>

@implementation RecognizeFromPCMOperation

- (void) dealloc
{
  [super dealloc];
}

+ (RecognizeFromPCMOperation*) recognizeFromPCMOperation:(GNConfig*)config
{
  RecognizeFromPCMOperation *obj = [[RecognizeFromPCMOperation alloc] initWithConfig:config];
  [obj autorelease];
  return obj;
}

- (NSString*) operationName
{
  return @"RecognizeFromPCMOperation";
}

-(SearchType)searchType
{
	return SearchTypeRecognizeFromPCM;
}

@end
