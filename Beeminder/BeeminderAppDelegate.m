//
//  BeeminderAppDelegate.m
//  Beeminder
//
//  Created by Andy Brett on 6/17/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "BeeminderAppDelegate.h"
#import <CoreData/CoreData.h>
#import "CoreData+MagicalRecord.h"
#import "NSString+Base64.h"

@implementation BeeminderAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

NSString *const FBSessionStateChangedNotification =
@"com.beeminder.beeminder:FBSessionStateChangedNotification";

+ (UIButton *)standardGrayButtonWith:(UIButton *)button
{
    button.backgroundColor = [BeeminderAppDelegate grayButtonColor];
    [button.layer setBorderWidth:1.0f];
    [button.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    button.layer.cornerRadius = 5.0f;

    [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    return button;
}

+ (UIColor *)grayButtonColor
{
    return [UIColor colorWithRed:184.0f/255.0 green:184.0f/255.0 blue:184.0f/255.0 alpha:1.0];
}

- (Goal *)sessionGoal
{
    if (!_sessionGoal) {
        self.sessionGoal = [Goal MR_createEntity];
    }
    return _sessionGoal;
}

+ (Goal *)sharedSessionGoal
{
    BeeminderAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    return delegate.sessionGoal;
}

+ (void)clearSessionGoal
{
    BeeminderAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    delegate.sessionGoal = nil;
}

+ (NSString *)slugFromTitle:(NSString *)title
{
    NSRegularExpression *whitespaceRegex = [NSRegularExpression regularExpressionWithPattern:@"[\\s]" options:0 error:nil];
    
    NSString *noSpaces = [whitespaceRegex stringByReplacingMatchesInString:title options:0 range:NSMakeRange(0, title.length) withTemplate:@"-"];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^A-Za-z0-9\\-\\_]" options:0 error:nil];
    
    NSString *slug = [regex stringByReplacingMatchesInString:noSpaces options:0 range:NSMakeRange(0, noSpaces.length) withTemplate:@""];
    
    return slug;
}

+ (NSDictionary *)goalTypesInfo
{
    NSDictionary *fatLoser = [NSDictionary dictionaryWithObjectsAndKeys:kFatloserPrivate, kPrivateNameKey, kFatloserPublic, kPublicNameKey, kFatloserDetails, kDetailsKey, kFatloserInstructions, kInstructionsKey, [NSNumber numberWithInt:3], kSortPriorityKey, [NSNumber numberWithBool:NO], kKyoomKey, nil];
    
    NSDictionary *hustler = [NSDictionary dictionaryWithObjectsAndKeys:kHustlerPrivate, kPrivateNameKey, kHustlerPublic, kPublicNameKey, kHustlerDetails, kDetailsKey, kHustlerInstructions, kInstructionsKey, [NSNumber numberWithInt:1], kSortPriorityKey, [NSNumber numberWithBool:YES], kKyoomKey, nil];
    
    NSDictionary *biker = [NSDictionary dictionaryWithObjectsAndKeys:kBikerPrivate, kPrivateNameKey, kBikerPublic, kPublicNameKey, kBikerDetails, kDetailsKey, kBikerInstructions, kInstructionsKey, [NSNumber numberWithInt:2], kSortPriorityKey, [NSNumber numberWithBool:NO], kKyoomKey, nil];
    
    NSDictionary *inboxer = [NSDictionary dictionaryWithObjectsAndKeys:kInboxerPrivate, kPrivateNameKey, kInboxerPublic, kPublicNameKey, kInboxerDetails, kDetailsKey, kBikerInstructions, kInstructionsKey, [NSNumber numberWithInt:4], kSortPriorityKey, [NSNumber numberWithBool:NO], kKyoomKey, nil];
    
    NSDictionary *drinker = [NSDictionary dictionaryWithObjectsAndKeys:kDrinkerPrivate, kPrivateNameKey, kDrinkerPublic, kPublicNameKey, kDrinkerDetails, kDetailsKey, kDrinkerInstructions, kInstructionsKey, [NSNumber numberWithInt:5], kSortPriorityKey, [NSNumber numberWithBool:YES], kKyoomKey, nil];
    
    NSDictionary *fitbit = [NSDictionary dictionaryWithObjectsAndKeys:kFitbitPrivate, kPrivateNameKey, kFitbitPublic, kPublicNameKey, kFitbitDetails, kDetailsKey, kFitbitInstructions, kInstructionsKey, [NSNumber numberWithInt:6], kSortPriorityKey, [NSNumber numberWithBool:NO], kKyoomKey, nil];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:fatLoser, kFatloserPrivate, hustler, kHustlerPrivate, biker, kBikerPrivate, inboxer, kInboxerPrivate, drinker, kDrinkerPrivate, fitbit, kFitbitPrivate, nil];
}

