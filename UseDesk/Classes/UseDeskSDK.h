//
//  UseDeskSDK.h
//  Use_Desk_iOS_SDK
//
//  Created by Maxim Melikhov on 08.02.2018.
//

#import <Foundation/Foundation.h>
#import "RCMessagesView.h"
#import "RCMessage.h"
#import "Utility.h"
#import "UseDeskSDKHelp.h"

@class SocketIOClient;

#define UDS [UseDeskSDK getInstance]

typedef void (^UDSStartBlock)(BOOL success, NSString *error);
typedef void (^UDSConnectBlock)(BOOL success, NSString *error);
typedef void (^UDSNewMessageBlock)(BOOL success, RCMessage *message);
typedef void (^UDSErrorBlock)(NSArray *errors);
typedef void (^UDSFeedbackMessageBlock)(RCMessage *message);
typedef void (^UDSFeedbackAnswerMessageBlock)(BOOL succes);





@interface UseDeskSDK : NSObject{
    
    SocketIOClient* socket;
    
    NSString *companyID;
    NSString *url;
    NSString *token;
    
    
    
}
@property (nonatomic, readwrite) UDSNewMessageBlock newMessageBlock;
@property (nonatomic, readwrite) UDSConnectBlock connectBlock;
@property (nonatomic, readwrite) UDSErrorBlock errorBlock;
@property (nonatomic, readwrite) UDSFeedbackMessageBlock feedbackMessageBlock;
@property (nonatomic, readwrite) UDSFeedbackAnswerMessageBlock feedbackAnswerMessageBlock;

@property (nonatomic, readwrite) NSMutableArray *historyMess;


-(void)startWithCompanyID:(NSString*)_companyID host:(NSString*)host port:(NSNumber*)port connectionStatus:(UDSStartBlock)startBlock;
-(void)startWithoutGUICompanyID:(NSString*)_companyID url:(NSString*)_url connectionStatus:(UDSStartBlock)startBlock;

-(void)sendMessage:(NSString*)text;
-(void)sendMessage:(NSString *)text withFileName:(NSString*)fileName fileType:(NSString*)fileType contentBase64:(NSString*)contentBase64;
-(void)sendMessageFeedBack:(BOOL)status;
-(void)disconnect;

+(UseDeskSDK*)getInstance;
+(void)killInstance;
+(UseDeskSDK*)createNewInstance;
+(NSBundle *)assetBundle;

@end
