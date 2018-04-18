#import "DialogflowView.h"
#import "UseDeskSDK.h"
#import "Utility.h"


//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface DialogflowView () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIImage *sendImage;
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
    
    self.labelAttachmentFile.hidden = YES;
    
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.buttonInputAttach.userInteractionEnabled = NO;
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

        
        if(message.incoming)
            [UDAudio playMessageIncoming];

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
        return @"you";
	}
	else return @"Ad";
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
        return [NSDate stringFromDate:dateInLocalTimezone withFormat:NSDateFormatHms24 andTimeZone:NSDateTimeZoneGMT];
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
	self.labelTitle2.text = @"online now";
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
	[UDAudio playMessageIncoming];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionDone
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSendMessage:(NSString *)text
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[UDAudio playMessageOutgoing];
    if(sendImage == nil){
        [UDS sendMessage:text];
    }
    else{
        NSString *content = [NSString stringWithFormat:@"data:image/png;base64,%@",[UseDeskSDKHelp imageToNSString:sendImage]];
        [UDS sendMessage:text withFileName:@"file" fileType:@"image/png" contentBase64:content];
        sendImage = nil;
        self.labelAttachmentFile.hidden = YES;

    }
	//---------------------------------------------------------------------------------------------------------------------------------------------
}

- (void)actionAttachMessage
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select Sharing option:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"Take a Photo",
                            @"Select From Photos",
                            nil];
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
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (void)selectPhoto {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
    
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    sendImage = chosenImage;
    self.labelAttachmentFile.hidden = NO;
    self.buttonInputSend.hidden = NO;
   // self.imageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma mark - User actions (menu)

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionMenuCopy:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSIndexPath *indexPath = [RCMenuItem indexPath:sender];
	RCMessage *rcmessage = [self rcmessage:indexPath];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[[UIPasteboard generalPasteboard] setString:rcmessage.text];
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
