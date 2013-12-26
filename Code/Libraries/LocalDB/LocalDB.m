//
//  LocalDB.m
//  bootstrap-ios
//
//  Created by Marcos Pinazo on 2/1/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "LocalDB.h"

#import "Constants.h"
#import "Restaurant.h"
#import "Menu.h"
#import "Section.h"
#import "Dish.h"
#import "Table.h"
#import "Floor.h"
#import "OrderMod.h"
#import "Discount.h"
#import "Payment.h"

@implementation LocalDB

- (id)init
{
	if (self = [super init]) {
		isOpen = NO;
	}
	return self;
}

- (BOOL)configMultithreading
{
	// Intentamos abrir la base de datos en modo SERIALIZED (multithreading-safe):
	
	// Primero analizamos si es posible o no, esto depende de una variable de compilación:
	/*
     The default is SQLITE_THREADSAFE=1 which is safe for use in a multithreaded environment. When compiled with SQLITE_THREADSAFE=0 all
     mutexing code is omitted and it is unsafe to use SQLite in a multithreaded program. When compiled with SQLITE_THREADSAFE=2, SQLite can
     be used in a multithreaded program so long as no two threads attempt to use the same database connection at the same time.
	 
     Si se compiló con SQLITE_THREADSAFE = 0, no es posible activar el modo multithread. En otro caso sí que es posible.
     */
	// Modificaciones en iOS 5: http://stackoverflow.com/questions/7795973/setting-sqlite-config-sqlite-config-serialized-returns-sqlite-misuse-on-ios-5
    // Ver también: http://www.sqlite.org/c3ref/c_config_getmalloc.html
	int threadsafety = sqlite3_threadsafe();
    
    #ifdef LOG_SQLITE
	NSLog(@"LocalDB: threadsafe: %d", threadsafety);
    #endif
	
	if (threadsafety != 0) {
        #ifdef LOG_SQLITE
		NSLog(@"LocalDB: es posible activar el funcionamiento en multithread");
        #endif
        
        // Ver http://stackoverflow.com/questions/7795973/setting-sqlite-config-sqlite-config-serialized-returns-sqlite-misuse-on-ios-5
        #ifdef LOG_SQLITE
        int initialize =
        #endif
        sqlite3_initialize();
        
        #ifdef LOG_SQLITE
        NSLog(@"LocalDB: inicializando BD: %d", initialize);
        #endif
        
        #ifdef LOG_SQLITE
        int shutdown =
        #endif
        sqlite3_shutdown();
        
        #ifdef LOG_SQLITE
        NSLog(@"LocalDB: ahora toca hacer shutdwon: %d", shutdown);
        #endif
        
		int result = sqlite3_config(SQLITE_CONFIG_SERIALIZED);
		if (result != SQLITE_OK) {
            
            #ifdef LOG_SQLITE
			NSLog(@"LocalDB: NO SE HA PODIDO ACTIVAR EL MODO SERIALIZED");
            #endif
			
			return NO;
		} else {
            #ifdef LOG_SQLITE
			NSLog(@"LocalDB: ACTIVADO EL MODO SERIALIZED");
            #endif
			return YES;
		}
        
	} else {
        #ifdef LOG_SQLITE
        NSLog(@"LocalDB: NO ES POSIBLE ACTIVAR EL MODO SERIALIZED");
        #endif
		
		return NO;
	}
}

- (BOOL)open
{
	
	BOOL multithreadSupported = [self configMultithreading];
	if (!multithreadSupported) {
        
        #ifdef LOG_SQLITE
        NSLog(@"LocalDB: NO SE SOPORTA MULTITHREADING");
        #endif
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kLocalDBInitializationError object:self];
		return NO;
	}
    
	NSString *filePath = [self getDBFullPath];
	if (sqlite3_open([filePath UTF8String], &db) != SQLITE_OK) {
		[self close];
        
        #ifdef LOG_SQLITE
        NSLog(@"LocalDB: NO SE HA PODIDO ABRIR LA BASE DE DATOS [%@]", [self getDBFullPath]);
        #endif
		
        [[NSNotificationCenter defaultCenter] postNotificationName:kLocalDBInitializationError object:self];
        
        return NO;
	} else {

        #ifdef LOG_SQLITE
        NSLog(@"LocalDB: ABIERTA LA BASE DE DATOS [%@]", [self getDBFullPath]);
        #endif
        
		isOpen = YES;
        
        return YES;
	}
}

- (void)close
{
	sqlite3_close(db);
	isOpen = NO;
}

- (void) dealloc
{
	[self close];
}

