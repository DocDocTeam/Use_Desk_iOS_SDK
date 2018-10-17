//
//  UDOfflineForm.h
//  Use_Desk_iOS_SDK_Example
//
//  Created by Maxim Melikhov on 13.02.2018.
//  Copyright © 2018 Maxim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UDOfflineForm : UIViewController <UITextFieldDelegate,UITextViewDelegate, UIViewControllerTransitioningDelegate>{
    IBOutlet UILabel *headerLabel;
    IBOutlet UITextField *emailTextField;
    IBOutlet UITextField *nameTextField;
    IBOutlet UITextView *messageTextField;
    IBOutlet UIButton *cancelButton;
    IBOutlet UIButton *sendButton;
    IBOutlet UIView *contentView;
}

@property (nonatomic,strong) NSString *url;
@property (nonatomic, strong) NSString *companyId;

@end