+ (NSDate *)defaultEnterDataReminderDate
{
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:2012];
    [components setHour:21];
    [components setMinute:0];
    [components setSecond:0];
    
    NSDate *date = [calendar dateFromComponents:components];
    return date;
}

+ (NSDate *)defaultEmergencyDayReminderDate
{
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:2012];
    [components setHour:9];
    [components setMinute:0];
    [components setSecond:0];
    
    NSDate *date = [calendar dateFromComponents:components];
    return date;
}

+ (void)scheduleEnterDataReminders
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kRemindMeToEnterDataKey]) {
        return;
    }
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:kRemindMeToEnterDataAtKey];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned timeUnitFlags = NSMinuteCalendarUnit | NSHourCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *timeComponents = [calendar components:timeUnitFlags fromDate:date];
    
    for (int i = 0; i < 7; i++) {
        NSDate *today = [NSDate date];

        unsigned dayUnitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
        
        NSDateComponents *todayComponents = [calendar components:dayUnitFlags fromDate:today];
        
        [todayComponents setMinute:[timeComponents minute]];
        [todayComponents setHour:[timeComponents hour]];
        [todayComponents setSecond:[timeComponents second]];
        
        NSDate *todayAtReminderTime = [calendar dateFromComponents:todayComponents];
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        [offsetComponents setDay:i];
        
        NSDate *reminderDate = [calendar dateByAddingComponents:offsetComponents toDate:todayAtReminderTime options:0];
        
        if ([reminderDate timeIntervalSince1970] > [[NSDate date] timeIntervalSince1970]) {
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            
            [notification setFireDate:reminderDate];
            [notification setAlertBody:@"Don't forget to enter your Beeminder data for today!"];
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
    }
    
}

+ (void)requestPushNotificationAccess
{
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
}

// Begin Twitter Auth code
+ (AFHTTPRequestOperation *)reverseAuthTokenOperationForTwitterAccount:(ACAccount *)twitterAccount
{
    NSString *timestamp = [NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]];

    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSUInteger length = 32;
    NSMutableString *nonce = [NSMutableString stringWithCapacity: length];

    for (int i=0; i<length; i++) {
        [nonce appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }

    NSDictionary *baseParams = [NSDictionary dictionaryWithObjectsAndKeys: kTwitterConsumerKey, @"oauth_consumer_key", nonce, @"oauth_nonce", @"HMAC-SHA1", @"oauth_signature_method", timestamp, @"oauth_timestamp", @"1.0", @"oauth_version", @"reverse_auth", @"x_auth_mode", nil];

    NSString *paramString = [NSString stringWithFormat:@"oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@&oauth_version=%@&x_auth_mode=reverse_auth", [baseParams objectForKey:@"oauth_consumer_key"], [baseParams objectForKey:@"oauth_nonce"], [baseParams objectForKey:@"oauth_signature_method"], [baseParams objectForKey:@"oauth_timestamp"], [baseParams objectForKey:@"oauth_version"]];

    NSString *signatureBaseString = [NSString stringWithFormat:@"POST&https%%3A%%2F%%2Fapi.twitter.com%%2Foauth%%2Frequest_token&%@", AFURLEncodedStringFromStringWithEncoding(paramString, NSUTF8StringEncoding)];
    NSString *signingKey = [NSString stringWithFormat:@"%@&", kTwitterConsumerSecret];

    NSString *signature = [BeeminderAppDelegate hmacSha1SignatureForBaseString:signatureBaseString andKey:signingKey];

    NSString *headerString = [NSString stringWithFormat:@"OAuth oauth_consumer_key=\"%@\", oauth_nonce=\"%@\", oauth_signature=\"%@\", oauth_signature_method=\"%@\", oauth_timestamp=\"%@\", oauth_version=\"%@\"", [baseParams objectForKey:@"oauth_consumer_key"], [baseParams objectForKey:@"oauth_nonce"], AFURLEncodedStringFromStringWithEncoding(signature, NSUTF8StringEncoding), [baseParams objectForKey:@"oauth_signature_method"], [baseParams objectForKey:@"oauth_timestamp"], [baseParams objectForKey:@"oauth_version"], nil];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api.twitter.com/oauth/request_token"]];
    [request setHTTPBody:[@"x_auth_mode=reverse_auth" dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:[NSDictionary dictionaryWithObjectsAndKeys:headerString, @"Authorization", nil]];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    return operation;
}

+ (NSString *)hmacSha1SignatureForBaseString:(NSString *)baseString andKey:(NSString *)key
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [baseString cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    return [NSString base64StringFromData:HMAC length:HMAC.length];
}

+ (void)removeStoredOAuthDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kFacebookUserIdKey];
    [defaults removeObjectForKey:kFacebookOAuthTokenKey];
    [defaults removeObjectForKey:kFacebookUsernameKey];
    [defaults removeObjectForKey:kTwitterOAuthTokenKey];
    [defaults removeObjectForKey:kTwitterOAuthTokenSecretKey];
    [defaults removeObjectForKey:kTwitterScreenNameKey];
    [defaults removeObjectForKey:kTwitterUserIdKey];
}

