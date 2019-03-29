//
//  ViewController.m
//  AutoTweet
//
//  Created by 日比野 達哉 on 2013/10/24.
//  Copyright (c) 2013年 Tatsuya Hibino. All rights reserved.
//

#import "ViewController.h"
#import "NSURL+dictionaryFromQueryString.h"

@interface ViewController ()
{
    IBOutlet UIWebView *webView;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //ログインページを開く
    NSString *url = @"http://autotweet.hibinotatsuya.com/1.0/token.php";
    NSURLRequest *urlReq = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [webView loadRequest:urlReq];
}

-(void)viewDidAppear:(BOOL)animated{
    //設定を取得
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSString *user_id = [ud stringForKey:@"user_id"];
    NSString *authkey = [ud stringForKey:@"authkey"];
    NSString *screen_name = [ud stringForKey:@"screen_name"];
    
    NSLog(@"user_id: %@, authkey: %@, screen_name:%@", user_id, authkey, screen_name);
    
    //すでに設定があればフォーム画面へ
    if (user_id != nil && authkey != nil && screen_name != nil) {
        [self performSegueWithIdentifier:@"ViewToListView" sender:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ネットワークエラー" message:@"ネットワークに繋げてください" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.tag = 1;
    [alert show];
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        //ログインページを開く
        NSString *url = @"http://autotweet.hibinotatsuya.com/1.0/token.php";
        NSURLRequest *urlReq = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [webView loadRequest:urlReq];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *requestString = [[request URL] absoluteString];
    NSLog(@"%@", requestString);
    
    if ([requestString rangeOfString:@"http://autotweet.hibinotatsuya.com/1.0/login_success.php"].location == NSNotFound){
        return YES;
    }
    
    //辞書にする
    NSDictionary *dict = [[request URL] dictionaryFromQueryString];
    
    NSString *dict_user_id = [dict objectForKey:@"user_id"];
    NSString *dict_authkey = [dict objectForKey:@"authkey"];
    NSString *dict_screen_name = [dict objectForKey:@"screen_name"];
    
    // 設定を保存
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    [ud setObject:dict_user_id forKey:@"user_id"];
    [ud setObject:dict_authkey forKey:@"authkey"];
    [ud setObject:dict_screen_name forKey:@"screen_name"];
    
    [self performSegueWithIdentifier:@"ViewToListView" sender:self];
    
    return YES;
}

@end
