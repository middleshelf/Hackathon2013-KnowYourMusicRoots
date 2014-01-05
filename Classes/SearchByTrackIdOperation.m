//
//  SearchByTrackIdOperation.m
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2010. All rights reserved.
//

#import "SearchByTrackIdOperation.h"
#import <GracenoteMusicID/GNUtil.h>
#import <GracenoteMusicID/GNSearchResult.h>
#import <GracenoteMusicID/GNSearchResponse.h>
#import <GracenoteMusicID/GNOperations.h>

@implementation SearchByTrackIdOperation

@synthesize trackId = m_trackId;

- (void) dealloc
{	
	self.trackId = nil;
	return [super dealloc];
}


+ (SearchByTrackIdOperation*) searchByTrackIdOperation:(GNConfig*)config
{
	SearchByTrackIdOperation *obj = [[SearchByTrackIdOperation alloc] initWithConfig:config];
	[obj autorelease];
	return obj;
}

- (void) startOperation
{
	/*
	[GNOperations searchByText:self
						config:self.config
						artist:self.artist
					albumTitle:self.album
					trackTitle:self.track];
	 */
	
	[GNOperations fetchByTrackId:self
						  config:self.config
						 trackId:self.trackId];
	 
	//	[GNOperations searchByGN_ID:self config:self.config gn_ID:@"9312245-25FA066E1D9BE86434A95492EBB8D4DE"];
}

- (NSString*) operationName
{
	return @"SearchByTrackIdOperation";
}


-(SearchType)searchType
{
	return SearchTypeFetchByTrackId;
}


@end
