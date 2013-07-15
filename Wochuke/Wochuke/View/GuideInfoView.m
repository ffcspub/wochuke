//
//  GuideInfoView.m
//  Wochuke
//
//  Created by he songhang on 13-6-25.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "GuideInfoView.h"
#import "NSObject+Notification.h"

@interface UIUnderlinedButton : UIButton {
    
}

@property(nonatomic,assign) BOOL underLine;

+ (UIUnderlinedButton*) underlinedButton;

@end

@implementation UIUnderlinedButton

+ (UIUnderlinedButton*) underlinedButton {
    
    UIUnderlinedButton* button = [[UIUnderlinedButton alloc] init];
    return [button autorelease];
}

- (void) drawRect:(CGRect)rect {
    if (_underLine) {
        CGRect textRect = self.titleLabel.frame;
        // need to put the line at top of descenders (negative value)
        CGFloat descender = self.titleLabel.font.descender + 3;
        CGContextRef contextRef = UIGraphicsGetCurrentContext();
        // set to same colour as text
        CGContextSetStrokeColorWithColor(contextRef, [[UIColor lightGrayColor]CGColor]);
        float lengths[] = {2,2};
        CGContextSetLineDash(contextRef, 0, lengths,2);
        CGContextMoveToPoint(contextRef, textRect.origin.x, textRect.origin.y + textRect.size.height + descender);
        CGContextAddLineToPoint(contextRef, textRect.origin.x + textRect.size.width + 3, textRect.origin.y + textRect.size.height + descender);
        CGContextStrokePath(contextRef);
//        CGContextClosePath(contextRef);
        CGContextDrawPath(contextRef, kCGPathStroke);
    }
}

@end

@implementation GuideInfoView

-(void)handleNotification:(NSNotification *)notification{
    if ([notification.name isEqual:NOTIFICATION_COMMENTCOUNTCHANGE]) {
        [btn_commentCount setTitle:[NSString stringWithFormat:@" %d",_guide.commentCount] forState:UIControlStateNormal];
        if (_guide.viewCount > 0) {
            ((UIUnderlinedButton *)btn_viewCount).underLine = YES;
        }
    }else if([notification.name isEqual:NOTIFICATION_VIEWCOUNTCHANGE]){
        [btn_viewCount setTitle:[NSString stringWithFormat:@" %d",_guide.viewCount] forState:UIControlStateNormal];
        if (_guide.favoriteCount > 0) {
            ((UIUnderlinedButton *)btn_favoriteCount).underLine = YES;
        }
    }else if([notification.name isEqual:NOTIFICATION_FAVORITECOUNT]){
        [btn_favoriteCount setTitle:[NSString stringWithFormat:@" %d",_guide.favoriteCount] forState:UIControlStateNormal];
        if (_guide.commentCount > 0) {
            ((UIUnderlinedButton *)btn_commentCount).underLine = YES;
        }
    }
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    backImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    backTopImageView.frame = CGRectMake(5, 5, frame.size.width - 10, frame.size.height -10);
    
    tagImageView.frame = CGRectMake(frame.size.width - tagImageView.frame.size.width, 100, tagImageView.frame.size.width, tagImageView.frame.size.height);
    
    lb_tag.frame = CGRectMake(frame.size.width - tagImageView.frame.size.width + 8, 97, tagImageView.frame.size.width -10, tagImageView.frame.size.height);
    
    iv_photoback.frame = CGRectMake((frame.size.width - 46)/2, 72, 46, 46);
    
    iv_photo.frame = CGRectMake((frame.size.width - 40)/2, 75, 40 , 40);
    tv_title.frame = CGRectMake(5, 20, frame.size.width-10, 30);
    tv_title.textMaxLength = 30;
    tv_title.delegate = self;
    lb_publisher.frame = CGRectMake(0, 130, frame.size.width, 20);
    CGFloat btnwidth = fabsf((frame.size.width - 100)/3);
    btn_viewCount.frame = CGRectMake(50,155,btnwidth,30);
    btn_favoriteCount.frame = CGRectMake(50 + btnwidth,155,btnwidth,30);
    btn_commentCount.frame = CGRectMake(50 + btnwidth + btnwidth,155,btnwidth,30);
    
    CGSize contentSize = [_guide.description_.length>0?_guide.description_:@"1" sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(frame.size.width - 30 -UITEXTVIEW_MARGIN*2, 1000)];

    tv_content.frame = CGRectMake(15, 190, frame.size.width - 30, MIN(contentSize.height + UITEXTVIEW_MARGIN*2, frame.size.height - 190 - 30));
    
    iv_contentBackView.frame = CGRectMake(tv_content.frame.origin.x , tv_content.frame.origin.y, tv_content.frame.size.width, tv_content.frame.size.height + UITEXTVIEW_MARGIN);
    
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height)/2;
    
	CGPoint r = growingTextView.center;
    growingTextView.center = CGPointMake(r.x, r.y + diff);
    iv_contentBackView.frame = CGRectMake(iv_contentBackView.frame.origin.x, iv_contentBackView.frame.origin.y, iv_contentBackView.frame.size.width,iv_contentBackView.frame.size.height + diff);
}

