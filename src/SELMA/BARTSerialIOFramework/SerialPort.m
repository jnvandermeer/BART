//
//  SerialPort.m
//  
//
//  Created by Karsten Molka on 4/20/10.
//  Copyright 2010 MPI Cognitive and Human Brain Sciences Leipzig. All rights reserved.
//

/**
 * The class SerialPort is the wrapper for the IOKit Serial Port. For use, one has to init an instance 
 * with the many parameters as descripted and afterwards to start. 
 * It will send the values arrived on the initialized serial port to all observers that has been added before 
 * start. 
 * These observers in best case are plugins (BARTSerialIOPlugins) knowing how to interpret the arrived stuff.
 */


#import "SerialPort.h"
#include "SerialPort_C.h"
#import <termios.h>



@interface SerialPort (hidden) 

- (NSError*) openSerialPort;	
- (NSError*) initCommunication;


- (void) dispatchData:(char)data;
- (void) readChar;
- (void) createFinalObserverList;

@end



@implementation SerialPort

@synthesize devicePath;
@synthesize deviceDescription;
@synthesize baud;
@synthesize parity;
@synthesize bits;

	

- (id) initSerialPortWithDevicePath:(NSString*)aDevicePath 
                     deviceDescript:(NSString*)aDeviceDescription
						 symbolrate:(int)aSymbolrate 
                       enableParity:(BOOL)useParity 
                          oddParity:(BOOL)oddParity 
                            andBits:(int)aBits
{

	if((self = [super init])) {
		devicePath = [aDevicePath copy];
		deviceDescription = [aDeviceDescription copy];
        baud = aSymbolrate;
        isParityEnabled = useParity;
        isParityOdd = oddParity;
        bits = aBits;
        addingObserversAllowed = YES;
        observerMutableList = [[NSMutableArray alloc] initWithCapacity:0];
        observerList = nil;
	}
	
	return self;	
}

- (NSError*) openSerialPort {

    const char *device = [devicePath cStringUsingEncoding:NSASCIIStringEncoding];
    
    int parenb = (YES == isParityEnabled) ? PARENB : 0;
    int parodd = (YES == isParityOdd) ? PARODD : 0;
    int res = FindAndOpenModem(device, strlen(device), baud, parenb, parodd, bits, &portDescriptor);
    if (res != 0) {
        NSString *domain = @"Fehler beim Finden und Oeffnen des Devices.";
        [domain stringByAppendingString:devicePath];
         
        NSError *err = [[NSError alloc] initWithDomain:domain code:res userInfo:nil];
        return [err autorelease];
    }

    return nil; 
}

- (NSError*) initCommunication {
 
    int res = InitAndStartModem(portDescriptor);
    if (res != 0) {
        NSString *domain = @"Fehler bei der Kommunikation mit dem Device.";
        [domain stringByAppendingString:devicePath];

        NSError *err = [[NSError alloc] initWithDomain:domain code:res userInfo:nil];
        return err;
    }
	
    return nil;
}

-(void)closeSerialPort:(NSError*)err {
    
	err = nil;
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_apply([observerList count], queue, ^(size_t i) {
        NSLog(@"sending connectionIsClosed() to: %@", [observerList objectAtIndex:i]);
		[((id<BARTSerialIOProtocol>) [observerList objectAtIndex:i]) connectionIsClosed];
    });
	
    int res = CloseSerialPort(portDescriptor);
    if (res != 0) {
        NSString *domain = @"Fehler beim Schließen des Devices.";
        [domain stringByAppendingString:devicePath];
        err = [NSError errorWithDomain:domain code:res userInfo:nil];
        if (nil != err)
        {
            NSLog(@"Error closing serial Port: %s, %lu",[err.domain UTF8String], err.code);
        }
	}
    NSLog(@"serial port closed: %@", devicePath);
    return;
}


- (void) readChar {

    int isValid = 0;
    
    char c = ReadData(portDescriptor, &isValid) & 0xFF;    
    if(isValid > 0) {
        [self dispatchData:c];
    }
    return;
    //return c;
}

- (void) dispatchData:(char)data {

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_apply([observerList count], queue, ^(size_t i) {
		[((id<BARTSerialIOProtocol>) [observerList objectAtIndex:i]) valueArrived:data];
    });
}



- (BOOL) addObserver:(id)anObserver {
   
	if (YES == addingObserversAllowed)
	{
		
		[anObserver retain];
		if ( ! [anObserver conformsToProtocol:@protocol(BARTSerialIOProtocol)]  ) {
			[anObserver release];
			return NO;
		}
		else {
			[observerMutableList addObject:anObserver];
		}
		return YES;
	}
	
	return NO;
}

- (void) createFinalObserverList {
	// to work with a static array 
    addingObserversAllowed = NO;
	if (observerList != nil) {
        [observerList release];
    }
    observerList = [[NSArray alloc] initWithArray:observerMutableList];
    [observerMutableList release];
}


- (void) startSerialPortThread:(NSError*)err {
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    err = [self openSerialPort];
	if(err != nil) {
        NSLog( @"Error: %s, %d\n", [err.domain UTF8String], (int) err.code );
        [pool drain];
		return;
	}
    
	err = [self initCommunication];
	if(err != nil) {
		NSLog( @"Error: %s, %d\n", [err.domain UTF8String], (int) err.code );
        [pool drain];
		return;
	}

    [self createFinalObserverList];

	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_apply([observerList count], queue, ^(size_t i) {
		[((id<BARTSerialIOProtocol>) [observerList objectAtIndex:i]) connectionIsOpen];
    });
	
	while (![[NSThread currentThread] isCancelled]) {
       // NSLog(@"read Char");
		[self readChar];        
	}
    
    //TODO: CHECK THIS
//    [self closeSerialPort:err];
//    if (nil != err){
//        NSLog( @"Error: %s, %d\n", [err.domain UTF8String], (int) err.code );
//    }
//	 
//    NSLog(@"SerialPortThread canceled! Close SerialPort now!!!");
    [pool drain];
}


- (void) dealloc {
    
    [observerList release];
    [devicePath release];
	[deviceDescription release];
    [super dealloc];
}

-(NSDictionary*)evaluateConstraintForParams:(NSDictionary*)params
{
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    __block NSDictionary *ret = nil;
    dispatch_apply([observerList count], queue, ^(size_t i) {
		ret = [((id<BARTSerialIOProtocol>) [observerList objectAtIndex:i]) evaluateConstraintForParams:params];
    });
	return ret;
}


@end
