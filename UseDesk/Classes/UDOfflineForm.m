//
//  UDOfflineForm.m
//  Use_Desk_iOS_SDK_Example
//
//  Created by Maxim Melikhov on 13.02.2018.
//  Copyright © 2018 Maxim. All rights reserved.
//

#import "UDOfflineForm.h"
#import "MBProgressHUD.h"
#import "UseDeskSDK.h"
#import "AFHTTPSessionManager.h"
#import "UIColor+Palette.h"
#import "NSString+Localize.h"
#import "BlurPresentationController.h"

#define KEYBOARD_MARGIN 16.0

@interface UDOfflineForm ()

@property (nonatomic, readonly) NSArray *fields;

@end

@implementation UDOfflineForm

- (NSArray *)fields {
    return @[emailTextField, nameTextField, messageTextField];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Offline form";
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                          initWithTarget:self action:@selector(handleSingleTap:)];
    
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTapGestureRecognizer];
    
    headerLabel.text = [@"offline_form.header" localized];
    emailTextField.placeholder = [@"offline_form.email_placeholder" localized];
    nameTextField.placeholder = [@"offline_form.name_placeholder" localized];
    messageTextField.text = [@"offline_form.message_placeholder" localized];
    messageTextField.textColor = [UIColor lightGrayColor];
    [cancelButton setTitle:[@"offline_form.cancel" localized] forState:UIControlStateNormal];
    [sendButton setTitle:[@"offline_form.send" localized] forState:UIControlStateNormal];
    
    [self.fields enumerateObjectsUsingBlock:^(UIView *field, NSUInteger idx, BOOL * _Nonnull stop) {
        [self setUntouchedAppearance:field];
    }];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(keyboardWillShow:)
                                               name:UIKeyboardWillShowNotification
                                             object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(keyboardWillHide:)
                                               name:UIKeyboardWillHideNotification
                                             object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [emailTextField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self setTouchedAppearance:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.hasText) {
        [self setTouchedAppearance:textField];
    } else {
        [self setUntouchedAppearance:textField];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:[@"offline_form.message_placeholder" localized]]) {
        textView.text = @"";
        textView.textColor = [UIColor darkTextColor];
    }
    [self setTouchedAppearance:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.hasText) {
        [self setTouchedAppearance:textView];
    } else {
        textView.text = [@"offline_form.message_placeholder" localized];
        textView.textColor = [UIColor lightGrayColor];
        [self setUntouchedAppearance:textView];
    }
}

- (void)setTouchedAppearance:(UIView *)view {
    view.backgroundColor = [UIColor whiteColor];
    view.layer.borderColor = [UIColor ramiGray].CGColor;
}

- (void)setUntouchedAppearance:(UIView *)view {
    view.backgroundColor = [UIColor skyGray];
    view.layer.borderColor = [UIColor skyGray].CGColor;
}

//********** VIEW TAPPED **********
-(void) handleSingleTap:(UITapGestureRecognizer *)sender
{
    NSLog(@"Touched and hide keyboard");
    [self.view endEditing:YES];
}


-(IBAction)sendMessage:(id)sender{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = [@"offline_form.sending_message" localized];
    NSDictionary *body = [self getPostData];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        //manager.securityPolicy.allowInvalidCertificates = YES;
        
        [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithArray:@[@"application/json"]]];
        manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        NSString *urlStr = [NSString stringWithFormat:@"%@/widget.js/post",self.url];
        [manager POST:urlStr parameters:body progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"autorization JSON: %@", responseObject);
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
                [self dismissViewControllerAnimated:YES completion:nil];
                // }];
            });
           
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self showAlert:@"Error" text:error.description];
            [hud hideAnimated:YES];
           
        }];
        
                           
    });
}

-(NSDictionary*)getPostData{
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys: self.companyId,@"company_id",
                                                                      nameTextField.text,@"name",
                                                                      emailTextField.text,@"email",
                                                                      messageTextField.text,@"message",
                                                                         nil];
    return dic;
    
}

-(IBAction)cancelMessage:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)showAlert:(NSString*)title text:(NSString*)text{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:text preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                         {
                             //BUTTON OK CLICK EVENT
                         }];
   // UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
   // [alert addAction:cancel];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    return [[BlurPresentationController alloc] initWithPresentedViewController:presented
                                                      presentingViewController:presenting];
}

- (id<UIViewControllerTransitioningDelegate>)transitioningDelegate {
    return self;
}

- (UIModalPresentationStyle)modalPresentationStyle {
    return UIModalPresentationCustom;
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect keyboardRect = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval duration = [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat offset = keyboardRect.origin.y - KEYBOARD_MARGIN - contentView.frame.origin.y - contentView.frame.size.height;
    [UIView animateWithDuration:duration animations:^{
        contentView.transform = CGAffineTransformMakeTranslation(0, offset);
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSTimeInterval duration = [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        contentView.transform = CGAffineTransformIdentity;
    }];
}

@end
