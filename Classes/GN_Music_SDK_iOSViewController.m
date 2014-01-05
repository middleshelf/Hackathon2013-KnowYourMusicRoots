//
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2010. All rights reserved.
//

#import "GN_Music_SDK_iOSViewController.h"

#import <GracenoteMusicID/GNConfig.h>
#import <GracenoteMusicID/GNSampleBuffer.h>
#import <GracenoteMusicID/GNOperations.h>
#import <GracenoteMusicID/GNSearchResponse.h>

#import "SearchByFingerprintOperation.h"
#import "RecognizeFromMicOperation.h"
#import "RecognizeFromPCMOperation.h"
#import "RecognizeStreamOperation.h"

#import "SearchByTextViewController.h"
#import "SearchByTextOperation.h"
#import "SearchByLyricFragmentViewController.h"
#import "SearchByLyricFragmentOperation.h"

#import "SearchResultTableViewController.h"
#import "SearchHistoryViewController.h"
#import "RecognizeFromFileOperation.h"
#import "AlbumIdOperation.h"
#import "ImgRecord.h"
#import <GracenoteMusicID/GNCoverArt.h>

#define ALBUMIDACTIONSHEETTAG 5000
#define RECOGNIZEACTIONSHEETTAG 5001

@implementation GN_Music_SDK_iOSViewController

@synthesize searchTableContainer = m_searchTableContainer;
@synthesize searchResultTableViewController = m_searchResultTableViewController;
//@synthesize statusLabel = m_statusLabel;
@synthesize debugSwitch = m_debugSwitch;
@synthesize config = m_config;
@synthesize locationManager = m_locationManager;
@synthesize currentSearchType = m_currentSearchType;
@synthesize indicator = m_indicator;
@synthesize audioConfig = m_audioConfig;
@synthesize objAudioSource = m_objAudioSource;
@synthesize recognizeFromPCM = m_recognizeFromPCM;
@synthesize idNowButton = m_idNowButton;

@synthesize interruptionInProgress = m_interruptionInProgress;

int metadataNumImagesRendered;
int maxMetaDataNumImagesRender = 10;

- (void)dealloc {
    
    self.idNowButton = nil;
	self.searchTableContainer = nil;
	self.searchResultTableViewController = nil;
	//self.statusLabel = nil;
	self.debugSwitch = nil;
	self.config = nil;
	self.locationManager = nil;
	self.indicator = nil;
	[super dealloc];
}

- (void) setStatus:(NSString*)status showStatusPrefix:(BOOL)showStatusPrefix
{
	NSString *statusToDisplay;
	
	if (showStatusPrefix) {
		NSMutableString *mstr = [NSMutableString string];
		[mstr appendString:@"Status: "];
		[mstr appendString:status];
		statusToDisplay = [NSString stringWithString:mstr];
	} else {
		statusToDisplay = status;
	}
	
	//self.statusLabel.text = statusToDisplay;
}

