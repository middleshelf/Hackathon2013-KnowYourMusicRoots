//
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2010. All rights reserved.
//

#import "LookupFingerprintOperation.h"

#import <GracenoteMusicID/GNUtil.h>
#import <GracenoteMusicID/GNSearchResult.h>
#import <GracenoteMusicID/GNSearchResponse.h>
#import <GracenoteMusicID/GNOperations.h>

@implementation LookupFingerprintOperation

@synthesize textView = m_textView;

- (void) dealloc {
  self.textView = nil;
  [super dealloc];
}

+ (LookupFingerprintOperation*) lookupFingerprintOperation:(UITextView*)textView
{
  NSAssert(textView, @"textView");
  LookupFingerprintOperation *obj = [[LookupFingerprintOperation alloc] init];
  obj.textView = textView;
  [obj autorelease];
  return obj;
}

- (NSString*) loadFingerprint
{
  NSString *resPath = [[NSBundle mainBundle] pathForResource:@"Dido_MyLoversGone_Fingerprint_MIDStream.xml" ofType:nil];
  NSAssert(resPath, @"can't find resource");
  NSString *fingerprintXML = [GNUtil readUTF8:resPath];
  return fingerprintXML;
}

// Invoked by SDK when search has completed and result is ready

- (void) GNResultReady:(GNSearchResult*)result
{
  NSString *currentContents = self.textView.text;
  
  NSMutableString *mstr = [NSMutableString stringWithString:currentContents];
  [mstr appendString:@"\n"];
  [mstr appendString:@"LookupFingerprintOperation:\n"];
  
  if ([result isFailure]) {
    [mstr appendFormat:@"[%d] %@", result.errCode, result.errMessage];
  } else {
    if ([result isAnySearchNoMatchStatus]) {
      [mstr appendString:@"NO_MATCH\n"];
    } else {
      GNSearchResponse *best = [result bestResponse];
      
      [mstr appendFormat:@"Artist: %@", best.artist];
      if (best.artistYomi != nil) {
        [mstr appendFormat:@"  (%@)\n", best.artistYomi];
      } else {
        [mstr appendString:@"\n"];
      }
      
      [mstr appendFormat:@"Album: %@", best.albumTitle];
      if (best.albumTitleYomi != nil) {
        [mstr appendFormat:@"  (%@)\n", best.albumTitleYomi];
      } else {
        [mstr appendString:@"\n"];
      }
      
      [mstr appendFormat:@"Track: %@", best.trackTitle];
      if (best.trackTitleYomi != nil) {
        [mstr appendFormat:@"  (%@)\n", best.trackTitleYomi];
      } else {
        [mstr appendString:@"\n"];
      }
      
      if (best.coverArt != nil) {
        [mstr appendFormat:@"%@\n", [best.coverArt description]];
      } 
    }
  }
  
  self.textView.text = mstr;
  
  return;
}

@end
