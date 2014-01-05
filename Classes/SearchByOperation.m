//
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2010. All rights reserved.
//
// A SearchByOperation is a generic superclass for any
// specific type of search operation. This class will
// report results that will be displayed in the main
// view as a list.

#import <GracenoteMusicID/GNConfig.h>
#import <GracenoteMusicID/GNUtil.h>
#import <GracenoteMusicID/GNSearchResult.h>
#import <GracenoteMusicID/GNSearchResponse.h>
#import <GracenoteMusicID/GNOperations.h>
#import <GracenoteMusicID/GNStatus.h>
#import <GracenoteMusicID/GNCoverArt.h>
#import "SearchByOperation.h"

#import "GN_Music_SDK_iOSAppDelegate.h"
#import "GN_Music_SDK_iOSViewController.h"

#import "History.h"
#import "Metadata.h"
#import "CoverArt.h"
#import "constant.h"

@implementation SearchByOperation

@synthesize viewController = m_viewController;
@synthesize config = m_config;
@synthesize searchType;

- (void) dealloc
{
  self.viewController = nil;
  self.config = nil;
  [super dealloc];
}

+(const unsigned int)getCap_Limit
{
	return CAP_LIMIT;
}

- (id) initWithConfig:(GNConfig*)config
{
  NSAssert(config, @"config");
  self = [super init];
  if (self) {
    // Lookup GN_Music_SDKViewController via GN_Music_SDKAppDelegate
    GN_Music_SDK_iOSAppDelegate *delegate = [[UIApplication sharedApplication] delegate];    
    self.viewController = delegate.viewController;
    self.config = config;
    // Always kick off an empty "result" report so that the GUI is cleared
    // while waiting for the real results from an operaton to come back
	  [self.viewController reportSearchResults:@"" results:nil forSearchType:SearchTypeNone];
  }
  return self;
}

// Invoked by GNSDK in the main thread when a search result is ready

- (void) GNResultReady:(GNSearchResult*)result
{ 
	NSString *statusString = nil;
	NSArray *responses = nil;
	NSString *operationName = [self operationName];
	NSAssert(operationName, @"operationName");
	
	if ([result isFailure]) {
		statusString = [NSString stringWithFormat:@"%@: [%d] %@", operationName, result.errCode, result.errMessage];
	} else {
		if ([result isAnySearchNoMatchStatus]) {
			statusString = [NSString stringWithFormat:@"%@: NO_MATCH", operationName];
		} else {
			// A search might return 1 best match, or 1 to N responses
			responses = [result responses];
			statusString = [NSString stringWithFormat:@"%@: Found %lu", operationName, (unsigned long)[responses count]];
			if((self.searchType == SearchTypeRecognizeFromMic || self.searchType == SearchTypeRecognizeFromPCM 
			   || self.searchType == SearchTypeFingerprint || self.searchType == SearchTypeRecognizeStream) && responses.count == 1)
			{
				@synchronized(self)
				{
					[self saveResultsForHistory:result];
				}
			}
		}
	}	
	NSAssert(statusString, @"statusString");
    
    NSLog(@" ---->  GNResultReady Operation: %@  status: %@", operationName, statusString);

	[self.viewController reportSearchResults:statusString results:responses forSearchType:self.searchType];
	return;
}

// Invoked by GNSDK in the main thread when an incremental status update is ready.
// An operation that records from the microphone will generate a "recording" status
// message that indicate the percentage done WRT the amount of audio needed to
// generate an MIDStream fingerprint.

- (void) GNStatusChanged:(GNStatus*)status
{
	NSString *msg;

	//if (status.status == /*GNStatusEnum*/ LISTENING) {
	//msg = [NSString stringWithFormat:@"%@ %d%@", status.message, status.percentDone, @"%"];
	//} else {
	msg = status.message;
	//}

	[self.viewController setStatus:msg showStatusPrefix:TRUE];
}

// This method will be defined in the subclass

- (NSString*) operationName
{
  return nil;
}

