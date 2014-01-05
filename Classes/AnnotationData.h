//
//  AnnotationData.h
//  GN_Music_SDK_iOS
//
//  Copyright 2010 GraceNote. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "History.h"

@interface AnnotationData : NSObject 
{
	NSString *m_title;
	NSString *m_subTitle;
	CLLocationCoordinate2D m_coordinate;
}

@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *subTitle;
@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id) initWithHistoryData:(History *)history;
@end
