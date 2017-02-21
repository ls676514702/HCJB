//
//  HCHomeViewController.m
//  HCJB
//
//  Created by 互传 on 2017/2/20.
//  Copyright © 2017年 互传. All rights reserved.
//

#import "HCHomeViewController.h"
#import <WebKit/WebKit.h>
#import <AFNetworking/AFNetworking.h>
#import "HCNotiView.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface HCHomeViewController ()<WKNavigationDelegate>
//占位视图
@property (weak, nonatomic) IBOutlet UIView *backView;
//顶部导航条视图
@property (weak, nonatomic) IBOutlet UIView *topView;
//进度条
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
//占位视图顶部约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLeading;
@property(nonatomic,copy)NSString *strUrl;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@end
//记录第一次加载页面
static BOOL isFirstLoad = YES;
//是否是登陆界面
static BOOL isQQ = NO;
@implementation HCHomeViewController{
    WKWebView *_wkWebview;
    AFNetworkReachabilityManager *_manager;
    HCNotiView *_notiView;
}
- (IBAction)back:(id)sender {
    [_wkWebview goBack];
}

- (IBAction)refresh:(id)sender {
    [SVProgressHUD showWithStatus:@"正在重新加载，请稍后..."];
    [_wkWebview reload];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setWebViewAndSendNoti];
    [SVProgressHUD showWithStatus:@"正在加载，请稍后"];
    [self setReachability];
    //    开始监测网络
    [_manager startMonitoring];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.backBtn.hidden = YES;
    
    
}

#pragma mark --设置网络监测
- (void)setReachability{
    _manager = [AFNetworkReachabilityManager sharedManager];
    
    __weak HCHomeViewController *weakSelf = self;
    
    [_manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"无网络");
                [weakSelf setNotiView];
                break;
            default:
                NSLog(@"有网");
                if (isFirstLoad == NO) {
                    [weakSelf removeNotiView];
                }
                isFirstLoad = NO;
                break;
        }
    }];
    
    
}
- (void)setNotiView{
    _notiView = [HCNotiView loadNotiView];
    _notiView.frame = self.backView.bounds;
    [self.backView addSubview:_notiView];
}
- (void)removeNotiView{
    [SVProgressHUD showWithStatus:@"检测到网络，正在为您加载，请稍后"];
    [_wkWebview reload];
    if (_progress.progress==1) {
        if (_notiView) {
            [_notiView removeFromSuperview];
        }
    }
}
#pragma mark --设置WebView并且设置KVO
- (void)setWebViewAndSendNoti{
    //    WKWebViewConfiguration *config =[[WKWebViewConfiguration alloc]init];
    //    config.userContentController = [WKUserContentController new];
    //    _wkWebview = [[WKWebView alloc]initWithFrame:self.backView.bounds configuration:config];
    _wkWebview = [[WKWebView alloc] initWithFrame:self.backView.bounds];
    _wkWebview.navigationDelegate = self;
    _wkWebview.backgroundColor = [UIColor whiteColor];
    [self setMessage];
    NSURL *url = [NSURL URLWithString:@"http://110.huchuan6.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_wkWebview loadRequest:request];
    [self.backView addSubview:_wkWebview];
    
    [_wkWebview addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionOld context:nil];
    //  [_wkWebview addObserver:self forKeyPath:@"canGoForward" options:NSKeyValueObservingOptionNew context:nil];
    [_wkWebview addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionOld context:nil];
}
- (void)setMessage{
    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.frame = CGRectMake(0, 100, 100, 20);
    messageLabel.text = @"haha";
    [self.backView addSubview:messageLabel];
    NSLog(@"%@",messageLabel);
}
#pragma mark --KVO监听属性变化
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (_wkWebview.canGoBack&&isQQ==NO) {
        //如果不是第一页，就让导航条的返回按钮显示
        self.backBtn.hidden = NO;
        //不是qq登录页面的时候将导航条和进度条隐藏
        if (![_strUrl containsString:@"xui.ptlogin2.qq.com"]) {
            isQQ = NO;
            self.topView.hidden = YES;
            self.progress.hidden = YES;
        }else{
            isQQ = YES;
            [self appearTopView];
        }
    }else{
        //如果是第一页将顶部导航条和进度条显示
        self.topView.hidden = NO;
        self.progress.hidden = NO;
    }
    //监听进度条
    self.progress.progress = _wkWebview.estimatedProgress;
    if (self.progress.progress==1) {
        self.progress.hidden = YES;
        [SVProgressHUD dismiss];
        if (_notiView) {
            [_notiView removeFromSuperview];
        }
        
    }
}
#pragma mark --移除KVO
- (void)dealloc{
    [_wkWebview removeObserver:self forKeyPath:@"canGoBack"];
    //    [_wkWebview removeObserver:self forKeyPath:@"canGoForward"];
    [_wkWebview removeObserver:self forKeyPath:@"estimatedProgress"];
}
#pragma mark --真正设置控件frame的方法
- (void)viewDidLayoutSubviews{
    _wkWebview.frame = CGRectMake(0, 0, self.view.frame.size.width, self.backView.frame.size.height);
    _notiView.frame = self.backView.bounds;
}
#pragma mark --禁用屏幕旋转
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

#pragma mark--WKWebView的代理方法
//拦截url的代理方法
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandlerZ{
    NSURL *url = navigationAction.request.URL;
    NSString * strUrl = url.absoluteString;
    self.strUrl = strUrl;
    NSLog(@"%@",strUrl);
    //监听请求，如果不写这句代码，程序会崩溃
    decisionHandlerZ(WKNavigationActionPolicyAllow);
}

//网页加载完成后的代理方法--提高用户体验
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    //如果是腾讯接口登陆页面
    if ([self.strUrl containsString:@"qqLoginAuth.html"]) {
        isQQ = YES;
        [self appearTopView];
    }
    //登陆成功后举报页面
    if ([self.strUrl containsString:@"myadd.html"]) {
        isQQ = NO;
        [self appearTopView];
    }
    //即将调用腾讯接口的页面
    if ([self.strUrl containsString:@"qqlogin.html"]) {
        isQQ = NO;
        [self appearTopView];
    }
    //如果是首页，隐藏返回按钮
    if ([self.strUrl isEqualToString:@"http://110.huchuan6.com/"]) {
        self.backBtn.hidden = YES;
    }
}

- (void)appearTopView{
    if (isQQ == YES) {
        self.topLeading.constant = 64;
        self.topView.hidden = NO;
    }else{
        self.topLeading.constant = 20;
        self.topView.hidden = YES;
    }
    
}
@end
