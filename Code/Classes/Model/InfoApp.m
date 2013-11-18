//
//  InfoApp.m
//  meWaiter-ios
//
//  Created by omar megdadi on 21/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "InfoApp.h"

@implementation InfoApp
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
- (id) initWithDictionary: (NSDictionary *) dictionary
{
    self = [super init];
    if (self) {
        
        [self hydrateWithDictionary: dictionary];
    }
    return self;
}

- (void) hydrateWithDictionary: (NSDictionary *) dictionary
{
    self.name=[dictionary objectForKey:@"name"];
    self.version=[dictionary objectForKey:@"version"];
    self.os=[dictionary objectForKey:@"os"];
    self.termOfuse=[dictionary objectForKey:@"terms_of_use"];
    self.privatePolicy=[dictionary objectForKey:@"privacy_policy"];
    self.whatsNew=[dictionary objectForKey:@"whats_new"];
    self.linkToStore=[dictionary objectForKey:@"link_to_store"];
}
@end
