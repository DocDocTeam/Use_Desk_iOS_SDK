#import "DialogflowView.h"
#import "UseDeskSDK.h"
#import "UDAudio.h"
#import "NSDate+Escort.h"
#import "NSDate+Helpers.h"
#import "MBProgressHUD.h"
#import <QBImagePickerController/QBImagePickerController.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "NSString+Localize.h"

#define MAX_PHOTO_SIDE 2000.0

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface DialogflowView () <UIImagePickerControllerDelegate,UINavigationControllerDelegate,QBImagePickerControllerDelegate>
{
    NSArray *sendImageArr;
    MBProgressHUD *hudErrorConnection;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation DialogflowView

@synthesize rcmessages;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self
																						   action:@selector(actionDone)];
    
    hudErrorConnection = [[MBProgressHUD alloc] initWithView:self.view];
    hudErrorConnection.removeFromSuperViewOnHide = YES;
    [self.view addSubview:hudErrorConnection];
    
    hudErrorConnection.mode = MBProgressHUDModeIndeterminate;
    //hudErrorConnection.label.text = @"Loading";
    
    //---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	//if ([FUser wallpaper] != nil)
		//self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[FUser wallpaper]]];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	//---------------------------------------------------------------------------------------------------------------------------------------------
	rcmessages = [[NSMutableArray alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self loadEarlierShow:NO];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self updateTitleDetails];
    
    UDS.connectBlock = ^(BOOL success, NSString *error) {
        [hudErrorConnection hideAnimated:YES];
        [self reloadhistory];

    };
    
    UDS.newMessageBlock = ^(BOOL success, RCMessage *message) {
        //[rcmessages removeAllObjects];
        [rcmessages addObject:message];
        [self refreshTableView1];


        // TODO: Разобраться с загрузкой звуков
//        if(message.incoming)
//            [UDAudio playMessageIncoming];

    };
    
    UDS.feedbackAnswerMessageBlock = ^(BOOL success){
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@""
                                     message:@"Спасибо за вашу оценку"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Ok"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                    }];
        
        
        [alert addAction:yesButton];
        
        [self presentViewController:alert animated:YES completion:nil];
    };
    
    UDS.errorBlock = ^(NSArray *errors) {
        if(errors.count > 0)
            hudErrorConnection.label.text = [errors objectAtIndex:0];
        [hudErrorConnection showAnimated:YES];
    };
    
    UDS.feedbackMessageBlock = ^ (RCMessage *message){
        [rcmessages addObject:message];
        [self refreshTableView1];
    };
    
    [self reloadhistory];
   

    
	//---------------------------------------------------------------------------------------------------------------------------------------------
}

-(void)reloadhistory{
    [rcmessages removeAllObjects];
    for (RCMessage *message in UDS.historyMess){
        [rcmessages addObject:message];
    }
    [self refreshTableView1];
}

#pragma mark - Message methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (RCMessage *)rcmessage:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return rcmessages[indexPath.section];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)addMessage:(NSString *)text incoming:(BOOL)incoming
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	RCMessage *rcmessage = [[RCMessage alloc] initWithText:text incoming:incoming];
	[rcmessages addObject:rcmessage];
	[self refreshTableView1];
}

#pragma mark - Avatar methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)avatarInitials:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	RCMessage *rcmessage = rcmessages[indexPath.section];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (rcmessage.outgoing)
	{
        return [@"dialog.user" localized];
	}
	else return [@"dialog.support" localized];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UIImage *)avatarImage:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    RCMessage *rcmessage = rcmessages[indexPath.section];
    if(rcmessage.avatar == nil)
        return nil;
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:rcmessage.avatar]]];
	return image;
}

