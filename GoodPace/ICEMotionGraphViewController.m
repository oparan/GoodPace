//
//  ICEMotionGraphViewController.m
//  GoodPaceLogic
//
//  Created by Steiner, Ron on 12/24/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import "ICEMotionGraphViewController.h"
#import "ICEMotionData.h"
#import "ICEMotionMonitor.h"
#import "CPTFill.h"
#import "ICELogger.h"
static const NSString* TAG=@"MotionGraph";

@interface ICEMotionGraphViewController ()
{
    NSInteger currentSegment;
    NSMutableArray *highLows;
    ICEMotionRecords *accelerationRecords;
    CPTScatterPlot *accelarationPlot;
    CPTScatterPlot *accelarationPlotX;
    CPTScatterPlot *accelarationPlotY;
    CPTScatterPlot *accelarationPlotZ;
    CPTScatterPlot *accelarationHighLowPlot;
    CPTScatterPlot *stepsPeaksPlot;
    
    ICEMotionRecords *gyroRecords;
    
    CPTScatterPlot *gyroPlot;
    
    CPTXYGraph *graph;
    
    ICEMotionMonitor *motionMonitor;
    IBOutlet UISwipeGestureRecognizer *leftSwipeRecognizer;
    IBOutlet UISwipeGestureRecognizer *rightSwipeRecognizer;

}
@end

@implementation ICEMotionGraphViewController


- (void)onSwipeLeftRight:(UISwipeGestureRecognizer *)sender {
    if(sender==rightSwipeRecognizer && currentSegment>0){
        currentSegment--;
        [self calculatePlotRangeForSegment];
        [self composeHighLowsDataSourceForSegment];
        [graph reloadData];
    }
    else if(sender==leftSwipeRecognizer && currentSegment<accelerationRecords.motionSegments.count-1){
        currentSegment++;
        [self calculatePlotRangeForSegment];
        [self composeHighLowsDataSourceForSegment];
        
        [graph reloadData];
    }
}

- (IBAction)onSwipeLeft:(id)sender {
    [self onSwipeLeftRight:sender];
}

- (IBAction)onSwipeRight:(id)sender {
    [self onSwipeLeftRight:sender];
}

-(void)calculatePlotRangeForSegment{
    ICEMotionSegmentRecords* accelerationSegment = accelerationRecords.motionSegments[currentSegment];
    ICEMotionSegmentRecords* gyroSegment = gyroRecords.motionSegments[currentSegment];
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace*) graph.defaultPlotSpace;
    
    double min = MIN(accelerationRecords.minValue, MIN(gyroRecords.minValue,accelerationRecords.minValue+ gyroRecords.minValue));
    double max = MAX((accelerationRecords.maxValue-accelerationRecords.minValue)+(gyroRecords.maxValue-gyroRecords.minValue), MAX((accelerationRecords.maxValue-accelerationRecords.minValue), (gyroRecords.maxValue-gyroRecords.minValue)));
    
    CPTPlotRange * rangeY = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble (min) length:CPTDecimalFromDouble(max)];
    
    min= MIN(accelerationSegment.startTime, gyroSegment.startTime);
    max = MAX((accelerationSegment.endTime-accelerationSegment.startTime), (gyroSegment.endTime-gyroSegment.startTime));
    CPTPlotRange * rangeX = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble (min) length:CPTDecimalFromDouble(max)];
    //NSLog(@"\n\n-range X: %@ range Y: %@",rangeX,rangeY);
    
    [plotSpace setXRange:rangeX];
    [plotSpace setYRange:rangeY];
}

