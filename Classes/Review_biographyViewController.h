//
//  Review_biographyViewController.h
//  iOSMobileVideoSDK
//
//  Copyright Gracenote Inc. 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GNSearchResponse;
@interface Review_biographyViewController : UIViewController 
{
	UITextView *textView;
	GNSearchResponse *searchResponse;
	BOOL isReview;
}

+(Review_biographyViewController *)Review_biographyViewControllerWithSearchResponse:(GNSearchResponse *)response;

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;

@property(nonatomic, retain) IBOutlet UITextView *textView;
@property(nonatomic, retain) GNSearchResponse *searchResponse;
@property(nonatomic) BOOL isReview;
@property(nonatomic) BOOL isSampled;
@property(nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, retain) UIView *tempLogo;

-(IBAction)done:(id)sender;

@end
