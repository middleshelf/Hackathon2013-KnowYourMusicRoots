//
//  SearchHistoryViewController.h
//  GN_Music_SDK_iOS
//
//  Copyright 2010 GraceNote. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SearchHistoryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	UITableView *m_historyTable;
	NSMutableArray *m_historyData;
	NSMutableArray *m_historyDataStatus;
}

@property (nonatomic, retain) NSMutableArray *historyData;
@property (nonatomic, retain) NSMutableArray *historyDataStatus;
@property (nonatomic, retain) IBOutlet UITableView *historyTable;

+ (SearchHistoryViewController*) searchHistoryViewController;
-(void)deleteRecordWithIndex:(NSInteger)index;
-(IBAction)done;
-(IBAction)editTable:(id)sender;
@end
