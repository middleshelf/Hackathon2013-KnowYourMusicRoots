//
//  MapViewController.m
//  GN_Music_SDK_iOS
//
//  Copyright 2010 GraceNote. All rights reserved.
//

#import "MapViewController.h"
#import "MapAnnotation.h"
#import "AnnotationData.h"
#import "History.h"

#define RANGE	3.0

@implementation MapViewController

@synthesize mapView = m_mapView;
@synthesize annotations = m_annotations;

- (void)dealloc 
{
	self.mapView = nil;
	self.annotations = nil;
    [super dealloc];
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
	self.mapView = nil;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil 
			   bundle:(NSBundle *)nibBundleOrNil
          historyData:(NSArray *)array
		selectedindex:(NSInteger)index
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
	{
		m_selectedIndex = index;
		self.annotations = [self annotationDataFromHistoryData:array];
    }
    return self;
}

-(NSArray *)annotationDataFromHistoryData:(NSArray *)array
{
	NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:array.count];
	for (History *history in array)
	{
		AnnotationData *data = [[AnnotationData alloc] initWithHistoryData:history];
		MapAnnotation *annotation = [[MapAnnotation alloc] initWithAnnotationData:data];
		[mutableArray addObject:annotation];
		[data release];
		[annotation release];
	}
	return [[mutableArray copy] autorelease];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	self.mapView.showsUserLocation=NO;
	self.mapView.mapType=MKMapTypeStandard;
	self.mapView.delegate = self;
	MKCoordinateRegion newRegion;
	MapAnnotation *annotation = [self.annotations objectAtIndex:m_selectedIndex];
	newRegion.center = annotation.coordinate;
	newRegion.span.latitudeDelta = (RANGE*2)/60.0;	// For Miles
	newRegion.span.longitudeDelta = ((RANGE*2)/60.0) *(cos(newRegion.span.latitudeDelta));	// For Miles
	self.mapView.region = newRegion;
	[self.mapView addAnnotations:self.annotations];
}

#pragma mark -
#pragma mark MKMapViewDelegate Methods

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
	MapAnnotation *annotation = [self.annotations objectAtIndex:m_selectedIndex];
	[self.mapView selectAnnotation:annotation animated:YES];
}
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
	
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	
}

-(MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MapAnnotation class]])
    {
        // try to dequeue an existing pin view first
        static NSString* annotationIdentifier = @"annotationIdentifier";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)
		[self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        if (!pinView)
        {
            // if an existing pin view was not available, create one
            MKPinAnnotationView* customPinView = [[[MKPinAnnotationView alloc]
												   initWithAnnotation:annotation reuseIdentifier:annotationIdentifier] autorelease];
            customPinView.pinColor = MKPinAnnotationColorRed;
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
			
            return customPinView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    }
	return nil;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


@end
