//
//  RecognizeFromFileOperation.m
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2011. All rights reserved.
//

#import "RecognizeFromFileOperation.h"
#import <GracenoteMusicID/GNConfig.h>

@implementation RecognizeFromFileOperation

- (void) dealloc
{
	[super dealloc];
}

+ (RecognizeFromFileOperation*) recognizeFromFileOperation:(GNConfig*)config
{
	RecognizeFromFileOperation *obj = [[RecognizeFromFileOperation alloc] initWithConfig:config];
	[obj autorelease];
	return obj;
}

- (NSString*) operationName
{
	return @"RecognizeFromFileOperation";
}


-(SearchType)searchType
{
	return SearchTypeRecognizeFromFile;
}


@end
