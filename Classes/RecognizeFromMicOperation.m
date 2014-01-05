//
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2010. All rights reserved.
//

#import "RecognizeFromMicOperation.h"

#import <GracenoteMusicID/GNUtil.h>
#import <GracenoteMusicID/GNSearchResult.h>
#import <GracenoteMusicID/GNSearchResponse.h>
#import <GracenoteMusicID/GNOperations.h>

@implementation RecognizeFromMicOperation

- (void) dealloc {
  [super dealloc];
}

+ (RecognizeFromMicOperation*) recognizeFromMicOperation:(GNConfig*)config
{
  RecognizeFromMicOperation *obj = [[RecognizeFromMicOperation alloc] initWithConfig:config];
  [obj autorelease];
  return obj;
}

- (NSString*) operationName
{
  return @"RecognizeFromMicOperation";
}
-(SearchType)searchType
{
	return SearchTypeRecognizeFromMic;
}
@end
