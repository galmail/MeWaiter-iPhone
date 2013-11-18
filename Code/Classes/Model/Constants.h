//
//  Constants.h
//  bootstrap-ios
//
//  Created by Marcos Pinazo on 2/1/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#ifndef bootstrap_Constants_h
#define bootstrap_Constants_h

#import "CommonUtil.h"

#define APP_NAME @"bootstrap-ios"

/*** ENTORNO DE EJECUCIÓN ***/
#define DEVELOPMENT
//#define PREPRODUCTION
//#define PRODUCTION
/****************************/

// URL de la API:
// TODO: Definir la URL de la API de esta aplicación (si procede, si no eliminar todo el código relativo a API).
#define API_VERSION @""//antes era #define API_VERSION @"/v1"

#ifdef DEVELOPMENT
#define API_BASE_URL @"http://beta.tocarta.com"
#define POS_API_BASE_URL @"http://192.168.1.3:8080"

#if TARGET_IPHONE_SIMULATOR
#define API_CLIENT_ID @"0"
#else
#define API_CLIENT_ID @"0"//[[[UIDevice currentDevice] identifierForVendor] UUIDString]
#endif

#define API_CLIENT_SECRET [[[Model getInstance] loggedUser] mwKey]
#endif

#ifdef PREPRODUCTION
#define API_BASE_URL @"http://beta.tocarta.com"
#define POS_API_BASE_URL @"http://192.168.1.3:8080"
#if TARGET_IPHONE_SIMULATOR
#define API_CLIENT_ID @"0"
#else
#define API_CLIENT_ID /*@"0"*/[[[UIDevice currentDevice] identifierForVendor] UUIDString]
#endif

#define API_CLIENT_SECRET [[[Model getInstance] loggedUser] mwKey]
//#define API_CLIENT_ID @"dev"
//#define API_CLIENT_SECRET @"UNSECURE"
#endif

#ifdef PRODUCTION
#define API_BASE_URL @"http://beta.tocarta.com"
#define POS_API_BASE_URL @"http://192.168.1.3:8080"
#if TARGET_IPHONE_SIMULATOR
#define API_CLIENT_ID @"0"
#else
#define API_CLIENT_ID /*@"0"*/[[[UIDevice currentDevice] identifierForVendor] UUIDString]
#endif

#define API_CLIENT_SECRET [[[Model getInstance] loggedUser] mwKey]
//#define API_CLIENT_ID @"dev"
//#define API_CLIENT_SECRET @"UNSECURE"
#endif

// Google Analytics ID:
#define GAID @"UA-XXXXXX-X" // TODO: Definir el Google ID para esta aplicación.

// Trazas:
//#define LOG_VERBOSE
//#define LOG_SQLITE
#define LOG_API

// TODO: Definir si esta aplicación tiene usuarios, si no borrar.
#define SETTINGS_TOKEN @"SETTINGS_TOKEN"
#define SETTINGS_LAST_UPDATE @"SETTINGS_LAST_UPDATE"
#define SETTINGS_LAST_SUGGESTION_UPDATE @"SETTINGS_LAST_SUGGESTION_UPDATE"
#define KsugestionString @"sugestionString"
#define KinfoString @"infoString"
#define KResizeNoteView 100
#endif
