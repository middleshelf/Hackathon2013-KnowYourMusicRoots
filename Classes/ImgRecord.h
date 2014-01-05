//
//  ImgRecord.h
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2012. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImgRecord : NSObject
{
    NSString *strImageURL;
    UIImage *imgIcon;
}

@property (nonatomic, retain) NSString *strImageURL;
@property (nonatomic, retain) UIImage *imgIcon;

@end
