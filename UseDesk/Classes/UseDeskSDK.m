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
#import "NSDate+Helpers.h"
#import "MBProgressHUD.h"
#import "NSString+Localize.h"
#import <UseDesk/UseDesk-Swift.h>

#define TOKEN_KEY @"USEDESK_TOKEN"
#define TIMEOUT 5

@interface UseDeskSDK()

@property (nonatomic, strong) NSBundle *assetBundle;

@end

@implementation UseDeskSDK

@synthesize assetBundle = _assetBundle;

static UseDeskSDK * s_instance;
static NSBundle *_assetBundle;

- (UIViewController *)topController {
    UIViewController *top = UIApplication.sharedApplication.keyWindow.rootViewController;
    while (top.presentedViewController != nil &&
           !top.presentedViewController.isBeingDismissed) {
        top = top.presentedViewController;
    }
    return top;
}

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

+ (NSBundle *)assetBundle {
    if (_assetBundle == nil) {
        NSBundle *framework = [NSBundle bundleForClass:self.class];
        NSString *resourcePath = [framework pathForResource:@"UseDesk" ofType:@"bundle"];
        _assetBundle = [NSBundle bundleWithPath:resourcePath];
    }
    return _assetBundle;
}

- (BOOL)dialogShown {
    return [self.topController isKindOfClass:[UDNavigationController class]];
}

-(void)startWithCompanyID:(NSString*)_companyID host:(NSString*)host port:(NSNumber*)port presentationStyle:(UIModalPresentationStyle)presentationStyle connectionStatus:(UDSStartBlock)startBlock{
    NSString *companyId = _companyID;
    NSString * urlChat = [self chatUrlWithHost:host andPort:port].absoluteString;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [UDS startWithoutGUICompanyID:companyId url:urlChat connectionStatus:^(BOOL success, NSString *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                startBlock(success, error);
                if ([self dialogShown]) {
                    return;
                }
                if(success){
                    DialogflowView *dialogflowView = [[DialogflowView alloc] init];
                    UDNavigationController *navController = [[UDNavigationController alloc] initWithRootViewController:dialogflowView];
                    navController.modalPresentationStyle = presentationStyle;
                    [self.topController presentViewController:navController animated:YES completion:nil];
                }else{
                    [self disconnect];
                    UDOfflineForm *offline = [[UDOfflineForm alloc] initWithNibName:@"UDOfflineForm" bundle:[UseDeskSDK assetBundle]];
                    offline.url = [self offlineFormUrlWithHost:host].absoluteString;
                    offline.companyId = companyId;
                    offline.modalPresentationStyle = presentationStyle;
                    [self.topController presentViewController:offline animated:YES completion:nil];
                }
            });
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

-(void)startWithoutGUICompanyID:(NSString*)_companyID url:(NSString*)_url connectionStatus:(UDSStartBlock)startBlock{
  
    companyID = _companyID;
    url = _url;
    
    NSURL *urlAdress = [[NSURL alloc] initWithString:url];
    
    NSDictionary *config = @{
                             @"log":@YES
                             };

    socket = [[SocketIOClient alloc] initWithSocketURL:urlAdress config:config];
    
    [socket connectWithTimeoutAfter:TIMEOUT withHandler:^{
        startBlock(NO, @"noInternetConnection");
    }];

    [socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"socket connected");
        NSString *token = [self loadToken];
        NSArray *arrConfStart = [UseDeskSDKHelp config_CompanyID:self->companyID url:self->url token:token];
        [self->socket emit:@"dispatch" with:arrConfStart];
    }];
    
    [socket on:@"error" callback:^(NSArray* data, SocketAckEmitter* ack) {
        if (startBlock) {
            startBlock(NO, @"unknownError");
        }
    }];
    
    [socket on:@"dispatch" callback:^(NSArray* data, SocketAckEmitter* ack) {
        if([data count] == 0 || data == nil)
            return;
       
        [self action_INITED:data];
        
        BOOL no_operators = [self action_INITED_no_operators:data];
       
        if(no_operators && startBlock) {
            startBlock(NO,@"noOperators");
            return;
        }
        
        
        
        
        
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

- (void)disconnect {
    [socket removeAllHandlers];
    [socket disconnect];
    socket = nil;
}

-(void)action_INITED:(NSArray*)data{
    
    NSDictionary * dicServer = (NSDictionary*)[data objectAtIndex:0];
    
    if([dicServer objectForKey:@"token"] != nil){
        token = [dicServer objectForKey:@"token"];
        [self saveToken:token];
    }
    
    NSDictionary *setup = [dicServer objectForKey:@"setup"];
    
    if(setup != nil){
        NSArray * messages = [setup objectForKey:@"messages"];
        self.historyMess = [[NSMutableArray alloc] init];
        for(NSDictionary *mess in messages){
            RCMessage *m = [self parseMessageDic:mess];
            [self.historyMess addObject:m];
        }
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
    if(![type isEqualToString:@"@@chat/current/INITED"])
        return NO;
    return YES;
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

-(void)saveToken:(NSString*)token{
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:TOKEN_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString*)loadToken{
    NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                            stringForKey:TOKEN_KEY];
    return savedValue;
}

- (NSURL *)chatUrlWithHost:(NSString *)host andPort:(NSNumber *)port {
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.host = [NSString stringWithFormat:@"pubsub.%@", host];
    components.scheme = @"https";
    components.port = port;
    return components.URL;
}

- (NSURL *)offlineFormUrlWithHost:(NSString *)host {
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.host = [NSString stringWithFormat:@"secure.%@", host];
    components.scheme = @"https";
    return components.URL;
}

@end
