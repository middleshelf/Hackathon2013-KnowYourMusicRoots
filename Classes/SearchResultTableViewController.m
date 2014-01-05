//
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2010. All rights reserved.
//

#import "SearchResultTableViewController.h"

#import <GracenoteMusicID/GNSearchResponse.h>
#import <GracenoteMusicID/GNCoverArt.h>
#import <QuartzCore/QuartzCore.h>
#import "Review_biographyViewController.h"
#import "GN_Music_SDK_iOSViewController.h"
#import "ImgRecord.h"
#import "SizableImageCell.h"

@interface SearchResultTableViewController ()

- (void)startIconDownload:(ImgRecord *)appRecord forIndexPath:(NSIndexPath *)indexPath;

@end

@implementation SearchResultTableViewController

@synthesize tableView = m_tableView;
@synthesize results = m_results;
@synthesize searchByTrackIdOperation = m_searchByTrackIdOperation;
@synthesize parentController = m_parentController;
@synthesize aryOfImageView;
@synthesize imageDownloadsInProgress;

- (void)dealloc {
	self.parentController = nil;
	self.tableView = nil;
	self.results = nil;
    self.aryOfImageView = nil;
	[super dealloc];
}

+ (SearchResultTableViewController*) searchResultTableViewController
{
	SearchResultTableViewController *obj = [[SearchResultTableViewController alloc] initWithNibName:@"SearchResultTableViewController" bundle:nil];
	[obj autorelease];
	obj.tableView = (UITableView*) obj.view;
    
    //Setting the background image
    obj.tableView.backgroundView = nil;
    obj.tableView.backgroundView = [[[UIView alloc] init] autorelease];
    //obj.tableView.backgroundColor = [UIColor redColor];
    UIImage *pattern = [UIImage imageNamed:@"background.png"];
    
    //Attempt to scale image
    //UIImageView *imageView = [[UIImageView alloc] initWithImage:pattern];
    //imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    obj.tableView.backgroundColor = [UIColor colorWithPatternImage:pattern];
    
    //Remove the cell lines
    obj.tableView.separatorColor = [UIColor clearColor];
    
	NSAssert(obj.tableView, @"tableView");
	return obj;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	NSAssert(self.view, @"view not set in NIB");
	self.results = [NSMutableArray array];
    self.aryOfImageView = [NSMutableArray array];
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
	NSAssert(self.results, @"results");
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	GN_Music_SDK_iOSViewController *controller = (GN_Music_SDK_iOSViewController *)self.parentController;
	if(controller.currentSearchType == SearchTypeNone || controller.currentSearchType == SearchTypeText || controller.currentSearchType == SearchTypeLyricFragment){

		showBioReview = NO;
    }
    else{

        showBioReview = YES;
    }
	return [self.results count];
}