#pragma mark - Header, Footer methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)textSectionHeader:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    RCMessage *rcmessage = rcmessages[indexPath.section];
    
    NSTimeInterval timeZoneSeconds = [[NSTimeZone localTimeZone] secondsFromGMT];
    NSDate *dateInLocalTimezone = [rcmessage.date dateByAddingTimeInterval:timeZoneSeconds];
    
    if ([rcmessage.date isToday])
        return [NSDate stringFromDate:dateInLocalTimezone withFormat:NSDateFormatHm24 andTimeZone:NSDateTimeZoneGMT];
    return [NSDate stringFromDate:dateInLocalTimezone withFormatString:@"dd.MM.yyyy HH:mm" andTimeZone:NSDateTimeZoneGMT];
    

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)textBubbleHeader:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)textBubbleFooter:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

	return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)textSectionFooter:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    RCMessage *rcmessage = rcmessages[indexPath.section];
    if (rcmessage.incoming){
        return rcmessage.name;
    }
	return nil;
}

#pragma mark - Menu controller methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSArray *)menuItems:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	RCMenuItem *menuItemCopy = [[RCMenuItem alloc] initWithTitle:@"Copy" action:@selector(actionMenuCopy:)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	menuItemCopy.indexPath = indexPath;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return @[menuItemCopy];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (action == @selector(actionMenuCopy:))	return YES;
	return NO;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)canBecomeFirstResponder
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return YES;
}

#pragma mark - Typing indicator methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)typingIndicatorShow:(BOOL)show animated:(BOOL)animated delay:(CGFloat)delay
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
	dispatch_after(time, dispatch_get_main_queue(), ^{ [self typingIndicatorShow:show animated:animated]; });
}

#pragma mark - Title details methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateTitleDetails
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self.labelTitle1.text = @"UseDesk";
	self.labelTitle2.text = [@"dialog.online" localized];
}

#pragma mark - Refresh methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)refreshTableView1
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self refreshTableView2];
	[self scrollToBottom:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)refreshTableView2
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.tableView reloadData];
}

#pragma mark - Dialogflow methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendDialogflowRequest:(NSString *)text
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self typingIndicatorShow:YES animated:YES delay:0.5];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	/*AITextRequest *aiRequest = [apiAI textRequest];
	aiRequest.query = @[text];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[aiRequest setCompletionBlockSuccess:^(AIRequest *request, id response)
	{
		[self typingIndicatorShow:NO animated:YES delay:1.0];
		[self displayDialogflowResponse:response delay:1.1];
	}
	failure:^(AIRequest *request, NSError *error)
	{
		[ProgressHUD showError:@"Dialogflow request error."];
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[apiAI enqueue:aiRequest];*/
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)displayDialogflowResponse:(NSDictionary *)dictionary delay:(CGFloat)delay
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
	dispatch_after(time, dispatch_get_main_queue(), ^{ [self displayDialogflowResponse:dictionary]; });
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)displayDialogflowResponse:(NSDictionary *)dictionary
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSDictionary *result = dictionary[@"result"];
	NSDictionary *fulfillment = result[@"fulfillment"];
	NSString *text = fulfillment[@"speech"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self addMessage:text incoming:YES];
    
    // TODO: Разобраться с загрузкой звуков
//    [UDAudio playMessageIncoming];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionDone
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self dismissViewControllerAnimated:YES completion:nil];
    [UDS disconnect];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSendMessage:(NSString *)text
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[UDAudio playMessageOutgoing];
    if([sendImageArr count] == 0 || sendImageArr == nil){
        [UDS sendMessage:text];
    }
    else{
        for(int i = 0; i < [sendImageArr count];i++){
            UIImage *pickedImage;
            if ([sendImageArr[i] isKindOfClass:PHAsset.class]) {
                pickedImage = [self getAssetThumbnail:sendImageArr[i]];
            } else {
                pickedImage = sendImageArr[i];
            }
            NSString *content = [NSString stringWithFormat:@"data:image/png;base64,%@",[UseDeskSDKHelp imageToNSString:pickedImage]];
            [UDS sendMessage:text
                withFileName:@"file.png"
                    fileType:@"image/png"
               contentBase64:content];
        }
        sendImageArr = nil;
    }
	//---------------------------------------------------------------------------------------------------------------------------------------------
}

