//
//  GoalViewController.m
//  Beeminder
//
//  Created by Andy Brett on 6/19/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "GoalViewController.h"
#import "constants.h"
#import "SBJson.h"
#import "UIViewController+ManagedObjectContext.h"

@interface GoalViewController () <NSURLConnectionDelegate>

@property (nonatomic, strong) CPTXYGraph *graph;

- (void)setupGraph;
- (void)setupPlotSpace;
- (double)minYValue;
- (double)maxYValue;

@end

@implementation GoalViewController

@synthesize responseData = _responseData;
@synthesize responseStatus = _responseStatus;
@synthesize datapoints = _datapoints;
@synthesize slug = _slug;
@synthesize graphHostingView = _graphHostingView;
@synthesize graph = _graph;
@synthesize symbolTextAnnotation = _symbolTextAnnotation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *authenticationToken = [defaults objectForKey:@"authenticationTokenKey"];
    
    NSString *username = [defaults objectForKey:@"username"];
    
    NSURL *datapointsUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/v1/users/%@/goals/%@/datapoints.json?auth_token=%@", kBaseURL, username, self.slug, authenticationToken]];
    
    NSMutableURLRequest *datapointsRequest = [NSMutableURLRequest requestWithURL:datapointsUrl];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:datapointsRequest delegate:self];
    
    if (connection) {
        self.responseData = [NSMutableData data];
    }
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    self.responseStatus = [httpResponse statusCode];
    
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d {
    [self.responseData appendData:d];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
                                message:[error localizedDescription]
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                      otherButtonTitles:nil] show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (self.responseStatus == 200) {
        NSString *responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
        
        NSArray *responseJSON = [responseString JSONValue];

        self.datapoints = [NSMutableArray arrayWithArray:responseJSON];
        
        [self setupGraph];
        [self setupPlotSpace];
        [self setupAxes];
        [self setupScatterPlots];

    }
    else {
        self.title = @"Bad Login";
    }
}

- (void)viewDidUnload {
    [self setGraphHostingView:nil];
    [super viewDidUnload];
}

#pragma mark - Core Plot related methods

- (double)extrema:(NSString *)extrema ForAxis:(NSString *)axis {
    NSArray *copy = [self.datapoints copy];
    
    NSArray *sortedCopy = [copy sortedArrayUsingComparator:^(id a, id b){
        id first = [a objectForKey:axis];
        id second = [b objectForKey:axis];
        return [first compare:second];
    }];
    if (extrema == @"max") {
        return [[sortedCopy.lastObject objectForKey:axis] doubleValue];
    }
    else {
        return [[[sortedCopy objectAtIndex:0] objectForKey:axis] doubleValue];
    }
}

- (double)minYValue {
    return [self extrema:@"min" ForAxis:@"value"];
}

- (double)maxYValue {
    return [self extrema:@"max" ForAxis:@"value"];
}


- (void)setupGraph {
    self.graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
    [self.graph applyTheme:theme];
//    CPTFill *fill = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:26.0f/255.0f green:83.0f/255.0f blue:103.0f/255.0f alpha:1.0f]];
//    self.graph.fill = fill;
//    self.graph.plotAreaFrame.fill = fill;

    self.graphHostingView.collapsesLayers = NO;
    self.graphHostingView.hostedGraph = self.graph;
    
    
    self.graph.paddingLeft   = 0.0;
    self.graph.paddingTop    = 0.0;
    self.graph.paddingRight  = 0.0;
    self.graph.paddingBottom = 0.0;
}

-(void) setupPlotSpace {
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    
    plotSpace.allowsUserInteraction = YES;
    
    double startX = [[[self.datapoints objectAtIndex:0] objectForKey:@"measured_at"] doubleValue];
    
    double endX = [[[self.datapoints lastObject] objectForKey:@"measured_at"] doubleValue];
    
    double xLength = endX - startX;
    
    double startY = self.minYValue;
    
    double endY = self.maxYValue;
    
    double yLength = endY - startY;
    
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble (startX) length:CPTDecimalFromDouble(xLength)];
    
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(startY) length:CPTDecimalFromDouble(yLength)];
}

