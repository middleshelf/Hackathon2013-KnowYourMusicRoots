//
//  MapAnnotation.m
//
//  Copyright 2010 GraceNote. All rights reserved.
//

#import "MapAnnotation.h"

@implementation MapAnnotation

@synthesize data = m_data;

- (void)dealloc 
{
	[self.data release];
	[super dealloc];
}
- (id)initWithAnnotationData:(AnnotationData *)newData
{
	if (self = [super init])
	{
		self.data=newData;
	}
	return self;
}

- (CLLocationCoordinate2D)coordinate
{
    return self.data.coordinate;
//	CLLocationCoordinate2D location;
//	location.latitude = 23.013354;
//	location.longitude = 72.517173;
//	return location;
}

- (NSString *)title
{
	if(self.data.title)
		return self.data.title;
	return @" -- ";
}

// optional
- (NSString *)subtitle
{
	if(self.data.subTitle)
		return self.data.subTitle;
	return @" -- ";
}
@end