-(void) composeHighLowsDataSourceForSegment
{
    highLows = [[NSMutableArray alloc] init];
    ICEMotionSegmentRecords* segment = accelerationRecords.motionSegments[currentSegment];
    ICEMotionData *item, *jtem;
    NSArray* currentLows = segment.lowPeaks;
    NSArray* currentHighs = segment.highPeaks;
    @try {
        for(int i=0, j=0; i<currentLows.count && j<currentHighs.count; ){
            item = currentLows[i];
            jtem = currentHighs[j];
            if(item.timeStamp<jtem.timeStamp){
                [highLows addObject:item];
                i++;
            }
            else {
                [highLows addObject:jtem];
                j++;
            }
        }

    }
    @catch (NSException *exception) {
        [ICELogger debug:TAG line:@"Error creating the high-low series"];
    }
    [ICELogger debug:TAG line:[NSString stringWithFormat:@"composed %lu high-low series", (unsigned long)highLows.count]];
    
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plotnumberOfRecords {
    ICEMotionSegmentRecords* motionData = (plotnumberOfRecords==gyroPlot ? gyroRecords.motionSegments[currentSegment]:accelerationRecords.motionSegments[currentSegment]);
    
    if(plotnumberOfRecords==accelarationHighLowPlot){
        return highLows.count;
    }
    else if(plotnumberOfRecords==stepsPeaksPlot){
        return motionData.analyzedStepsPeaks.count;
    }
    
    return motionData.motionValues.count;
}

// This method is here because this class also functions as datasource for our graph
// Therefore this class implements the CPTPlotDataSource protocol
-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    BOOL isGyro = plot==gyroPlot;
    BOOL isHighLow = plot==accelarationHighLowPlot;
    BOOL isSteps = plot==stepsPeaksPlot;
    
    ICEMotionSegmentRecords* motionData = ( isGyro ? gyroRecords.motionSegments[currentSegment]:accelerationRecords.motionSegments[currentSegment]);
    
    if(isHighLow){
        ICEMotionData* item = highLows[index];
        if(fieldEnum == CPTScatterPlotFieldX)
        {
            return [NSNumber numberWithDouble:item.timeStamp];
        } else {
            return [NSNumber numberWithDouble:item.vector.size];
        }
    }
    else if(isSteps){
        ICEMotionData* item = motionData.analyzedStepsPeaks[index];
        if(fieldEnum == CPTScatterPlotFieldX)
        {
            return [NSNumber numberWithDouble:item.timeStamp];
        } else {
            return [NSNumber numberWithDouble:item.vector.size];
        }
    }
    
    
    // We need to provide an X or Y (this method will be called for each) value for every index
    if(index>=motionData.motionValues.count){
        return [NSNumber numberWithDouble:0.0];
    }
    ICEMotionData* item = (ICEMotionData*)motionData.motionValues[index];
    
    // This method is actually called twice per point in the plot, one for the X and one for the Y value
    if(fieldEnum == CPTScatterPlotFieldX)
    {
        return [NSNumber numberWithDouble:item.timeStamp];
    } else {
        NSNumber *result;
        if(isGyro || plot==accelarationPlot){
            result= [NSNumber numberWithDouble:item.vector.size];
        }
        else if(plot==accelarationPlotX){
            result= [NSNumber numberWithDouble:item.vector.x];
        }
        else if(plot==accelarationPlotY){
            result= [NSNumber numberWithDouble:item.vector.y];
        }
        else if(plot==accelarationPlotZ){
            result= [NSNumber numberWithDouble:item.vector.z];
        }

        return result;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    currentSegment=0;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    motionMonitor =  [ICEMotionMonitor sharedMonitor];
    
	// Do any additional setup after loading the view.
    accelerationRecords = motionMonitor.accelerationRecords;
    gyroRecords = motionMonitor.gyroRecords;
    
    // NSLog(@"adding graph with frame:%fx%f at %f,%f",self.view.frame.size.width, self.view.frame.size.height,self.view.frame.origin.x, self.view.frame.origin.y);
    CPTGraphHostingView * hostView = [[CPTGraphHostingView alloc] initWithFrame:self.view.frame];
    [hostView setBackgroundColor:[[UIColor alloc] initWithRed:0.5 green:0.5 blue:(0.5) alpha:(1.0)]];
    [self.view addSubview:hostView];

    if(rightSwipeRecognizer==nil){
        rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeRight:)];
        rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    }
    if(leftSwipeRecognizer==nil){
        leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeLeft:)];
        leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    }
    [hostView addGestureRecognizer:rightSwipeRecognizer];
    [hostView addGestureRecognizer:leftSwipeRecognizer];
    
    graph = [[CPTXYGraph alloc] initWithFrame:hostView.bounds];
    graph.fill = [CPTFill fillWithColor:[CPTColor lightGrayColor]];
    hostView.hostedGraph = graph;
    
    [self calculatePlotRangeForSegment];
    [self composeHighLowsDataSourceForSegment];
    
    
    gyroPlot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    
    gyroPlot.dataSource = self;
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth = 1.0f;
    lineStyle.lineColor = [CPTColor redColor];
    gyroPlot.dataLineStyle = lineStyle;
    
    
    
    
    accelarationHighLowPlot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    accelarationHighLowPlot.dataSource = self;

    lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth = 1.0f;
    lineStyle.lineColor = [CPTColor blueColor];
    accelarationHighLowPlot.dataLineStyle = lineStyle;
    
    accelarationPlotX = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    accelarationPlotY = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    accelarationPlotZ = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    
    accelarationPlotX.dataSource = self;
    
    lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth = 0.25f;
    lineStyle.lineColor = [CPTColor redColor];
    accelarationPlotX.dataLineStyle = lineStyle;
    
    //[graph addPlot:accelarationPlotX];

    accelarationPlotY.dataSource = self;
    
    lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth = 0.25f;
    lineStyle.lineColor = [CPTColor greenColor];
    accelarationPlotY.dataLineStyle = lineStyle;
    
    //[graph addPlot:accelarationPlotY];
    
    accelarationPlotZ.dataSource = self;
    
    lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth = 0.25f;
    lineStyle.lineColor = [CPTColor blueColor];
    accelarationPlotZ.dataLineStyle = lineStyle;
    
    //[graph addPlot:accelarationPlotZ];
    
    accelarationPlot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    
    accelarationPlot.dataSource = self;
    
    lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth = 0.75f;
    lineStyle.lineColor = [CPTColor darkGrayColor];
    accelarationPlot.dataLineStyle = lineStyle;
    
    stepsPeaksPlot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    
    stepsPeaksPlot.dataSource = self;
    
    lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth = 1.0f;
    lineStyle.lineColor = [CPTColor greenColor];
    stepsPeaksPlot.dataLineStyle = lineStyle;
    
    [graph addPlot:gyroPlot];
    [graph addPlot:accelarationPlot];
    [graph addPlot:accelarationHighLowPlot];
    
    [graph addPlot:stepsPeaksPlot];

    
    

    
    /*});*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
