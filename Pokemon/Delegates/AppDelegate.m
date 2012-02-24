//
//  AppDelegate.m
//  Pokemon
//
//  Created by Kaijie Yu on 1/30/12.
//  Copyright (c) 2012 Kjuly. All rights reserved.
//

#import "AppDelegate.h"

#import "GlobalNotificationConstants.h"
#import "MainViewController.h"

#import <CoreLocation/CoreLocation.h>

#ifdef DEBUG
#import "GlobalConstants.h"
#import "Pokemon+DataController.h"
#endif


@interface AppDelegate ()

- (void)registerDefaultsFromSettingsBundle;

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (void)dealloc
{
  [_window release];
  [__managedObjectContext release];
  [__managedObjectModel release];
  [__persistentStoreCoordinator release];
  [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // User Preferences
  // If not exists, load keyValues from |Settings.bundle| to |NSUserDefaults|
  NSString * appVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"keyAboutAppVersion"];
  if (! appVersion) {
    NSLog(@"Register Defaults From Settings.bundle...");
    [self registerDefaultsFromSettingsBundle];
  }
  
  // Set View
  self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
  MainViewController * mainViewController = [[MainViewController alloc] init];
  self.window.rootViewController = mainViewController;
  [mainViewController release];
  [self.window makeKeyAndVisible];
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
  
  
  // Push Notification Register (for iOS 5.0's bug?)
  [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge
                                                                       |UIRemoteNotificationTypeAlert
                                                                       |UIRemoteNotificationTypeSound];
  
  // Deal with Local Notification if user received the local notification
  UILocalNotification * localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
  if (localNotification)
    [self application:application didReceiveLocalNotification:localNotification];
  application.applicationIconBadgeNumber = 0;
  
  
  // Create a location manager instance to determine if location services are enabled.
  if (! [CLLocationManager locationServicesEnabled]) {
    UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled. If you proceed, you will be asked to confirm whether location services should be reenabled." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [servicesDisabledAlert show];
    [servicesDisabledAlert release];
  }
  else {
    // Set value in User Preferences (its default value is NO)
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"keyAppSettingsLocationServices"];
    [[NSUserDefaults standardUserDefaults] synchronize];
  }
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  /*
   Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
   Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
   */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  /*
   Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
   If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
   */
  NSLog(@"Application entered background state...");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  /*
   Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
   */
  application.applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  /*
   Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
   */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Saves changes in the application's managed object context before the application terminates.
  [self saveContext];
}

- (void)saveContext
{
  NSError *error = nil;
  NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
  if (managedObjectContext != nil)
  {
    if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
    {
      /*
       Replace this implementation with code to handle the error appropriately.
       
       abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
       */
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
    } 
  }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
  if (__managedObjectContext != nil)
  {
    return __managedObjectContext;
  }
  
  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  if (coordinator != nil)
  {
    __managedObjectContext = [[NSManagedObjectContext alloc] init];
    [__managedObjectContext setPersistentStoreCoordinator:coordinator];
  }
  return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
  if (__managedObjectModel != nil)
  {
    return __managedObjectModel;
  }
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Pokemon" withExtension:@"momd"];
  __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
  if (__persistentStoreCoordinator != nil)
  {
    return __persistentStoreCoordinator;
  }
  
  NSURL * storeURL;
  
#ifdef DEBUG
  if (! kPupulateData) {
#endif

  // Generate Path for |Pokemon.sqlite| in Document
  NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString * documentsDirectory = [paths objectAtIndex:0];
  NSString * storePath = [documentsDirectory stringByAppendingPathComponent:@"Pokemon.sqlite3"];
  storeURL = [NSURL fileURLWithPath:storePath];
  
#ifdef DEBUG
  NSLog(@">>> storePath: %@ ---", storePath);
#endif
  // Put down default db if it doesn't exist
  NSFileManager * fileManager = [NSFileManager defaultManager];
  if (! [fileManager fileExistsAtPath:storePath]) {
#ifdef DEBUG
    NSLog(@">>> |Pokemon.sqlite3| does not exists, Copying it to Document from main bundle");
#endif
    NSString * defaultStorePath = [[NSBundle mainBundle] pathForResource:@"Pokemon" ofType:@"sqlite3"];
    if (defaultStorePath)
      [fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
  }
  
#ifdef DEBUG
  } else {
    // Just use the db generated
    storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Pokemon.sqlite3"];
  }
#endif
  
  NSError *error = nil;
  __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
  if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
  {
    /*
     Replace this implementation with code to handle the error appropriately.
     
     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
     
     Typical reasons for an error here include:
     * The persistent store is not accessible;
     * The schema for the persistent store is incompatible with current managed object model.
     Check the error message to determine what the actual problem was.
     
     
     If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
     
     If you encounter schema incompatibility errors during development, you can reduce their frequency by:
     * Simply deleting the existing store:
     [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
     
     * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
     [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
     
     Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
     
     */
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
  }    
  
  return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
  return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Notification

// Remote Notification
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
  NSLog(@"--- AppDelegate didReceiveRemoteNotification:");
}

// Local Notification
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
//  NSLog(@"--- AppDelegate didReceiveLocalNotification:");
  if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
    NSLog(@"Background to Foreground, Run App after User Pressed the button");
    NSLog(@"Notification's |userInfo|: %@", notification.userInfo);
    application.applicationIconBadgeNumber = 0;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kPMNPokemonAppeared
                                                        object:self
                                                      userInfo:notification.userInfo];
  }
  else NSLog(@"In Foreground, and receive a Local Notification");
}

#pragma mark - Private Methods

- (void)registerDefaultsFromSettingsBundle
{
  NSString * settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
  if(! settingsBundle) return;
  
  NSDictionary * settings = [[NSDictionary alloc] initWithContentsOfFile:
                             [settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
  NSArray * preferences = [[NSArray alloc] initWithArray:[settings objectForKey:@"PreferenceSpecifiers"]];
  [settings release];
  
  NSMutableDictionary * defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
  for(NSDictionary * prefSpecification in preferences) {
    NSString * key = [prefSpecification objectForKey:@"Key"];
    if(key && [prefSpecification objectForKey:@"DefaultValue"])
      [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
  }
  [preferences release];
  
  [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
  [defaultsToRegister release];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
