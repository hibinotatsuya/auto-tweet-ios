//
//  FormViewController.m
//  AutoTweet
//
//  Created by 日比野 達哉 on 2013/10/24.
//  Copyright (c) 2013年 Tatsuya Hibino. All rights reserved.
//

#import "FormViewController.h"

@interface FormViewController ()
{
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *lengthLabel;
    IBOutlet UITextField *textField;
    IBOutlet UIPickerView *picker;
    
    NSString *typePicker[8];
    NSString *hourPicker[24];
    
    NSString *user_id;
    NSString *authkey;
    NSString *screen_name;
    
    NSString *comment;
    NSString *type;
    NSString *hour;
}
@end

@implementation FormViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //Picker Viewの選択肢一覧を準備
    typePicker[0] = @"毎日";
    typePicker[1] = @"毎週月曜";
    typePicker[2] = @"毎週火曜";
    typePicker[3] = @"毎週水曜";
    typePicker[4] = @"毎週木曜";
    typePicker[5] = @"毎週金曜";
    typePicker[6] = @"毎週土曜";
    typePicker[7] = @"毎週日曜";
    
    for (int i = 0; i < 24; i++) {
        NSString *hourText = [NSString stringWithFormat:@"%d時", i];
        hourPicker[i] = hourText;
    }
    
    //薄い文字
    textField.placeholder = @"つぶやき";
}

// 画面表示後の処理
-(void)viewDidAppear:(BOOL)animated{
    //設定を取得
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    user_id = [ud stringForKey:@"user_id"];
    authkey = [ud stringForKey:@"authkey"];
    screen_name = [ud stringForKey:@"screen_name"];
    NSLog(@"user_id: %@, authkey: %@, screen_name:%@", user_id, authkey, screen_name);
    
    //設定がなかったらログイン画面へ
    if (user_id == nil || authkey == nil || screen_name == nil) {
        [self performSegueWithIdentifier:@"FormViewToListView" sender:self];
    }
    
    //TwitterID表示
    nameLabel.text = screen_name;
    
    [self getTweet];
}

// tweetIdがあったらつぶやき取得
-(void)getTweet {
    if (_tweetId == nil || [_tweetId isEqual:@""]) {
        // なんにもしないで終了
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"http://autotweet.hibinotatsuya.com/1.0/list.php?user_id=%@&authkey=%@&limit=1&offset=0&tweet_id=%@", user_id, authkey, _tweetId];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        // ネットワークにつながってないとnilになる
        if (data != nil) {
            NSDictionary *parsedDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:NULL];
        
            // 絶対一件しかない
            NSDictionary *tweet = parsedDict[@"0"];
        
            if (tweet != nil) {
                // つぶやき表示
                comment = tweet[@"comment"];
                type = tweet[@"type"];
                hour = tweet[@"hour"];
                
                textField.text = tweet[@"comment"];
                lengthLabel.text = [NSString stringWithFormat:@"%d", (int)[tweet[@"comment"] length]];
                
                NSInteger defaultType = [tweet[@"type"] integerValue];
                NSInteger defaultHour = [tweet[@"hour"] integerValue];
                
                [picker selectRow:defaultType inComponent:0 animated:YES];
                [picker selectRow:defaultHour inComponent:1 animated:YES];
            }
        } else {
            // ネットワークのエラー
        }
    }];
}

// テキストフィールドでリターン押した時
- (BOOL)textFieldShouldReturn:(UITextField *)sender {
    comment = sender.text;
    lengthLabel.text = [NSString stringWithFormat:@"%d", (int)[comment length]];
    
    // キーボードしまう
    [sender resignFirstResponder];
    
    return TRUE;
}

// PickerViewの列の数を指定
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

// カラムの要素数を指定
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if(component == 0){
        return 8;
    }else{
        return 24;
    }
}

// 選択肢要素の表示文字列
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    //row番目の要素に表示する文字列
    if(component == 0){
        return typePicker[row];
    }else{
        return hourPicker[row];
    }
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if(component == 0){
        type = [NSString stringWithFormat:@"%d", (int)row];
    }else{
        hour = [NSString stringWithFormat:@"%d", (int)row];
    }
}

// 登録ボタン
- (IBAction)post:(id)sender
{
    NSLog(@"comment: %@, type: %@, hour:%@", comment, type, hour);
    
    // つぶやきの入力チェック
    if (comment == nil || [comment isEqual:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"結果" message:@"つぶやきを入力してください" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if ([comment length] > 140) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"結果" message:@"140字以内で入力してください" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // httpでリクエスト
    NSString *query = [NSString stringWithFormat:@"user_id=%@&authkey=%@&comment=%@&type=%@&hour=%@&tweet_id=%@", user_id, authkey, comment, type, hour, _tweetId];
    NSData *queryData = [query dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *url = @"http://autotweet.hibinotatsuya.com/1.0/add.php";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:queryData];
    
    NSURLResponse *response;
    NSError *error;
    
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    NSLog(@"%@", resultString);
    
    // 結果をポップアップで出す
    NSString *alertMessage;
    if ([resultString rangeOfString:@"success"].location == NSNotFound){
        // 失敗
        NSLog(@"false");
        alertMessage = [[NSString alloc] initWithFormat:@"登録に失敗しました %@", resultString];
    } else {
        // 成功
        NSLog(@"true");
        [self performSegueWithIdentifier:@"FormViewToListView" sender:self];
        return;
        
        //alertMessage = [[NSString alloc] initWithFormat:@"つぶやきを登録しました"];
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"結果" message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

// 削除ボタン
- (IBAction)delete:(id)sender
{
    // httpでリクエスト
    NSString *query = [NSString stringWithFormat:@"user_id=%@&authkey=%@&tweet_id=%@", user_id, authkey, _tweetId];
    NSData *queryData = [query dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *url = @"http://autotweet.hibinotatsuya.com/1.0/delete.php";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:queryData];
    
    NSURLResponse *response;
    NSError *error;
    
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    NSLog(@"%@", resultString);
    
    // 結果をポップアップで出す
    NSString *alertMessage;
    if ([resultString rangeOfString:@"success"].location == NSNotFound){
        // 失敗
        NSLog(@"false");
        alertMessage = [[NSString alloc] initWithFormat:@"削除に失敗しました %@", resultString];
    } else {
        // 成功
        NSLog(@"true");
        [self performSegueWithIdentifier:@"FormViewToListView" sender:self];
        return;
        
        /*
        alertMessage = [[NSString alloc] initWithFormat:@"つぶやきを削除しました"];
        
        // 表示も初期状態に
        textField.text = @"";
        lengthLabel.text = @"0";
        [picker selectRow:0 inComponent:0 animated:YES];
        [picker selectRow:0 inComponent:1 animated:YES];
        */
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"結果" message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

// 戻る
- (IBAction)back:(id)sender
{
    [self performSegueWithIdentifier:@"FormViewToListView" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
