//
//  CoverArt.h
//  GN_Music_SDK_iOS
//
//  Copyright 2010 GraceNote. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Metadata;

@interface CoverArt :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * size;
@property (nonatomic, retain) NSString * mimeType;
@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) Metadata * metaData;

@end