- (void)setupAxes {
    NSDate *refDate = [NSDate dateWithTimeIntervalSince1970:0];
    
    // style the graph with white text and lines
    CPTMutableTextStyle *grayTextStyle = [[CPTMutableTextStyle alloc] init];
    grayTextStyle.color = [CPTColor darkGrayColor];
    CPTMutableLineStyle *grayLineStyle = [[CPTMutableLineStyle alloc] init];
    grayLineStyle.lineColor = [CPTColor lightGrayColor];
    grayLineStyle.lineWidth = 2.0f;
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;    
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    
    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(plotSpace.yRange.locationDouble);
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd";
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate = refDate;
    x.labelFormatter = timeFormatter;
    
    x.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    x.minorTicksPerInterval       = 2;
    x.preferredNumberOfMajorTicks = 6;
    x.labelTextStyle = grayTextStyle;
    x.axisLineStyle = grayLineStyle;
    x.majorTickLineStyle = grayLineStyle;
    x.minorTickLineStyle = grayLineStyle;    
    
    CPTXYAxis *y = axisSet.yAxis;
    y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(plotSpace.xRange.locationDouble);
    y.labelOffset = -35;
    y.delegate = self;
    y.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    y.preferredNumberOfMajorTicks = 4;
    y.minorTicksPerInterval       = 5;
    y.majorTickLineStyle = grayLineStyle;
    y.minorTickLineStyle = grayLineStyle;
    y.labelTextStyle = grayTextStyle;
    y.axisLineStyle = grayLineStyle;
}

- (void)setupScatterPlots {
    CPTScatterPlot *scatterPlot = [[CPTScatterPlot alloc] init];
    
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.miterLimit        = 1.0f;
    lineStyle.lineWidth         = 3.0f;
    lineStyle.lineColor         = [CPTColor darkGrayColor];
    scatterPlot.dataLineStyle = lineStyle;
    
    scatterPlot.dataSource = self;
    scatterPlot.interpolation = CPTScatterPlotInterpolationCurved;
    scatterPlot.delegate = self;
    scatterPlot.plotSymbolMarginForHitDetection = 10.0;
    
    // Add plot symbols
    CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = [CPTColor whiteColor];
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill          = [CPTFill fillWithColor:[CPTColor whiteColor]];
    plotSymbol.lineStyle     = symbolLineStyle;
    plotSymbol.size          = CGSizeMake(1.0, 1.0);
    scatterPlot.plotSymbol = plotSymbol;
    
    [self.graph addPlot:scatterPlot];
}

-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index
{
    if ( self.symbolTextAnnotation ) {
        [self.graph.plotAreaFrame.plotArea removeAnnotation:self.symbolTextAnnotation];
        self.symbolTextAnnotation = nil;
    }
    
    // Setup a style for the annotation
    CPTMutableTextStyle *hitAnnotationTextStyle = [CPTMutableTextStyle textStyle];
    hitAnnotationTextStyle.color    = [CPTColor lightGrayColor];
    hitAnnotationTextStyle.fontSize = 16.0f;
    hitAnnotationTextStyle.fontName = @"Helvetica-Bold";
    
    // Determine point of symbol in plot coordinates
    NSNumber *x          = [[self.datapoints objectAtIndex:index] valueForKey:@"measured_at"];
    NSNumber *y          = [[self.datapoints objectAtIndex:index] valueForKey:@"value"];
    NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
    
    // Add annotation
    // First make a string for the y value
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];
    NSString *yString = [formatter stringFromNumber:y];
    
    // Now add the annotation to the plot area
    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:yString style:hitAnnotationTextStyle];
    textLayer.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
    self.symbolTextAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:self.graph.defaultPlotSpace anchorPlotPoint:anchorPoint];
    self.symbolTextAnnotation.contentLayer = textLayer;
    self.symbolTextAnnotation.displacement = CGPointMake(0.0f, 20.0f);
    [self.graph.plotAreaFrame.plotArea addAnnotation:self.symbolTextAnnotation];
    
}

#pragma mark - CPTPlotDataSource delegate methods

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return self.datapoints.count;
}

- (double)doubleForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSString *key = (fieldEnum == CPTScatterPlotFieldX) ? @"measured_at" : @"value";
    
    return [[[self.datapoints objectAtIndex:index] objectForKey:key] doubleValue];
    
}

@end
