//
//  AlbumDetailHeaderView.h
//  iOSMobileVideoSDK
//
//  Copyright Gracenote Inc. 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GNSearchResponse;
@interface AlbumDetailHeaderView : UIView 
{
	UIImageView *coverArt;
	UILabel *albumNameLabel;
	UILabel *artistNameLabel;
}

@property(nonatomic, retain) UIImageView *coverArt;
@property(nonatomic, retain) UILabel *albumNameLabel;
@property(nonatomic, retain) UILabel *artistNameLabel;

- (id)initWIthSearchResponse:(GNSearchResponse *)searchResponse forReview:(BOOL)flag;

-(void)setCoverArtImage:(UIImage *)image;
-(CGRect)newFrameForImageView:(UIImageView *)imageViewObj forImage:(UIImage *)imageObj;

@end
