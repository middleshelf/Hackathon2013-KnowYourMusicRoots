//
//  SearchHistoryViewController.m
//  GN_Music_SDK_iOS
//
//  Copyright 2010 GraceNote. All rights reserved.
//

#import "SearchHistoryViewController.h"
#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>
#import "GN_Music_SDK_iOSAppDelegate.h"
#import "History.h"
#import "Metadata.h"
#import "CoverArt.h"
#import "MapViewController.h"
#import "SearchByOperation.h"
#import "constant.h"

@implementation SearchHistoryViewController

@synthesize historyData = m_historyData;
@synthesize historyTable = m_historyTable;
@synthesize historyDataStatus = m_historyDataStatus;

+ (SearchHistoryViewController*) searchHistoryViewController
{
	SearchHistoryViewController *obj = [[SearchHistoryViewController alloc] initWithNibName:@"SearchHistoryViewController" bundle:[NSBundle mainBundle]];
	[obj autorelease];
	return obj;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
	self.title = @"History";
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] 
								   initWithTitle:@"Done" style:UIBarButtonItemStyleBordered 
								   target:self action:@selector(done)];
	self.navigationItem.leftBarButtonItem = doneButton;
	[doneButton release];
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] 
								   initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered 
								   target:self action:@selector(editTable:)];
	self.navigationItem.rightBarButtonItem = editButton;
	[editButton release];
	NSError *error = nil;
	NSFetchRequest *fetchRequest;
	NSEntityDescription *entity;
	NSSortDescriptor *dateSortDescriptor;
	
	NSManagedObjectContext *context = [GN_Music_SDK_iOSAppDelegate sharedContext];
	fetchRequest = [[NSFetchRequest alloc] init];
	entity = [NSEntityDescription 
								   entityForName:@"History" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:nil];
	dateSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"current_date" ascending:NO] autorelease];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:dateSortDescriptor]];
	self.historyData = [[[context executeFetchRequest:fetchRequest error:&error] mutableCopy] autorelease];
	[fetchRequest release];
	if ([self.historyData count] == 0) 
	{
		if(error)
		{
			NSLog(@"%@",[error description]);
		}
	}
	else
	{
		self.historyDataStatus = [NSMutableArray arrayWithCapacity:self.historyData.count];
		for (int i=0; i<self.historyData.count; i++)
		{
			[self.historyDataStatus addObject:[NSNull null]];
		}
	}
}



 - (void)viewWillAppear:(BOOL)animated {
     if([self.historyData count] <= 0)
     {
         [self.historyTable setHidden:TRUE];
         // No data available.
         UILabel *lblMsg = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 300, 25)];
         [lblMsg setText:@"No Data Available"];
         [self.view addSubview:lblMsg];
         [lblMsg release];
     }
     else
     {
         [self.historyTable setHidden:FALSE];
     }
 [super viewWillAppear:animated];
 }


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.historyData.count;
}