- (BOOL)createTables
{
    BOOL success = YES;
	if (!isOpen) {
        success = [self open];
    }
    if (success) {
        char *err;
        NSString *sql;
        
        // config
        sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS config (name TEXT PRIMARY KEY, value TEXT)"];
        if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
            [self close];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLocalDBInitializationError object:self];
            success = NO;
        }
        //TODO: terminar de crear las tablas necesarias del restaurante
        sql=[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS restaurant (name TEXT PRIMARY KEY, pos_ip_address TEXT, logo TEXT, i18nbgs TEXT)"];
        if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
            [self close];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLocalDBInitializationError object:self];
            success = NO;
        }
        //menus
        sql=[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS menus (id INTEGER, sid TEXT, name TEXT, menu_type TEXT, price TEXT,order_id INTEGER PRIMARY KEY)"];
        if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
            [self close];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLocalDBInitializationError object:self];
            success = NO;
        }
        //sections
        sql=[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS sections (id INTEGER,menu_id INTEGER, sid TEXT, name TEXT, mini TEXT, thumbnail TEXT,order_id INTEGER PRIMARY KEY)"];
        if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
            [self close];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLocalDBInitializationError object:self];
            success = NO;
        }
        //Subsections
        sql=[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS subsections (sid TEXT, id_menu INTEGER, id INTEGER, id_section INTEGER, name TEXT, short_title TEXT, mini TEXT, order_id INTEGER PRIMARY KEY)"];
        if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
            [self close];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLocalDBInitializationError object:self];
            success = NO;
        }
        //dishes
        sql=[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS dishes(id INTEGER,menu_id INTEGER ,section_id INTEGER, sid TEXT, name TEXT, price TEXT, sd_dish_id TEXT, short_title TEXT, description TEXT,order_id INTEGER PRIMARY KEY)"];
        if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
            [self close];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLocalDBInitializationError object:self];
            success = NO;
        }
        
        //Floors
        sql=[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS floors(id INTEGER PRIMARY KEY, sid TEXT, name TEXT)"];
        if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
            [self close];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLocalDBInitializationError object:self];
            success = NO;
        }
        
        //Tables
        sql=[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS tables(id INTEGER PRIMARY KEY, sid TEXT, number INTEGER, floor_id INTEGER, status INTEGER)"];
        if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
            [self close];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLocalDBInitializationError object:self];
            success = NO;
        }
        //Users
        sql=[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS user(user_id TEXT PRIMARY KEY, mwkey TEXT, api_key TEXT, location_id TEXT, device_id TEXT,employee_id TEXT)"];
        if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
            [self close];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLocalDBInitializationError object:self];
            success = NO;
        }
        //Modifier_list
        sql=[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS modifier_list (id_mls INTEGER, sid TEXT, id_list INTEGER, name TEXT, is_mandatory TEXT, is_multioption TEXT,selected_modifier_sid TEXT)"]; // antes id_list INTEGER PRIMARY KEY
        if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
            [self close];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLocalDBInitializationError object:self];
            success = NO;
        }
        //Modifier_list_set
        sql=[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS modifier_list_set (sid TEXT, id INTEGER PRIMARY KEY, name TEXT)"];
        if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
            [self close];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLocalDBInitializationError object:self];
            success = NO;
        }
        //Modifier
        sql=[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS modifier (sid TEXT, id_modifier INTEGER PRIMARY KEY, id_list INTEGER, name TEXT, sd_modifierid TEXT, description TEXT, price TEXT)"];
        if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
            [self close];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLocalDBInitializationError object:self];
            success = NO;
        }
        //Orders
        sql=[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS orders (sid TEXT, product_name TEXT, category_sid TEXT, status INTEGER, note TEXT, price TEXT, quantity INTEGER, id INTEGER PRIMARY KEY , id_table INTEGER)"];
        if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
            [self close];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLocalDBInitializationError object:self];
            success = NO;
        }
        //Order_mods
        sql=[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS order_mods (id_order INTEGER, sid_mls TEXT, sid_ml TEXT, sid_modifier TEXT, value TEXT)"];
        if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
            [self close];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLocalDBInitializationError object:self];
            success = NO;
        }
        //dish_mod
        sql=[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS dish_mod (id INTEGER PRIMARY KEY, id_mls INTEGER, sid TEXT)"];
        if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
            [self close];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLocalDBInitializationError object:self];
            success = NO;
        }
        //info
        sql=[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS info (id INTEGER PRIMARY KEY, name TEXT, version TEXT, os TEXT, term_of_use TEXT, private_policy TEXT, whats_new TEXT, link_to_store TEXT)"];
        if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
            [self close];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLocalDBInitializationError object:self];
            success = NO;
        }
        //discounts
        sql=[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS discounts (id INTEGER PRIMARY KEY,sid TEXT,name TEXT,dtype TEXT,amount TEXT,position INTEGER, note TEXT,restaurant_id TEXT,menu_id TEXT,section_id TEXT,dish_id TEXT)"];
        if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
            [self close];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLocalDBInitializationError object:self];
            success = NO;
        }
        //discounts
        sql=[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS order_discounts (id INTEGER PRIMARY KEY, order_id INTEGER, discount_sid TEXT)"];
        if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
            [self close];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLocalDBInitializationError object:self];
            success = NO;
        }
        //payments
        sql=[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS payments (id INTEGER, position INTEGER PRIMARY KEY, sid TEXT, name TEXT, payment_key TEXT)"];
        if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
            [self close];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLocalDBInitializationError object:self];
            success = NO;
        }
    }
    return success;
}

- (void)executeBatch:(NSString *)query
{
	if (!isOpen) [self open];
	
	char *err;
	NSString *sql = [NSString stringWithFormat:@"%@%@%@",
					 @"BEGIN; ",
					 query,
					 @"; COMMIT;"
					 ];
	
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
        #ifdef LOG_SQLITE
		NSLog(@"Error al ejecutar la query: executeBatch: %s", err);
        #endif
	}
}

- (NSString *)getDBFullPath
{
    return @"";
}

#pragma mark - config methods

- (void)insertConfigWithName:(NSString *)configName andValue:(NSString *)configValue
{
	if (!isOpen) [self open];
	
	char *err;
	NSString *sql = [NSString stringWithFormat:@"insert or replace into config(name, value) values ('%@', '%@')",
					 [configName stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
					 [configValue stringByReplacingOccurrencesOfString:@"'" withString:@"''"]
					 ];
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
        #ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: insertConfigWithName: %s", err);
        #endif
	}
}

- (NSString *)getConfigWithName:(NSString *)configName
{
	if (!isOpen) [self open];
	
	NSString *value = nil;
	NSString *sql = [NSString stringWithFormat:@"select value from config where name = '%@'", [configName stringByReplacingOccurrencesOfString:@"'" withString:@"''"]];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
			value = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
		}
	} else {
		[self close];
        #ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: getConfigWithName");
        #endif
	}
	sqlite3_finalize(compiledStatement);
	return value;
}

- (void)deleteConfigWithName:(NSString *)configName
{
	if (!isOpen) [self open];
	
	char *err;
	NSString *sql = [NSString stringWithFormat:@"delete from config where name = '%@'", [configName stringByReplacingOccurrencesOfString:@"'" withString:@"''"]];
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
        #ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: deleteConfigWithName: %s", err);
        #endif
	}
}

#pragma mark - restaurant methods

- (void)insertRestaurantWithInfo:(Restaurant *)restaurant
{
	if (!isOpen) [self open];
	
	char *err;
	NSString *sql = [NSString stringWithFormat:@"insert or replace into restaurant(name, pos_ip_address, logo, i18nbgs ) values ('%@', '%@', '%@', '%@')",
					 [restaurant name],[restaurant posIpAddress],[restaurant logo],[restaurant i18nbg]
					 ];
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
        #ifdef LOG_SQLITE
                NSLog(@"LocalDB: Error al ejecutar la query: insertConfigWithName: %s", err);
        #endif
	}
}

- (Restaurant *)getRestaurantWithName:(NSString *)restaurantName
{
	if (!isOpen) [self open];
	
	Restaurant *restaurant = [[Restaurant alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from restaurant where name = '%@'", [restaurantName stringByReplacingOccurrencesOfString:@"'" withString:@"''"]];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
			restaurant.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
            restaurant.posIpAddress= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
            restaurant.logo = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
            restaurant.i18nbg=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
		}
	} else {
		[self close];
        #ifdef LOG_SQLITE
                NSLog(@"LocalDB: Error al ejecutar la query: getConfigWithName");
        #endif
	}
	sqlite3_finalize(compiledStatement);
	return restaurant;
}

- (Restaurant *)getRestaurant
{
	if (!isOpen) [self open];
	
	Restaurant *restaurant = [[Restaurant alloc]init];
	NSString *sql = [NSString stringWithFormat:@"SELECT * FROM restaurant ORDER BY ROWID ASC LIMIT 1"];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
			restaurant.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
            restaurant.posIpAddress= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
            restaurant.logo = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
            restaurant.i18nbg=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
            restaurant.menus=[self getMenuArray];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: getConfigWithName");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return restaurant;
}

- (void)deleteRestaurantWithName:(NSString *)restaurantName
{
	if (!isOpen) [self open];
	
	char *err;
	NSString *sql = [NSString stringWithFormat:@"delete from restaurant where name = '%@'", [restaurantName stringByReplacingOccurrencesOfString:@"'" withString:@"''"]];
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
        #ifdef LOG_SQLITE
                NSLog(@"LocalDB: Error al ejecutar la query: deleteConfigWithName: %s", err);
        #endif
	}
}

#pragma mark - Menu methods