// This method will be defined in the subclass

-(SearchType)searchType
{
	return SearchTypeNone;
}

// Save the user's MusicID-Stream query incase of search by 
// RecognizeFromMic or RecognizeFromPCM or Fingerprint
-(void)saveResultsForHistory:(GNSearchResult*) result
{
	NSDate *currentDate = [NSDate date];
	NSDateFormatter *gmtDF = [[[NSDateFormatter alloc] init] autorelease];	
	[gmtDF setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
	[gmtDF setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];	
	NSString *dateStr = [gmtDF stringFromDate:currentDate];
	NSDate *gmtDate = [gmtDF dateFromString:dateStr];
	

	NSManagedObjectContext *context = [GN_Music_SDK_iOSAppDelegate sharedContext];
	GNSearchResponse *response = [[result responses] objectAtIndex:0];
	Metadata *metadata = [NSEntityDescription insertNewObjectForEntityForName:@"Metadata" inManagedObjectContext:context];
	CoverArt *coverArt = [NSEntityDescription insertNewObjectForEntityForName:@"CoverArt" inManagedObjectContext:context];
	History *history = [NSEntityDescription insertNewObjectForEntityForName:@"History" inManagedObjectContext:context];
	
	//Setup metadata entity attributes.
	metadata.albumTitle = response.albumTitle;
	metadata.albumTitleYomi = response.albumTitleYomi;
	metadata.artist = response.artist;
	metadata.artistYomi = response.artistYomi;
	metadata.artistBetsumei = response.artistBetsumei;
	metadata.trackTitle = response.trackTitle;
	metadata.trackTitleYomi = response.trackTitleYomi;
	metadata.albumId = response.albumId;
	metadata.albumTrackCount = [NSNumber numberWithInteger:response.albumTrackCount];
	metadata.trackNumber = [NSNumber numberWithInteger:response.trackNumber];;
	
	
	//Setup coverArt entity Attributes
	coverArt.size = response.coverArt.size;
	coverArt.mimeType = response.coverArt.mimeType;
	coverArt.data = response.coverArt.data;
	
	//Setup history entity attributes
	history.auto_id = [NSNumber numberWithUnsignedInt:[GN_Music_SDK_iOSAppDelegate getLastInsertedAuto_id]];
	history.current_date = gmtDate;
	history.fingerprint = result.fingerprintData;
	CLLocation *location = [GN_Music_SDK_iOSViewController getCurrentLocation];
	if(location)
	{
		history.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
		history.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
	}
	else
	{
		history.latitude = [NSNumber numberWithDouble:0.0];
		history.longitude = [NSNumber numberWithDouble:0.0];
	}
	
	//setup relationships
	metadata.coverArt = coverArt;
	coverArt.metaData = metadata;
	history.metadata = metadata;
	//Save new record.
	NSError *error = nil;
	unsigned int newId = (unsigned int)[GN_Music_SDK_iOSAppDelegate getLastInsertedAuto_id]+1;
	[GN_Music_SDK_iOSAppDelegate setLastInsertedAuto_id:newId];
	[context save:&error];
	if(error)
	{
		NSLog(@"Could not save the data after inserting.");
	}
	error = nil;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription 
								   entityForName:@"History" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	NSSortDescriptor *dateSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"current_date" ascending:YES] autorelease];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:dateSortDescriptor]];
	 NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	if(error)
	{
		NSLog(@"Could not fetch objects to delete");
	}
	error = nil;
	if(fetchedObjects.count>CAP_LIMIT)
	{
		int noOfExtraObjects = (int32_t)fetchedObjects.count - CAP_LIMIT;
		for(int i =0;i<noOfExtraObjects;i++)
		{
			History *historyToDelete = (History *)[fetchedObjects objectAtIndex:i];
			[context deleteObject:historyToDelete];
		}
		[context save:&error];
		if(error)
		{
			NSLog(@"Could not save the context after deleting.");
		}
	}
	[fetchRequest release];
}

@end
