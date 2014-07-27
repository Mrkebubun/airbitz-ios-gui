//
//  CommonTypes.h
//  AirBitz
//
//  See LICENSE for copy, modification, and use permissions
//
//  See AUTHORS for contributing developers
//

#import <Foundation/Foundation.h>

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
#define IS_IPHONE5                                  (([[UIScreen mainScreen] bounds].size.height == 568) ? YES : NO)

#define COLOR_BAR_TINT          [UIColor colorWithRed:0.0 / 255.0 green:94.0 / 255.0 blue:155.0 / 255.0 alpha:1.0]
#define COLOR_GRADIENT_TOP      [UIColor colorWithRed:80.0 / 255.0 green:181.0 / 255.0 blue:224.0 / 255.0 alpha:1.0]
#define COLOR_GRADIENT_BOTTOM   [UIColor colorWithRed:17.0 / 255.0 green:128.0 / 255.0 blue:178.0 / 255.0 alpha:1.0]

#define BIT0 0x1
#define BIT1 0x2
#define BIT2 0x4
#define BIT3 0x8
#define BIT4 0x10
#define BIT5 0x20
#define BIT6 0x40
#define BIT7 0x80

#define SCREEN_HEIGHT       ([[UIScreen mainScreen] bounds].size.height)
#define TOOLBAR_HEIGHT      49
#define SUB_SCREEN_HEIGHT   (SCREEN_HEIGHT - TOOLBAR_HEIGHT)
#define HEADER_HEIGHT       64
#define DISPLAY_AREA_HEIGHT (SUB_SCREEN_HEIGHT - HEADER_HEIGHT)

#define KEYBOARD_HEIGHT     216

#define DOLLAR_CURRENCY_NUM	840

// notifications

#define NOTIFICATION_MAIN_RESET                         @"Main_Views_Reset"
#define NOTIFICATION_REMOTE_PASSWORD_CHANGE             @"Remote_Password_Change"
#define NOTIFICATION_BLOCK_HEIGHT_CHANGE                @"Block_Height_Change"
#define NOTIFICATION_EXCHANGE_RATE_CHANGE               @"Exchange_Rate_Change"
#define NOTIFICATION_DATA_SYNC_UPDATE                   @"Data_Sync_Update"
#define NOTIFICATION_HANDLE_BITCOIN_URI                 @"Handle_Bitcoin_URI"
#define NOTIFICATION_TRANSACTION_DETAILS_EXITED         @"Notification_Transaction_Details_Exited"     // sent when the user has finished using a transaction details screen
#define NOTIFICATION_LAUNCH_SEND_FOR_WALLET             @"Notification_Launch_Send_For_Wallet"
#define NOTIFICATION_LAUNCH_REQUEST_FOR_WALLET          @"Notification_Launch_Request_For_Wallet"
#define KEY_TX_DETAILS_EXITED_TX                        @"transaction"
#define KEY_TX_DETAILS_EXITED_WALLET_UUID               @"walletUUID"
#define KEY_TX_DETAILS_EXITED_WALLET_NAME               @"walletName"
#define KEY_TX_DETAILS_EXITED_TX_ID                     @"transactionID"
#define KEY_URL                                         @"url"