-(void)viewCountBtnClicked{
    if (_guide.viewCount == 0) {
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(guideInfoViewViewcount:)]) {
        [_delegate guideInfoViewViewcount:self];
    }
}

-(void)favoriteCountBtnClicked{
    if (_guide.favoriteCount == 0) {
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(guideInfoViewFavorite:)]) {
        [_delegate guideInfoViewFavorite:self];
    }
}

-(void)commentCountBtnClicked{
    if (_guide.commentCount == 0) {
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(guideInfoViewComment:)]) {
        [_delegate guideInfoViewComment:self];
    }
}

-(void)handleSingleTapFrom{
    if (_delegate && [_delegate respondsToSelector:@selector(guideInfoViewUserShow:)]) {
        [_delegate guideInfoViewUserShow:self];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        backImageView = [[[UIImageView alloc]init]autorelease];
        UIImage *backImage = [[UIImage imageNamed:@"lightBoard"]resizableImageWithCapInsets:UIEdgeInsetsMake(14, 14, 14, 14)];
        [backImageView setImage:backImage];
        
        tagImageView = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tag_cook_firstcard_slip"]]autorelease];
        
        lb_tag = [[[UILabel alloc]init]autorelease];
        lb_tag.text = @"滑动浏览";
        lb_tag.font = [UIFont systemFontOfSize:13];
        lb_tag.backgroundColor = [UIColor clearColor];
        lb_tag.textColor = [UIColor whiteColor];
        lb_tag.textAlignment = UITextAlignmentCenter;
        
        backTopImageView = [[[UIImageView alloc]init]autorelease];
        backTopImageView.contentMode = UIViewContentModeScaleToFill;
        [backTopImageView setImage:[UIImage imageNamed:@"bg_cook_card_1"]];
        backTopImageView.layer.cornerRadius = 12;
        backTopImageView.layer.masksToBounds = YES;
        
        
        iv_photoback = [[[UIView alloc]init]autorelease];
        iv_photoback.backgroundColor = [UIColor whiteColor];
        iv_photoback.layer.cornerRadius = 6;
        iv_photoback.layer.masksToBounds = YES;
        
        iv_photo = [[[MyWebImgView alloc]init]autorelease];
        iv_photo.layer.cornerRadius = 6;
        iv_photo.layer.masksToBounds = YES;
        iv_photo.contentMode = UIViewContentModeScaleAspectFill;
        iv_photo.backgroundColor = [UIColor grayColor];
        UITapGestureRecognizer* singleRecognizer;  
        singleRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom)]autorelease];
        singleRecognizer.numberOfTapsRequired = 1; // 单击  
        [iv_photo addGestureRecognizer:singleRecognizer];  
        [iv_photo setUserInteractionEnabled:YES];
        
        tv_title = [[[HPGrowingTextView alloc]init]autorelease];
        tv_title.font = [UIFont boldSystemFontOfSize:18];
        tv_title.backgroundColor = [UIColor clearColor];
        tv_title.textColor = [UIColor darkTextColor];
        tv_title.textAlignment = UITextAlignmentCenter;
        tv_title.placeholder = @"指南名称";
        tv_title.placeholderColor = [UIColor grayColor];
        tv_title.editable = NO;
        
        lb_publisher = [[[UILabel alloc]init]autorelease];
        lb_publisher.font = [UIFont boldSystemFontOfSize:16];
        lb_publisher.backgroundColor = [UIColor clearColor];
        lb_publisher.textColor = [UIColor darkTextColor];
        lb_publisher.textAlignment = UITextAlignmentCenter;
        
        btn_viewCount = [[[UIUnderlinedButton alloc]init]autorelease];
        btn_viewCount.titleLabel.font = [UIFont systemFontOfSize:12];
        btn_viewCount.backgroundColor = [UIColor clearColor];
        [btn_viewCount setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [btn_viewCount setImage:[UIImage imageNamed:@"ic_cookhome_read"] forState:UIControlStateNormal];
        [btn_viewCount addTarget:self action:@selector(viewCountBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        
        btn_favoriteCount = [[[UIUnderlinedButton alloc]init]autorelease];
        btn_favoriteCount.titleLabel.font = [UIFont systemFontOfSize:12];
        btn_favoriteCount.backgroundColor = [UIColor clearColor];
        [btn_favoriteCount setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [btn_favoriteCount setImage:[UIImage imageNamed:@"ic_cookhome_like"] forState:UIControlStateNormal];
        [btn_favoriteCount addTarget:self action:@selector(favoriteCountBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        
        btn_commentCount = [[[UIUnderlinedButton alloc]init]autorelease];
        btn_commentCount.titleLabel.font = [UIFont systemFontOfSize:12];
        btn_commentCount.backgroundColor = [UIColor clearColor];
        [btn_commentCount setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [btn_commentCount setImage:[UIImage imageNamed:@"ic_cookhome_comment"] forState:UIControlStateNormal];
         [btn_commentCount addTarget:self action:@selector(commentCountBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        
        iv_contentBackView = [[[UIImageView alloc]init]autorelease];
        UIImage *contentbackImage = [[UIImage imageNamed:@"textViewBoard"]resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
        iv_contentBackView.contentMode = UIViewContentModeScaleToFill;
        [iv_contentBackView setImage:contentbackImage];
        
        tv_content = [[[HPGrowingTextView alloc]init]autorelease];
        tv_content.font = [UIFont systemFontOfSize:12];
        tv_content.minNumberOfLines = 1;
        tv_content.backgroundColor = [UIColor clearColor];
        tv_content.textColor = [UIColor grayColor];
        tv_content.placeholder = @"指南简介";
        tv_content.placeholderColor = [UIColor grayColor];
        tv_content.editable = NO;
        
                
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:backImageView];
        [self addSubview:backTopImageView];
        [self addSubview:tagImageView];
        [self addSubview:lb_tag];
        [self addSubview:tv_title];
        [self addSubview:iv_photoback];
        [self addSubview:iv_photo];
        [self addSubview:lb_publisher];
        [self addSubview:btn_viewCount];
        [self addSubview:btn_favoriteCount];
        [self addSubview:btn_commentCount];
        [self addSubview:iv_contentBackView];
        [self addSubview:tv_content];
        
        [self observeNotification:NOTIFICATION_COMMENTCOUNTCHANGE];
        [self observeNotification:NOTIFICATION_FAVORITECOUNT];
        [self observeNotification:NOTIFICATION_VIEWCOUNTCHANGE];
        
    }
    return self;
}


-(void)setGuide:(JCGuide *)guide{
    if (_guide) {
        [_guide release];
        _guide = nil;
    }
    _guide = [guide retain];
    tv_title.text = _guide.title;
    [tv_title sizeToFit];
//    CGSize tvsize = [_guide.title sizeWithFont:tv_title.font constrainedToSize:CGSizeMake(tv_title.frame.size.width - 16, CGFLOAT_MAX)];
//    tv_title.frame = CGRectMake(tv_title.frame.origin.x, tv_title.frame.origin.y, tv_title.frame.size.width, tvsize.height);
    [iv_photo setImageWithURL:[NSURL URLWithString:_guide.userAvatar.url] placeholderImage:[UIImage imageNamed:@"ic_user_top"]];
    lb_publisher.text = _guide.userName;
    [btn_viewCount setTitle:[NSString stringWithFormat:@" %d",_guide.viewCount] forState:UIControlStateNormal];
    if (_guide.viewCount > 0) {
        ((UIUnderlinedButton *)btn_viewCount).underLine = YES;
    }
    [btn_favoriteCount setTitle:[NSString stringWithFormat:@" %d",_guide.favoriteCount] forState:UIControlStateNormal];
    if (_guide.favoriteCount > 0) {
        ((UIUnderlinedButton *)btn_favoriteCount).underLine = YES;
    }
    [btn_commentCount setTitle:[NSString stringWithFormat:@" %d",_guide.commentCount] forState:UIControlStateNormal];
    if (_guide.commentCount > 0) {
        ((UIUnderlinedButton *)btn_commentCount).underLine = YES;
    }
    if (_guide.description_.length == 0) {
        tv_content.hidden = YES;
        iv_contentBackView.hidden = YES;
    }else{
        tv_content.hidden = NO;
        iv_contentBackView.hidden = NO;
    }
    tv_content.text = _guide.description_;
    [tv_content refreshHeight];
}

-(void)dealloc{
    [self unobserveNotification:NOTIFICATION_COMMENTCOUNTCHANGE];
    [self unobserveNotification:NOTIFICATION_FAVORITECOUNT];
    [self unobserveNotification:NOTIFICATION_VIEWCOUNTCHANGE];
    [_guide release];
    [super dealloc];
}

@end

@implementation GuideEditView

-(void)beginEdit;{
    [tv_title becomeFirstResponder];
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    backImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    backTopImageView.frame = CGRectMake(5, 5, frame.size.width - 10, frame.size.height -10);
    
    iv_photoback.frame = CGRectMake((frame.size.width - 46)/2, 92, 46, 46);
    iv_photo.frame = CGRectMake((frame.size.width - 40)/2, 95, 40 , 40);
    tv_title.frame = CGRectMake(5, 30, frame.size.width-10, 30);
    tv_title.textMaxLength = 30;
    tv_title.delegate = self;
    lb_publisher.frame = CGRectMake(0, 140, frame.size.width, 20);
    
    CGSize contentSize = [[ShareVaule shareInstance].editGuideEx.guideInfo.description_.length>0?[ShareVaule shareInstance].editGuideEx.guideInfo.description_:@" " sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(frame.size.width - 30 - UITEXTVIEW_MARGIN*2, 1000)];
    
    tv_content.frame = CGRectMake(15, 190, frame.size.width - 30, MIN(contentSize.height + UITEXTVIEW_MARGIN*2, frame.size.height - 190 - 30));
//    tv_content.maxHeight = frame.size.height - 190 - 30;
    iv_contentBackView.frame = CGRectMake(tv_content.frame.origin.x, tv_content.frame.origin.y, tv_content.frame.size.width, tv_content.frame.size.height + 8);
    [tv_content refreshHeight];
    
}


- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
//    float diff = growingTextView.frame.size.height - height;
//    growingTextView.frame = CGRectMake(growingTextView.frame.origin.x, growingTextView.frame.origin.y, growingTextView.frame.size.width, growingTextView.frame.size.height + diff);
    iv_contentBackView.frame = CGRectMake(iv_contentBackView.frame.origin.x, iv_contentBackView.frame.origin.y, iv_contentBackView.frame.size.width, height + 8);
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        backImageView = [[[UIImageView alloc]init]autorelease];
        UIImage *backImage = [[UIImage imageNamed:@"lightBoard"]resizableImageWithCapInsets:UIEdgeInsetsMake(14, 14, 14, 14)];
        [backImageView setImage:backImage];
        
        backTopImageView = [[[UIImageView alloc]init]autorelease];
        backTopImageView.contentMode = UIViewContentModeScaleToFill;
        [backTopImageView setImage:[UIImage imageNamed:@"bg_cook_card_1"]];
        backTopImageView.layer.cornerRadius = 12;
        backTopImageView.layer.masksToBounds = YES;
        
        iv_photoback = [[[UIView alloc]init]autorelease];
        iv_photoback.backgroundColor = [UIColor whiteColor];
        iv_photoback.layer.cornerRadius = 6;
        iv_photoback.layer.masksToBounds = YES;
        
        // Initialization code
        iv_photo = [[[MyWebImgView alloc]init]autorelease];
        iv_photo.layer.cornerRadius = 6;
        iv_photo.layer.masksToBounds = YES;
        iv_photo.contentMode = UIViewContentModeScaleAspectFill;
        iv_photo.backgroundColor = [UIColor grayColor];
        
        tv_title = [[[HPGrowingTextView alloc]init]autorelease];
        tv_title.font = [UIFont boldSystemFontOfSize:18];
        tv_title.backgroundColor = [UIColor clearColor];
        tv_title.textColor = [UIColor darkTextColor];
        tv_title.textAlignment = UITextAlignmentCenter;
        tv_title.placeholder = @"指南名称";
        tv_title.placeholderColor = [UIColor grayColor];
        
        lb_publisher = [[[UILabel alloc]init]autorelease];
        lb_publisher.font = [UIFont boldSystemFontOfSize:16];
        lb_publisher.backgroundColor = [UIColor clearColor];
        lb_publisher.textColor = [UIColor darkTextColor];
        lb_publisher.textAlignment = UITextAlignmentCenter;
    
        
        iv_contentBackView = [[[UIImageView alloc]init]autorelease];
        UIImage *contentbackImage = [[UIImage imageNamed:@"textViewBoard"]resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
        iv_contentBackView.contentMode = UIViewContentModeScaleToFill;
        [iv_contentBackView setImage:contentbackImage];
        
        tv_content = [[[HPGrowingTextView alloc]init]autorelease];
        tv_content.font = [UIFont systemFontOfSize:12];
        tv_content.backgroundColor = [UIColor clearColor];
        tv_content.textColor = [UIColor grayColor];
        tv_content.placeholder = @"指南简介";
        tv_content.placeholderColor = [UIColor grayColor];
        tv_content.delegate = self;
        
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:backImageView];
        [self addSubview:backTopImageView];
        [self addSubview:tv_title];
        [self addSubview:iv_photoback];
        [self addSubview:iv_photo];
        [self addSubview:lb_publisher];
        [self addSubview:iv_contentBackView];
        [self addSubview:tv_content];
        
        JCGuide *_guide = [ShareVaule shareInstance].editGuideEx.guideInfo;
        
        tv_title.text = _guide.title;
        [iv_photo setImageWithURL:[NSURL URLWithString:_guide.userAvatar.url] placeholderImage:[UIImage imageNamed:@"ic_user_top"]];
        lb_publisher.text = _guide.userName;
        tv_content.text = _guide.description_;
        
        
        UITapGestureRecognizer* singleRecognizer;  
        singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
        singleRecognizer.numberOfTapsRequired = 1; // 单击
        [self addGestureRecognizer:singleRecognizer];
        self.userInteractionEnabled = YES;
        NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
        [notification addObserver:self
                         selector:@selector(hideKeyBoard)
                             name:UIKeyboardWillHideNotification
                           object:nil];
    }
    return self;
}


#pragma mark -HPGrowingTextViewDelegate
- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView;{
    if (growingTextView == tv_content) {
        oldCenter = self.center;
        [UIView animateWithDuration:0.5 animations:^{
            self.center = CGPointMake(oldCenter.x, oldCenter.y - 150);
            panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyBoard)];
            [self addGestureRecognizer:panGestureRecognizer];
        }];
    }
    return YES;
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView;{
    if (growingTextView == tv_title) {
        [ShareVaule shareInstance].editGuideEx.guideInfo.title = growingTextView.text;
    }else if (growingTextView == tv_content) {
        [ShareVaule shareInstance].editGuideEx.guideInfo.description_ = growingTextView.text;
    }
}

-(void)hideKeyBoard{
    [tv_title resignFirstResponder];
    [tv_content resignFirstResponder];
    if (oldCenter.y > 0) {
        [UIView animateWithDuration:0.5 animations:^{
            self.center = oldCenter;
            [self removeGestureRecognizer:panGestureRecognizer];
            [panGestureRecognizer release];
            panGestureRecognizer = nil;
        }];
    }
}

-(void)dealloc{
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification removeObserver:self
                            name:UIKeyboardWillHideNotification
                          object:nil];

    [keyBoardController release];
    [super dealloc];
}

@end

@implementation GuideInfoMinView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        tv_title.font = [UIFont boldSystemFontOfSize:12];
        lb_publisher.font = [UIFont systemFontOfSize:10];
    }
    return self;
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    iv_photoback.frame = CGRectMake((frame.size.width - 36)/2, 57, 36, 36);
    iv_photo.frame = CGRectMake((frame.size.width - 30)/2, 60, 30 , 30);
    tv_title.frame = CGRectMake(0, 10, frame.size.width, 50);
    lb_publisher.frame = CGRectMake(0, 95, frame.size.width, 20);
    btn_viewCount.frame = CGRectZero;
    btn_favoriteCount.frame = CGRectZero;
    btn_commentCount.frame = CGRectZero;
    tv_content.frame = CGRectZero;
    iv_contentBackView.frame = CGRectZero;
    lb_tag.frame = CGRectZero;
    tagImageView.frame = CGRectZero;
}

@end


#pragma mark -Cell

@implementation GuideInfoCell

-(void)handleNotification:(NSNotification *)notification{
    if ([notification.name isEqual:NOTIFICATION_COMMENTCOUNTCHANGE]) {
        JCGuide *_guide = self.cellData;
        [btn_commentCount setTitle:[NSString stringWithFormat:@"%d",_guide.commentCount] forState:UIControlStateNormal];
    }else if([notification.name isEqual:NOTIFICATION_VIEWCOUNTCHANGE]){
        JCGuide *_guide = self.cellData;
        [btn_viewCount setTitle:[NSString stringWithFormat:@"%d",_guide.viewCount] forState:UIControlStateNormal];
    }else if([notification.name isEqual:NOTIFICATION_FAVORITECOUNT]){
        JCGuide *_guide = self.cellData;
        [btn_favoriteCount setTitle:[NSString stringWithFormat:@"%d",_guide.favoriteCount] forState:UIControlStateNormal];
    }
}


+ (CGSize)sizeInBound:(CGSize)bound forData:(NSObject *)data
{
	return bound;
}

- (void)layoutInBound:(CGSize)bound forCell:(BeeUIGridCell *)cell
{
    backImageView.frame = CGRectMake(10, 10, bound.width -20, bound.height -20);
    iv_photo.frame = CGRectMake(22, 22, bound.width - 44, bound.height - 44);
    lb_title.frame = CGRectMake(32, bound.height - 22 - 50, bound.width - 44 - 64, 20);
    line.frame = CGRectMake(22, bound.height - 22 - 25, bound.width - 44, 0.5);
    btn_viewCount.frame = CGRectMake(30,bound.height - 22 - 25,40,25);
    btn_favoriteCount.frame = CGRectMake(70 ,bound.height - 22 - 25,40,25);
    btn_commentCount.frame = CGRectMake(110 , bound.height - 22 - 25,40,25);
    lb_publisher.frame = CGRectMake(140, bound.height - 22 - 25, bound.width - 22 - 140 - 10,25);
    gradImageView.frame = CGRectMake(22, bound.height - 22 - 70, bound.width - 44, 70);
}

- (void)dataDidChanged
{
    if (self.cellData) {
        JCGuide *_guide = self.cellData;
        lb_title.text = _guide.title;
        [iv_photo setImageWithURL:[NSURL URLWithString:_guide.cover.url] ];
        
        lb_publisher.text = [NSString stringWithFormat:@"by %@",_guide.userName];
        [btn_viewCount setTitle:[NSString stringWithFormat:@"%d",_guide.viewCount] forState:UIControlStateNormal];
        [btn_viewCount setImage:[UIImage imageNamed:@"ic_classify_list_read"] forState:UIControlStateNormal];
        [btn_favoriteCount setTitle:[NSString stringWithFormat:@"%d",_guide.favoriteCount] forState:UIControlStateNormal];
        [btn_favoriteCount setImage:[UIImage imageNamed:@"ic_classify_list_like"] forState:UIControlStateNormal];
        [btn_commentCount setTitle:[NSString stringWithFormat:@"%d",_guide.commentCount] forState:UIControlStateNormal];
        [btn_commentCount setImage:[UIImage imageNamed:@"ic_classify_list_comment"] forState:UIControlStateNormal];
    }
}

- (void)load
{
    iv_photo = [[[MyWebImgView alloc]init]autorelease];
    iv_photo.contentMode = UIViewContentModeScaleAspectFill;
    iv_photo.layer.cornerRadius = 6;
    iv_photo.layer.masksToBounds = YES;
    
    gradImageView = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"back_grad"]]autorelease];
    gradImageView.layer.cornerRadius = 6;
    gradImageView.layer.masksToBounds = YES;
    
    lb_title = [[[UILabel alloc]init]autorelease];
    lb_title.font = [UIFont boldSystemFontOfSize:18];
    lb_title.backgroundColor = [UIColor clearColor];
    lb_title.textColor = [UIColor whiteColor];
    lb_title.textAlignment = UITextAlignmentLeft;
    lb_title.numberOfLines = 2;
    
    lb_publisher = [[[UILabel alloc]init]autorelease];
    lb_publisher.font = [UIFont boldSystemFontOfSize:12];
    lb_publisher.backgroundColor = [UIColor clearColor];
    lb_publisher.textColor = [UIColor whiteColor];
    lb_publisher.textAlignment = UITextAlignmentRight;
    
    btn_viewCount = [[[UIButton alloc]init]autorelease];
    btn_viewCount.titleLabel.font = [UIFont systemFontOfSize:12];
    btn_viewCount.backgroundColor = [UIColor clearColor];
    [btn_viewCount setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    btn_favoriteCount = [[[UIButton alloc]init]autorelease];
    btn_favoriteCount.titleLabel.font = [UIFont systemFontOfSize:12];
    btn_favoriteCount.backgroundColor = [UIColor clearColor];
    [btn_favoriteCount setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    btn_commentCount = [[[UIButton alloc]init]autorelease];
    btn_commentCount.titleLabel.font = [UIFont systemFontOfSize:12];
    btn_commentCount.backgroundColor = [UIColor clearColor];
    [btn_commentCount setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    line = [[[UIView alloc]init]autorelease];
    line.backgroundColor = [UIColor whiteColor];
    
    backImageView = [[[UIImageView alloc]init]autorelease];
    UIImage *backImage = [[UIImage imageNamed:@"lightBoard"]resizableImageWithCapInsets:UIEdgeInsetsMake(14, 14, 14, 14)];
    [backImageView setImage:backImage];
    
    [self addSubview:backImageView];
    [self addSubview:iv_photo];
    [self addSubview:gradImageView];
    [self addSubview:lb_title];
    [self addSubview:line];
    [self addSubview:lb_publisher];
    [self addSubview:btn_viewCount];
    [self addSubview:btn_favoriteCount];
    [self addSubview:btn_commentCount];
    
    [self observeNotification:NOTIFICATION_COMMENTCOUNTCHANGE];
    [self observeNotification:NOTIFICATION_FAVORITECOUNT];
    [self observeNotification:NOTIFICATION_VIEWCOUNTCHANGE];
}

-(void)unload{
    [self unobserveNotification:NOTIFICATION_COMMENTCOUNTCHANGE];
    [self unobserveNotification:NOTIFICATION_FAVORITECOUNT];
    [self unobserveNotification:NOTIFICATION_VIEWCOUNTCHANGE];
    [super unload];
}

@end


@implementation GuideInfoMinCell

- (void)dataDidChanged
{
    [super dataDidChanged];
    [btn_viewCount setImage:[UIImage imageNamed:@"ic_classify_list_read_grad"] forState:UIControlStateNormal];
    [btn_commentCount setImage:[UIImage imageNamed:@"ic_classify_list_comment_grad"] forState:UIControlStateNormal];
    [btn_favoriteCount setImage:[UIImage imageNamed:@"ic_classify_list_like_grad"] forState:UIControlStateNormal];
}

- (void)layoutInBound:(CGSize)bound forCell:(BeeUIGridCell *)cell
{
    backImageView.frame = CGRectZero;
    iv_photo.frame = CGRectMake(5, 5, bound.height-10, bound.height-10);
    lb_title.frame = CGRectMake(bound.height + 5, 5, bound.width - 20 - bound.height, 30);
    line.frame = CGRectMake(2, bound.height-0.5, bound.width - 4, 0.5);
    btn_viewCount.frame = CGRectMake(bound.height + 5, (bound.height -10)/2, 40, 30);
    btn_favoriteCount.frame = CGRectMake(bound.height + 5 + 40, (bound.height -10)/2, 40, 30);
    btn_commentCount.frame = CGRectMake(bound.height + 5 + 40 + 40, (bound.height -10)/2, 40, 30);
    lb_publisher.frame = CGRectMake(bound.width - 100, (bound.height -10)/2, 100 - 5,25);
    gradImageView.frame = CGRectZero;
}

- (void)load
{
    [super load];
    iv_photo.layer.cornerRadius = 4;
    self.backgroundColor = [UIColor clearColor];
    line.backgroundColor = [UIColor grayColor];
    lb_publisher.textColor = [UIColor grayColor];
    lb_publisher.font = [UIFont systemFontOfSize:10];
    lb_title.font = [UIFont boldSystemFontOfSize:14];
    lb_title.numberOfLines = 2;
    lb_title.textColor = [UIColor darkTextColor];
    [btn_commentCount setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btn_favoriteCount setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btn_viewCount setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
}
@end

@implementation GuideInfoEditCell

-(void)editBtnClicked{
    if (_delegate && [_delegate respondsToSelector:@selector(guideInfoEditCellEdit:)]) {
        [_delegate guideInfoEditCellEdit:self];
    }
}

-(void)load{
    [super load];
    btn_edit = [[[UIButton alloc]init]autorelease];
    btn_edit.titleLabel.font = [UIFont systemFontOfSize:12];
    btn_edit.backgroundColor = [UIColor clearColor];
    UIImage *btn_editImage = [[UIImage imageNamed:@"btn_grad"]resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
    [btn_edit setBackgroundImage:btn_editImage forState:UIControlStateNormal];
    [btn_edit setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btn_edit setTitle:@"编辑" forState:UIControlStateNormal];
    [btn_edit addTarget:self action:@selector(editBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn_edit];
}

- (void)layoutInBound:(CGSize)bound forCell:(BeeUIGridCell *)cell
{
    [super layoutInBound:bound forCell:cell];
    backImageView.frame = CGRectZero;
    btn_edit.frame = CGRectMake(bound.width - 50 , (bound.height - 30)/2, 45,30);
    lb_publisher.frame = CGRectZero;
}

- (void)dataDidChanged
{
    [super dataDidChanged];
    if (self.cellData) {
        JCGuide *guide = self.cellData;
        if (!guide.published) {
            [lb_title setTextColor:[UIColor redColor]];
            [lb_title setText:[NSString stringWithFormat:@"草稿:%@",guide.title]];
        }else{
            [lb_title setTextColor:[UIColor darkTextColor]];

        }
    }
}

@end
