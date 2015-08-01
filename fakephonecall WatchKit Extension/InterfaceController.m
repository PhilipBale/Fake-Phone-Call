//
//  InterfaceController.m
//  fakephonecall WatchKit Extension
//
//  Created by Philip Bale on 8/1/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "InterfaceController.h"
#import "ContactsTableRowController.h"
#import "Realm/Realm.h"
#import "FPCContact.h"

@interface InterfaceController()

@property (nonatomic, strong) RLMResults *contacts;

@end


@implementation InterfaceController

// Configure interface objects here.
- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    NSURL *realmDirectoy = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.logikcomputing.fakephonecall"];
    NSString *realmPath = [realmDirectoy.path stringByAppendingString:@"db.realm"];
    [RLMRealm setDefaultRealmPath:realmPath];

    [self loadContactsTable];
}

// This method is called when watch view controller is about to be visible to user
- (void)willActivate {
    [super willActivate];
}

// This method is called when watch view controller is no longer visible
- (void)didDeactivate {
    [super didDeactivate];
}

- (void)loadContactsTable
{
    self.contacts = [FPCContact allObjects];
    [self.contactsTable setNumberOfRows:self.contacts.count withRowType:@"ContactsTableRowController"];
    for (int i = 0; i < self.contacts.count; i++)
    {
        ContactsTableRowController *rowController = [self.contactsTable rowControllerAtIndex:i];
        FPCContact *contact = [self.contacts objectAtIndex:i];
        [rowController.contactNameLabel setText:[self formatNameForContact:contact]];
    }
}

- (NSString *)formatNameForContact:(FPCContact *)contact
{
    NSArray *split = [[contact.name stringByReplacingOccurrencesOfString:@"," withString:@""] componentsSeparatedByString:@" "];
    if (split.count == 3)
    {
        return [NSString stringWithFormat:@"%@ %@ %@", [split objectAtIndex:1], [split objectAtIndex:0], [split objectAtIndex:2]];
    } else if (split.count == 2)
    {
        if ([((NSString *)[split objectAtIndex:1]) containsString:@"("]) {
            return [NSString stringWithFormat:@"%@ %@", [split objectAtIndex:0], [split objectAtIndex:1]];
        } else {
            return [NSString stringWithFormat:@"%@ %@", [split objectAtIndex:1], [split objectAtIndex:0]];
        }
    }
    else
    {
        return [((NSString *)[split objectAtIndex:0]) stringByReplacingOccurrencesOfString:@"," withString:@""];
    }
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex
{
    [self pushControllerWithName:@"Call Options" context:[self.contacts objectAtIndex:rowIndex]];
}

@end



