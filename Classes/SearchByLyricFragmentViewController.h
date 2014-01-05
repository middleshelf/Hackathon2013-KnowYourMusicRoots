//
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchByLyricFragmentOperation;

@interface SearchByLyricFragmentViewController : UIViewController <UITextFieldDelegate> {
  IBOutlet UITextField *m_artistField;
  IBOutlet UITextField *m_lyricFagmentField;
  SearchByLyricFragmentOperation *m_searchByLyricFragmentOperation;
}

@property (nonatomic, retain) UITextField *artistField;
@property (nonatomic, retain) UITextField *lyricFagmentField;
@property (nonatomic, retain) SearchByLyricFragmentOperation *searchByLyricFragmentOperation;

+ (SearchByLyricFragmentViewController*) searchByLyricFragmentViewController;

- (IBAction) okButtonAction;

- (IBAction) cancelButtonAction;

@end