- (UITableViewCell *) getCellContentView:(NSString *)cellIdentifier {
	
	
	CGRect artistLabelFrame = CGRectMake(10, 1, 290, 25);
	CGRect trackLabelFrame = CGRectMake(10, 40, 290, 25);
	CGRect albumLabelFrame = CGRectMake(10, 20, 290, 25);
	//CGRect bioButtonFrame = CGRectMake(10, 65, 60, 25);
	CGRect bioButtonFrame = CGRectMake(10, 65, 110, 25);
	//CGRect reviewButtonFrame = CGRectMake(90, 65, 60, 25);
	CGRect reviewButtonFrame = CGRectMake(140, 65, 70, 25);
    CGRect sampledButtonFrame = CGRectMake(240, 65, 70, 25);
	
	UILabel *lblTemp;
	
    
    UITableViewCell *cell = [[[SizableImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
	
	if ([cellIdentifier isEqualToString: @"ImageCell"]) {
		
		CGRect coverArtImageFrame = CGRectMake(5, 5, 55, 55);
		artistLabelFrame = CGRectMake(63, 1, 230, 25);
		trackLabelFrame = CGRectMake(63, 40, 230, 25);
		albumLabelFrame = CGRectMake(63, 20, 230, 25);
		
		UIImageView *coverArtImageView = [[UIImageView alloc] initWithFrame:coverArtImageFrame];
		//coverArtImageView.tag = 4;
        coverArtImageView.contentMode = UIViewContentModeScaleToFill;
		[cell.contentView addSubview:coverArtImageView];
      	[coverArtImageView release];
        
	}
    

	
	//Initialize Label with tag 1.
	lblTemp = [[UILabel alloc] initWithFrame:artistLabelFrame];
	lblTemp.font = [UIFont boldSystemFontOfSize:12];
	lblTemp.tag = 1;
	[cell.contentView addSubview:lblTemp];
	[lblTemp release];
	
	//Initialize Label with tag 2.
	lblTemp = [[UILabel alloc] initWithFrame:albumLabelFrame];
	lblTemp.tag = 2;
	lblTemp.font = [UIFont boldSystemFontOfSize:11];
	lblTemp.textColor = [UIColor grayColor];
	[cell.contentView addSubview:lblTemp];
	[lblTemp release];
	
	//Initialize Label with tag 2.
	lblTemp = [[UILabel alloc] initWithFrame:trackLabelFrame];
	lblTemp.tag = 3;
	lblTemp.font = [UIFont boldSystemFontOfSize:11];
	lblTemp.textColor = [UIColor grayColor];
	[cell.contentView addSubview:lblTemp];
	[lblTemp release];
	
    if(showBioReview)
    {

        [[cell.contentView viewWithTag:5] setHidden:FALSE];
        [[cell.contentView viewWithTag:6] setHidden:FALSE];
    }
    else
    {

        [[cell.contentView viewWithTag:5] setHidden:TRUE];
        [[cell.contentView viewWithTag:6] setHidden:TRUE];
    }
    
	
	
	//Initialize Bio Button with tag 5.
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.frame = bioButtonFrame;
	button.tag = 5;
	//[button setTitle:@"Bio" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:153.0/255.0 green:204.0/255.0 blue:51.0/255.0 alpha:1.0] forState:UIControlStateNormal];
	[button setTitle:@"Artist Details" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(showBiography:) forControlEvents:UIControlEventTouchUpInside];
	[cell.contentView addSubview:button];
	
	//Initialize Review Button with tag 6.
	button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.frame = reviewButtonFrame;
	button.tag = 6;
    [button setTitleColor:[UIColor colorWithRed:153.0/255.0 green:204.0/255.0 blue:51.0/255.0 alpha:1.0] forState:UIControlStateNormal];
	[button setTitle:@"Roots" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(showReview:) forControlEvents:UIControlEventTouchUpInside];
	[cell.contentView addSubview:button];
    
    
    //Initialize Sampled? Button with tag 7.
	button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.frame = sampledButtonFrame;
	button.tag = 7;
    [button setTitleColor:[UIColor colorWithRed:153.0/255.0 green:204.0/255.0 blue:51.0/255.0 alpha:1.0] forState:UIControlStateNormal];
	[button setTitle:@"Review" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(showSampled:) forControlEvents:UIControlEventTouchUpInside];
	[cell.contentView addSubview:button];
	
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
   
	static NSString *CellIdentifier = @"Cell";
	
	GNSearchResponse *response = [self.results objectAtIndex:indexPath.row];
	
    CellIdentifier = @"ImageCell";
    
	if(response.coverArt != nil) {
		CellIdentifier = @"ImageCell";
	}else {
		CellIdentifier = @"Cell";
	}

	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if(cell == nil) {

		cell = [self getCellContentView:CellIdentifier];

	}
    
	UILabel *lblArtist = (UILabel *)[cell viewWithTag:1];
	UILabel *lblAlbum = (UILabel *)[cell viewWithTag:2];
	UILabel *lblTrack = (UILabel *)[cell viewWithTag:3];
	
  
    if([self.aryOfImageView count]>0)
    {
             
        
        ImgRecord *objImgRecord = [self.aryOfImageView objectAtIndex:indexPath.row];
        
        if([objImgRecord.strImageURL isEqualToString:@""] || objImgRecord.strImageURL == nil)
        {
            
        }
        else
        {
            if(!objImgRecord.imgIcon)
            {
                
                /*if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
                {
                    [self startIconDownload:objImgRecord forIndexPath:indexPath];
                }
                if([objImgRecord.strImageURL isEqualToString:@""] || objImgRecord.strImageURL == nil)
                {
                    cell.imageView.image = [UIImage imageNamed:@"no_Loading.png"];                
                }
                else
                {
                    cell.imageView.image = [UIImage imageNamed:@"loading.png"];                
                }*/
                if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
                {
                    [self startIconDownload:objImgRecord forIndexPath:indexPath];
                }
               /* if([objImgRecord.strImageURL isEqualToString:@""] || objImgRecord.strImageURL == nil)
                {
                    cell.imageView.image = [UIImage imageNamed:@"no_Loading.png"];                
                }
                else
                {*/
                    cell.imageView.image = [UIImage imageNamed:@"loading.png"];                
               // }
                
            }
            else
            {
                cell.imageView.image = objImgRecord.imgIcon;
            }
        }
        
    }
    

    
    if(showBioReview)
    {

        cell.imageView.hidden=FALSE;
        [[cell.contentView viewWithTag:5] setHidden:FALSE];
        [[cell.contentView viewWithTag:6] setHidden:FALSE];
    }
    else
    {

        cell.imageView.hidden=TRUE;
        [[cell.contentView viewWithTag:5] setHidden:TRUE];
        [[cell.contentView viewWithTag:6] setHidden:TRUE];
        
    }
   
   		
	// Init the contents of the cell based on the search result object
	
	NSString *artist = response.artist;
	NSString *album = response.albumTitle;
	NSString *track = response.trackTitle;
	
	if (artist == nil) {
		artist = @" -- ";
	}
	
	if (album == nil) {
		album = @" -- ";
	}
	
	if (track == nil) {
		track = @" -- ";
	}
	
	lblArtist.text = artist;
	lblAlbum.text = album;
	lblTrack.text = track;
	
	return cell;
}


#pragma mark -
#pragma mark Table cell image support

- (void)startIconDownload:(ImgRecord *)appRecord forIndexPath:(NSIndexPath *)indexPath
{

    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil) 
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.appRecord = appRecord;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
        [iconDownloader release];   
    }
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    if ([self.aryOfImageView count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            ImgRecord *appRecord = [self.aryOfImageView objectAtIndex:indexPath.row];
            
            if (!appRecord.imgIcon) // avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:appRecord forIndexPath:indexPath];
            }
        }
    }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        
//        [cell.imageView setContentMode:UIViewContentModeScaleToFill];
//        [cell.imageView setFrame:CGRectMake(5,5,55,55)];
        
        // Display the newly loaded image
        cell.imageView.image = iconDownloader.appRecord.imgIcon;
    }
}




