//
//  NELogFormatter.m
//  BARTPresentation
//
//  Created by Oliver Zscheyge on 5/3/10.
//  Copyright 2010 MPI Cognitive and Human Brain Scienes Leipzig. All rights reserved.
//

#import "NELogFormatter.h"
#import "NEStimEvent.h"


@implementation NELogFormatter

@synthesize keyValuePairSeperator;
@synthesize keyValueSeperator;

@synthesize beginSetDelimiter;
@synthesize entrySeperator;
@synthesize endSetDelimiter;

@synthesize triggerIdentifier;
@synthesize buttonIdentifier;
@synthesize actionIdentifier;


@synthesize eventIdentifier;
@synthesize startEventIdentifier;
@synthesize endEventIdentifier;

-(id)init
{
    if ((self = [super init])) {
        keyValuePairSeperator = @",\t";
        keyValueSeperator     = @",\t";
        
        beginSetDelimiter     = @"\t";
        entrySeperator        = @",\t\t";
        endSetDelimiter       = @",\t";
        
        triggerIdentifier     = @"Trigger";
        buttonIdentifier      = @"Keyboard";
        actionIdentifier      = @"Action";

        
        eventIdentifier       = @"Event";
        startEventIdentifier  = @"Start";
        endEventIdentifier    = @"End";
    }
    
    return self;
}

+(NELogFormatter*)defaultFormatter
{
    /** Default instance of NELogFormatter. */
    static NELogFormatter* mDefaultFormatter = nil;

    if (!mDefaultFormatter) {
        mDefaultFormatter = [[self alloc] init];
    } 

    return mDefaultFormatter;
}

-(NSString*)stringForTriggerNumber:(NSUInteger)triggerNr
{
    // @"T:triggerNr"
    //return [NSString stringWithFormat:@"%@%@%d", triggerIdentifier, keyValueSeperator, triggerNr];
    return [NSString stringWithFormat:@"%5lu", triggerNr];
}

-(NSString*)stringForButtonPress:(NSUInteger)button
{
    return [NSString stringWithFormat:@"%5lu", button];
}

-(NSString*)stringForOnsetTime:(NSUInteger)t
{
    return [NSString stringWithFormat:@"%8lu", t];
}

-(NSString*)stringForStimEvent:(NEStimEvent*)event
{
    // @"E:{time,duration,ID}"
    return [NSString stringWithFormat:@"%@%@%@%ld%@%ld%@%@%@{%.0f %0.f}%@", 
            eventIdentifier, 
            keyValueSeperator, 
            beginSetDelimiter, 
            [event time], 
            entrySeperator,
            [event duration], 
            entrySeperator,
            [[event mediaObject] getID],
            entrySeperator,
            [[event mediaObject] position].x,
            [[event mediaObject] position].y,
            endSetDelimiter];
}

-(NSString*)stringForEventDescription:(NEStimEvent*)event
{
    
    return [[event mediaObject] getID];
}

-(NSString*)stringForEventDuration:(NEStimEvent *)event
{
    return [NSString stringWithFormat:@"%ld", 
            [event duration]];
}

-(NSString*)stringForEventPos:(NEStimEvent*)event
{
    return [NSString stringWithFormat:@"{%.0f_%.0f}", 
            [[event mediaObject] position].x, 
            [[event mediaObject] position].y]; 
}

-(NSString*)stringForEndEventIdentifier:(NEStimEvent *)event
{
    return [NSString stringWithFormat:@"%@_%@",
            [[event mediaObject] eventIdentifier],
            endEventIdentifier];
}

-(NSString*)stringForStartEventIdentifier:(NEStimEvent *)event
{
    return [NSString stringWithFormat:@"%@_%@",
            [[event mediaObject] eventIdentifier],
            startEventIdentifier];
}





@end
