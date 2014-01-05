//
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2010. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GracenoteMusicID/GNSearchResultReady.h>

@class GNConfig;

@interface LookupFingerprintOperation : NSObject <GNSearchResultReady> {
  UITextView *m_textView;
}

@property (nonatomic, retain) UITextView *textView;

+ (LookupFingerprintOperation*) lookupFingerprintOperation:(UITextView*)textView;

- (NSString*) loadFingerprint;

@end
