# ShowImage
图片浏览器
/通过简单设置就能实现图片浏览器效果
ShowImageView *showView = [[ShowImageView alloc]init];

[weakSelf.collectionView addSubview:showView];
showView.backgroundColor = [UIColor blackColor];
//消失回调
[showView setDismissBlock:^{

self.tabBarController.tabBar.hidden = NO;
self.navigationController.navigationBar.hidden = NO;
}];

self.tabBarController.tabBar.hidden = YES;
self.navigationController.navigationBar.hidden = YES;

showView.frame = CGRectMake(0,
self.collectionView.contentOffset.y,
self.collectionView.frame.size.width,
self.collectionView.frame.size.height);

showView.imageUrlArr = data.imgList;
