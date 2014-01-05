//
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2010. All rights reserved.
//

#import "SearchByLyricFragmentOperation.h"

#import <GracenoteMusicID/GNUtil.h>
#import <GracenoteMusicID/GNSearchResult.h>
#import <GracenoteMusicID/GNSearchResponse.h>
#import <GracenoteMusicID/GNOperations.h>

@implementation SearchByLyricFragmentOperation

@synthesize artist = m_artist;
@synthesize lyricFragment = m_lyricFragment;

- (void) dealloc
{
  self.artist = nil;
  self.lyricFragment = nil;
  [super dealloc];
}

+ (SearchByLyricFragmentOperation*) searchByLyricFragmentOperation:(GNConfig*)config
{
  SearchByLyricFragmentOperation *obj = [[SearchByLyricFragmentOperation alloc] initWithConfig:config];
  [obj autorelease];
  return obj;
}

- (void) startOperation
{
  [GNOperations searchByLyricFragment:self
                               config:self.config
                        lyricFragment:self.lyricFragment
                               artist:self.artist];  
}

- (NSString*) operationName
{
  return @"SearchByLyricFragmentOperation";
}

-(SearchType)searchType
{
	return SearchTypeLyricFragment;
}

@end
