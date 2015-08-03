//
//  CallOptionsInterfaceController.m
//  fakephonecall
//
//  Created by Philip Bale on 8/1/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "CallOptionsInterfaceController.h"
#import "CallOptionsRowController.h"
#import "FPCContact.h"
#import "WatchWormholeManager.h"

@interface CallOptionsInterfaceController ()

@property (nonatomic, strong) FPCContact* contact;
@end

#define callOptions @[@0, @30, @60, @300, @600]

@implementation CallOptionsInterfaceController

// Configure interface objects here.
- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    self.contact = context;
    NSLog(@"Contact name: %@", self.contact.name);
    [self loadOptionsTable];
}

// This method is called when watch view controller is about to be visible to user
- (void)willActivate {
    [super willActivate];
}

// This method is called when watch view controller is no longer visible
- (void)didDeactivate {
    [super didDeactivate];
}

- (void)loadOptionsTable
{
    NSArray *labels = @[@"now", @"in 30 sec", @"in 1 min", @"in  5 min", @"in  10 min"];
    [self.optionsTable setNumberOfRows:labels.count withRowType:@"CallOptionsRowController"];
    for (int i = 0; i < labels.count; i++)
    {
        CallOptionsRowController *rowController = [self.optionsTable rowControllerAtIndex:i];
        [rowController.whenLabel setText:[NSString stringWithFormat:@"Call %@", [labels objectAtIndex:i]]];
    }
}

-(void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex
{
    NSLog(@"Calling %@ in %@ secs", self.contact.number, [callOptions objectAtIndex:rowIndex]);
    //[[WatchWormholeManager sharedManager] placeCallWithNumber:self.contact.number when:[callOptions objectAtIndex:rowIndex]];
    NSDictionary *userInfo = @{@"number":self.contact.number, @"when":[callOptions objectAtIndex:rowIndex]};
    [WKInterfaceController openParentApplication:userInfo reply:^(NSDictionary *replyInfo, NSError *error){
         NSLog(@"Received reply from parent app!");
     }];
    

    [self presentControllerWithName:@"CallResult" context:nil];
    
}
@end



