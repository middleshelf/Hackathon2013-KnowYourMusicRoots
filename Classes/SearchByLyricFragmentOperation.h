//
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2010. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SearchByOperation.h"

@interface SearchByLyricFragmentOperation : SearchByOperation {
  NSString *m_artist;
  NSString *m_lyricFragment;
}

@property (nonatomic, copy) NSString *artist;
@property (nonatomic, copy) NSString *lyricFragment;

+ (SearchByLyricFragmentOperation*) searchByLyricFragmentOperation:(GNConfig*)config;

- (void) startOperation;

@end
