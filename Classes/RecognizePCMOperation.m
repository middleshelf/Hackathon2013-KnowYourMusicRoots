//
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2010. All rights reserved.
//

#import "RecognizePCMOperation.h"
#import <GracenoteMusicID/GNConfig.h>

@implementation RecognizePCMOperation

- (void) dealloc
{
    [super dealloc];
}

+ (RecognizePCMOperation*) recognizePCMOperation:(GNConfig*)config
{
    RecognizePCMOperation *obj = [[RecognizePCMOperation alloc] initWithConfig:config];
    [obj autorelease];
    return obj;
}

- (NSString*) operationName
{
    return @"RecognizePCMOperation";
}

-(SearchType)searchType
{
	return SearchTypeRecognizePCM;
}


@end
