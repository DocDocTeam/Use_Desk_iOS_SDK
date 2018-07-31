//
// Copyright (c) 2017 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "RCPictureMessageCell.h"
#import "UDMimeType.h"
//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface RCPictureMessageCell()
{
	NSIndexPath *indexPath;
	RCMessagesView *messagesView;
    UITextView *textView;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation RCPictureMessageCell

@synthesize imageView, spinner, imageManual,textView;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)bindData:(NSIndexPath *)indexPath_ messagesView:(RCMessagesView *)messagesView_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	indexPath = indexPath_;
	messagesView = messagesView_;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	RCMessage *rcmessage = [messagesView rcmessage:indexPath];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	[super bindData:indexPath messagesView:messagesView];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.viewBubble.backgroundColor = rcmessage.incoming ? [RCMessages pictureBubbleColorIncoming] : [RCMessages pictureBubbleColorOutgoing];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	
    
    if (textView == nil)
    {
        textView = [[UITextView alloc] init];
        textView.font = [RCMessages textFont];
        textView.editable = NO;
        textView.selectable = NO;
        textView.scrollEnabled = NO;
        textView.userInteractionEnabled = NO;
        textView.backgroundColor = [UIColor clearColor];
        textView.textContainer.lineFragmentPadding = 0;
        textView.textContainerInset = [RCMessages textInset];
        [self.viewBubble addSubview:textView];
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    textView.textColor = rcmessage.incoming ? [RCMessages textTextColorIncoming] : [RCMessages textTextColorOutgoing];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    textView.text = rcmessage.text;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    
    
       if (imageView == nil)
	{
		imageView = [[UIImageView alloc] init];
		imageView.layer.masksToBounds = YES;
		imageView.layer.cornerRadius = [RCMessages bubbleRadius];
		[self.viewBubble addSubview:imageView];
        
       
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (spinner == nil)
	{
		spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		[self.viewBubble addSubview:spinner];
	}
    __weak RCPictureMessageCell * weakSelf = self;

   // if(imageView.image == nil){
    
    //}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (imageManual == nil)
	{
		imageManual = [[UIImageView alloc] initWithImage:[RCMessages pictureImageManual]];
		[self.viewBubble addSubview:imageManual];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (rcmessage.status == RC_STATUS_LOADING)
	{
		imageView.image = nil;
		[spinner startAnimating];
		imageManual.hidden = YES;
        
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithURL:[NSURL URLWithString:rcmessage.file.content]
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                    if(error == nil){
                        NSString *mimeType = [UDMimeType mimeTypeForData:data];
                        if([mimeType isEqualToString:@"image"]){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                rcmessage.picture_image = [UIImage imageWithData:data];
                                weakSelf.imageView.image = rcmessage.picture_image;
                                [spinner stopAnimating];
                                rcmessage.status = RC_STATUS_SUCCEED;
                                rcmessage.file.type = mimeType;

                            });
                        }else{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                rcmessage.picture_image = [UIImage imageNamed:@"icon_file.png"];
                                weakSelf.imageView.image = rcmessage.picture_image;
                                [spinner stopAnimating];
                                rcmessage.status = RC_STATUS_SUCCEED;
                                rcmessage.file.type = mimeType;

                            });
                            
                        }
                    }
                }] resume];
        [spinner startAnimating];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (rcmessage.status == RC_STATUS_SUCCEED)
	{
		imageView.image = rcmessage.picture_image;
		[spinner stopAnimating];
		imageManual.hidden = YES;
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (rcmessage.status == RC_STATUS_MANUAL)
	{
		imageView.image = nil;
		[spinner stopAnimating];
		imageManual.hidden = NO;
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)layoutSubviews
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    
    CGSize sizeText = [RCPictureMessageCell textSize:indexPath messagesView:messagesView];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    //---------------------------------------------------------------------------------------------------------------------------------------------
    textView.frame = CGRectMake(0, 0, sizeText.width, sizeText.height);
    
    CGSize sizePicture = [RCPictureMessageCell size:indexPath messagesView:messagesView];
    CGSize size = CGSizeMake(sizePicture.width, sizeText.height + sizePicture.height);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[super layoutSubviews:size];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	imageView.frame = CGRectMake(0, sizeText.height, sizePicture.width, sizePicture.height);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat widthSpinner = spinner.frame.size.width;
	CGFloat heightSpinner = spinner.frame.size.height;
	CGFloat xSpinner = (size.width - widthSpinner) / 2;
	CGFloat ySpinner = sizeText.height + (sizePicture.height - heightSpinner) / 2;
	spinner.frame = CGRectMake(xSpinner, ySpinner, widthSpinner, heightSpinner);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat widthManual = imageManual.image.size.width;
	CGFloat heightManual = imageManual.image.size.height;
	CGFloat xManual = (size.width - widthManual) / 2;
	CGFloat yManual = (size.height - heightManual) / 2;
	imageManual.frame = CGRectMake(xManual, yManual, widthManual, heightManual);
}

#pragma mark - Size methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (CGFloat)height:(NSIndexPath *)indexPath messagesView:(RCMessagesView *)messagesView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CGSize size = [self size:indexPath messagesView:messagesView];
    CGSize sizeText = [RCPictureMessageCell textSize:indexPath messagesView:messagesView];

	return (size.height + sizeText.height+20);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (CGSize)size:(NSIndexPath *)indexPath messagesView:(RCMessagesView *)messagesView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	RCMessage *rcmessage = [messagesView rcmessage:indexPath];
	CGFloat width = fminf([RCMessages pictureBubbleWidth], rcmessage.picture_width);
	return CGSizeMake(width, rcmessage.picture_height * width / rcmessage.picture_width);
}



+ (CGFloat)textHeight:(NSIndexPath *)indexPath messagesView:(RCMessagesView *)messagesView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    CGSize size = [self textSize:indexPath messagesView:messagesView];
    return size.height;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (CGSize)textSize:(NSIndexPath *)indexPath messagesView:(RCMessagesView *)messagesView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    CGSize size = [self size:indexPath messagesView:messagesView];

    
    RCMessage *rcmessage = [messagesView rcmessage:indexPath];
    if(rcmessage.text.length == 0 || rcmessage.text == nil)
        return CGSizeMake(0, 0);
    //---------------------------------------------------------------------------------------------------------------------------------------------
    //// (0.6 * SCREEN_WIDTH)
    CGFloat maxwidth =size.width - [RCMessages textInsetLeft] - [RCMessages textInsetRight];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    CGRect rect = [rcmessage.text boundingRectWithSize:CGSizeMake(maxwidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName:[RCMessages textFont]} context:nil];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    CGFloat width = rect.size.width + [RCMessages textInsetLeft] + [RCMessages textInsetRight];
    CGFloat height = rect.size.height + [RCMessages textInsetTop] + [RCMessages textInsetBottom];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    return CGSizeMake(fmaxf(width, [RCMessages pictureBubbleWidth]), fmaxf(height, [RCMessages textBubbleHeightMin]));
}

@end