- (void)viewDidLoad {
	[super viewDidLoad]; 
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationResignedActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object: nil];

    
	//NSAssert(self.statusLabel, @"searchTableContainer not set in NIB");
	NSAssert(self.searchTableContainer, @"searchTableContainer not set in NIB");
	
	// Put SearchResultTableViewController inside placeholder view

	self.searchResultTableViewController = [SearchResultTableViewController searchResultTableViewController];
	self.searchResultTableViewController.parentController = self;
	//[self.searchTableContainer addSubview:self.searchResultTableViewController.view];
	   
    self.interruptionInProgress = NO;
    
    if ([self is4InchRetina]) {
        
        self.searchResultTableViewController.view.frame = CGRectMake(self.searchResultTableViewController.view.frame.origin.x, self.searchResultTableViewController.view.frame.origin.y, self.searchResultTableViewController.view.frame.size.width, self.searchResultTableViewController.view.frame.size.height + 85);
    }

    
	@try {		
		self.config = [GNConfig init:CLIENTID];
	}
	@catch (NSException * e) {
		NSLog(@"clientId can't be nil or the empty string");
		[self setStatus:@"clientId can't be nil or the empty string" showStatusPrefix:FALSE];
		[self.view setUserInteractionEnabled:FALSE];
		return;
	}
	
	// Debug is disabled in the GUI by default
	[self.config setProperty:@"debugEnabled" value:@"0"];
    [self.config setProperty:@"lookupmodelocalonly" value:@"0"];
    
    
	//Create locationManager to get latitude,longitude for search history record.
	self.locationManager = [[[CLLocationManager alloc] init] autorelease];
	self.locationManager.delegate = self; // Tells the location manager to send updates to this object
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	self.locationManager.distanceFilter = 20.0;
	[self.locationManager startUpdatingLocation];
    
    
    // -------------------------------------------------------------------------------
    //Init AudioSource to Start Recording.
    // -------------------------------------------------------------------------------
    
    self.recognizeFromPCM = [GNRecognizeStream gNRecognizeStream:self.config];
    self.audioConfig = [GNAudioConfig gNAudioConfigWithSampleRate:44100 bytesPerSample:2 numChannels:1];
    
    self.objAudioSource = [GNAudioSourceMic gNAudioSourceMic:self.audioConfig];
    self.objAudioSource.delegate=self;
    
    NSError *err;
    
    RecognizeStreamOperation *op = [RecognizeStreamOperation recognizeStreamOperation:self.config];
    err = [self.recognizeFromPCM startRecognizeSession:op audioConfig:self.audioConfig];
    
    if (err) {
        NSLog(@"ERROR: %@",[err localizedDescription]);
    }
    
    [self.objAudioSource startRecording];
    
    [self performSelectorInBackground:@selector(setUpRecognizePCMSession) withObject:nil];
    
    
    NSString *sdkVersion = [self.config getProperty:@"version"];
	NSString *version = [NSString stringWithFormat:@"GNSDK %@", sdkVersion];

#if __LP64__
    version = [version stringByAppendingString:@"   64 bit"];
#else
    version = [version stringByAppendingString:@"   32 bit"];
#endif
    
	[self setStatus:version showStatusPrefix:FALSE];

	return;
}

#pragma mark - Recording interrurpt handler

- (void) applicationResignedActive:(NSNotification *)notification {
    self.interruptionInProgress = YES;
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    [self.objAudioSource stopRecording];
}

- (void) applicationDidBecomeActive:(NSNotification *)notification {
    self.interruptionInProgress = NO;
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [self.objAudioSource startRecording];
}



#pragma mark -
#pragma mark GNRecognizeStream methods

-(void)clearCache{

    GNCacheStatus *status = [self.config clearCache];
    NSLog(@"Clear Cache Status : %@",[status statusString]);
}

-(void)setUpRecognizePCMSession{

    NSString *bundleFileName = @"161.b";
    NSString *filePath = [[NSBundle mainBundle] pathForResource:bundleFileName ofType:nil];
    
    if (filePath !=nil && filePath.length != 0) {
      GNCacheStatus *status = [self.config loadCache:filePath];
        NSLog(@"Load Cache Status : %@",[status statusString]);
    }
    
    NSString *sdkVersion = [self.config getProperty:@"version"];
	NSString *version = [NSString stringWithFormat:@"GNSDK %@", sdkVersion];
    
#if __LP64__
    version = [version stringByAppendingString:@"   64 bit"];
#else
    version = [version stringByAppendingString:@"   32 bit"];
#endif

	[self setStatus:version showStatusPrefix:FALSE];
}


