//
//  InfoApp.h
//  meWaiter-ios
//
//  Created by omar megdadi on 21/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InfoApp : NSObject
/*
 waiter_app: {
 name: "MeWaiter Android App en Español",
 version: "1.0.0",
 os: "Android 2.3+",
 terms_of_use: "Aqui van los términos de uso",
 privacy_policy: "Aquí va la política de privacidad y protección de datos",
 whats_new: "Aquí va lo nuevo en este release",
 link_to_store: "https://play.google.com/store/apps/details?id=com.halfbrick.fruitninjafree"
 }
 */
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *version;
@property (nonatomic,strong) NSString *os;
@property (nonatomic,strong) NSString *termOfuse;
@property (nonatomic,strong) NSString *privatePolicy;
@property (nonatomic,strong) NSString *whatsNew;
@property (nonatomic,strong) NSString *linkToStore;

- (id) initWithDictionary: (NSDictionary *) dictionary;
@end
