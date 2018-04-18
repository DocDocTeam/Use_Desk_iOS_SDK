//
//  UseDeskSDKHelp.h
//  Use_Desk_iOS_SDK
//
//  Created by Maxim Melikhov on 08.02.2018.
//

#import <Foundation/Foundation.h>

@interface UseDeskSDKHelp : NSObject

+(NSArray*)config_CompanyID:(NSString*)companyID email:(NSString*)email url:(NSString*)url token:(NSString*)token;
+(NSString *)dictToJson:(NSDictionary *)dict;
+(NSArray*)dataEmail:(NSString*)email;
+(NSArray*)messageText:(NSString*)text;
+(NSArray*)feedback:(BOOL)fb;
+(NSArray*)message:(NSString *)text withFileName:(NSString*)fileName fileType:(NSString*)fileType contentBase64:(NSString*)contentBase64;
+(NSString *)imageToNSString:(UIImage *)image;
@end