- (IBAction)idNow
{
    //[self.searchTableContainer addSubview:self.searchResultTableViewController.view];
    [self.searchResultTableViewController.results removeAllObjects];
    [self.searchResultTableViewController.aryOfImageView removeAllObjects];
    self.searchResultTableViewController.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    [self.searchResultTableViewController.tableView reloadData];
    [self.searchTableContainer addSubview:self.searchResultTableViewController.view];

   
    NSError *error;
    error = [self.recognizeFromPCM idNow];
    
        
    if (error) {
         NSLog(@"ERROR: %@",[error localizedDescription]);
    }
    else{
    
        self.debugSwitch.enabled = NO;
    }
}


- (void) audioBufferDidBecomeReady:(GNAudioSource*)audioSource samples:(NSData*)samples {
    NSError *err;
    err = [self.recognizeFromPCM writeBytes:samples];
    
    if (err) {
        NSLog(@"ERROR: %@",[err localizedDescription]);
    }
}

-(void)applicationDidEnterInBackground{
    
   if(!self.interruptionInProgress)
   {
    [self.objAudioSource stopRecording];
    [self.recognizeFromPCM stopRecognizeSession];
   }
    
}


-(void)applicationWillEnterInForeground{
   
    if(!self.interruptionInProgress)
    {
        RecognizeStreamOperation *op = [RecognizeStreamOperation recognizeStreamOperation:self.config];
        [self.recognizeFromPCM startRecognizeSession:op audioConfig:self.audioConfig];
        [self.objAudioSource startRecording];
    }
}


#pragma mark -
#pragma mark Other methods

-(BOOL)is4InchRetina
{
    if ((![UIApplication sharedApplication].statusBarHidden && (int)[[UIScreen mainScreen] applicationFrame].size.height == 548 )|| ([UIApplication sharedApplication].statusBarHidden && (int)[[UIScreen mainScreen] applicationFrame].size.height == 568))
        return YES;
    
    return NO;
}

// Invoked via button press in GUI

- (IBAction) cancelAllOperations {
	
    [GNOperations cancelAll];
    NSString *message = @"All operations are canceled.";
	[self setStatus:message showStatusPrefix:FALSE];
    self.debugSwitch.enabled = YES;
    
}

// Invoked via button press in GUI

- (IBAction) recognizeFromMicAction {
	[self recognizeFromMicOperation];
}

// Invoked via button press in GUI

- (IBAction) lookupFingerprintAction {
	[self lookupFingerprintOperation];
}

-(BOOL)validateSystemOSVersionAndModel {
	NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
	NSString *systemModel = [[UIDevice currentDevice] model]; //if simulator or device?
	
	float iOSVersion = [systemVersion floatValue];
	
	if(iOSVersion < 4.0 || [systemModel isEqualToString:@"iPhone Simulator"])
	{
		NSLog(@"Either iOS version is < 4.0 or current device model is iPhone simulator");
		return FALSE;
	}else {
		return TRUE;
	}
}

- (IBAction) recognizeFileFromFile
{	
	UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:@"Select..."
															  delegate:self cancelButtonTitle:@"Cancel" 
												destructiveButtonTitle:nil 
													 otherButtonTitles:@"Choose File From iPod",@"Files From Documents",nil] autorelease];
	[actionSheet showInView:self.view];	
}
-(IBAction) recognizeFromBtnTapped
{
	UIActionSheet *recognizeFromActionsheet = [[[UIActionSheet alloc] initWithTitle:@"Recognize from:" 
																		   delegate:self 
																  cancelButtonTitle:@"Cancel" 
															 destructiveButtonTitle:nil 
																  otherButtonTitles:@"iPod-Library",@"DocumentDirectory",@"FPX",@"PCM",nil] autorelease];
    recognizeFromActionsheet.tag = RECOGNIZEACTIONSHEETTAG;
	[recognizeFromActionsheet setAutoresizesSubviews:TRUE];
	[recognizeFromActionsheet showInView:self.view];
	
	
}

-(IBAction)albumIdBtnTapped
{
    UIActionSheet *albumIDActionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose AlbumID Action..." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"AlbumIDFile",@"AlbumID iPOD Library",nil];
    albumIDActionSheet.tag = ALBUMIDACTIONSHEETTAG;
    [albumIDActionSheet showInView:self.view];
    [albumIDActionSheet release];
}

