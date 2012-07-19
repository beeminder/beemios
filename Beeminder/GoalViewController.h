//
//  GoalViewController.h
//  Beeminder
//
//  Created by Andy Brett on 6/19/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "constants.h"
#import "SBJson.h"
#import "UIViewController+NSURLConnectionDelegate.h"

@interface GoalViewController : UIViewController <CPTPlotSpaceDelegate,
    CPTPlotDataSource,
    CPTAxisDelegate,
    CPTPlotDelegate>

@property NSMutableData *responseData;
@property NSUInteger responseStatus;
@property (strong, nonatomic) NSMutableArray *datapoints;
@property (strong, nonatomic) NSString *slug;
@property (strong, nonatomic) IBOutlet CPTGraphHostingView *graphHostingView;
@property (nonatomic, strong) CPTPlotSpaceAnnotation *symbolTextAnnotation;

@end
