//
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2010. All rights reserved.
//

#import "SearchByLyricFragmentViewController.h"

#import "SearchByLyricFragmentOperation.h"

@implementation SearchByLyricFragmentViewController

@synthesize artistField = m_artistField;
@synthesize lyricFagmentField = m_lyricFagmentField;
@synthesize searchByLyricFragmentOperation = m_searchByLyricFragmentOperation;

- (void)dealloc {
  self.artistField = nil;
  self.lyricFagmentField = nil;
  self.searchByLyricFragmentOperation = nil;
  [super dealloc];
}


+ (SearchByLyricFragmentViewController*) searchByLyricFragmentViewController
{
  SearchByLyricFragmentViewController *obj = [[SearchByLyricFragmentViewController alloc] initWithNibName:@"SearchByLyricFragmentViewController" bundle:nil];
  [obj autorelease];
  return obj;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];
  
  NSAssert(self.artistField, @"artistField not set in NIB");
  NSAssert(self.lyricFagmentField, @"lyricFagmentField not set in NIB");
  
  self.artistField.delegate = self;
  self.lyricFagmentField.delegate = self;
}

- (void) removeDelegates {
  self.artistField.delegate = nil;
  self.lyricFagmentField.delegate = nil;
}

- (IBAction) okButtonAction
{
  // Fill in data entered into the text fields
  NSAssert(self.searchByLyricFragmentOperation, @"searchByLyricFragmentOperation");
  self.searchByLyricFragmentOperation.artist = self.artistField.text;
  self.searchByLyricFragmentOperation.lyricFragment = self.lyricFagmentField.text;
  
  // Put away the dialog
  [self removeDelegates];
  [self dismissModalViewControllerAnimated:YES];
  
  // Kick off the operation  
  [self.searchByLyricFragmentOperation startOperation];
}

- (IBAction) cancelButtonAction
{
  [self removeDelegates];
  [self dismissModalViewControllerAnimated:YES];
}

// Invoked via "Done" in text edit window

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
  [theTextField resignFirstResponder];
  return YES;
}

@end
