//
//  UseDeskSDK.h
//  Use_Desk_iOS_SDK
//
//  Created by Maxim Melikhov on 08.02.2018.
//

#import <Foundation/Foundation.h>
@import SocketIO;
#import "RCMessagesView.h"
#import "RCMessage.h"
#import "Utility.h"
#import "UseDeskSDKHelp.h"


#define UDS [UseDeskSDK getInstance]

typedef void (^UDSStartBlock)(BOOL success, NSString *error);
typedef void (^UDSConnectBlock)(BOOL success, NSString *error);
typedef void (^UDSNewMessageBlock)(BOOL success, RCMessage *message);
typedef void (^UDSErrorBlock)(NSArray *errors);
typedef void (^UDSFeedbackMessageBlock)(RCMessage *message);
typedef void (^UDSFeedbackAnswerMessageBlock)(BOOL succes);





@interface UseDeskSDK : NSObject{
    
    SocketManager* manager;
    SocketIOClient* socket;
    
    NSString *companyID;
    NSString *email;
    NSString *url;
    NSString *token;
    
    
    
}
@property (nonatomic, readwrite) UDSNewMessageBlock newMessageBlock;
@property (nonatomic, readwrite) UDSConnectBlock connectBlock;
@property (nonatomic, readwrite) UDSErrorBlock errorBlock;
@property (nonatomic, readwrite) UDSFeedbackMessageBlock feedbackMessageBlock;
@property (nonatomic, readwrite) UDSFeedbackAnswerMessageBlock feedbackAnswerMessageBlock;

@property (nonatomic, readwrite) NSMutableArray *historyMess;


-(void)startWithCompanyID:(NSString*)_companyID email:(NSString*)_email url:(NSString*)_url port:(NSString*)_port connectionStatus:(UDSStartBlock)startBlock;
-(void)startWithoutGUICompanyID:(NSString*)_companyID email:(NSString*)_email url:(NSString*)_url connectionStatus:(UDSStartBlock)startBlock;

-(void)sendMessage:(NSString*)text;
-(void)sendMessage:(NSString *)text withFileName:(NSString*)fileName fileType:(NSString*)fileType contentBase64:(NSString*)contentBase64;
-(void)sendMessageFeedBack:(BOOL)status;


+(UseDeskSDK*)getInstance;
+(void)killInstance;
+(UseDeskSDK*)createNewInstance;

@end
