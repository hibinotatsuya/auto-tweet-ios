//
//  ListViewController.m
//  AutoTweet
//
//  Created by 日比野 達哉 on 2013/11/15.
//  Copyright (c) 2013年 Tatsuya Hibino. All rights reserved.
//

#import "ListViewController.h"
#import "Tweet.h"
#import "FormViewController.h"

@interface ListViewController ()
{
    NSMutableArray *tweetList;
    IBOutlet UITableView *table;
    
    NSString *typePicker[8];
    NSString *hourPicker[24];
    
    NSString *user_id;
    NSString *authkey;
    NSString *screen_name;
    
    NSString *selectTweetId;
}
@end

@implementation ListViewController

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
        [self performSegueWithIdentifier:@"ListViewtoView" sender:self];
    }

    [self getTweetList];
}

-(void)getTweetList{
    //くるくるアイコン
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    //初期化
    tweetList = [[NSMutableArray alloc] init];
    
    // つぶやきデータ取得
    NSString *url = [NSString stringWithFormat:@"http://autotweet.hibinotatsuya.com/1.0/list.php?user_id=%@&authkey=%@&limit=10&offset=0", user_id, authkey];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        // ネットワークにつながってないとnilになる
        if (data != nil) {
            NSDictionary *parsedDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:NULL];
            
            int i = 0;
            while (1) {
                NSString *key = [NSString stringWithFormat:@"%d", i];
                NSDictionary *tweet = parsedDict[key];
            
                if (tweet != nil) {
                    Tweet *t = [[Tweet alloc] init];
                
                    t.comment = tweet[@"comment"];
                    t.type = tweet[@"type"];
                    t.hour = tweet[@"hour"];
                    t.tweet_id = tweet[@"id"];
                    
                    //追加
                    [tweetList addObject:t];
                } else {
                    break;
                }
                
                i++;
            }
        } else {
            // ネットワークのエラー
        }
        
        // テーブルに表示
        [table reloadData];
    }];
    
    //くるくるアイコン終わり
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (IBAction)reloadTable {
    [self getTweetList];
}

//Table Viewのセクション数を指定
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//Table Viewのセルの数を指定
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tweetList count];
}

//各セルに文字をセット
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //セルのスタイルを標準のものに指定
    static NSString *CellIdentifier = @"TweetCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //カスタムセル上のラベル
    UILabel *typeHourLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *commentLabel = (UILabel *)[cell viewWithTag:2];
    //UILabel *tweetIdLabel = (UILabel *)[cell viewWithTag:3];
    
    //セルに表示
    Tweet *t = [tweetList objectAtIndex:[indexPath row]];
    
    int type = [t.type intValue];
    int hour = [t.hour intValue];
    NSString *type_str = typePicker[type];
    NSString *hour_str = hourPicker[hour];
    
    typeHourLabel.text = [type_str stringByAppendingString: hour_str];
    commentLabel.text = t.comment;
    //tweetIdLabel.text = t.tweet_id;
    
    //commentLabelのサイズを調整
    [commentLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [commentLabel setNumberOfLines:0];
    CGRect frame = commentLabel.frame;
    frame.size = CGSizeMake(290, 5000);
    [commentLabel setFrame:frame];
    [commentLabel sizeToFit];
    
    return cell;
}

//セルの高さを指定
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Tweet *t = [tweetList objectAtIndex:[indexPath row]];
    NSString* text = t.comment;
    UIFont* font = [UIFont systemFontOfSize:16];
    
    // label は表示する UILabel
    CGSize size = CGSizeMake(290, 1000);
    CGSize textSize = [text sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    
    float height = 57.0f; // セルの最低限の高さ
    
    // 元の UILabel よりも高さが高ければ高さを補正する
    float h = textSize.height - 20;
    if (h > 0) {
        height += h;
    }
    return height;  
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"ListViewToFormView"]) {
        FormViewController *formVC = segue.destinationViewController;
        formVC.tweetId = selectTweetId;
    }
}

//リストのtweetが選択された時の処理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //選択された項目のURLを参照
    Tweet *t = [tweetList objectAtIndex:[indexPath row]];
    selectTweetId = t.tweet_id;
    [self performSegueWithIdentifier:@"ListViewToFormView" sender:self];
}

// ログアウト
- (IBAction)logout:(id)sender
{
    // 設定を削除
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:@"user_id"];
    [ud removeObjectForKey:@"authkey"];
    [ud removeObjectForKey:@"screen_name"];
    
    [self performSegueWithIdentifier:@"ListViewToView" sender:self];
}

- (IBAction)add:(id)sender
{
    selectTweetId = @"";
    
    if ([tweetList count] >= 10) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"登録できるつぶやきは10件までです" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        [self performSegueWithIdentifier:@"ListViewToFormView" sender:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