+ (void)requestAccessToTwitterFromView:(UIView *)view withDelegate:(id<UIActionSheetDelegate, TwitterAuthDelegate>)delegate
{
    // Create an account store object.
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    // Create an account type that ensures Twitter accounts are retrieved.
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    // Request access from the user to use their Twitter accounts.
    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        if(granted) {
            NSArray *twitterAccounts = [accountStore accountsWithAccountType:accountType];
            delegate.twitterAccounts = twitterAccounts;
            if ([twitterAccounts count] == 1) {
                ACAccount *twitterAccount = [twitterAccounts objectAtIndex:0];
                delegate.selectedTwitterAccount = twitterAccount;
                [BeeminderAppDelegate getReverseAuthTokensForTwitterAccount:twitterAccount fromView:view withDelegate:delegate];
            }
            else if ([twitterAccounts count] > 1) {
                // ask the user which one they want to use
                UIActionSheet *sheet;
                switch ([twitterAccounts count]) {
                    case 2:
                        sheet = [[UIActionSheet alloc] initWithTitle:@"Choose Twitter Account" delegate:delegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:[[twitterAccounts objectAtIndex:0] username], [[twitterAccounts objectAtIndex:1] username], nil];
                        break;
                    case 3:
                        sheet = [[UIActionSheet alloc] initWithTitle:@"Choose Twitter Account" delegate:delegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:[[twitterAccounts objectAtIndex:0] username], [[twitterAccounts objectAtIndex:1] username], [[twitterAccounts objectAtIndex:2] username], nil];
                        break;
                        
                    case 4:
                        sheet = [[UIActionSheet alloc] initWithTitle:@"Choose Twitter Account" delegate:delegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:[[twitterAccounts objectAtIndex:0] username], [[twitterAccounts objectAtIndex:1] username], [[twitterAccounts objectAtIndex:2] username], [[twitterAccounts objectAtIndex:3] username], nil];
                        break;
                        
                    case 5:
                        sheet = [[UIActionSheet alloc] initWithTitle:@"Choose Twitter Account" delegate:delegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:[[twitterAccounts objectAtIndex:0] username], [[twitterAccounts objectAtIndex:1] username], [[twitterAccounts objectAtIndex:2] username], [[twitterAccounts objectAtIndex:3] username], [[twitterAccounts objectAtIndex:4] username], nil];
                        break;
                        
                    default:
                        sheet = [[UIActionSheet alloc] initWithTitle:@"Choose Twitter Account" delegate:delegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:[[twitterAccounts objectAtIndex:0] username], [[twitterAccounts objectAtIndex:1] username], [[twitterAccounts objectAtIndex:2] username], [[twitterAccounts objectAtIndex:3] username], [[twitterAccounts objectAtIndex:4] username], [[twitterAccounts objectAtIndex:5] username], nil];
                        break;
                }
                // show the sheet on the main thread
                int64_t delayInSeconds = 0.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [sheet showInView:view];
                });
                
            }
            else {
                // no accounts found
            }
        }
        else {
            // show the alert on the main thread
            int64_t delayInSeconds = 0.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:@"Error signing in to Twitter"
                                          message:@"To sign in with Twitter, go to Settings -> Twitter and enable Beeminder."
                                          delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                [alertView show];
            });

            NSLog(@"not granted");
        }
    }];
}

