//
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2010. All rights reserved.
//

#import "SearchByFingerprintOperation.h"

#import <GracenoteMusicID/GNUtil.h>
#import <GracenoteMusicID/GNSearchResult.h>
#import <GracenoteMusicID/GNSearchResponse.h>
#import <GracenoteMusicID/GNOperations.h>

@implementation SearchByFingerprintOperation

- (void) dealloc {
  [super dealloc];
}

+ (SearchByFingerprintOperation*) searchByFingerprintOperation:(GNConfig*)config
{
  SearchByFingerprintOperation *obj = [[SearchByFingerprintOperation alloc] initWithConfig:config];
  [obj autorelease];
  return obj;
}

- (NSString*) loadFingerprint
{
  NSString *resPath = [[NSBundle mainBundle] pathForResource:@"Dido_MyLoversGone_Fingerprint_MIDStream.xml" ofType:nil];
  NSAssert(resPath, @"can't find resource");
  NSString *fingerprintXML = [GNUtil readUTF8:resPath];
  return fingerprintXML;
}

- (NSString*) operationName
{
  return @"SearchByFingerprintOperation";
}

-(SearchType)searchType
{
	return SearchTypeFingerprint;
}

@end