#pragma mark -
#pragma mark ActionSheet Delegate Methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{	
    
    [self.searchResultTableViewController.aryOfImageView removeAllObjects];
    self.searchResultTableViewController.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    [self.searchResultTableViewController.tableView reloadData];
    
	if(actionSheet.tag == RECOGNIZEACTIONSHEETTAG)
    {      
    //Process for recognize from actions
	switch (buttonIndex) 
	{
           
		case 0: //btnIndex 1 = Recognize from iPod-Library
		{
			if ([self validateSystemOSVersionAndModel]) {
				MPMediaPickerController *pickerController =	[[MPMediaPickerController alloc]
															 initWithMediaTypes: MPMediaTypeMusic];
				pickerController.prompt = @"Choose song to export";
				pickerController.allowsPickingMultipleItems = YES;
				pickerController.delegate = self;
				[self presentModalViewController:pickerController animated:YES];
				[pickerController release];
			}
			break;
		}
		case 1:	//btnIndex 2 = Recognize from DocumentDirectory
		{
			{
				int filesCount = 0;
				NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
				NSString *documentDirectory = [paths objectAtIndex:0];
				NSArray *filesPathArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentDirectory error:nil];
				for (int i=0; i < [filesPathArray count] ; i++) {
					NSString* filePath = [filesPathArray objectAtIndex:i];
					filePath = [documentDirectory stringByAppendingPathComponent:filePath];
					NSURL *fileURL = [NSURL fileURLWithPath:filePath];
					if ([self isFileFormatSupported:fileURL] == FALSE) //if file format is not supported then skip current and process next
					{
						NSLog(@"File format for fileUrl = %@ is not supported so skipping it",[fileURL description]);
						continue;
					}
					filesCount++;
					RecognizeFromFileOperation *op = [RecognizeFromFileOperation recognizeFromFileOperation:self.config];
					[GNOperations recognizeMIDFileFromFile:op config:self.config fileUrl:fileURL];		
				}
				
				if (filesCount == 0) {
					[self reportSearchResults:@"RecognizeFromFileOperation: Please add supported files in DocumentDirectory" results:nil];
				}
			}
			break;
		}
		case 2:	//btnIndex 3 = Recognize from FPX
		{
			[self lookupFingerprintAction];
			break;
		}
		case 3:	//btnIndex 4 = Recognize from PCM
		{
			[self recognizeFromPCMOperation];
			break;
		}
		case 4:	//btnIndex 5 = Cancel
		{
			[actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
			break;
		}
			
		default:
			break;
	}
    }
    else
    {
        //Process AlbumId Actions
        switch (buttonIndex) {
            case 0: //AlbumIDFIle
            {
                [self albumIDFile];
                break;
            }
            case 1: //iPod Library
            {
                if ([self validateSystemOSVersionAndModel]) {
                
                    MPMediaPickerController *pickerController =	[[MPMediaPickerController alloc]
                                                                 initWithMediaTypes: MPMediaTypeMusic];
                    pickerController.prompt = @"Choose song...";
                    pickerController.allowsPickingMultipleItems = YES;
                    pickerController.delegate = self;
                    [self presentModalViewController:pickerController animated:YES];
                    [pickerController release];
                }
                break;
            }
            case 2: //Cancel
            {
                break;
            }
            default:
                break;
        }
        
    }
}
-(void)albumIDFile
{    
    AlbumIdOperation *op = [AlbumIdOperation albumIdOperation:self.config];	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    for(int i=0;i<[paths count]; i++)
    {
        NSLog(@"paths @ %d = %@",i,[paths objectAtIndex:i]);
    }    
	NSString *documentDirectryPath = [paths objectAtIndex:0];
    NSError *err;
    NSArray *filPathsAtDocDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentDirectryPath error:&err];
    for(int i=0;i<[filPathsAtDocDirectory count]; i++)
    {
        NSLog(@"filPathsAtDocDirectory @ %d = %@",i,[filPathsAtDocDirectory objectAtIndex:i]);
    }
	
    NSMutableArray *aidFilePathsArray = [NSMutableArray array];
    
    for(int i=0;i<[filPathsAtDocDirectory count]; i++)
    {
        NSString *fileURL = [documentDirectryPath stringByAppendingPathComponent:[filPathsAtDocDirectory objectAtIndex:i]];
        [aidFilePathsArray insertObject:fileURL atIndex:i];
    }   
    
	[GNOperations albumIdFile:op config:self.config filePaths:aidFilePathsArray];
}

