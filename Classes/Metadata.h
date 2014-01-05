//
//  Metadata.h
//  GN_Music_SDK_iOS
//
//  Copyright 2010 GraceNote. All rights reserved.
//

#import <CoreData/CoreData.h>

@class CoverArt;
@class History;

@interface Metadata :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * trackTitle;
@property (nonatomic, retain) NSString * genreId;
@property (nonatomic, retain) NSNumber * trackNumber;
@property (nonatomic, retain) NSString * trackTitleYomi;
@property (nonatomic, retain) NSNumber * albumTrackCount;
@property (nonatomic, retain) NSString * albumTitle;
@property (nonatomic, retain) NSString * albumTitleYomi;
@property (nonatomic, retain) NSString * artistBetsumei;
@property (nonatomic, retain) NSString * artistYomi;
@property (nonatomic, retain) NSString * albumId;
@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSString * genre;
@property (nonatomic, retain) CoverArt * coverArt;
@property (nonatomic, retain) History * history;

@end