+ (void)getReverseAuthTokensForTwitterAccount:(ACAccount *)twitterAccount fromView:(UIView *)view withDelegate:(id<TwitterAuthDelegate>)delegate
{
    AFHTTPRequestOperation *operation = [BeeminderAppDelegate reverseAuthTokenOperationForTwitterAccount:twitterAccount];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseString = [operation responseString];
        [BeeminderAppDelegate fetchAccessTokenForTwitterAccount:twitterAccount authParams:responseString withDelegate: delegate];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //foo
        NSLog(@"%@", error);
    }];
    [MBProgressHUD showHUDAddedTo:view animated:YES];
    [operation start];
}

+ (void)fetchAccessTokenForTwitterAccount:twitterAccount authParams:authParams withDelegate:(id<TwitterAuthDelegate>)delegate
{
    NSDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:kTwitterConsumerKey forKey:@"x_reverse_auth_target"];
    [params setValue:authParams forKey:@"x_reverse_auth_parameters"];
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"];
    TWRequest *request = [[TWRequest alloc] initWithURL:url parameters:params requestMethod:TWRequestMethodPOST];
    [request setAccount:twitterAccount];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        // update form on the main thread
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [BeeminderAppDelegate saveTwitterOAuthResponseToDefaults:responseString];
            [delegate didSuccessfullyAuthWithTwitter];
        });
    }];
}

+ (void)saveTwitterOAuthResponseToDefaults:(NSString *)response
{
    NSDictionary *oAuthDictionary = [BeeminderAppDelegate parseTwitterOAuthInfo:response];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[oAuthDictionary objectForKey:@"oauth_token"] forKey:kTwitterOAuthTokenKey];
    [defaults setObject:[oAuthDictionary objectForKey:@"oauth_token_secret"] forKey:kTwitterOAuthTokenSecretKey];
    [defaults setObject:[oAuthDictionary objectForKey:@"user_id"] forKey:kTwitterUserIdKey];
    [defaults setObject:[oAuthDictionary objectForKey:@"screen_name"] forKey:kTwitterScreenNameKey];
}

+ (NSDictionary *)parseTwitterOAuthInfo:(NSString *)responseString
{
    NSArray *components = [responseString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"=&"]];
    NSString *oauthToken = [components objectAtIndex:[components indexOfObject:@"oauth_token"] + 1];
    NSString *oauthTokenSecret = [components objectAtIndex:[components indexOfObject:@"oauth_token_secret"] + 1];
    NSString *userId = [components objectAtIndex:[components indexOfObject:@"user_id"] + 1];
    NSString *screenName = [components objectAtIndex:[components indexOfObject:@"screen_name"] + 1];
    return [NSDictionary dictionaryWithObjectsAndKeys:oauthToken, @"oauth_token", oauthTokenSecret, @"oauth_token_secret", userId, @"user_id", screenName, @"screen_name", nil];
}


/* Begin Facebook SDK code
 * Callback for session changes.
 */
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                // We have a valid session
                NSLog(@"User session found");
            }
            break;
        case FBSessionStateClosed:
            NSLog(@"closed");
        case FBSessionStateClosedLoginFailed:
            NSLog(@"login failed");
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FBSessionStateChangedNotification object:session];

    if (error) {
        NSLog(@"%@", error.localizedDescription);

        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error signing in to Facebook"
                                  message:@"To sign in with Facebook, go to Settings -> Facebook and enable Beeminder."
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

/*
 * Opens a Facebook session and optionally shows the login UX.
 */
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    NSArray *permissions = [[NSArray alloc] initWithObjects:@"email", nil];
    return [FBSession openActiveSessionWithReadPermissions:permissions allowLoginUI:allowLoginUI completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
            [self sessionStateChanged:session state:state error:error];
        }];
}

/*
 * If we have a valid session at the time of openURL call, we handle
 * Facebook transitions by passing the url argument to handleOpenURL
 */
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBSession.activeSession handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kHas20Key]) {
        NSArray *stores = [self.persistentStoreCoordinator persistentStores];
        
        NSURL *url;
        for(NSPersistentStore *store in stores) {
            [self.persistentStoreCoordinator removePersistentStore:store error:nil];
            url = store.URL;
            [[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];
        }
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                                 nil];
        [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:options error:nil];
        
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kHas20Key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self managedObjectContext];
    }

    [MagicalRecord setupAutoMigratingCoreDataStack];
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        NSDictionary *payload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        
        [[NSUserDefaults standardUserDefaults] setObject:[payload objectForKey:@"slug"] forKey:kGoToGoalWithSlugKey];
    }
    [BeeminderAppDelegate scheduleEnterDataReminders];