#pragma mark -
#pragma mark MPMediaPicker Delegate Methods
- (void)mediaPicker: (MPMediaPickerController *)mediaPicker
  didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    
    if([mediaPicker.prompt isEqualToString:@"Choose song to export"])
    {
        [self dismissModalViewControllerAnimated:YES];
	
	for (int i=0; i< [mediaItemCollection items].count; i++) {
		MPMediaItem *song = [[[mediaItemCollection items] objectAtIndex:i] retain];
		NSURL *assetURL = [song valueForProperty:MPMediaItemPropertyAssetURL];	
		RecognizeFromFileOperation *op = [RecognizeFromFileOperation recognizeFromFileOperation:self.config];
		[GNOperations recognizeMIDFileFromFile:op config:self.config fileUrl:assetURL];
	}
    }
    else if([mediaPicker.prompt isEqualToString:@"Choose song..."]) 
    {
        [self dismissModalViewControllerAnimated:YES];
        
        AlbumIdOperation *op = [AlbumIdOperation albumIdOperation:self.config];                
        [GNOperations albumIdFromMPMediaItemCollection:op config:self.config collection:mediaItemCollection];
    }
    else
    {
        NSAssert(YES,@"Failed to get either case");
    }
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
	[mediaPicker dismissModalViewControllerAnimated:YES];
}
#pragma mark -
-(BOOL)isFileFormatSupported:(NSURL*)filePath
{
	NSArray *supportedFileFormats = [NSArray arrayWithObjects:@".mp3",@".mp4",@".wav",@".m4a",@".aac",@".caf",@".aiff",nil];
	BOOL result = NO;
	NSString *fileNameWithExtension = [NSString stringWithString:[filePath description]];
	NSString *extension = [[NSString stringWithFormat:@".%@",[[fileNameWithExtension componentsSeparatedByString: @"."] lastObject]] lowercaseString];
	if ([supportedFileFormats containsObject:extension]) 
	{
		result = YES;
	}
	else
	{
		result = NO;
	}
	return result;
}

-(NSString*) myDocumentsDirectory 
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];;
}	

- (IBAction) recognizeFromPCMAction
{
	[self recognizeFromPCMOperation];
}

- (IBAction) searchByTextAction
{
    [self.searchResultTableViewController.aryOfImageView removeAllObjects];
    self.searchResultTableViewController.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    [self.searchResultTableViewController.tableView reloadData];
    
	SearchByTextViewController *viewController = [SearchByTextViewController searchByTextViewController];
	SearchByTrackIdOperation *trackIdOp = [SearchByTrackIdOperation searchByTrackIdOperation:self.config];
	// Create SearchByTextOperation that will be invoked when Ok button is pressed
	
	SearchByTextOperation *op = [SearchByTextOperation searchByTextOperation:self.config];
	viewController.searchByTrackIdOperation = trackIdOp;
	viewController.searchByTextOperation = op;
	self.searchResultTableViewController.searchByTrackIdOperation = trackIdOp;
	
	[self presentModalViewController:viewController animated:TRUE];
}

