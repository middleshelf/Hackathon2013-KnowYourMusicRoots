//
//  ImgRecord.m
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2012. All rights reserved.
//

#import "ImgRecord.h"

@implementation ImgRecord

@synthesize strImageURL;
@synthesize imgIcon;

- (void)dealloc
{
    [strImageURL release];
    [imgIcon release];
       
    [super dealloc];
}

@end
