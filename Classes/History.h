//
//  History.h
//  GN_Music_SDK_iOS
//
//  Copyright 2010 GraceNote. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Metadata;

@interface History :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * fingerprint;
@property (nonatomic, retain) NSDate * current_date;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * auto_id;
@property (nonatomic, retain) Metadata * metadata;

@end



