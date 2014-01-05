//
//  MapViewController.h
//  GN_Music_SDK_iOS
//
//  Copyright 2010 GraceNote. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController <MKMapViewDelegate>
{
	MKMapView *m_mapView;
	NSArray   *m_annotations;
	NSInteger  m_selectedIndex;
}

@property(nonatomic, retain) IBOutlet MKMapView *mapView;
@property(nonatomic, retain) NSArray *annotations;

- (id)initWithNibName:(NSString *)nibNameOrNil 
			   bundle:(NSBundle *)nibBundleOrNil
          historyData:(NSArray *)array
		selectedindex:(NSInteger)index;
-(NSArray *)annotationDataFromHistoryData:(NSArray *)array;
@end
