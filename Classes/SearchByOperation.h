//
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2010. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GracenoteMusicID/GNSearchResultReady.h>
#import <GracenoteMusicID/GNOperationStatusChanged.h>

@class GN_Music_SDK_iOSViewController;
@class GNConfig;

typedef enum
{
	SearchTypeRecognizeFromMic,
	SearchTypeRecognizeFromPCM,
    SearchTypeRecognizeStream,
	SearchTypeRecognizeFromFile,
	SearchTypeLyricFragment,
	SearchTypeFingerprint,
	SearchTypeFetchByTrackId,
	SearchTypeText,
	SearchTypeAlbumId,
	SearchTypeNone
}SearchType;

@interface SearchByOperation : NSObject <GNSearchResultReady, GNOperationStatusChanged> {
  GN_Music_SDK_iOSViewController *m_viewController;
  GNConfig *m_config;
}

@property (nonatomic, retain) GN_Music_SDK_iOSViewController *viewController;
@property (nonatomic, retain) GNConfig *config;
@property (nonatomic, readonly) SearchType searchType;
- (id) initWithConfig:(GNConfig*)config;

- (NSString*) operationName;
-(void)saveResultsForHistory:(GNSearchResult*) result;
+(const unsigned int)getCap_Limit;
@end