- (IBAction) searchByLyricFragmentAction
{
    
    [self.searchResultTableViewController.aryOfImageView removeAllObjects];
    self.searchResultTableViewController.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    [self.searchResultTableViewController.tableView reloadData];
    
	SearchByLyricFragmentViewController *viewController = [SearchByLyricFragmentViewController searchByLyricFragmentViewController];
	
	// Create SearchByLyricFragmentOperation that will be invoked when Ok button is pressed
	
	SearchByLyricFragmentOperation *op = [SearchByLyricFragmentOperation searchByLyricFragmentOperation:self.config];
	viewController.searchByLyricFragmentOperation = op;
	
	[self presentModalViewController:viewController animated:TRUE];
}

- (IBAction) debugSwitchChangedAction
{
	BOOL isOn = self.debugSwitch.on;
	NSLog(@"changed debug property to %d", isOn);
	NSString *value = [NSString stringWithFormat:@"%d", isOn];
	[self.config setProperty:@"debugEnabled" value:value];
    
    if (self.recognizeFromPCM) {
        
        [self.objAudioSource stopRecording];
        [self.recognizeFromPCM stopRecognizeSession];
        self.recognizeFromPCM = nil;
        
        self.recognizeFromPCM = [GNRecognizeStream gNRecognizeStream:self.config];
        NSError *err;
        
        RecognizeStreamOperation *op = [RecognizeStreamOperation recognizeStreamOperation:self.config];
        err = [self.recognizeFromPCM startRecognizeSession:op audioConfig:self.audioConfig];
        [self.objAudioSource startRecording];
        
        if (err) {
            NSLog(@"ERROR: %@",[err localizedDescription]);
        }
        
    }
    
	
	return;
}

-(IBAction) showSearchHistory
{
    [self.searchResultTableViewController.aryOfImageView removeAllObjects];
    self.searchResultTableViewController.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    [self.searchResultTableViewController.tableView reloadData];
    
	SearchHistoryViewController *viewController = [SearchHistoryViewController searchHistoryViewController];
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
	navController.navigationBar.tintColor = [UIColor colorWithRed:192.0/255.0 green:2.0/255.0 blue:0.0 alpha:1];
	[self presentModalViewController:navController animated:TRUE];
	[navController release];
}
// Invoke [GNOperations searchByFingerprint] to lookup an already calculated fingerprint and
// append the results to the text view.

- (void) lookupFingerprintOperation
{
	SearchByFingerprintOperation *op = [SearchByFingerprintOperation searchByFingerprintOperation:self.config];
	NSString *fingerprintXML = [op loadFingerprint];  
	[GNOperations searchByFingerprint:op config:self.config fingerprintData:fingerprintXML];
}

// Invoke [GNOperations recognizeMIDStreamFromMic] to record from the mic, generate a fingerprint, then
// lookup the fingerprint and query metadata.

- (void) recognizeFromMicOperation
{
	RecognizeFromMicOperation *op = [RecognizeFromMicOperation recognizeFromMicOperation:self.config];
	[GNOperations recognizeMIDStreamFromMic:op config:self.config];
}

- (void) recognizeFromPCMOperation
{  
	RecognizeFromPCMOperation *op = [RecognizeFromPCMOperation recognizeFromPCMOperation:self.config];
	
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"sample.pcm" ofType:nil];
	NSData *sampleData = [NSData dataWithContentsOfFile:filePath];
	GNSampleBuffer *sampleBuffer = [GNSampleBuffer gNSampleBuffer:sampleData numChannels:1 sampleRate:8000];
	
	[GNOperations recognizeMIDStreamFromPcm:op config:self.config sampleBuffer:sampleBuffer];
}

// Invoked when results from a search operation are ready, or before an operation begins

- (void) reportSearchResults:(NSString*)message results:(NSArray*)results
{
	metadataNumImagesRendered = 0;
	[self.searchResultTableViewController.results removeAllObjects];
	[self.searchResultTableViewController.results addObjectsFromArray:results];
	[self.searchResultTableViewController.tableView reloadData];
	[self setStatus:message showStatusPrefix:FALSE];
}

