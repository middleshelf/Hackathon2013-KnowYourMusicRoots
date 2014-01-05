//
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2010. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SearchByOperation.h"

@interface SearchByTextOperation : SearchByOperation {
  NSString *m_artist;
  NSString *m_album;
  NSString *m_track;
}

@property (nonatomic, copy) NSString *artist;
@property (nonatomic, copy) NSString *album;
@property (nonatomic, copy) NSString *track;

+ (SearchByTextOperation*) searchByTextOperation:(GNConfig*)config;

- (void) startOperation;

@end
