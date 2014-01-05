//
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2010. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchByOperation.h"


@interface SearchByTrackIdOperation : SearchByOperation {
	 NSString *m_trackId;
}

@property (nonatomic, copy) NSString *trackId;
+ (SearchByTrackIdOperation*) searchByTrackIdOperation:(GNConfig*)config;
- (void) startOperation;

@end