//
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchByTrackIdOperation.h"
//@class SearchByTrackIdOperation;
#import "IconDownloader.h"

@interface SearchResultTableViewController : UITableViewController <IconDownloaderDelegate>{
  UITableView *m_tableView;
  NSMutableArray *m_results;
	SearchByTrackIdOperation *m_searchByTrackIdOperation;
	UIViewController *m_parentController;
	BOOL showBioReview;
    NSMutableArray *aryOfImageView;
    NSMutableDictionary *imageDownloadsInProgress;

}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *results;
@property (nonatomic, retain) SearchByTrackIdOperation *searchByTrackIdOperation;
@property (nonatomic, assign) UIViewController *parentController;
@property (nonatomic, retain) NSMutableArray *aryOfImageView;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;

- (void)appImageDidLoad:(NSIndexPath *)indexPath;

+ (SearchResultTableViewController*) searchResultTableViewController;
-(void)startFetchByTrackIdOperation:(NSString*)trackId;
-(void)showBiography:(id)sender;
-(void)showReview:(id)sender;
-(void)showSampled:(id)sender;

@end
