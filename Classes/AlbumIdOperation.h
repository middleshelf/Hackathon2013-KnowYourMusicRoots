//
//  AlbumIdOperation.h
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2011. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchByOperation.h"

@interface AlbumIdOperation : SearchByOperation 
{
	
}

+(AlbumIdOperation *) albumIdOperation:(GNConfig *)config;
@end