- (void) reportSearchResults:(NSString*)message results:(NSArray*)results forSearchType:(SearchType)searchType
{
	// The GUI can't display an unlimited number of images because
	// we would run out of memory before long. Once the max number
	// of images has been rendered, just treat the rest as "no cover"
	
	self.currentSearchType = searchType;
    
    if (searchType == SearchTypeRecognizeStream) {
        
        self.debugSwitch.enabled = YES;
    }
    
	if (self.searchResultTableViewController.results.count == 0) {
		metadataNumImagesRendered = 0;
	}
	
	if(searchType != SearchTypeRecognizeFromFile)
	{
        if (m_currentSearchType !=	(SearchType)SearchTypeNone) {
            [self.searchTableContainer addSubview:self.searchResultTableViewController.view];
        }
        
		metadataNumImagesRendered = 0;
		[self.searchResultTableViewController.results removeAllObjects];
        [self.searchResultTableViewController.aryOfImageView removeAllObjects];
        self.searchResultTableViewController.imageDownloadsInProgress = [NSMutableDictionary dictionary];
        
        for (int i=0; i<results.count; i++) {
			GNSearchResponse *response = [results objectAtIndex:i];
			
            ImgRecord *tmpImgRecord = [[ImgRecord alloc] init];
            tmpImgRecord.strImageURL = response.coverArt.url;
            [self.searchResultTableViewController.aryOfImageView addObject:tmpImgRecord];
            [tmpImgRecord release];
            
		}
		[self.searchResultTableViewController.results addObjectsFromArray:results];
      
        
      
	}else {
        if (m_currentSearchType !=	(SearchType)SearchTypeNone) {
                [self.searchTableContainer addSubview:self.searchResultTableViewController.view];
        }
		for (int i=0; i<results.count; i++) {
			GNSearchResponse *response = [results objectAtIndex:i];
			
			//Comment below if block to show coverArt for all results.
			if (response.coverArt != nil) 
			{
				metadataNumImagesRendered++;
				if (metadataNumImagesRendered > maxMetaDataNumImagesRender) {
					response.coverArt = nil;
				}
			}
			
            ImgRecord *tmpImgRecord = [[ImgRecord alloc] init];

            tmpImgRecord.strImageURL = response.coverArt.url;
            [self.searchResultTableViewController.aryOfImageView addObject:tmpImgRecord];
            [tmpImgRecord release];
            [self.searchResultTableViewController.results addObject:response];
		}
	}
	[self.searchResultTableViewController.tableView reloadData];
	[self setStatus:message showStatusPrefix:FALSE];
}

static CLLocation *currentLocation = nil;
#pragma mark -
#pragma mark CLLocationManagerDelegate Mrethods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	NSComparisonResult result = [newLocation.timestamp compare:[NSDate dateWithTimeIntervalSinceNow:-10]];
	if(result == NSOrderedDescending || result == NSOrderedSame)
	{
		[manager stopUpdatingLocation];
		@synchronized(self)
		{
			[currentLocation release];
			currentLocation = [[CLLocation alloc] initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
		}
	}
}

- (void)locationManager: (CLLocationManager *)manager
	   didFailWithError: (NSError *)error
{
	[manager stopUpdatingLocation];
	@synchronized(self)
	{
		[currentLocation release];
		//Failed to get correct location, store that entry as(0,0) and at the time of display show proper message
		currentLocation = [[CLLocation alloc] initWithLatitude:0.0 longitude:0.0];
	}
	switch([error code])
	{
		case kCLErrorNetwork: // general, network-related error
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"please check your network connection or that you are not in airplane mode" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
			[alert show];
			[alert release];
			break;
		}
		case kCLErrorDenied:
		{
			
			break;
		}
		case kCLErrorLocationUnknown:
		{
			break;
		}
		default:
		{
			break;
		}
	}
}

//Class method to get the current location
+(CLLocation*)getCurrentLocation
{
	return currentLocation;
}
@end