- (UITableViewCell *) getCellContentView:(NSString *)cellIdentifier {
	
	
	CGRect artistLabelFrame = CGRectMake(10, 1, 290, 25);
	CGRect trackLabelFrame = CGRectMake(10, 40, 290, 25);
	CGRect albumLabelFrame = CGRectMake(10, 20, 290, 25);
	CGRect dateLabelFrame = CGRectMake(210, 1, 110, 25);	
	
	
	
	UILabel *lblTemp;
	
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];

    
	if ([cellIdentifier  isEqualToString: @"ImageCell"]) {
		
		CGRect coverArtImageFrame = CGRectMake(4, 5, 55, 55);
		artistLabelFrame = CGRectMake(63, 1, 230, 25);
		trackLabelFrame = CGRectMake(63, 40, 230, 25);
		albumLabelFrame = CGRectMake(63, 20, 230, 25);
		
		UIImageView *coverArtImageView = [[UIImageView alloc] initWithFrame:coverArtImageFrame];
		coverArtImageView.tag = 4;
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
	
	//Initialize Label with tag 3.
	lblTemp = [[UILabel alloc] initWithFrame:trackLabelFrame];
	lblTemp.tag = 3;
	lblTemp.font = [UIFont boldSystemFontOfSize:11];
	lblTemp.textColor = [UIColor grayColor];
	[cell.contentView addSubview:lblTemp];
	[lblTemp release];
	
	//Initialize Label with tag 5.
	lblTemp = [[UILabel alloc] initWithFrame:dateLabelFrame];
	lblTemp.tag = 5;
	lblTemp.font = [UIFont boldSystemFontOfSize:11];
	lblTemp.textColor = [UIColor grayColor];
	[cell.contentView addSubview:lblTemp];
	[lblTemp release];
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	return cell;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	History *history = [self.historyData objectAtIndex:indexPath.row];
	Metadata *metadata = history.metadata;
	BOOL recordCorrupted = NO;
	@try
	{
		if(metadata.coverArt != nil) {
			CellIdentifier = @"ImageCell";
		}else {
			CellIdentifier = @"Cell";
		}
	}
	@catch (NSException *exception) 
	{
		recordCorrupted = YES;
		CellIdentifier = @"Cell";
	}
	
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if(cell == nil)
		cell = [self getCellContentView:CellIdentifier];
	
	
	
	UILabel *lblArtist = (UILabel *)[cell viewWithTag:1];
	UILabel *lblAlbum = (UILabel *)[cell viewWithTag:2];
	UILabel *lblTrack = (UILabel *)[cell viewWithTag:3];
	UILabel *lblDate = (UILabel *)[cell viewWithTag:5];
	
	if(!recordCorrupted)
	{
		@try
		{
			if(metadata.coverArt != nil) 
			{
				UIImageView *coverArtImageView = (UIImageView*)[cell viewWithTag:4];
				[coverArtImageView.layer setMasksToBounds:YES];
				[coverArtImageView.layer setCornerRadius:8];
				
				CoverArt *coverArt = metadata.coverArt;
				UIImage *image = [UIImage imageWithData:coverArt.data];
				coverArtImageView.image = image;
			}
			else {
				cell.imageView.image = nil;
			}
		}
		@catch (NSException *exception) 
		{
			recordCorrupted = YES;
			NSLog(@"%@",[exception description]);
		}
	}
	[self.historyDataStatus replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:recordCorrupted]];
	if(recordCorrupted)
	{
		cell.textLabel.text = @"Unknown";
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}
	// Init the contents of the cell based on the search result object
	
	NSString *artist = metadata.artist;
	NSString *album = metadata.albumTitle;
	NSString *track = metadata.trackTitle;
    
	NSDate *savedGMTDate = history.current_date;
	NSDateFormatter *gmtDF = [[[NSDateFormatter alloc] init] autorelease];	
	[gmtDF setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
	[NSTimeZone resetSystemTimeZone]; //must reset or it will take cached TZ
	[gmtDF setTimeZone:[NSTimeZone systemTimeZone]];	
	NSString *dateStr = [gmtDF stringFromDate:savedGMTDate];
	
	NSRange range;
	range.location = 0;
	range.length = 16;
	NSString *date = [dateStr substringWithRange:range];
	if (artist == nil) {
		artist = @" -- ";
	}
	
	if (album == nil) {
		album = @" -- ";
	}
	
	if (track == nil) {
		track = @" -- ";
	}
	
	if (date == nil) {
		date = @" -- ";
	}
	
	lblArtist.text = artist;
	lblAlbum.text = album;
	lblTrack.text = track;
	lblDate.text = date;
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 65;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self deleteRecordWithIndex:[indexPath row]];
        //  Animate deletion
        NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
        [[self historyTable] deleteRowsAtIndexPaths:indexPaths
								   withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)deleteRecordWithIndex:(NSInteger)index
{
	NSError *error = nil;
	History *historyObject = [self.historyData objectAtIndex:index];
	NSManagedObjectContext *context = [GN_Music_SDK_iOSAppDelegate sharedContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription 
								   entityForName:@"History" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@" auto_id = %d",[historyObject.auto_id unsignedIntValue]];
	[fetchRequest setPredicate:predicate];
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	if ([fetchedObjects count] == 0) 
	{
		if(error)
		{
			NSLog(@"%@",[error description]);
		}
	}
	else
	{
		error = nil;
		[context deleteObject:[fetchedObjects objectAtIndex:0]];
		[context save:&error];
		if(error)
			NSLog(@"could not delete history at index: %ld",(long)index);
	}
	[self.historyData removeObjectAtIndex:index];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if([(NSNumber *)[self.historyDataStatus objectAtIndex:indexPath.row] boolValue])
		return;
	History *history = [self.historyData objectAtIndex:indexPath.row];
	NSComparisonResult result;
	result = [history.latitude compare:[NSNumber numberWithInt:0]]; 
	result = [history.longitude compare:[NSNumber numberWithInt:0]]; 
	if(result == NSOrderedSame)
	{
		UIAlertView *showErrAlert = [[UIAlertView alloc] initWithTitle:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] message:@"History saved when location was not available, could not render into a map." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[showErrAlert show];
		[showErrAlert release];
		return;
	}	
	
	MapViewController *mapController = [[MapViewController alloc] initWithNibName:@"MapViewController" 
																		   bundle:nil 
																	  historyData:self.historyData
                                                                    selectedindex:indexPath.row];
	[self.navigationController pushViewController:mapController animated:YES];
	[mapController release];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc 
{
	self.historyData = nil;
	self.historyTable = nil;
    [super dealloc];
}

-(IBAction)done
{
	if([self.historyTable isEditing])	//Delete All
	{
		NSError *error = nil;
		NSManagedObjectContext *context = [GN_Music_SDK_iOSAppDelegate sharedContext];
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription 
									   entityForName:@"History" inManagedObjectContext:context];
		[fetchRequest setEntity:entity];
		NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
		[fetchRequest release];
		if ([fetchedObjects count] == 0) 
		{
			if(error)
			{
				NSLog(@"%@",[error description]);
			}
		}
		else
		{
			error = nil;
			for (NSManagedObject *mobject in fetchedObjects)
			{
				[context deleteObject:mobject];
			}
			[context save:&error];
			if(error)
				NSLog(@"%@",[error description]);
			else
			{
				[self.historyData removeAllObjects];
				[self.historyTable reloadData];
			}
		}
	}
	else	//Done
	{
	
        [self dismissModalViewControllerAnimated:YES];
	}
	
}

-(IBAction)editTable:(id)sender
{
	UIBarButtonItem *barItem = (UIBarButtonItem*) sender;
	if([self.historyTable isEditing])
	{
		[self.historyTable setEditing:NO animated:YES];
		barItem.title = @"Edit";
		self.navigationItem.leftBarButtonItem.title = @"Done";
	}
	else
	{
		[self.historyTable setEditing:YES animated:YES];
		barItem.title = @"Cancel";
		self.navigationItem.leftBarButtonItem.title = @"Delete All";
	}
}
@end
