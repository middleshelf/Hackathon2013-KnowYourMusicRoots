//
//  GN_Music_SDK_iOS
//
//  Copyright Gracenote Inc. 2010. All rights reserved.
//

#import "GN_Music_SDK_iOSAppDelegate.h"
#import "GN_Music_SDK_iOSViewController.h"
#import "constant.h"
#import "History.h"

@implementation GN_Music_SDK_iOSAppDelegate

@synthesize window;
@synthesize viewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	[self getLastInsertedAuto_idFromUserDefaults];
    [self checkForHistoryDataLimit];
	return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[self storeLastInsertedAuto_idToUserDefaults];
    [self.viewController applicationDidEnterInBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	[self getLastInsertedAuto_idFromUserDefaults];
    [self.viewController applicationWillEnterInForeground];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[self storeLastInsertedAuto_idToUserDefaults];
}

- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}

static unsigned int lastInsertedAuto_id = 0;
+(unsigned int)getLastInsertedAuto_id
{
	return lastInsertedAuto_id;
}

+(void)setLastInsertedAuto_id:(unsigned int)newId
{
	lastInsertedAuto_id = newId;
}

-(void)getLastInsertedAuto_idFromUserDefaults
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSNumber *lastAuto_id = [userDefaults objectForKey:@"lastRecord"];
	if(!lastAuto_id)
	{
		[userDefaults setValue:[NSNumber numberWithUnsignedInt:1] forKey:@"lastRecord"];
		[userDefaults synchronize];
		lastInsertedAuto_id = 1;
	}
	else 
	{
		lastInsertedAuto_id = [lastAuto_id unsignedIntValue];
	}
}

-(void)storeLastInsertedAuto_idToUserDefaults
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setValue:[NSNumber numberWithUnsignedInt:lastInsertedAuto_id] forKey:@"lastRecord"];
	[userDefaults synchronize];
}

static NSManagedObjectContext *_managedObjectContext = nil;
+ (NSManagedObjectContext *)sharedContext 
{
	@synchronized(self) 
	{
		if (_managedObjectContext == nil)
		{
			NSPersistentStoreCoordinator *coordinator = [GN_Music_SDK_iOSAppDelegate sharedCoordinator];
			if (coordinator != nil) {
				_managedObjectContext = [[NSManagedObjectContext alloc] init];
				[_managedObjectContext setPersistentStoreCoordinator: coordinator];
			}
		}
	}
	return _managedObjectContext;
}

static NSManagedObjectModel *_managedObjectModel = nil;
+ (NSManagedObjectModel *)sharedManagedObjectModel 
{
	@synchronized(self) 
	{
		if (_managedObjectModel == nil)
		{
			_managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
		}
	}
    return _managedObjectModel;
}
static NSPersistentStoreCoordinator *_persistentStoreCoordinator = nil;
+ (NSPersistentStoreCoordinator *)sharedCoordinator 
{
	@synchronized(self) 
	{
		if (_persistentStoreCoordinator == nil)
		{
			NSString *storePath = [[GN_Music_SDK_iOSAppDelegate applicationDocumentsDirectory] stringByAppendingPathComponent: @"History.sqlite"];
			
			/*
			 Set up the store.
			 For the sake of illustration, provide a pre-populated default store.
			 */
			NSFileManager *fileManager = [NSFileManager defaultManager];
			// If the expected store(sqlite file) doesn't exist, copy the default store(sqlite file).
			if (![fileManager fileExistsAtPath:storePath]) {
				NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"History" ofType:@"sqlite"];
				if (defaultStorePath) {
					[fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
				}
			}
			
			NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
			
			NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];	
			_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [GN_Music_SDK_iOSAppDelegate sharedManagedObjectModel]];
			
			NSError *error;
			if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
				// Update to handle the error appropriately.
				NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
				exit(-1);  // Fail
			}
		}
	}
    return _persistentStoreCoordinator;
}

static NSString * docDirectory = nil;
+ (NSString *)applicationDocumentsDirectory
{
	if(docDirectory == nil)
	{
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		docDirectory = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
	}
    return docDirectory;
}

-(void)checkForHistoryDataLimit
{
    NSError *error = nil;
    
    NSManagedObjectContext *context = [GN_Music_SDK_iOSAppDelegate sharedContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription 
								   entityForName:@"History" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	NSSortDescriptor *dateSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"current_date" ascending:YES] autorelease];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:dateSortDescriptor]];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	if(error)
	{
		NSLog(@"Could not fetch objects to delete");
	}
	error = nil;
	if(fetchedObjects.count>CAP_LIMIT)
	{
		int noOfExtraObjects = (int32_t)fetchedObjects.count - CAP_LIMIT;
		for(int i =0;i<noOfExtraObjects;i++)
		{
			History *historyToDelete = (History *)[fetchedObjects objectAtIndex:i];
			[context deleteObject:historyToDelete];
		}
		[context save:&error];
		if(error)
		{
			NSLog(@"Could not save the context after deleting.");
		}
	}
	[fetchRequest release];
}

@end
