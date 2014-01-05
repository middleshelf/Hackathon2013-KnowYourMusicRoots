//
//  SizableImageCell.m
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2012. All rights reserved.
//
//

#import "SizableImageCell.h"

@implementation SizableImageCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    float desiredWidth = 50;
    
    float w=self.imageView.frame.size.width;
    if (w>desiredWidth) {
        float widthSub = w - desiredWidth;
        self.imageView.frame = CGRectMake(self.imageView.frame.origin.x-5,self.imageView.frame.origin.y-13,desiredWidth,self.imageView.frame.size.height);
        self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x-widthSub,self.textLabel.frame.origin.y,self.textLabel.frame.size.width+widthSub,self.textLabel.frame.size.height);
        self.detailTextLabel.frame = CGRectMake(self.detailTextLabel.frame.origin.x-widthSub,self.detailTextLabel.frame.origin.y,self.detailTextLabel.frame.size.width+widthSub,self.detailTextLabel.frame.size.height);
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
}

@end
