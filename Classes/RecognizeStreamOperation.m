//
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2010. All rights reserved.
//

#import "RecognizeStreamOperation.h"
#import <GracenoteMusicID/GNConfig.h>

@implementation RecognizeStreamOperation

- (void) dealloc
{
    [super dealloc];
}

+ (RecognizeStreamOperation*) recognizeStreamOperation:(GNConfig*)config
{
    RecognizeStreamOperation *obj = [[RecognizeStreamOperation alloc] initWithConfig:config];
    [obj autorelease];
    return obj;
}

- (NSString*) operationName
{
    return @"RecognizeStreamOperation";
}

-(SearchType)searchType
{
	return SearchTypeRecognizeStream;
}


@end
