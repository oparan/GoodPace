//
//  LogViewController.m
//  GoodPace
//
//  Created by Paran, Omer on 12/30/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import "LogViewController.h"
#import "Globals.h"
#import "LogObj.h"
#import "ICEMotionGraphViewController.h"


@interface LogViewController ()

@end

@implementation LogViewController

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
    [UI addRightButton:self title:@"Graphs" action:@selector(showGraphView)];
    
    self.logView = [[UITextView alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width,self.view.frame.size.height)];
    [self.view addSubview:self.logView];
}

- (void) showGraphView {
    
    ICEMotionGraphViewController*  graphViewController = [[ICEMotionGraphViewController alloc] init];
    graphViewController.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:graphViewController animated:YES];
}

- (void) viewWillAppear:(BOOL)animated  {
    logView = self;
    [super viewWillAppear:animated];
    
    self.logView.text = logObj.logs;
}

- (void) viewWillDisappear:(BOOL)animated {
    logView = nil;
}

- (void) upodateLog  {
    
    self.logView.text = logObj.logs;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