- (void)insertMenu:(Menu *)menu
{
	if (!isOpen) [self open];
	//(id text PRIMARY KEY, sid text, name text, menu_type text, price text)
	char *err;
	NSString *sql = [NSString stringWithFormat:@"insert or replace into menus(id, sid, name, menu_type, price,order_id ) values ('%i', '%@', '%@', '%@', '%@', null)",
					 [menu menuId],[menu sid],[menu name],[menu menuType],[menu price]
					 ];
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: insertConfigWithName: %s", err);
#endif
	}
}

- (Menu*)getMenuWithId:(int )menuId
{
	if (!isOpen) [self open];
	
	Menu *menu = [[Menu alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from menus where id = '%i'", menuId ];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
			menu.menuId = menuId;
            menu.sid= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
            menu.name= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
            menu.menuType=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
            menu.price=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: getConfigWithName");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return menu;
}

- (int)getMenuIdWithSid:(NSString *)sid
{
	if (!isOpen) [self open];
	
	Menu *menu = [[Menu alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from menus where sid = '%@'", sid ];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
			menu.menuId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)] intValue];
            menu.sid= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
            menu.name= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
            menu.menuType=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
            menu.price=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: getConfigWithName");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return menu.menuId;
}


- (NSMutableArray*)getMenuArray
{
	if (!isOpen) [self open];
	
	NSMutableArray *menuArray=[[NSMutableArray alloc]init];
	NSString *sql =@"select * from menus ";
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            Menu *menu = [[Menu alloc]init];
			menu.menuId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)] intValue];
            menu.sid= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
            menu.name= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
            menu.menuType=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
            menu.price=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
            menu.sections=[self getSectionsArrayWithMenuId:menu.menuId];
            [menuArray addObject:menu];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: getConfigWithName");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return menuArray;
}

- (void)deleteMenuWithId:(int )menuId
{
	if (!isOpen) [self open];
	
	char *err;
	NSString *sql = [NSString stringWithFormat:@"delete from menus where id = '%i'", menuId];
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: deleteConfigWithName: %s", err);
#endif
	}
}

- (void)deleteMenus
{
	if (!isOpen) [self open];
	
	char *err;
	NSString *sql = @"delete from menus ";
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: deleteConfigWithName: %s", err);
#endif
	}
}

#pragma mark - Sections methods

- (void)insertWithSection:(Section *)section menuId:(int)menuId
{
	if (!isOpen) [self open];
	//(id text PRIMARY KEY, sid text, name text, menu_type text, price text)
	char *err;
	NSString *sql = [NSString stringWithFormat:@"insert or replace into sections(id, menu_id, sid, name, mini, thumbnail,order_id ) values ('%i','%i' ,'%@', '%@', '%@', '%@',null)",
					 [section sectionId],menuId,[section sid],[section name],[section mini],[section thumbnail]
					 ];
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: insertConfigWithName: %s", err);
#endif
	}
}

- (Section*)getSectionWithId:(int )sectionId
{
	if (!isOpen) [self open];
	
	Section *section = [[Section alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from sections where id = '%i'", sectionId ];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
			section.sectionId = sectionId;
            section.sid= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
            section.name= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
            section.mini=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
            section.thumbnail=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: getConfigWithName");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return section;
}

- (NSMutableArray*)getSectionsArrayWithMenuId:(int )menuId
{
	if (!isOpen) [self open];
	
	NSMutableArray *sectionsArray=[[NSMutableArray alloc] init];
	NSString *sql = [NSString stringWithFormat:@"select * from sections where menu_id ='%i'", menuId ];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            Section *section = [[Section alloc]init];
			section.sectionId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)] intValue];
            section.sid= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
            section.name= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
            section.mini=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
            section.thumbnail=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
            section.dishes=[self getDishesArrayWithSectionId:section.sectionId];
            section.subsections=[self getSubsectionsArrayWithSectionId:section.sectionId];
            [sectionsArray addObject:section];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: getConfigWithName");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return sectionsArray;
}



- (void)deleteSectionWithId:(int )menuId
{
	if (!isOpen) [self open];
	
	char *err;
	NSString *sql = [NSString stringWithFormat:@"delete from sections where id = '%i'", menuId];
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: deleteConfigWithName: %s", err);
#endif
	}
}

- (void)deleteSections
{
	if (!isOpen) [self open];
	
	char *err;
	NSString *sql =@"delete from sections ";
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: deleteConfigWithName: %s", err);
#endif
	}
}

#pragma mark - Sections methods

- (void)insertSubsection:(Section *)subsection menuId:(int)menuId sectionId:(int)sectionId
{
	if (!isOpen) [self open];
	//subsections (sid TEXT, id_menu INTEGER, id INTEGER, id_section TEXT, name TEXT, short_title TEXT, mini TEXT, order_id INTEGER PRIMARY KEY)
	char *err;
	NSString *sql = [NSString stringWithFormat:@"insert or replace into subsections (sid, id_menu, id, id_section, name, short_title, mini, order_id) values ('%@','%i' ,'%i', '%i', '%@', '%@', '%@',null)",[subsection sid],menuId,[subsection sectionId],sectionId,[subsection name],@"",[subsection mini]];
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: insertConfigWithName: %s", err);
#endif
	}
}

- (NSMutableArray*)getSubsectionsArrayWithSectionId:(int )sectionId
{
	if (!isOpen) [self open];
	
	NSMutableArray *sectionsArray=[[NSMutableArray alloc] init];
	NSString *sql = [NSString stringWithFormat:@"select * from subsections where id_section ='%i'", sectionId ];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            Section *section = [[Section alloc]init];
            //(sid, id_menu, id, id_section, name, short_title, mini, order_id)
			section.sectionId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)] intValue];
            section.sid= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
            section.name= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
            section.mini=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
            section.dishes=[self getDishesArrayWithSectionId:section.sectionId];
            [sectionsArray addObject:section];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: getConfigWithName");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return sectionsArray;
}

- (void)deleteSubsections
{
	if (!isOpen) [self open];
	
	char *err;
	NSString *sql =@"delete from subsections ";
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: deleteConfigWithName: %s", err);
#endif
	}
}

#pragma mark - Dishes methods

- (void)insertWithDish:(Dish *)dish menuId:(int)menuId sectionId:(int)sectionId
{
	if (!isOpen) [self open];
	char *err;
	NSString *sql = [NSString stringWithFormat:@"insert or replace into dishes(id ,menu_id, section_id, sid, name, price, sd_dish_id, short_title, description,order_id) values ('%i', '%i', '%i', '%@', '%@', '%@', '%@', '%@', '%@',null)",
					 [dish dishId],menuId,sectionId,[dish sid],[dish name],[dish price],[dish sdDishId],[dish shortTitle],[dish dishDescription]];
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: insertConfigWithName: %s", err);
#endif
	}
}

- (Dish*)getDishWithId:(int )dishId
{
	if (!isOpen) [self open];
	
	Dish *dish = [[Dish alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from dishes where id = '%i'", dishId ];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
			dish.dishId = dishId;
            dish.sid= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
            dish.name= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
            dish.price=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
            dish.sdDishId=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)];
            dish.shortTitle=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)];
            dish.dishDescription=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: getConfigWithName");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return dish;
}

