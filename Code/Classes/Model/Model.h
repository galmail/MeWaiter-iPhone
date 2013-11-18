//
//  Model.h
//  bootstrap-ios
//
//  Created by Marcos Pinazo on 3/11/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import <Foundation/Foundation.h>

// TODO: Definir si esta aplicación tiene usuarios, si no borrar.
#import "User.h"
#import "Table.h"
#import "Floor.h"

@interface Model : NSObject

@property (strong, nonatomic) NSString *token;
// TODO: Definir si esta aplicación tiene usuarios, si no borrar.
@property (strong, nonatomic) User *loggedUser;
@property (nonatomic,strong) NSDate *LastUpdateDate;
@property (nonatomic,strong) Table *selectedTable;
@property (nonatomic,strong) Floor *selectedFloor;

+ (id)getInstance;

@end