#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	GNSearchResponse *response = [self.results objectAtIndex:indexPath.row];
	if ([response.trackId isEqualToString:@"(null)"] || response.trackId == nil || [response.trackId isEqualToString:@""]) {
		return;
	}
	[self startFetchByTrackIdOperation:response.trackId];
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	if(!showBioReview)
		return 65;
	return 95;
}

-(void)startFetchByTrackIdOperation:(NSString*)trackId
{
	self.searchByTrackIdOperation.trackId = trackId;
	
	[self.searchByTrackIdOperation startOperation];
}

-(void)showBiography:(id)sender
{
	[NSThread detachNewThreadSelector:@selector(startAnimating) toTarget:[(GN_Music_SDK_iOSViewController *)self.parentController indicator] withObject:nil];
	[self performSelector:@selector(showBio_Review:) withObject:sender afterDelay:0.1];
}

-(void)showReview:(id)sender
{
	[NSThread detachNewThreadSelector:@selector(startAnimating) toTarget:[(GN_Music_SDK_iOSViewController *)self.parentController indicator] withObject:nil];
	[self performSelector:@selector(showBio_Review:) withObject:sender afterDelay:0.1];
}

-(void)showBio_Review:(UIButton *)selectedBtn
{
	UITableView *tableViewObj = (UITableView *)self.view;
	NSIndexPath *indexPath = [tableViewObj indexPathForCell:(UITableViewCell *)[(UIView *)[selectedBtn superview] superview]];
	Review_biographyViewController *controller = [Review_biographyViewController Review_biographyViewControllerWithSearchResponse:[self.results objectAtIndex:indexPath.row]];
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve; 
	controller.isReview = NO;
	if(selectedBtn.tag ==6)
		controller.isReview = YES;
    if(selectedBtn.tag ==7)
        controller.isSampled = YES;
	[self.parentController presentModalViewController:controller animated:YES];
    [[(GN_Music_SDK_iOSViewController*) self.parentController indicator] stopAnimating];
}

-(void)showSampled:(id)sender
{
	[NSThread detachNewThreadSelector:@selector(startAnimating) toTarget:[(GN_Music_SDK_iOSViewController *)self.parentController indicator] withObject:nil];
	[self performSelector:@selector(showBio_Review:) withObject:sender afterDelay:0.1];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // terminate all pending download connections
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
}

@end