-(UIImage *)getAssetThumbnail:(PHAsset * )asset {
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
    options.synchronous = true;
    CGFloat aspectRatio = ((CGFloat)asset.pixelWidth) / asset.pixelHeight;
    CGSize targetSize;
    if (aspectRatio > 1) {
        targetSize = CGSizeMake(MAX_PHOTO_SIDE, MAX_PHOTO_SIDE / aspectRatio);
    } else {
        targetSize = CGSizeMake(MAX_PHOTO_SIDE * aspectRatio, MAX_PHOTO_SIDE);
    }
    
    __block UIImage *image;
    [PHCachingImageManager.defaultManager requestImageForAsset:asset
                                                    targetSize:targetSize
                                                   contentMode:PHImageContentModeAspectFit
                                                       options:options
                                                 resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        image = result;
    }];
    return image;
}

- (void)actionAttachMessage
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:[@"attachments.cancel" localized]
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:[@"attachments.take_photo" localized], [@"attachments.select_photo" localized], nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}

#pragma  mark : Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    [self takePhoto];
                    NSLog(@"Select From Camera");
                    break;
                case 1:
                    [self selectPhoto];
                    NSLog(@"Select From Photos");
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (void)takePhoto {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            [self showNoAccessDialog:[@"permissions.camera_denied_message" localized]];
            return;
        default:
            break;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (void)selectPhoto {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusDenied:
        case PHAuthorizationStatusRestricted:
            [self showNoAccessDialog:[@"permissions.gallery_denied_message" localized]];
            return;
        default:
            break;
    }
    QBImagePickerController *imagePickerController = [QBImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.maximumNumberOfSelection = 3;
    imagePickerController.showsNumberOfSelectedAssets = YES;
    
    [self presentViewController:imagePickerController animated:YES completion:NULL];
}

- (void)showNoAccessDialog:(NSString *)message {
    UIAlertController *permissionPrompt =
    [UIAlertController alertControllerWithTitle:@""
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    [permissionPrompt addAction:[UIAlertAction actionWithTitle:[@"permissions.cancel" localized]
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil]];
    [permissionPrompt addAction:[UIAlertAction actionWithTitle:[@"permissions.go_to_settings" localized]
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           NSURL *settings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                           [UIApplication.sharedApplication openURL:settings];
                                                       }]];
    [self presentViewController:permissionPrompt animated:YES completion:nil];
}

#pragma mark - QBImagePickerControllerDelegate

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets
{
    NSLog(@"Selected assets:");
    NSLog(@"%@", assets);
    sendImageArr = [NSArray arrayWithArray:assets];
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self actionSendMessage:@""];
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    NSLog(@"Canceled.");
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    sendImageArr = [NSArray arrayWithObject:chosenImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self actionSendMessage:@""];
}

#pragma mark - User actions (menu)

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionMenuCopy:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSIndexPath *indexPath = [RCMenuItem indexPath:sender];
	RCMessage *rcmessage = [self rcmessage:indexPath];
	//---------------------------------------------------------------------------------------------------------------------------------------------
    NSString *text = rcmessage.text;
    if (text != (id)[NSNull null] && text.length > 0) {
        [[UIPasteboard generalPasteboard] setString:text];
    }
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [rcmessages count];
}


- (void)actionTapBubble:(NSIndexPath *)indexPath{
    RCMessage *rcmessage = rcmessages[indexPath.section];
    if(![rcmessage.file.type isEqualToString:@"image"]){
        NSURL *url = [NSURL URLWithString:rcmessage.file.content];
        
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:NULL];
        }else{
            // Fallback on earlier versions
            [[UIApplication sharedApplication] openURL:url];
        }
    }

}

@end
