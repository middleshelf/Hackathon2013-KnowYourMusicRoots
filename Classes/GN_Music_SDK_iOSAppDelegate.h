//
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2010. All rights reserved.
// latest

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class GN_Music_SDK_iOSViewController;

@interface GN_Music_SDK_iOSAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    GN_Music_SDK_iOSViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet GN_Music_SDK_iOSViewController *viewController;

+ (NSManagedObjectContext *)sharedContext;
+ (NSManagedObjectModel *)sharedManagedObjectModel;
+ (NSPersistentStoreCoordinator *)sharedCoordinator;
+ (NSString *)applicationDocumentsDirectory;

+(unsigned int)getLastInsertedAuto_id;
+(void)setLastInsertedAuto_id:(unsigned int)newId;
-(void)getLastInsertedAuto_idFromUserDefaults;
-(void)storeLastInsertedAuto_idToUserDefaults;
-(void)checkForHistoryDataLimit;
@end

