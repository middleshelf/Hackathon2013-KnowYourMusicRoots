//
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2010. All rights reserved.
//

#import "SearchByTextOperation.h"

#import <GracenoteMusicID/GNUtil.h>
#import <GracenoteMusicID/GNSearchResult.h>
#import <GracenoteMusicID/GNSearchResponse.h>
#import <GracenoteMusicID/GNOperations.h>

@implementation SearchByTextOperation

@synthesize artist = m_artist;
@synthesize album = m_album;
@synthesize track = m_track;

- (void) dealloc
{
  self.artist = nil;
  self.album = nil;
  self.track = nil;
  return [super dealloc];
}

+ (SearchByTextOperation*) searchByTextOperation:(GNConfig*)config
{
  SearchByTextOperation *obj = [[SearchByTextOperation alloc] initWithConfig:config];
  [obj autorelease];
  return obj;
}

- (void) startOperation
{
  [GNOperations searchByText:self
                      config:self.config
                      artist:self.artist
                  albumTitle:self.album
                  trackTitle:self.track];
	
//	[GNOperations searchByGN_ID:self config:self.config gn_ID:@"9312245-25FA066E1D9BE86434A95492EBB8D4DE"];
}

- (NSString*) operationName
{
  return @"SearchByTextOperation";
}

-(SearchType)searchType
{
	return SearchTypeText;
}

@end