- (int)getSectionIdOfDishWithId:(int )dishId
{
	if (!isOpen) [self open];
	
	int sectionId=0;
	NSString *sql = [NSString stringWithFormat:@"select * from dishes where id = '%i'", dishId ];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            sectionId= [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)] intValue];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: getConfigWithName");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return sectionId;
}

- (int)getMenuIdOfDishWithId:(int )dishId
{
	if (!isOpen) [self open];
	
	int menuId=0;
	NSString *sql = [NSString stringWithFormat:@"select * from dishes where id = '%i'", dishId ];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            menuId= [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)] intValue];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: getConfigWithName");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return menuId;
}

- (int)getMenuIdOfDishWithSid:(NSString *)sid
{
	if (!isOpen) [self open];
	
	int menuId=0;
	NSString *sql = [NSString stringWithFormat:@"select * from dishes where sid = '%@'", sid ];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            menuId= [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)] intValue];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: getConfigWithName");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return menuId;
}

- (Dish*)getDishWithName:(NSString *)dishName
{
	if (!isOpen) [self open];
	
	Dish *dish = [[Dish alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from dishes where name = '%@'", dishName ];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
			dish.dishId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)] intValue];
            dish.sid= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
            dish.name= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
            dish.price=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
            dish.sdDishId=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)];
            dish.shortTitle=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)];
            dish.dishDescription=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: getConfigWithName");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return dish;
}

- (NSMutableArray*)getDishesArrayWithSectionId:(int )sectionId
{
	if (!isOpen) [self open];
	
	NSMutableArray *dishesArray=[[NSMutableArray alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from dishes where section_id = '%i'", sectionId ];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            Dish *dish = [[Dish alloc]init];
			dish.dishId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)] intValue];
            dish.sid= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
            dish.name= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
            dish.price=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
            dish.sdDishId=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)];
            dish.shortTitle=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)];
            dish.dishDescription=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)];
            [dishesArray addObject:dish];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: getConfigWithName");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return dishesArray;
}

- (void)deleteDishWithId:(int )dishId
{
	if (!isOpen) [self open];
	
	char *err;
	NSString *sql = [NSString stringWithFormat:@"delete from dishes where id = '%i'", dishId];
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: deleteConfigWithName: %s", err);
#endif
	}
}

- (void)deleteDishes
{
	if (!isOpen) [self open];
	
	char *err;
	NSString *sql =@"delete from dishes ";
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: deleteConfigWithName: %s", err);
#endif
	}
}


#pragma mark - Tables methods

- (void)insertTable:(Table *)table floorId:(int)floorId
{
	if (!isOpen) [self open];
	//(id text PRIMARY KEY, sid text, name text, menu_type text, price text)
	char *err;
	NSString *sql = [NSString stringWithFormat:@"insert or replace into tables(id, sid, number, floor_id) values ('%i', '%@', '%i', '%i')",
					 [table tableId],[table sid],[table tableNumber],floorId];
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: insertConfigWithName: %s", err);
#endif
	}
}

- (Table*)getTableWithId:(int )tableId
{
	if (!isOpen) [self open];
	
	Table *table = [[Table alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from tables where id = '%i'", tableId ];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
			table.tableId = tableId;
            table.sid= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
            table.tableNumber= [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,2)] intValue];
            table.floorId=[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,3)]intValue];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: getConfigWithName");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return table;
}

- (NSMutableArray*)getTablesArrayWithFloorId:(int )floorId
{
	if (!isOpen) [self open];
	
	NSMutableArray *TablesArray=[[NSMutableArray alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from tables where floor_id = '%i'", floorId ];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            Table *table = [[Table alloc]init];
			table.tableId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)] intValue];
            table.sid= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
            table.tableNumber= [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,2)] intValue];
            [TablesArray addObject:table];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: getConfigWithName");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return TablesArray;
}

- (void)deleteTableWithId:(int )tableId
{
	if (!isOpen) [self open];
	
	char *err;
	NSString *sql = [NSString stringWithFormat:@"delete from tables where id = '%i'", tableId];
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: deleteConfigWithName: %s", err);
#endif
	}
}

- (void)deleteTables
{
	if (!isOpen) [self open];
	
	char *err;
	NSString *sql =@"delete from tables ";
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: deleteConfigWithName: %s", err);
#endif
	}
}

#pragma mark - Floors methods

- (void)insertfloor:(Floor*)floor
{
	if (!isOpen) [self open];
	//(id text PRIMARY KEY, sid text, name text, menu_type text, price text)
	char *err;
	NSString *sql = [NSString stringWithFormat:@"insert or replace into floors(id, sid, name) values ('%i', '%@', '%@')",
					 floor.floorId,floor.sid,floor.name];
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: insertConfigWithName: %s", err);
#endif
	}
}

- (Floor*)getFloorWithId:(int )floorId
{
	if (!isOpen) [self open];
	
	Floor *floor = [[Floor alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from floors where id = '%i'", floorId ];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
			floor.floorId= floorId;
            floor.sid= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
            floor.name= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,2)];
            floor.tables=[self getTablesArrayWithFloorId:floorId];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: getConfigWithName");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return floor;
}

- (NSMutableArray*)getFloorsArray
{
	if (!isOpen) [self open];
	
	NSMutableArray *floorsArray=[[NSMutableArray alloc]init];
	NSString *sql =@"select * from floors";
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            Floor *floor = [[Floor alloc]init];
			floor.floorId= [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)] intValue];
            floor.sid= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
            floor.name= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,2)];
            floor.tables=[self getTablesArrayWithFloorId:floor.floorId];
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"tableNumber" ascending:YES];
            floor.tables = [[floor.tables sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]] mutableCopy];
            [floorsArray addObject:floor];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: getConfigWithName");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return floorsArray;
}

- (void)deleteFloorWithId:(int )floorId
{
	if (!isOpen) [self open];
	
	char *err;
	NSString *sql = [NSString stringWithFormat:@"delete from floors where id = '%i'", floorId];
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: deleteConfigWithName: %s", err);
#endif
	}
}
- (void)deleteFloors
{
	if (!isOpen) [self open];
	
	char *err;
	NSString *sql =@"delete from floors";
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: deleteConfigWithName: %s", err);
#endif
	}
}

#pragma mark - User methods

- (void)insertWithUser:(User *)user
{
	if (!isOpen) [self open];
	//(id text PRIMARY KEY, sid text, name text, menu_type text, price text)
	char *err;
	NSString *sql = [NSString stringWithFormat:@"insert or replace into user(user_id,mwkey,api_key,location_id,device_id,employee_id) values ('%@', '%@', '%@', '%@', '%@', '%@')",
					 [user userId],[user mwKey],[user apiKey],[user locationId],[user deviceId],[user employee_id]];
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: insertConfigWithName: %s", err);
#endif
	}
}

