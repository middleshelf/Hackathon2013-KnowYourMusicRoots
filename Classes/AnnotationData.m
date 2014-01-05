//
//  AnnotationData.m
//  GN_Music_SDK_iOS
//
//  Copyright 2010 GraceNote. All rights reserved.
//

#import "AnnotationData.h"
#import "Metadata.h"


@implementation AnnotationData

@synthesize title = m_title;
@synthesize subTitle = m_subTitle;
@synthesize coordinate = m_coordinate;

- (id) initWithHistoryData:(History *)history
{
	self = [super init];
	if (self != nil) 
	{
		self.title = history.metadata.albumTitle;
		self.subTitle = history.metadata.artist;
		m_coordinate.latitude = [history.latitude doubleValue];
		m_coordinate.longitude = [history.longitude doubleValue];
	}
	return self;
}

@end
