//
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchByTrackIdOperation.h"

@class SearchByTextOperation;

@interface SearchByTextViewController : UIViewController <UITextFieldDelegate> {
  IBOutlet UITextField *m_artistField;
  IBOutlet UITextField *m_albumField;
  IBOutlet UITextField *m_trackField;
  SearchByTextOperation *m_searchByTextOperation;
	SearchByTrackIdOperation *m_searchByTrackIdOperation;
	
}

@property (nonatomic, retain) UITextField *artistField;
@property (nonatomic, retain) UITextField *albumField;
@property (nonatomic, retain) UITextField *trackField;
@property (nonatomic, retain) SearchByTextOperation *searchByTextOperation;
@property (nonatomic, retain) SearchByTrackIdOperation *searchByTrackIdOperation;

+ (SearchByTextViewController*) searchByTextViewController;

- (IBAction) okButtonAction;

- (IBAction) cancelButtonAction;

@end
