//
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreLocation/CoreLocation.h>
#import "SearchByOperation.h"

#import <GracenoteMusicID/GNRecognizeStream.h>
#import <GracenoteMusicID/GNAudioSourceMic.h> 
#import <GracenoteMusicID/GNAudioConfig.h>
#import <GracenoteMusicID/GNCacheStatus.h>

@class GNConfig;
@class SearchResultTableViewController;

@interface GN_Music_SDK_iOSViewController : UIViewController <CLLocationManagerDelegate,UIActionSheetDelegate,MPMediaPickerControllerDelegate,GNAudioSourceDelegate>
{
  
    IBOutlet UIView *m_searchTableContainer;
    SearchResultTableViewController *m_searchResultTableViewController;
    //IBOutlet UILabel *m_statusLabel;
    IBOutlet UISwitch *m_debugSwitch;
    GNConfig *m_config;
	CLLocationManager *m_locationManager;
	SearchType m_currentSearchType;
	IBOutlet UIActivityIndicatorView *m_indicator;
    GNRecognizeStream *m_recognizeFromPCM;
    GNAudioSourceMic *m_objAudioSource;
    GNAudioConfig *m_audioConfig;
    IBOutlet UIButton *m_idNowButton;
    
    BOOL m_interruptionInProgress;
    
}

@property (nonatomic, retain) UIView *searchTableContainer;
@property (nonatomic, retain) SearchResultTableViewController *searchResultTableViewController;
//@property (nonatomic, retain) UILabel *statusLabel;
@property (nonatomic, retain) UISwitch *debugSwitch;
@property (nonatomic, retain) GNConfig *config;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic) SearchType currentSearchType;
@property (nonatomic, assign) UIActivityIndicatorView *indicator;
@property (nonatomic, retain) GNAudioConfig *audioConfig;
@property (nonatomic, retain) GNAudioSourceMic *objAudioSource;
@property (nonatomic, retain) GNRecognizeStream *recognizeFromPCM;
@property (nonatomic, retain) IBOutlet UIButton *idNowButton;

@property (assign) BOOL interruptionInProgress;

@property (assign) NSTimeInterval startTime;


- (IBAction) lookupFingerprintAction;
- (IBAction) recognizeFromMicAction;
- (IBAction) recognizeFromPCMAction;
- (IBAction) searchByTextAction;
- (IBAction) searchByLyricFragmentAction;
- (IBAction) debugSwitchChangedAction;
-(IBAction) showSearchHistory;
- (IBAction) recognizeFileFromFile;
-(IBAction) recognizeFromBtnTapped;
-(IBAction)albumIdBtnTapped;
- (void) lookupFingerprintOperation;
- (void) recognizeFromMicOperation;
- (void) recognizeFromPCMOperation;
-(void)albumIDFile;
- (void) setStatus:(NSString*)status showStatusPrefix:(BOOL)showStatusPrefix;
-(BOOL)isFileFormatSupported:(NSURL*)filePath;
- (void) reportSearchResults:(NSString*)message results:(NSArray*)results;
- (void) reportSearchResults:(NSString*)message results:(NSArray*)results forSearchType:(SearchType)searchType;
+(CLLocation*)getCurrentLocation;

-(void)setUpRecognizePCMSession;
- (IBAction)idNow;
-(void)applicationDidEnterInBackground;
-(void)applicationWillEnterInForeground;

- (IBAction) cancelAllOperations;

@end

