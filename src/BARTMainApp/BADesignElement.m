//
//  BADesignElement.m
//  BARTCommandLine
//
//  Created by First Last on 11/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BADesignElement.h"
#import "NEDesignElementVI.h"
#import "NEDesignElementDyn.h"


@implementation BADesignElement

@synthesize mRepetitionTimeInMs;
@synthesize mNumberExplanatoryVariables;
@synthesize mNumberTimesteps;
@synthesize mImageDataType;
@synthesize mNumberRegressors;
@synthesize mNumberCovariates;

-(id)init
{
	self = [super init];
	if (nil != self){
		mRepetitionTimeInMs = 0;
		mNumberExplanatoryVariables = 0;
		mNumberTimesteps = 0;
		mImageDataType = 0;
		mNumberRegressors = 0;
		mNumberCovariates = 0;
	}
	return self;
}

-(id)initWithDatasetFile:(NSString*)path ofImageDataType:(enum ImageDataType)type
{
    // TODO!!
	self = [super init];
    [self release];
    self = [[NEDesignElementDyn alloc] initWithFile:path ofImageDataType:type];
    return self;
}


-(NSError*)writeDesignFile:(NSString*) path
{
    [self doesNotRecognizeSelector:_cmd];
	return nil;
}

-(id)copyWithZone:(NSZone *)zone
{
	id newDesign = [[[self class] allocWithZone:zone] init];
	
	[newDesign setMRepetitionTimeInMs:[self mRepetitionTimeInMs]];
	[newDesign setMNumberExplanatoryVariables: [self mNumberExplanatoryVariables]];
	[newDesign setMNumberTimesteps: [self mNumberTimesteps]];
	[newDesign setMNumberRegressors: [self mNumberRegressors]];
	[newDesign setMNumberCovariates: [self mNumberCovariates]];
	[newDesign setMImageDataType: [self mImageDataType]];
	
	
	return newDesign;
}

-(void)setRegressor:(TrialList *)regressor
{
    [self doesNotRecognizeSelector:_cmd];
	return;
}

-(void)setRegressorValue:(Trial)value forRegressorID:(int)regID atTimestep:(int)timestep
{
	[self doesNotRecognizeSelector:_cmd];
	return;
}

-(void)setCovariate:(float*)covariate forCovariateID:(int)covID
{
	[self doesNotRecognizeSelector:_cmd];
	return;
}

-(void)setCovariateValue:(float)value forCovariateID:(int)covID atTimestep:(int)timestep
{
	[self doesNotRecognizeSelector:_cmd];
	return;
}

@end





