//
//  UseDeskSDK.m
//  Use_Desk_iOS_SDK
//
//  Created by Maxim Melikhov on 08.02.2018.
//

#import "UseDeskSDK.h"
#import "UseDeskSDKHelp.h"
#import "DialogflowView.h"
#import "UDOfflineForm.h"
#import "UDNavigationController.h"
#import "RCMessage.h"
#import "AFHTTPSessionManager.h"




#define RootView [[[UIApplication sharedApplication] keyWindow] rootViewController]

@implementation UseDeskSDK


static UseDeskSDK * s_instance;

+(UseDeskSDK*)getInstance{
    if (s_instance == nil) {
        s_instance = [[UseDeskSDK alloc] init];
        
    }
    return s_instance;
}

+(void)killInstance {
    if (s_instance) {
        s_instance = nil;
    }
}

+(UseDeskSDK*)createNewInstance {
    if (s_instance != nil) {
        s_instance = nil;
    }
    return [UseDeskSDK getInstance];
}


-(void)startWithCompanyID:(NSString*)_companyID email:(NSString*)_email url:(NSString*)_url port:(NSString*)_port connectionStatus:(UDSStartBlock)startBlock{

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:RootView.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = @"Loading";
    
    NSString *companyId = _companyID;
    NSString * email = _email;
    NSString * url =_url;
    NSString * port =_port;
    
    NSString * urlChat = [NSString stringWithFormat:@"%@:%@",url,port];
    
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [UDS startWithoutGUICompanyID:companyId email:email url:urlChat connectionStatus:^(BOOL success, NSString *error) {
            if(success){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [hud hideAnimated:YES];
                    DialogflowView *dialogflowView = [[DialogflowView alloc] init];
                    UDNavigationController *navController = [[UDNavigationController alloc] initWithRootViewController:dialogflowView];
                    [RootView presentViewController:navController animated:YES completion:nil];
                });
            }else{
                if([error isEqualToString:@"noOperators"]){
                    [hud hideAnimated:YES];
                    UDOfflineForm *offline = [[UDOfflineForm alloc] initWithNibName:@"UDOfflineForm" bundle:nil];
                    offline.url = url;
                    UDNavigationController *navController = [[UDNavigationController alloc] initWithRootViewController:offline];
                    [RootView presentViewController:navController animated:YES completion:nil];
                }
            }
            
        }];
        
    });
}

-(void)sendMessage:(NSString*)text{
    NSArray *mess = [UseDeskSDKHelp messageText:text];
    [socket emit:@"dispatch" with:mess];
}

-(void)sendMessage:(NSString *)text withFileName:(NSString*)fileName fileType:(NSString*)fileType contentBase64:(NSString*)contentBase64{
    NSArray *mess = [UseDeskSDKHelp message:text withFileName:fileName fileType:fileType contentBase64:contentBase64];
    [socket emit:@"dispatch" with:mess];
    
}

-(void)startWithoutGUICompanyID:(NSString*)_companyID email:(NSString*)_email url:(NSString*)_url connectionStatus:(UDSStartBlock)startBlock{
  
    companyID = _companyID;
    email = _email;
    url = _url;
    
    NSURL *urlAdress = [[NSURL alloc] initWithString:url];
    
    NSDictionary *config = @{
                             @"log":@YES
                             };
    manager = [[SocketManager alloc] initWithSocketURL:urlAdress config: config];
    
    socket = manager.defaultSocket;
    
    [socket connect];

    [socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"socket connected");
        NSString *token = [self loadTokenFor:email];
        NSArray *arrConfStart = [UseDeskSDKHelp config_CompanyID:companyID email:email url:url token:token];
        [socket emit:@"dispatch" with:arrConfStart];
    }];
    
    [socket on:@"error" callback:^(NSArray* data, SocketAckEmitter* ack) {
        if(self.errorBlock)
            self.errorBlock(data);
    }];
    [socket on:@"disconnect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"socket disconnect");
        NSString *token = [self loadTokenFor:email];
        NSArray *arrConfStart = [UseDeskSDKHelp config_CompanyID:companyID email:email url:url token:token];
        [socket emit:@"dispatch" with:arrConfStart];
    }];
    
    [socket on:@"dispatch" callback:^(NSArray* data, SocketAckEmitter* ack) {
        if([data count] == 0 || data == nil)
            return;
       
        [self action_INITED:data];
        
        BOOL no_operators = [self action_INITED_no_operators:data];
       
        if(no_operators && startBlock)
            startBlock(NO,@"noOperators");
        
        
        
        
        
        BOOL auth_success = [self action_ADD_INIT:data];
    
        if(auth_success && startBlock)
            startBlock(auth_success,@"");
        
        if(auth_success && self.connectBlock)
            self.connectBlock(YES,nil);
        
        [self action_Feedback_Answer:data];

        [self action_ADD_MESSAGE:data];
        

    }];
    
    
    
    


}

-(void)sendOfflineFormWithMessage:(NSString*)message url:(NSString*)url callback:(UDSStartBlock)resultBlock{
    
}


