//
//  MapAnnotation.h
//
//  Copyright 2010 GraceNote. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "AnnotationData.h"

@interface MapAnnotation  : NSObject <MKAnnotation>
{
	AnnotationData *m_data;
}

@property(nonatomic, retain) AnnotationData *data;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithAnnotationData:(AnnotationData *)newData;
@end
