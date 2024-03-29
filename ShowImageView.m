//
//  ShowImageController.m
//  漫画
//
//  Created by mac on 16/5/7.
//  Copyright © 2016年 黄. All rights reserved.
//

#import "ShowImageView.h"
#import <UIImageView+WebCache.h>
#import <AFNetworking/AFNetworking.h>
#import "SHProgerssView.h"

@interface ShowImageView ()<UIScrollViewDelegate>

@property (nonatomic, weak) id superView;

@property (nonatomic, assign) NSInteger indexed;

@property (nonatomic, assign) CGPoint imageCenter;

@property (nonatomic, weak) UIPageControl *pageControl;


/**
 *  scrollerView数组
 */
@property (nonatomic, strong) NSMutableArray *scrollerArr;


@end

@implementation ShowImageView



-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
         UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showViewClick:)];
        [self addGestureRecognizer:tap];
        self.showsHorizontalScrollIndicator = NO;
        self.bounces = NO;
        self.pagingEnabled = YES;
        
    }
    return self;
}


-(void)showViewClick:(UITapGestureRecognizer*)tap
{
    
    if ([self.superView isKindOfClass:[UIScrollView class]])
    {
        UIScrollView *superScrollView = self.superView;
        superScrollView.scrollEnabled = YES;
    }
    
    if (self.dismissBlock)
    {
        self.dismissBlock();
    }
    
    [self removeFromSuperview];
}

-(void)setImageUrlArr:(NSArray *)imageUrlArr
{
    _imageUrlArr = imageUrlArr;
    

    self.superView = self.superview;
    if ([self.superView isKindOfClass:[UIScrollView class]])
    {
        UIScrollView *superScrollView = self.superView;
        superScrollView.scrollEnabled = NO;
        
        
    }
    
    self.indexed = 0;

    [self loadThreeImage];
}



/**
 *  加载三张图片
 */
#define  padding 5



-(void)loadThreeImage
{
    long cout;
    if (!self.showImageCount)
    {
        self.showImageCount = 3;
        cout = self.imageUrlArr.count - self.indexed >=self.showImageCount? self.showImageCount:self.imageUrlArr.count - self.indexed;
    }else
    {
        if (self.showImageCount > self.imageUrlArr.count-1)
        {
            cout = self.imageUrlArr.count;
        }else
        {
            cout = self.imageUrlArr.count - self.indexed >=self.showImageCount? self.showImageCount:self.imageUrlArr.count - self.indexed;
        }
        
    }
    
    
    self.scrollerArr = [NSMutableArray array];
    self.contentSize = CGSizeMake(cout *self.frame.size.width, self.frame.size.height);
    
    
    CGFloat scX = 0;
    CGFloat scY = 0;
    CGFloat scW = self.frame.size.width;
    CGFloat scH = self.frame.size.height;
    
    CGFloat imageX = padding;
    CGFloat imageW  = scW- padding*2;
    __block CGFloat imageY = 0;
    __block CGFloat imageH = 0;
    
    
    CGFloat proW = 60;
    CGFloat proH = proW;
    CGFloat proX = (scW - proW) *0.5;
    CGFloat proY = (self.frame.size.height - proH)/2;
    
    
    CGFloat tallyY = 60;
    CGFloat tallyH = 40;
    CGFloat tallyX = 50;
    CGFloat tallyW = scW - tallyX*2;

    for (int i = 0; i < cout; ++i)
    {
        
        UIScrollView *scrollerView = [[UIScrollView alloc]init];
        [self addSubview:scrollerView];
        scrollerView.showsVerticalScrollIndicator = NO;
        scrollerView.bounces = NO;
        scrollerView.pagingEnabled = YES;
        [self.scrollerArr addObject:scrollerView];
        scrollerView.backgroundColor = [UIColor clearColor];
        
        UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(leftSwipe:)];
        leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
        UISwipeGestureRecognizer *rigthSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rigthSwipe:)];
        rigthSwipe.direction = UISwipeGestureRecognizerDirectionRight;
        [scrollerView addGestureRecognizer:leftSwipe];
        [scrollerView addGestureRecognizer:rigthSwipe];
    
        
        UIImageView *imageView = [[UIImageView alloc]init];
        [scrollerView addSubview:imageView];
        scrollerView.delegate = self;
        UIPinchGestureRecognizer*pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(imagePinch:)];
        [imageView addGestureRecognizer:pinch];
        imageView.userInteractionEnabled = YES;
        
        SHProgerssView *progerV = [[SHProgerssView alloc]init];
        if (!self.isProgerss)
        {
            progerV.hidden = YES;
        }else
        {
            [scrollerView addSubview:progerV];
            if (self.properssColor)
            {
                progerV.properssColor = self.properssColor;
            }else
            {
                progerV.properssColor = [UIColor whiteColor];
            }
        }
        progerV.backgroundColor = [UIColor clearColor];
        
        
        UILabel *tallyView = [[UILabel alloc]init];
        if (self.isTally)
        {
             [scrollerView addSubview:tallyView];
        }
       
        tallyView.tag = 1;
        
        if (!self.TallyColor)
        {
            tallyView.textColor = [UIColor whiteColor];
        }else
        {
            tallyView.textColor = self.TallyColor;
        }
        
        tallyView.text = [NSString stringWithFormat:@"%ld/%lu",self.indexed+1,(unsigned long)self.imageUrlArr.count];
        
        tallyView.frame = CGRectMake(tallyX, tallyY, tallyW, tallyH);
        if (self.tallyFont)
        {
            tallyView.font = self.tallyFont;
        }else
        {
            tallyView.font = [UIFont fontWithName:@"Bodoni 72 Book" size:15];
        }
        
        tallyView.textAlignment = NSTextAlignmentCenter;
        [scrollerView bringSubviewToFront:tallyView];

        
        
        scX =  i*(scW );
        scrollerView.frame = CGRectMake(scX, scY, scW, scH);
        progerV.frame = CGRectMake(proX, proY, proW, proH);
        
        
        NSString *urlstr = self.imageUrlArr[self.indexed];
        NSURL *url = [NSURL URLWithString:urlstr];
        
        __weak typeof(self) weakSelf = self;
        [[SDWebImageDownloader sharedDownloader]downloadImageWithURL:url options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
            progerV.progerss = receivedSize *1.0 / expectedSize *1.0;
            [progerV setNeedsDisplay];
            if (progerV.progerss==1)
            {
                progerV.hidden = YES;
            }
        } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            
            imageH = imageW / image.size.width * image.size.height;
            if (imageH > weakSelf.frame.size.height)
            {
                imageY = 0;
            }else
            {
                imageY = (weakSelf.frame.size.height - imageH)*0.5;
                
            }

            scrollerView.contentSize = CGSizeMake(scW, imageH);
            imageView.image = image;
             imageView.frame = CGRectMake(imageX, imageY, imageW, imageH);
            
        }];
        
        
        if (self.indexed<self.imageUrlArr.count)
        {
            self.indexed++;
            
        }
        
    }
}


