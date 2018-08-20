#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AudioView.h"
#import "DialogflowView.h"
#import "RCAudioMessageCell.h"
#import "RCBubbleFooterCell.h"
#import "RCBubbleHeaderCell.h"
#import "RCEmojiMessageCell.h"
#import "RCLocationMessageCell.h"
#import "RCMenuItem.h"
#import "RCMessage.h"
#import "RCMessageCell.h"
#import "RCMessages.h"
#import "RCMessagesView.h"
#import "RCPictureMessageCell.h"
#import "RCSectionFooterCell.h"
#import "RCSectionHeaderCell.h"
#import "RCStatusCell.h"
#import "RCTextMessageCell.h"
#import "RCVideoMessageCell.h"
#import "Settings.h"
#import "UDAudio.h"
#import "UDDir.h"
#import "UDMimeType.h"
#import "UDNavigationController.h"
#import "UDOfflineForm.h"
#import "UseDeskSDK.h"
#import "UseDeskSDKHelp.h"
#import "Utility.h"

FOUNDATION_EXPORT double UseDeskVersionNumber;
FOUNDATION_EXPORT const unsigned char UseDeskVersionString[];