- (User*)getUserWithId:(int )userId
{
	if (!isOpen) [self open];
	
	User *user = [[User alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from user where id = '%i'", userId ];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
			user.userId = [NSString stringWithFormat:@"%i",userId];
            user.mwKey= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
            user.apiKey= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,2)];
            user.locationId= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,3)];
            user.deviceId= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,4)];
            user.employee_id= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,5)];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: getUserWithId");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return user;
}

- (User*)getUser
{
	if (!isOpen) [self open];
	
	User *user = [[User alloc]init];
	NSString *sql = @"select * from user ORDER BY ROWID ASC LIMIT 1 ";
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
			user.userId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
            user.mwKey= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
            user.apiKey= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,2)];
            user.locationId= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,3)];
            user.deviceId= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,4)];
            user.employee_id= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,5)];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: getUserWithId");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return user;
}

- (User*)getUserWithApiKey:(NSString *)apiKey
{
	if (!isOpen) [self open];
	
	User *user = [[User alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from user where api_key = '%@'", apiKey ];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
			user.userId =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,0)];
            user.mwKey= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
            user.apiKey= apiKey;
            user.locationId= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,3)];
            user.deviceId= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,4)];
            user.employee_id= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,5)];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: getUserWithApiKey");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return user;
}

- (void)deleteUserWithId:(int )userId
{
	if (!isOpen) [self open];
	
	char *err;
	NSString *sql = [NSString stringWithFormat:@"delete from user where id = '%i'", userId];
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: deleteUserWithId: %s", err);
#endif
	}
}

-(void) deleteAllUsers
{
    if (!isOpen) [self open];
	
	char *err;
	NSString *sql = @"delete from user";
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: deleteAllUsers: %s", err);
#endif
	}
}


#pragma mark - Modifier_List_sets methods

- (void)insertModifierListSet:(ModifierListSets *)modifierListSet
{
	if (!isOpen) [self open];
	
	char *err;
	NSString *sql = [NSString stringWithFormat:@"insert or replace into modifier_list_set (sid, id, name) values ('%@', '%i', '%@')",
					 modifierListSet.sid,modifierListSet.modiferListSetsId,modifierListSet.name];
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: insertModifierListSet: %s", err);
#endif
	}
}

- (ModifierListSets *)getModifierListSetWithid:(int )modifierListSetId
{
	if (!isOpen) [self open];
	
	ModifierListSets *modifierListSet = [[ModifierListSets alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from modifier_list_set where id = '%i'", modifierListSetId];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            modifierListSet.sid= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
            modifierListSet.modiferListSetsId =modifierListSetId;
            modifierListSet.name= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,2)];
            modifierListSet.dishes=[self getDishesModWithModifierListSetid:modifierListSetId];
            modifierListSet.modifierLists=[self getModifierListWithModifierListSetid:modifierListSetId];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: getModifierListSetWithid");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return modifierListSet;
}

- (ModifierListSets *)getModifierListSetWithSid:(NSString *)sid{
    if (!isOpen) [self open];
	
	ModifierListSets *modifierListSet = [[ModifierListSets alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from modifier_list_set where sid = '%@'", sid];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            modifierListSet.sid= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
            modifierListSet.modiferListSetsId =[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)] intValue];
            modifierListSet.name= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,2)];
            modifierListSet.dishes=[self getDishesModWithModifierListSetid:modifierListSet.modiferListSetsId];
            modifierListSet.modifierLists=[self getModifierListWithModifierListSetid:modifierListSet.modiferListSetsId];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: getModifierListSetWithid");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return modifierListSet;
}

- (void)deleteModifierListSetWithid:(int)modifierListSetId
{
	if (!isOpen) [self open];
	
	char *err;
	NSString *sql = [NSString stringWithFormat:@"delete from modifier_list_set where id = '%i'", modifierListSetId];;
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: deleteModifierListSetWithid: %s", err);
#endif
	}
}
- (void)deleteAllModifierListSet{
    if (!isOpen) [self open];
	
	char *err;
	NSString *sql = @"delete from modifier_list_set";
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: deleteAllModifierListSet: %s", err);
#endif
	}
}

#pragma mark - Modifier_List methods

- (void)insertModifierList:(ModifierList*)modifierList withModifierListSetId:(int)modifierListSetId
{
	if (!isOpen) [self open];
	
	char *err;
	NSString *sql = [NSString stringWithFormat:@"insert or replace into modifier_list (id_mls, sid, id_list, name, is_mandatory, is_multioption,selected_modifier_sid) values ( '%i','%@', '%i', '%@', '%@', '%@', '%@')",modifierListSetId,modifierList.sid,modifierList.modiferListId,modifierList.name,modifierList.isMandatory,modifierList.isMultioption,modifierList.selectedModiefierSid];
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: insertModifierList: %s", err);
#endif
	}
}

- (ModifierList *)getModifierListWithid:(int )modifierListId
{
	if (!isOpen) [self open];
	
	ModifierList *modifierList = [[ModifierList alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from modifier_list where id = '%i'", modifierListId];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            modifierList.sid= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
            modifierList.modiferListId =modifierListId;
            modifierList.name= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,3)];
            modifierList.isMandatory= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,4)];
            modifierList.isMultioption= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,5)];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: getModifierListWithid");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return modifierList;
}

- (ModifierList *)getModifierListWithSid:(NSString *)modifierListSid
{
	if (!isOpen) [self open];
	
	ModifierList *modifierList = [[ModifierList alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from modifier_list where sid = '%@'", modifierListSid];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            modifierList.sid= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
            modifierList.modiferListId =[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)] intValue];
            modifierList.name= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,3)];
            modifierList.isMandatory= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,4)];
            modifierList.isMultioption= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,5)];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: getModifierListWithid");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return modifierList;
}

- (NSMutableArray *)getModifierListWithModifierListSetid:(int )modifierListSetId
{
	if (!isOpen) [self open];
	
	NSMutableArray *modifierListArray=[[NSMutableArray alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from modifier_list where id_mls = '%i'", modifierListSetId];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            ModifierList *modifierList = [[ModifierList alloc]init];
            modifierList.sid= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
            modifierList.modiferListId =[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)] intValue];
            modifierList.name= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,3)];
            modifierList.isMandatory= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,4)];
            modifierList.isMultioption= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,5)];
            modifierList.selectedModiefierSid=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,6)];
            modifierList.modifiers=[self getModifierWithModifierListid:modifierList.modiferListId];
            [modifierListArray addObject:modifierList];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: getModifierListWithid");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return modifierListArray;
}

- (void)deleteModifierListWithid:(int)modifierListId
{
	if (!isOpen) [self open];
	
	char *err;
	NSString *sql = [NSString stringWithFormat:@"delete from modifier_list where id = '%i'", modifierListId];;
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: deleteModifierListSetWithid: %s", err);
#endif
	}
}

#pragma mark - dish_mod methods

- (void)insertDishMod:(Dish*)DishMod withModifierListSetId:(int)modifierListSetId
{
	if (!isOpen) [self open];
	
	char *err;
	NSString *sql = [NSString stringWithFormat:@"insert or replace into dish_mod (id, id_mls, sid) values ( '%i', '%i', '%@')",DishMod.dishId,modifierListSetId,DishMod.sid];
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: insertDishMod: %s", err);
#endif
	}
}