-(void)imagePinch:(UIPinchGestureRecognizer*)pinch
{
    UIImageView *imageView = (UIImageView*)pinch.view;
    self.imageCenter = imageView.center;
    CGFloat scale = pinch.scale;
    
    imageView.transform = CGAffineTransformScale(imageView.transform, scale, scale);
    
    imageView.center = imageView.superview.center;
    pinch.scale = 1.0;
    
    //缩放完
    __weak typeof(self) weakSelf = self;
    if (pinch.state == UIGestureRecognizerStateEnded)
    {
        [UIView animateWithDuration:0.3 animations:^{
           
            // 清空控件的transform
            imageView.transform = CGAffineTransformIdentity;
            imageView.center = weakSelf.imageCenter;
        }];
    }
    
}


-(void)leftSwipe:(UISwipeGestureRecognizer*)swipe
{
    UIScrollView *scrollerV = (UIScrollView*)swipe.view;
    UIScrollView *SscrollerV = self.scrollerArr.lastObject;
    if (scrollerV ==SscrollerV )//数组最后一个
    {
        if (self.indexed < self.imageUrlArr.count-1)
        {
            self.indexed--;
            for (UIScrollView *view in self.scrollerArr)
            {
                [view removeFromSuperview];
            }
            [self loadThreeImage];
            self.contentOffset = CGPointMake(0, 0);
        }
    }
}
-(void)rigthSwipe:(UISwipeGestureRecognizer*)swipe
{
    UIScrollView *scrollerV = (UIScrollView*)swipe.view;
    UIScrollView *SscrollerV = self.scrollerArr.firstObject;
    if (scrollerV ==SscrollerV )//数组第一个
    {
        int ID;
        if ((self.indexed-self.scrollerArr.count)>0)
        {
            if ((self.indexed-self.scrollerArr.count)>1) { //回滚两张
                self.indexed -=(self.scrollerArr.count+2);
                ID=2;
            }else
            {
                self.indexed -=(self.scrollerArr.count+1); //回滚一张
                ID=1;
            }
            
            for (UIScrollView *view in self.scrollerArr)
            {
                [view removeFromSuperview];
            }
            [self loadThreeImage];
            self.contentOffset = CGPointMake(self.frame.size.width*ID, 0);
        }
    }

}

/**
 *  手势代理方法
 返回YES表示，当手势被识别时会将手势继续传递给他的父控件
 *
 */
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat tallyY = 60+scrollView.contentOffset.y;
    CGFloat tallyH = 40;
    CGFloat tallyX = 50;
    CGFloat tallyW = self.frame.size.width - tallyX*2;
    for (UIView *view in scrollView.subviews)
    {
        if ([view isKindOfClass:[UILabel class]]&&view.tag==1)
        {
            view.frame = CGRectMake(tallyX, tallyY, tallyW, tallyH);
        }
    }
}

@end