//    [BeeminderAppDelegate resendPendingDeviceTokenRequests];
    return YES;
}

+ (void)resendPendingDeviceTokenRequests
{
    // Perhaps store the operation as NSData? Right now it complains "Attempt to insert non-property value "
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    if ([defaults objectForKey:kPendingLogoutRequestKey]) {
//        AFJSONRequestOperation *operation = [defaults objectForKey:kPendingLogoutRequestKey];
//        [operation start];
//    }
//    if ([defaults objectForKey:kPendingDeviceTokenSyncKey]) {
//        AFJSONRequestOperation *syncOperation = [defaults objectForKey:kPendingDeviceTokenSyncKey];
//        [syncOperation start];
//    }
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    [BeeminderAppDelegate saveDeviceTokenToServer:deviceToken];
}

+ (NSString *)addDeviceTokenToParamString:(NSString *)paramString
{
    return [paramString stringByAppendingFormat:@"&beemios_token=%@", AFURLEncodedStringFromStringWithEncoding([BeeminderAppDelegate hmacSha1SignatureForBaseString:paramString andKey:kBeemiosSigningKey], NSUTF8StringEncoding)];
}

+ (void)saveDeviceTokenToServer:(NSData *)deviceToken
{
    NSString *deviceTokenString = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
 
    NSString *latestDeviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:kLatestDeviceTokenKey];

    if (latestDeviceToken && [deviceTokenString isEqualToString:latestDeviceToken]) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:deviceTokenString forKey:kLatestDeviceTokenKey];
    
    NSString *accessToken = [ABCurrentUser accessToken];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/device_tokens.json", kBaseURL, kPrivateAPIPrefix]];
    
    NSString *paramString = [NSString stringWithFormat:@"access_token=%@&device_token=%@", accessToken, deviceTokenString];
    paramString = [BeeminderAppDelegate addDeviceTokenToParamString:paramString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[paramString dataUsingEncoding:NSUTF8StringEncoding]];

    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPendingDeviceTokenSyncKey];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@", response);
        NSLog(@"%@", error);
    }];
//    [[NSUserDefaults standardUserDefaults] setObject:operation forKey:kPendingDeviceTokenSyncKey];
    [operation start];
}

+ (void)removeDeviceTokenFromServer
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *deviceToken = [defaults objectForKey:kLatestDeviceTokenKey];
    
    NSString *paramString = [NSString stringWithFormat:@"access_token=%@", [ABCurrentUser accessToken]];
    
    NSString *beemiosToken = [BeeminderAppDelegate addDeviceTokenToParamString:@""];
    
    paramString = [paramString stringByAppendingString:beemiosToken];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/device_tokens/%@.json?%@", kBaseURL, kPrivateAPIPrefix, deviceToken, paramString]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"DELETE"];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //        [defaults removeObjectForKey:kPendingLogoutRequestKey];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        //bar
    }];
    //    [defaults setObject:operation forKey:kPendingLogoutRequestKey];
    
    [operation start];
    [defaults removeObjectForKey:kLatestDeviceTokenKey];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

+ (void)updateApplicationIconBadgeCount
{
    __block int count = 0;
    [[ABCurrentUser user].goals enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        Goal *goal = (Goal *)obj;
        if (![goal.won boolValue] && [goal.panicTime doubleValue] < [[NSDate date] timeIntervalSince1970]) {
            count++;
        }
    }];

    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self refreshGoalsAndShowDashboard];
}

- (void)refreshGoalsAndShowDashboard
{
    UIViewController *rootCon = self.window.rootViewController;
    if ([rootCon.presentedViewController isMemberOfClass:[MainTabBarViewController class]]) {
        MainTabBarViewController *mtbvCon = (MainTabBarViewController *)rootCon.presentedViewController;
        [mtbvCon setSelectedIndex:0];
        UINavigationController *navCon = [[mtbvCon viewControllers] objectAtIndex:0];
        GoalsTableViewController *gtvCon = [[navCon viewControllers] objectAtIndex:0];
        [gtvCon fetchEverything];
        [mtbvCon setSelectedIndex:0];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // We need to properly handle activation of the application with regards to SSO
    // (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
    [FBSession.activeSession handleDidBecomeActive];
    [self refreshGoalsAndShowDashboard];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [FBSession.activeSession close];    
    [MagicalRecord cleanUp];
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Beeminder" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Beeminder.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
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
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