- (Dish *)getDishesModWithid:(int )DishesId
{
	if (!isOpen) [self open];
	
	Dish *dishMod = [[Dish alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from dish_mod where id = '%i'", DishesId];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            dishMod.dishId =DishesId;
            dishMod.sid= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: getDishesModWithid");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return dishMod;
}

- (NSMutableArray *)getDishesModWithModifierListSetid:(int )modifierListSetId
{
	if (!isOpen) [self open];
	
	NSMutableArray *dishesArray = [[NSMutableArray alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from dish_mod where id_mls = '%i'", modifierListSetId];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            Dish *dishMod=[[Dish alloc]init];
            dishMod.dishId =[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)] intValue];
            dishMod.sid= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
            [dishesArray addObject:dishMod];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: getDishesModWithid");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return dishesArray;
}


- (int)getIdMlsWithid:(int )DishesId
{
	if (!isOpen) [self open];
	
	int idMls =0;
	NSString *sql = [NSString stringWithFormat:@"select * from dish_mod where id = '%i'", DishesId];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            if (![[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,1)] isKindOfClass:[NSNull class]]) {
                idMls= [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,1)] intValue];
            }
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: getDishesModWithid");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return idMls;
}

- (void)deleteDishModWithid:(int)DishId
{
	if (!isOpen) [self open];
	
	char *err;
	NSString *sql = [NSString stringWithFormat:@"delete from dish_mod where id = '%i'", DishId];;
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: deleteDishModWithid: %s", err);
#endif
	}
}

#pragma mark - Modifier methods

- (void)insertModifier:(Modifier*)modifier withModifierListId:(int)modifierListId
{
	if (!isOpen) [self open];
	
	char *err;
	NSString *sql = [NSString stringWithFormat:@"insert or replace into modifier (sid, id_modifier, id_list, name, sd_modifierid, description, price) values ( '%@','%i','%i','%@', '%@', '%@', '%@')",modifier.sid,modifier.modiferId,modifierListId,modifier.name,modifier.sdModifierid,modifier.modifierDescription,modifier.price];
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: insertModifier: %s", err);
#endif
	}
}

- (Modifier *)getModifierWithid:(int )modifierId
{
	if (!isOpen) [self open];
	
	Modifier *modifier = [[Modifier alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from modifier where id_modifier = '%i'", modifierId];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            modifier.sid= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
            modifier.modiferId =modifierId;
            modifier.name= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,3)];
            modifier.sdModifierid= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,4)];
            modifier.modifierDescription= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,5)];
            modifier.price=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: getModifierWithid");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return modifier;
}

- (Modifier *)getModifierWithSid:(NSString *)modifierSid
{
	if (!isOpen) [self open];
	
	Modifier *modifier = [[Modifier alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from modifier where sid = '%@'", modifierSid];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            modifier.sid= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
            modifier.modiferId =[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)] intValue];
            modifier.name= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,3)];
            modifier.sdModifierid= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,4)];
            modifier.modifierDescription= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,5)];
            modifier.price=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: getModifierWithid");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return modifier;
}

- (NSMutableArray *)getModifierWithModifierListid:(int )modifierListId
{
	if (!isOpen) [self open];
	NSMutableArray *modifiersArray=[[NSMutableArray alloc]init];

	NSString *sql = [NSString stringWithFormat:@"select * from modifier where id_list = '%i'", modifierListId];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            Modifier *modifier = [[Modifier alloc]init];
            modifier.sid= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
            modifier.modiferId =[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)] intValue];
            modifier.name= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,3)];
            modifier.sdModifierid= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,4)];
            modifier.modifierDescription= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,5)];
            modifier.price=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)];
            [modifiersArray addObject:modifier];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: getModifierWithid");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return modifiersArray;
}

- (void)deleteModifierWithid:(int)modifierId
{
	if (!isOpen) [self open];
	
	char *err;
	NSString *sql = [NSString stringWithFormat:@"delete from modifier where id = '%i'", modifierId];;
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: deleteModifierWithid: %s", err);
#endif
	}
}

#pragma mark - Order methods
//(sid TEXT, product_name TEXT, category_sid TEXT, status INTEGER, note TEXT, price TEXT, quantity INTEGER, id INTEGER PRIMARY KEY, id_table INTEGER)

- (void)insertOrder:(Order *)order
{
	if (!isOpen) [self open];
	
	char *err;
    NSString *sql=nil;
    if (order.orderId) {
        sql = [NSString stringWithFormat:@"insert or replace into orders(sid, product_name, category_sid, status, note, price, quantity, id, id_table) values ('%@', '%@', '%@', '%i', '%@', '%@', '%i','%i', '%i')",order.sid,order.productName,order.categorySid,order.status,order.note,order.price,order.quantity,order.orderId,order.tableId];
    }else{
        sql = [NSString stringWithFormat:@"insert or replace into orders(sid, product_name, category_sid, status, note, price, quantity, id, id_table) values ('%@', '%@', '%@', '%i', '%@', '%@', '%i', null, '%i')",order.sid,order.productName,order.categorySid,order.status,order.note,order.price,order.quantity,order.tableId];
    }
	
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: insertConfigWithName: %s", err);
#endif
	}
}

- (Order *)getOrderWithid:(int)orderId
{
	if (!isOpen) [self open];
	
	Order *order = [[Order alloc] init];
	NSString *sql = [NSString stringWithFormat:@"select * from orders where id = '%i'", orderId];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            //(sid, product_name, category_sid, status, note, price, quantity, id, id_table)
			order.sid = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
            order.productName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
            order.categorySid = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
            order.status = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)] intValue];
            order.note = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
            order.price = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
            order.quantity = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)] intValue];
            order.orderId = orderId;
            order.tableId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)] intValue];
            
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: getConfigWithName");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return order;
}

-(Order*) getLastOrder{
    if (!isOpen) [self open];
	
	Order *order = [[Order alloc] init];
	NSString *sql = @"select * from orders order by id desc limit 1" ;
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            //(sid, product_name, category_sid, status, note, price, quantity, id, id_table)
			order.sid = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
            order.productName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
            order.categorySid = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
            order.status = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)] intValue];
            order.note = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
            order.price = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
            order.quantity = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)] intValue];
            order.orderId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)] intValue];
            order.tableId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)] intValue];
            
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: getConfigWithName");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return order;
}

- (NSMutableArray*)getOrdersWithTableid:(int)tableId
{
	if (!isOpen) [self open];
	NSMutableArray *OrdersArray=[[NSMutableArray alloc]init];
	
	NSString *sql = [NSString stringWithFormat:@"select * from orders where id_table = '%i'", tableId];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            Order *order = [[Order alloc] init];
			order.sid = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
            order.productName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
            order.categorySid = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
            order.status = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)] intValue];
            order.note = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
            order.price = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
            order.quantity = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)] intValue];
            order.orderId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)] intValue];
            order.tableId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)] intValue];
            [OrdersArray addObject:order];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: getConfigWithName");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return OrdersArray;
}

