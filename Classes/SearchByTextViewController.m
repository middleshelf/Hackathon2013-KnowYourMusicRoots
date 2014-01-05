//
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2010. All rights reserved.
//

#import "SearchByTextViewController.h"
#import "SearchByTextOperation.h"

@implementation SearchByTextViewController

@synthesize artistField = m_artistField;
@synthesize albumField = m_albumField;
@synthesize trackField = m_trackField;
@synthesize searchByTextOperation = m_searchByTextOperation;
@synthesize searchByTrackIdOperation = m_searchByTrackIdOperation;

- (void)dealloc {
  self.artistField = nil;
  self.albumField = nil;
  self.trackField = nil;
  self.searchByTextOperation = nil;
	self.searchByTrackIdOperation = nil;
  [super dealloc];
}

+ (SearchByTextViewController*) searchByTextViewController
{
  SearchByTextViewController *obj = [[SearchByTextViewController alloc] initWithNibName:@"SearchByTextViewController" bundle:nil];
  [obj autorelease];
  return obj;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  NSAssert(self.artistField, @"artistField not set in NIB");
  NSAssert(self.albumField, @"albumField not set in NIB");
  NSAssert(self.trackField, @"trackField not set in NIB");
  
  self.artistField.delegate = self;
  self.albumField.delegate = self;
  self.trackField.delegate = self;
  
  return;
}

- (void) removeDelegates {
  self.artistField.delegate = nil;
  self.albumField.delegate = nil;
  self.trackField.delegate = nil;
}

- (IBAction) okButtonAction
{
  // Fill in data entered into the text fields
  NSAssert(self.searchByTextOperation, @"searchByTextOperation");
  self.searchByTextOperation.artist = self.artistField.text;
  self.searchByTextOperation.album = self.albumField.text;
  self.searchByTextOperation.track = self.trackField.text;
  
  // Put away the dialog
  [self removeDelegates];
    [self dismissModalViewControllerAnimated:YES];
    
  // Kick off the operation
  [self.searchByTextOperation startOperation];
  
  return;
}

- (IBAction) cancelButtonAction
{
  [self removeDelegates];
  [self dismissModalViewControllerAnimated:YES];
  return;
}

// Invoked via "Done" in text edit window

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
  [theTextField resignFirstResponder];
  return YES;
}

@end
