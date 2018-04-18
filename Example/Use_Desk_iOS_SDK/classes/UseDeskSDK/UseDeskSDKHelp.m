//
//  UseDeskSDKHelp.m
//  Use_Desk_iOS_SDK
//
//  Created by Maxim Melikhov on 08.02.2018.
//

#import "UseDeskSDKHelp.h"

@implementation UseDeskSDKHelp

+(NSArray*)config_CompanyID:(NSString*)companyID email:(NSString*)email url:(NSString*)url token:(NSString*)token{
    NSDictionary *payload = [[NSDictionary alloc] initWithObjectsAndKeys:@"iOS",@"sdk",nil];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"@@server/chat/INIT",@"type",
                                                                     payload,@"payload",
                                                                     companyID,@"company_id",
                                                                     url,@"url",
                                                                     nil];
    if(token)
        [dic setObject:token forKey:@"token"];

    return @[dic];
}


+(NSArray*)dataEmail:(NSString*)email{
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"@@server/chat/SET_EMAIL",@"type",
                                                                         email,@"email",
                                                                         nil];
    return @[dic];
}



+(NSArray*)messageText:(NSString*)text{

    NSDictionary *message = [[NSDictionary alloc] initWithObjectsAndKeys:text,@"text",
                         nil];
    
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"@@server/chat/SEND_MESSAGE",@"type",
                         message,@"message",
                         nil];
    return @[dic];
}

+(NSArray*)feedback:(BOOL)fb{
    
    
    NSString *data;
    
    if(fb)
        data = @"LIKE";
    else
        data = @"DISLIKE";
    
    
    
    NSDictionary *payload = [[NSDictionary alloc] initWithObjectsAndKeys:data,@"data",
                                                                         @"action",@"type",
                             nil];
    
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"@@server/chat/CALLBACK",@"type",
                         payload,@"payload",
                         nil];
    return @[dic];
}

+(NSArray*)message:(NSString *)text withFileName:(NSString*)fileName fileType:(NSString*)fileType contentBase64:(NSString*)contentBase64{
    NSDictionary *file = [[NSDictionary alloc] initWithObjectsAndKeys:  fileName,@"name",
                                                                        fileType,@"type",
                                                                        contentBase64,@"content",
                                                                        nil];
    
    NSDictionary *message = [[NSDictionary alloc] initWithObjectsAndKeys:text,@"text",
                                                                         file,@"file",

                             nil];
    
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"@@server/chat/SEND_MESSAGE",@"type",
                         message,@"message",
                         nil];
    return @[dic];
}

+(NSString *)dictToJson:(NSDictionary *)dict
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    if (! jsonData) {
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return nil;
}


+(NSString *)imageToNSString:(UIImage *)image
{
    NSData *imageData = UIImagePNGRepresentation(image);
    return [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}


@end
