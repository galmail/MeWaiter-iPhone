//
//  Model.m
//  bootstrap-ios
//
//  Created by Marcos Pinazo on 3/11/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "Model.h"

@implementation Model

+ (id)getInstance {
	static Model *instance = nil;
	@synchronized(self) {
		if (instance == nil) {
			instance = [[Model alloc] init];
		}
		return instance;
	}
}

- (id)init {
	if (self = [super init]) {
        self.token = nil;
        self.loggedUser = nil;
        self.LastUpdateDate=nil;
        self.selectedTable=[[Table alloc]init];
        self.selectedFloor=[[Floor alloc]init];
	}
	return self;
}

@end