- (NSMutableArray*)getAllOrders
{
	if (!isOpen) [self open];
	NSMutableArray *OrdersArray=[[NSMutableArray alloc]init];
	
	NSString *sql =@"select * from orders";
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            Order *order = [[Order alloc] init];
			order.sid = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
            order.productName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
            order.categorySid = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
            order.status = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)] intValue];
            order.note = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
            order.price = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
            order.quantity = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)] intValue];
            order.orderId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)] intValue];
            order.tableId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)] intValue];
            [OrdersArray addObject:order];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: getConfigWithName");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return OrdersArray;
}

- (NSMutableSet*)getTableIdOrdersSet
{
	if (!isOpen) [self open];
	NSMutableSet *TableSet=[[NSMutableSet alloc]init];
	
	NSString *sql =@"select * from orders";
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            int tableid= [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)] intValue];
            [TableSet addObject:[NSNumber numberWithInt:tableid]];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: getConfigWithName");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return TableSet;
}

- (void)deleteOrderWithId:(int)orderId
{
	if (!isOpen) [self open];
	
	char *err;
	NSString *sql = [NSString stringWithFormat:@"delete from orders where id = '%i'", orderId];
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: deleteConfigWithName: %s", err);
#endif
	}
    sql = [NSString stringWithFormat:@"delete from order_mods where id_order = '%i'", orderId];
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: deleteConfigWithName: %s", err);
#endif
	}
    sql = [NSString stringWithFormat:@"delete from order_discounts where order_id = '%i'", orderId];
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: deleteConfigWithName: %s", err);
#endif
	}
    
}

#pragma mark - info methods

- (void)insertInfo:(InfoApp *)infoApp
{
	if (!isOpen) [self open];
	
	char *err;
    NSString *sql = [NSString stringWithFormat:@"insert or replace into info(id, name, version, os, term_of_use, private_policy, whats_new, link_to_store) values ('%i', '%@', '%@', '%@', '%@', '%@', '%@', '%@')",1,infoApp.name,infoApp.version,infoApp.os,infoApp.termOfuse,infoApp.privatePolicy,infoApp.whatsNew,infoApp.linkToStore];

	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: insertConfigWithName: %s", err);
#endif
	}
}

- (InfoApp *)getInfo
{
	if (!isOpen) [self open];
	
	InfoApp *infoApp = [[InfoApp alloc] init];
	NSString *sql = @"select * from info";
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            //(id, name, version, os, term_of_use, private_policy, whats_new, link_to_store)
			
            infoApp.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
            infoApp.version = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
            infoApp.os = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
            infoApp.termOfuse = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
            infoApp.privatePolicy = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
            infoApp.whatsNew = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)] ;
            infoApp.linkToStore= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)];
            
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: getConfigWithName");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return infoApp;
}

- (void)deleteInfo
{
	if (!isOpen) [self open];
	
	char *err;
	NSString *sql = @"delete from info";
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: deleteInfo: %s", err);
#endif
	}
}

#pragma mark - OrderMods methods

- (void) insertOrderModsWithIndexPath:(NSIndexPath*)indexpath modifiersListSet:(ModifierListSets*)modifierListSet orderId:(int)orderId{
    if (!isOpen) [self open];
	//(id_order INTEGER, sid_mls TEXT, sid_ml TEXT, sid_modifier TEXT, value TEXT)
	char *err;
    NSString *sql = [NSString stringWithFormat:@"insert or replace into order_mods(id_order, sid_mls, sid_ml, sid_modifier, value) values ('%i', '%@', '%@', '%@', '%@')",orderId,[modifierListSet sid],[[[modifierListSet modifierLists]objectAtIndex:indexpath.section] sid],[[[[[modifierListSet modifierLists]objectAtIndex:indexpath.section] modifiers]objectAtIndex:indexpath.row] sid],[[[[[modifierListSet modifierLists]objectAtIndex:indexpath.section] modifiers]objectAtIndex:indexpath.row] name]];
    
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: insertConfigWithName: %s", err);
#endif
	}
}

- (NSMutableArray*)getOrdersModsWithOrderId:(int)orderId
{
	if (!isOpen) [self open];
	NSMutableArray *OrderModsArray=[[NSMutableArray alloc]init];
	
	NSString *sql = [NSString stringWithFormat:@"select * from order_mods where id_order = '%i'", orderId];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            OrderMod *orderMod=[[OrderMod alloc]init];
            orderMod.orderId=[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)]intValue];
            orderMod.mlSetSid=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
            orderMod.mlistSid=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
            orderMod.modifierSid=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
            [OrderModsArray addObject:orderMod];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: getOrdersModsWithorderId");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return OrderModsArray;
}

-(void) deleteOrderModWithOrderId:(int) orderId
{
    if (!isOpen) [self open];
	
	char *err;
    NSString *sql = [NSString stringWithFormat:@"delete from order_mods where id_order = '%i'", orderId];
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: deleteConfigWithName: %s", err);
#endif
	}
}

#pragma mark - discount methods

-(void) insertDiscount:(Discount*)discount
{
    if (!isOpen) [self open];
	//(id INTEGER PRIMARY KEY,sid TEXT,name TEXT,dtype TEXT,amount TEXT,position INTEGER, note TEXT,restaurant_id TEXT,id_restaurant TEXT,menu_id TEXT,section_id TEXT,dish_id TEXT)
	char *err;
    NSString *sql = [NSString stringWithFormat:@"insert or replace into discounts(id,sid,name,dtype,amount,position, note,restaurant_id,menu_id,section_id,dish_id) values (null, '%@', '%@', '%@', '%@','%i', '%@','%i','%i','%i','%i')",discount.sid,discount.name,discount.dType,discount.amount,discount.position,discount.note,discount.restaurantId,discount.menuId,discount.sectionId,discount.dishId];
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: insertConfigWithName: %s", err);
#endif
	}
}

-(Discount*) getDiscountWithSid:(NSString*) sid
{
    if (!isOpen) [self open];
	Discount *discount=[[Discount alloc]init];
	
	NSString *sql = [NSString stringWithFormat:@"select * from discounts where sid = '%@'", sid];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            discount.sid=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
            discount.name=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
            discount.dType=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
            discount.amount=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
            discount.position=[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)]intValue];
            discount.note=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)];
            discount.restaurantId=[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)]intValue];
            discount.menuId=[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)]intValue];
            discount.sectionId=[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 9)]intValue];
            discount.dishId=[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 10)]intValue];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: getOrdersModsWithorderId");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return discount;
}

-(NSMutableArray *) getDiscountWithDishId:(int) dishId;
{
    if (!isOpen) [self open];
	NSMutableArray *discountsArray=[[NSMutableArray alloc]init];
	
	NSString *sql = [NSString stringWithFormat:@"select * from discounts where  dish_id = '%i'", dishId];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            Discount *discount=[[Discount alloc]init];
            discount.sid=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
            discount.name=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
            discount.dType=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
            discount.amount=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
            discount.position=[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)]intValue];
            discount.note=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)];
            discount.restaurantId=[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)]intValue];
            discount.menuId=[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)]intValue];
            discount.sectionId=[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 9)]intValue];
            discount.dishId=[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 10)]intValue];
            [discountsArray addObject:discount];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: getOrdersModsWithorderId");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return discountsArray;
}

