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

#import "RCEmojiMessageCell.h"
#import "UseDeskSDK.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface RCEmojiMessageCell()
{
	NSIndexPath *indexPath;
	RCMessagesView *messagesView;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation RCEmojiMessageCell

@synthesize textView;

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
	self.viewBubble.backgroundColor = rcmessage.incoming ? [RCMessages emojiBubbleColorIncoming] : [RCMessages emojiBubbleColorOutgoing];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (textView == nil)
	{
		textView = [[UITextView alloc] init];
		textView.font = [RCMessages textFont];
		textView.editable = NO;
		textView.selectable = NO;
        textView.textAlignment = NSTextAlignmentCenter;
		textView.scrollEnabled = NO;
		textView.userInteractionEnabled = NO;
		textView.backgroundColor = [UIColor clearColor];
		textView.textContainer.lineFragmentPadding = 0;
		textView.textContainerInset = [RCMessages emojiInset];
		[self.viewBubble addSubview:textView];
	}
    
    
    if(self.dislikeButton == nil){
        
        self.dislikeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.dislikeButton setBackgroundImage:[UIImage imageNamed:@"ic_dislike.png"]
                                   forState:UIControlStateNormal];
        [self.dislikeButton addTarget:self
                            action:@selector(dislikeButton_pressed:)
                  forControlEvents:UIControlEventTouchUpInside];
        [self.viewBubble addSubview:self.dislikeButton];
        
    }
    
    
    if(self.likeButton == nil){
        
        self.likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.likeButton setBackgroundImage:[UIImage imageNamed:@"ic_like.png"]
                       forState:UIControlStateNormal];
        [self.likeButton addTarget:self
                action:@selector(likeButton_pressed:)
      forControlEvents:UIControlEventTouchUpInside];
        [self.viewBubble addSubview:self.likeButton];
        
    }
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	textView.text = rcmessage.text;
	//---------------------------------------------------------------------------------------------------------------------------------------------
}

-(void)dislikeButton_pressed:(id)sender{
    [UDS sendMessageFeedBack:NO];
}
-(void)likeButton_pressed:(id)sender{
    [UDS sendMessageFeedBack:YES];
}
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)layoutSubviews
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CGSize size = [RCEmojiMessageCell size:indexPath messagesView:messagesView];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[super layoutSubviews:size];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	textView.frame = CGRectMake(0, size.height-80, size.width, 80);
    self.dislikeButton.frame = CGRectMake(size.width*1/10, size.height/4, size.width/4, size.height/4);
    self.likeButton.frame = CGRectMake(size.width*2/3, size.height/4, size.width/4, size.height/4);

}

#pragma mark - Size methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (CGFloat)height:(NSIndexPath *)indexPath messagesView:(RCMessagesView *)messagesView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CGSize size = [self size:indexPath messagesView:messagesView];
	return size.height;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (CGSize)size:(NSIndexPath *)indexPath messagesView:(RCMessagesView *)messagesView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	RCMessage *rcmessage = [messagesView rcmessage:indexPath];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat maxwidth = (0.6 * SCREEN_WIDTH) - [RCMessages emojiInsetLeft] - [RCMessages emojiInsetRight];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGRect rect = [rcmessage.text boundingRectWithSize:CGSizeMake(maxwidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin
											attributes:@{NSFontAttributeName:[RCMessages emojiFont]} context:nil];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat width = rect.size.width + [RCMessages emojiInsetLeft] + [RCMessages emojiInsetRight];
	CGFloat height = rect.size.height + [RCMessages emojiInsetTop] + [RCMessages emojiInsetBottom];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return CGSizeMake(fmaxf(width, [RCMessages emojiBubbleWidthMin]), fmaxf(height, [RCMessages emojiBubbleHeightMin]));
}

@end