-(void)action_INITED:(NSArray*)data{
    
    NSDictionary * dicServer = (NSDictionary*)[data objectAtIndex:0];
    
    if([dicServer objectForKey:@"token"] != nil){
        token = [dicServer objectForKey:@"token"];
        [self save:email token:token];
    }
    
    NSDictionary *setup = [dicServer objectForKey:@"setup"];
    
    if(setup != nil){
        NSArray * messages = [setup objectForKey:@"messages"];
        self.historyMess = [[NSMutableArray alloc] init];
        for(NSDictionary *mess in messages){
            RCMessage *m = [self parseMessageDic:mess];
            [self.historyMess addObject:m];
        }
        BOOL waitingEmail = [setup objectForKey:@"waitingEmail"];

        if(waitingEmail)
            [socket emit:@"dispatch" with:[UseDeskSDKHelp dataEmail:email]];

    }
    
}


-(RCMessage*)parseMessageDic:(NSDictionary*)mess{
    RCMessage *m = [[RCMessage alloc] initWithText:@"" incoming:NO];
    
    NSString *createdAt = [mess objectForKey:@"createdAt"];
    m.date = [NSDate dateFromString:createdAt withFormatString:@"yyyy-MM-dd'T'HH:mm:ssZ" andTimeZone:NSDateTimeZoneUTC];

    m.messageId = (NSInteger)[mess objectForKey:@"id"];
    m.incoming = ([[mess objectForKey:@"type"] isEqualToString:@"client_to_operator"])?NO:YES;
    m.outgoing = !m.incoming;
    m.text = [mess objectForKey:@"text"];
    
    NSDictionary * payload = [mess objectForKey:@"payload"];
    
  
    if(payload != nil && [payload isKindOfClass:[NSDictionary class]]){
        id avatar = [payload objectForKey:@"avatar"];
        
        if(avatar != nil){
            m.avatar = [payload objectForKey:@"avatar"];
        }
        
    }
    

    
    NSDictionary * fileDic = [mess objectForKey:@"file"];
    if(fileDic != nil){
        RCFile *file = [[RCFile alloc] init];
        file.content = [fileDic objectForKey:@"content"];
        file.name = [fileDic objectForKey:@"name"];
        file.type = [fileDic objectForKey:@"type"];
        m.file = file;
        m.type = RC_TYPE_PICTURE;
        m.status = RC_STATUS_LOADING;
        if([file.type isEqualToString:@"image/png"]){
                m.picture_image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:file.content]]];
        }

            m.picture_width = 0.6 * SCREEN_WIDTH;
            m.picture_height = 0.6 * SCREEN_WIDTH;;
    }
    
    if(payload != nil && [payload isKindOfClass:[NSString class]]){
        m.feedback = YES;
        m.type = 9;
    }
    
    
        return m;
}


-(BOOL)action_INITED_no_operators:(NSArray*)data{
    
    NSDictionary * dicServer = (NSDictionary*)[data objectAtIndex:0];
    
    if([dicServer objectForKey:@"token"] != nil)
        token = [dicServer objectForKey:@"token"];
    
    NSDictionary *setup = [dicServer objectForKey:@"setup"];
    
    if(setup != nil){
        
        BOOL noOperators = [setup objectForKey:@"noOperators"];
        
        if(noOperators){
            return YES;
        }
        
    }
    return NO;
}


-(BOOL)action_ADD_INIT:(NSArray*)data{
    
    NSDictionary *dicServer = (NSDictionary*)[data objectAtIndex:0];

    NSString *type = [dicServer objectForKey:@"type"];
    if(type == nil)
        return NO;
    if(![type isEqualToString:@"@@chat/current/ADD_MESSAGE"])
        return NO;

    NSDictionary * message = [dicServer objectForKey:@"message"];
    
    if(message != nil){
        if([[message objectForKey:@"chat"] isKindOfClass:[NSNull class]])
            return YES;
    }
    return NO;
    
}

-(void)action_Feedback_Answer:(NSArray*)data{
    NSDictionary *dicServer = (NSDictionary*)[data objectAtIndex:0];
    
    NSString *type = [dicServer objectForKey:@"type"];
    if(type == nil)
        return;
    if(![type isEqualToString:@"@@chat/current/CALLBACK_ANSWER"])
        return;
    
    NSDictionary *answer = [dicServer objectForKey:@"answer"];
    if(self.feedbackAnswerMessageBlock)
        self.feedbackAnswerMessageBlock([answer objectForKey:@"status"]);

}
-(void)action_ADD_MESSAGE:(NSArray*)data{
    
    NSDictionary *dicServer = (NSDictionary*)[data objectAtIndex:0];
    
    NSString *type = [dicServer objectForKey:@"type"];
    if(type == nil)
        return;
    if(![type isEqualToString:@"@@chat/current/ADD_MESSAGE"])
        return;
    
    if([type isEqualToString:@"bot_to_client"]){
        
    }
    
    
    NSDictionary * message = [dicServer objectForKey:@"message"];
    
    if(message != nil){
        
        if([[message objectForKey:@"chat"] isKindOfClass:[NSNull class]])
            return ;
        
        RCMessage *mess = [self parseMessageDic:message];
        
        if(mess.feedback && self.feedbackMessageBlock){
            self.feedbackMessageBlock(mess);
            return;
        }
        if(self.newMessageBlock)
            self.newMessageBlock(YES,mess);
    }
}

-(void)sendMessageFeedBack:(BOOL)status{
    [socket emit:@"dispatch" with:[UseDeskSDKHelp feedback:status]];
}

-(void)save:(NSString*)email token:(NSString*)token{
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:email];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString*)loadTokenFor:(NSString*)email{
    NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                            stringForKey:email];
    return savedValue;
}


@end