-(NSMutableArray *) getDiscountWithMenuId:(int) menuId
{
    if (!isOpen) [self open];
	NSMutableArray *discountsArray=[[NSMutableArray alloc]init];
	
	NSString *sql = [NSString stringWithFormat:@"select * from discounts where  menu_id = '%i'", menuId];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            Discount *discount=[[Discount alloc]init];
            discount.sid=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
            discount.name=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
            discount.dType=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
            discount.amount=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
            discount.position=[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)]intValue];
            discount.note=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)];
            discount.restaurantId=[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)]intValue];
            discount.menuId=[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)]intValue];
            discount.sectionId=[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 9)]intValue];
            discount.dishId=[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 10)]intValue];
            [discountsArray addObject:discount];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: getOrdersModsWithorderId");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return discountsArray;
}

-(NSMutableArray *) getDiscountWithOnlyMenuId:(int) menuId
{
    if (!isOpen) [self open];
	NSMutableArray *discountsArray=[[NSMutableArray alloc]init];
	
	NSString *sql = [NSString stringWithFormat:@"select * from discounts where  menu_id = '%i' AND section_id='0' AND dish_id='0'", menuId];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            Discount *discount=[[Discount alloc]init];
            discount.sid=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
            discount.name=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
            discount.dType=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
            discount.amount=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
            discount.position=[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)]intValue];
            discount.note=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)];
            discount.restaurantId=[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)]intValue];
            discount.menuId=[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)]intValue];
            discount.sectionId=[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 9)]intValue];
            discount.dishId=[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 10)]intValue];
            [discountsArray addObject:discount];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: getOrdersModsWithorderId");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return discountsArray;
}

-(NSMutableArray *) getDiscountWithSectionId:(int) sectionId;
{
    if (!isOpen) [self open];
	NSMutableArray *discountsArray=[[NSMutableArray alloc]init];
	
	NSString *sql = [NSString stringWithFormat:@"select * from discounts where  section_id = '%i'", sectionId];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            Discount *discount=[[Discount alloc]init];
            discount.sid=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
            discount.name=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
            discount.dType=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
            discount.amount=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
            discount.position=[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)]intValue];
            discount.note=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)];
            discount.restaurantId=[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)]intValue];
            discount.menuId=[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)]intValue];
            discount.sectionId=[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 9)]intValue];
            discount.dishId=[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 10)]intValue];
            [discountsArray addObject:discount];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: getOrdersModsWithorderId");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return discountsArray;
}

-(NSMutableArray *) getDiscountWithMenuId:(int) menuId sectionId:(int) sectionId dishId:(int) dishId;
{
	NSMutableArray *discountsArray=[[NSMutableArray alloc]init];
    [discountsArray addObjectsFromArray:[self getDiscountWithMenuId:menuId]];
    [discountsArray addObjectsFromArray:[self getDiscountWithSectionId:sectionId]];
    [discountsArray addObjectsFromArray:[self getDiscountWithDishId:dishId]];
	return discountsArray;
}

-(NSMutableArray *) getDiscountOnlyForRestaurant
{
    if (!isOpen) [self open];
	NSMutableArray *discountsArray=[[NSMutableArray alloc]init];
	
	NSString *sql = @"select * from discounts where section_id = '0' AND menu_id = '0' AND dish_id = '0'";
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            Discount *discount=[[Discount alloc]init];
            discount.sid=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
            discount.name=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
            discount.dType=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
            discount.amount=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
            discount.position=[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)]intValue];
            discount.note=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)];
            discount.restaurantId=[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)]intValue];
            discount.menuId=[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)]intValue];
            discount.sectionId=[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 9)]intValue];
            discount.dishId=[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 10)]intValue];
            [discountsArray addObject:discount];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: getOrdersModsWithorderId");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return discountsArray;
}

-(void) deleteDiscounts{
    if (!isOpen) [self open];
	
	char *err;
	NSString *sql = @"delete from discounts";
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: deleteDiscounts: %s", err);
#endif
	}
}

#pragma mark -OrderDiscount

-(void)insertOrderDiscountWithDiscount:(Discount *)discount OrderId:(int) orderId
{
    //order_discounts (id INTEGER PRIMARY KEY, order_id INTEGER, discount_sid TEXT)
    if (!isOpen) [self open];
	char *err;
    NSString *sql = [NSString stringWithFormat:@"insert or replace into order_discounts(id, order_id, discount_sid) values (null, '%i', '%@')",orderId,discount.sid];
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: insertConfigWithName: %s", err);
#endif
	}
}

-(Discount*)getOrderDiscountWithOrderId:(int) orderId
{
    if (!isOpen) [self open];
	Discount *discount=[[Discount alloc]init];
	
	NSString *sql = [NSString stringWithFormat:@"select * from order_discounts where order_id = '%i'", orderId];
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            discount.sid=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: getOrdersModsWithorderId");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return [self getDiscountWithSid:discount.sid];
}

-(void) deleteOrderDiscountsWithOrderId:(int)orderId
{
    if (!isOpen) [self open];
	
	char *err;
	NSString *sql = [NSString stringWithFormat:@"delete from order_discounts where order_id='%i'", orderId];
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
		NSLog(@"LocalDB: Error al ejecutar la query: deleteOrderDiscountsWithOrderId: %s", err);
#endif
	}
}

#pragma mark - Tables methods

- (void)insertPayment:(Payment *)payment
{
	if (!isOpen) [self open];
	//payments (id INTEGER, position INTEGER PRIMARY KEY, sid TEXT, name TEXT, payment_key TEXT)
	char *err;
	NSString *sql = [NSString stringWithFormat:@"insert or replace into payments(id, position, sid, name, payment_key) values ('%i', '%i', '%@', '%@', '%@')",payment.paymentId,payment.position,payment.sid,payment.name,payment.key];
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: insertConfigWithName: %s", err);
#endif
	}
}

- (NSMutableArray*)getPaymentsArray
{
	if (!isOpen) [self open];
	
	NSMutableArray *PaymentsArray=[[NSMutableArray alloc]init];
	NSString *sql =@"select * from payments ";
	const char *sqlStatement = [sql UTF8String];
	sqlite3_stmt *compiledStatement;
	if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            Payment *payment = [[Payment alloc]init];
			payment.paymentId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)] intValue];
            payment.position = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)] intValue];
            payment.sid= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
            payment.name= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,3)];
            payment.key=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,4)];
            [PaymentsArray addObject:payment];
		}
	} else {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: getConfigWithName");
#endif
	}
	sqlite3_finalize(compiledStatement);
	return PaymentsArray;
}

- (void)deletePayments
{
	if (!isOpen) [self open];
	
	char *err;
	NSString *sql =@"delete from payments";
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
		[self close];
#ifdef LOG_SQLITE
        NSLog(@"LocalDB: Error al ejecutar la query: deleteConfigWithName: %s", err);
#endif
	}
}
@end
