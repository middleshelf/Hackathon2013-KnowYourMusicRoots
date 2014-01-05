//
//  AlbumIdOperation.m
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2011. All rights reserved.
//

#import "AlbumIdOperation.h"
#import <GracenoteMusicID/GNConfig.h>
#import <GracenoteMusicID/GNUtil.h>
#import <GracenoteMusicID/GNSearchResult.h>
#import <GracenoteMusicID/GNSearchResponse.h>
#import <GracenoteMusicID/GNOperations.h>
#import <GracenoteMusicID/GNStatus.h>
#import <GracenoteMusicID/GNResult.h>
#import <GracenoteMusicID/GNCoverArt.h>
#import <GracenoteMusicID/GNAlbumIdFileError.h>
#import <GracenoteMusicID/GNAlbumIdSearchResult.h>
#import "GN_Music_SDK_iOSViewController.h"

@implementation AlbumIdOperation

+(AlbumIdOperation *) albumIdOperation:(GNConfig *)config
{
	AlbumIdOperation *obj = [[AlbumIdOperation alloc] initWithConfig:config];
	[obj autorelease];
	return obj;
}


- (NSString*) operationName
{
	return @"AlbumIdOperation";
}

- (void) GNResultReady:(GNSearchResult*)result
{ 
	NSString *statusString = nil;
	NSArray *responses = nil;
	NSString *operationName = [self operationName];
	NSAssert(operationName, @"operationName");
	
	if ([result isFailure]) {
		statusString = [NSString stringWithFormat:@"%@: [%d] %@", operationName, result.errCode, result.errMessage];
	} else {
        GNAlbumIdSearchResult *albumIdResult = (GNAlbumIdSearchResult *)result;
		if ([albumIdResult isAnySearchNoMatchStatus]) {
			statusString = [NSString stringWithFormat:@"%@: NO_MATCH", operationName];
            for(int i=0;i<[albumIdResult.noMatchResponses count];i++)
            {
				NSLog(@"No_Match, File %@",[albumIdResult.noMatchResponses objectAtIndex:i]);
            }
            
		} else {
			// A search might return 1 best match, or 1 to N responses
            if(albumIdResult.statusCode == GNResult.AlbumIdPartialFailure)
            {
                //print log error + nomatch
                
                for(int i=0;i<[albumIdResult.errorResponses count];i++)
                {
                    NSLog(@"Error_Files Files %@ : ErrorMessages: %@",[(GNAlbumIdFileError *)[albumIdResult.errorResponses objectAtIndex:i] fileIdent],[[albumIdResult.errorResponses objectAtIndex:i] errMessage]);
                }
               
                for(int i=0;i<[albumIdResult.noMatchResponses count];i++)
                {
                    NSLog(@"No_Match, File %@",[albumIdResult.noMatchResponses objectAtIndex:i]);
                }
                
            }
			responses = [result responses];
			statusString = [NSString stringWithFormat:@"%@: Found %lu", operationName, (unsigned long)[responses count]];
		}
	}	
	NSAssert(statusString, @"statusString");
	[self.viewController reportSearchResults:statusString results:responses forSearchType:self.searchType];
	return;
}

-(SearchType)searchType
{
	return SearchTypeAlbumId;
}
@end
