//
//  ITHelp.m
//  scan4PASE
//
//  Created by Dhruv Sringari on 11/6/13.
//  Copyright (c) 2013 Sringari Worldwide. All rights reserved.
//

#import "ITHelp.h"

@interface ITHelp ()

@end

@implementation ITHelp
@synthesize textView;

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
	// Do any additional setup after loading the view.
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"scan4pase-help" ofType:@"txt"];
    NSError *error;
    NSString *myText = [NSString stringWithContentsOfFile:filePath encoding:NSUTF16StringEncoding error:&error];
    textView.text = myText;
    
    if(error) {
        NSLog(@"%@",error);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
