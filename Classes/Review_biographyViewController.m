    //
//  Review_biographyViewController.m
//  iOSMobileVideoSDK
//
//  Copyright Gracenote Inc. 2010. All rights reserved.
//

#import "Review_biographyViewController.h"
#import <GracenoteMusicID/GNSearchResponse.h>
#import "AlbumDetailHeaderView.h"
#import "GN_Music_SDK_iOSViewController.h"
@implementation Review_biographyViewController


@synthesize textView;
@synthesize isReview;
@synthesize isSampled;
@synthesize searchResponse;
@synthesize responseData = _responseData;

- (void)dealloc 
{
	self.searchResponse = nil;
	self.textView = nil;
    [super dealloc];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.textView = nil;
}

+(Review_biographyViewController *)Review_biographyViewControllerWithSearchResponse:(GNSearchResponse *)response
{
	Review_biographyViewController *controller = [[[Review_biographyViewController alloc] initWithNibName:@"Review_biographyViewController" 
																								   bundle:nil] autorelease];
	controller.searchResponse = response;
	return controller;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	AlbumDetailHeaderView *header = [[AlbumDetailHeaderView alloc] initWIthSearchResponse:self.searchResponse forReview:(self.isSampled||self.isReview)];
	[self.view addSubview:header];
	[header release];
	CGRect newFrame = self.textView.frame;
	float heightDiff = self.textView.frame.origin.y - (header.frame.origin.y + header.frame.size.height + 10);
	newFrame.origin.y = header.frame.origin.y + header.frame.size.height + 10;
	newFrame.size.height +=heightDiff + 20;
	self.textView.frame = newFrame;
	NSMutableString * detailString = [[[NSMutableString alloc] init]autorelease];
    
    //Insert image on screen
    //UIImageView *tempLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"text_roots.png"]] ;
    //[self.view addSubView:tempLogo];
    
	if(self.isReview)
	{
		NSArray *stringArray = self.searchResponse.albumReview;
		if (stringArray != nil) {
			for (NSObject * obj in stringArray)
			{
				[detailString appendFormat:@"%@\n",[obj description]];
			}
		}
		else 
		{
			//[detailString appendString:@"No album review available"];
		}
	}
    
    //////////////////////////
    // New Sampled Code Area//
    //////////////////////////
    else if(self.isSampled) {
		NSArray *stringArray = self.searchResponse.albumReview;
        NSString *queryTitle = [self.searchResponse.trackTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *queryArtist = [self.searchResponse.artist stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        
        // Building the URL to query the API to find what samples are in a song
        NSString *sampleURL = @"http://developer.echonest.com/api/v4/song/search?api_key=FILDTEOIK2HBORODV&format=json&results=1&artist=";
        sampleURL = [sampleURL stringByAppendingString:queryArtist];
        sampleURL = [sampleURL stringByAppendingString:@"&title="];
        sampleURL = [sampleURL stringByAppendingString:queryTitle];
        sampleURL = [sampleURL stringByAppendingString:@"&bucket=id:whosampled&limit=true&bucket=tracks"];
        
        NSLog(@"sampleURL: %@", sampleURL);
        
        // Call WhoSampled service
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:sampleURL]];
        [[NSURLConnection alloc] initWithRequest:request delegate:self];
       
        
        //Query WhoSampled to pull back artist and song names
        
        
        //Build UI
        
		if (stringArray != nil) {
			for (NSObject * obj in stringArray)
			{
				[detailString appendFormat:@"%@\n",[obj description]];
			}
		}
		else
		{
			[detailString appendString:@"No album review available"];
		}
	}
	else 
	{
		NSArray *stringArray = self.searchResponse.artistBiography;
		if (stringArray != nil) {
			for (NSObject * obj in stringArray)
			{
				[detailString appendFormat:@"%@\n",[obj description]];
			}
		}
		else 
		{
			[detailString appendString:@"No artist details available"];
		}
	}
	textView.text = detailString;
//	[NSThread detachNewThreadSelector:@selector(stopAnimating) toTarget:[(GN_Music_SDK_iOSViewController *)self.parentViewController indicator] withObject:nil];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    NSLog([NSString stringWithFormat:@"Connection failed: %@", [error description]]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[self.responseData length]);
    
    // convert to JSON
    NSError *myError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    if (res != nil){
        // extract specific value...
        NSArray *results = [res objectForKey:@"results"];
        
        for (NSDictionary *result in results) {
            NSString *message = [result objectForKey:@"Success"];
            NSLog(@"message: %@", message);
            
            if ([message isEqualToString:@"Success"]){
                NSString *track = (NSString*) [result objectForKey:@"id"];
                NSString *artist = (NSString*) [result objectForKey:@"artist_id"];
                NSLog(@"track: %@", track);
                NSLog(@"artist %@", artist);
                
            }
        }
    }
}


-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return (UIInterfaceOrientationPortrait == interfaceOrientation);
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


-(IBAction)done:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

@end
