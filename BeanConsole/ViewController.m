//
//  ViewController.m
//  BeanConsole
//
//  Created by Caylan Larson on 5/14/15.
//  Copyright (c) 2015 Semireg Industries. All rights reserved.
//

#import "ViewController.h"
#import <PTDBeanManager.h>

@interface ViewController () <PTDBeanManagerDelegate, PTDBeanDelegate>
@property (strong, nonatomic) PTDBeanManager *beanManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.consoleOutputTextView.editable = NO;
    
    self.beanManager = [[PTDBeanManager alloc] initWithDelegate:self];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

// check to make sure we're on
- (void)beanManagerDidUpdateState:(PTDBeanManager *)manager{
    if(self.beanManager.state == BeanManagerState_PoweredOn){
        // if we're on, scan for advertisting beans
        NSError* scanError;
        [self.beanManager startScanningForBeans_error:&scanError];
        if (scanError) {
            NSLog(@"%@", [scanError localizedDescription]);
        }
    }
    else if (self.beanManager.state == BeanManagerState_PoweredOff) {
        // do something else
    }
}
// bean discovered
- (void)BeanManager:(PTDBeanManager*)beanManager didDiscoverBean:(PTDBean*)bean error:(NSError*)error{
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
        return;
    }
    NSError* connectError;
    [beanManager connectToBean:bean error:&connectError];
    if (connectError) {
        NSLog(@"%@", [connectError localizedDescription]);
    }
}
// bean connected
- (void)BeanManager:(PTDBeanManager*)beanManager didConnectToBean:(PTDBean*)bean error:(NSError*)error{
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
        return;
    }
    
    bean.delegate = self;
}

-(void)bean:(PTDBean *)bean serialDataReceived:(NSData *)data
{
    NSString *serialOutput = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSString *uuidSubstring = [bean.identifier.UUIDString substringFromIndex:bean.identifier.UUIDString.length-4];
//    serialOutput = [NSString stringWithFormat:@"%@-%@:%@", bean.name, uuidSubstring, serialOutput];

    if(serialOutput)
    {
        serialOutput = [self.consoleOutputTextView.string stringByAppendingString:serialOutput];
        self.consoleOutputTextView.string = serialOutput;
    }
    
    [self.consoleOutputTextView scrollRangeToVisible: NSMakeRange(self.consoleOutputTextView.string.length, 0)];
}

- (IBAction)clearButtonPressed:(NSButton *)sender {
    self.consoleOutputTextView.string = @"";
}

@end
