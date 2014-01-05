//
//  AlbumDetailHeaderView.m
//  iOSMobileVideoSDK
//
//  Copyright Gracenote Inc. 2010. All rights reserved.
//

#import "AlbumDetailHeaderView.h"
#import <GracenoteMusicID/GNSearchResponse.h>
#import <GracenoteMusicID/GNCoverArt.h>

@implementation AlbumDetailHeaderView

@synthesize coverArt;
@synthesize albumNameLabel;
@synthesize artistNameLabel;

- (void)dealloc 
{
	self.coverArt = nil;
	self.albumNameLabel = nil;
	self.artistNameLabel = nil;
    [super dealloc];
}


const float ADH_COVERART_WIDTH = 123.0;
const float ADH_COVERART_HEIGHT = 176.0;
const float ADH_HORIZONTAL_GAP = 5.0;
const float ADH_LEFT_MARGIN = 5.0;
const float ADH_VERTICAL_GAP = 5.0;
//const float BUTTON_WIDTH = 200.0;
//const float BUTTON_HEIGHT = 55.0;
const float ADH_TITLELABEL_HEIGHT = 20.0;
//const float TITLEDISK_EDITION_HEIGHT = 30.0;
const float ADH_OTHER_LABEL_HEIGHT = 20.0;
//const float SYNOPSIS_LABEL_HEIGHT = 100.0;
const float ADH_SELF_HEIGHT = 185.0;
const float ADH_COVERART_LEFT_MARGIN = 0.0;
const float ADH_COVERART_TOP_MARGIN = 5.0;
//const float BGHEADERIMAGEVIEW_LEFT_MARGIN = 19.0; 
- (id)initWIthSearchResponse:(GNSearchResponse *)searchResponse forReview:(BOOL)flag
{
	CGRect newFrame = CGRectMake(5, 50, 320 - ADH_LEFT_MARGIN*2, ADH_SELF_HEIGHT);
    if ((self = [super initWithFrame:newFrame])) 
	{
		//UIColor *labelBGColor = [UIColor colorWithRed:224.0/255 green:229.0/255 blue:234.0/255 alpha:1];
		UIColor *labelBGColor = [UIColor clearColor];
		UIColor *labelTextColor = [UIColor blackColor];
		
		//UIImage *image = [UIImage imageWithData:searchResponse.coverArt.data];
		//show artist image in header view
		UIImage *image = nil;
		
		// Now artist Image is deprecated. Use contributorImage for that.
		GNImage *objGNImage = searchResponse.contributorImage;
		if(flag)
		{
			image = [UIImage imageWithData:searchResponse.coverArt.data];
		}
		else if(objGNImage != nil)
		{
			//image = [UIImage imageWithData:searchResponse.artistImage];
			image = [UIImage imageWithData:objGNImage.data];
		}
		if(image)
		{
			newFrame = CGRectMake(ADH_COVERART_LEFT_MARGIN, ADH_COVERART_TOP_MARGIN, ADH_COVERART_WIDTH, ADH_COVERART_HEIGHT);
			
			UIImageView *tempImageView = [[UIImageView alloc] initWithFrame:newFrame];
			tempImageView.contentMode = UIViewContentModeScaleAspectFit;
			self.coverArt = tempImageView;
			[self setCoverArtImage:image];
			newFrame = self.frame;
			newFrame.size.height = self.coverArt.frame.size.height + 2*ADH_COVERART_TOP_MARGIN;
			self.frame = newFrame;
			[tempImageView release];
		}
		else 
		{
			newFrame = self.frame;
			newFrame.size.height = (flag)? 120.0:0.0;
			self.frame = newFrame;
		}

		UITextAlignment alignment = UITextAlignmentLeft; 
		UILineBreakMode lineBreak = UILineBreakModeWordWrap;
		int noOfLines = 2;
		UIFont *font = [UIFont fontWithName:@"Verdana" size:14];
		
		float xPos = self.coverArt.frame.origin.x + self.coverArt.frame.size.width + ADH_HORIZONTAL_GAP;
		newFrame = CGRectMake(xPos, self.coverArt.frame.origin.y, 
							  self.frame.size.width - (xPos+ ADH_HORIZONTAL_GAP), 0);
		UILabel *tempLabel = nil;
		if(flag)
		{
			if(searchResponse.artist)
			{
				newFrame = CGRectMake(xPos, newFrame.origin.y+newFrame.size.height+3, 
									  self.frame.size.width - (xPos+ ADH_HORIZONTAL_GAP), ADH_OTHER_LABEL_HEIGHT);
				tempLabel = [[UILabel alloc] initWithFrame:newFrame];
				tempLabel.numberOfLines = noOfLines;
				tempLabel.lineBreakMode = lineBreak;
				tempLabel.font = font;
				tempLabel.textAlignment = alignment;
				tempLabel.backgroundColor = labelBGColor;
				tempLabel.textColor = labelTextColor;
				self.artistNameLabel = tempLabel;
				self.artistNameLabel.text = [NSString stringWithFormat:@"Artist: %@",searchResponse.artist];
				[tempLabel release];
			}
			if(searchResponse.artist)
			{
				newFrame = CGRectMake(xPos,newFrame.origin.y+newFrame.size.height+3, 
									  self.frame.size.width - (xPos+ ADH_HORIZONTAL_GAP), ADH_OTHER_LABEL_HEIGHT);
				tempLabel = [[UILabel alloc] initWithFrame:newFrame];
				tempLabel.numberOfLines = noOfLines;
				tempLabel.lineBreakMode = lineBreak;
				tempLabel.textAlignment = alignment;
				tempLabel.font = font;
				tempLabel.textColor = labelTextColor;
				tempLabel.backgroundColor = labelBGColor;
				tempLabel.text = [NSString stringWithFormat:@"Album: %@",searchResponse.albumTitle];
				self.albumNameLabel= tempLabel;
				[tempLabel release];
			}
			[self addSubview:self.albumNameLabel];
			[self addSubview:self.artistNameLabel];
		}
		
		[self addSubview:self.coverArt];
		
//		self.backgroundColor = [UIColor redColor];
//		self.albumNameLabel.backgroundColor = [UIColor blueColor];
//		self.artistNameLabel.backgroundColor = [UIColor purpleColor];
//		self.coverArt.backgroundColor = [UIColor orangeColor];
    }
    return self;
}

-(void)setCoverArtImage:(UIImage *)image
{
	self.coverArt.image = image;
	CGRect newFrame = [self newFrameForImageView:self.coverArt forImage:image];
	self.coverArt.frame = newFrame;
}

-(CGRect)newFrameForImageView:(UIImageView *)imageViewObj forImage:(UIImage *)imageObj
{
	float height_width_ratio = (imageObj.size.width>0 && imageObj.size.height>0)?imageObj.size.height/imageObj.size.width:1;
	float current_height_width_ratio = ADH_COVERART_HEIGHT/ADH_COVERART_WIDTH;
	float widthToSubtract = 0.0;
	float heightToSubtract = 0.0;
	CGRect newFrame = imageViewObj.frame;
	if(height_width_ratio<=current_height_width_ratio)
	{
		newFrame.size.height = roundf(height_width_ratio * imageViewObj.frame.size.width);
		heightToSubtract = imageViewObj.frame.size.height - newFrame.size.height;
	}
	else
	{
		newFrame.size.width = roundf(imageViewObj.frame.size.height/height_width_ratio);
		widthToSubtract = imageViewObj.frame.size.width - newFrame.size.width;
	}
//	newFrame.origin.x += widthToSubtract;
//	newFrame.origin.y += heightToSubtract;
	return newFrame;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code.
 }
 */

@end
