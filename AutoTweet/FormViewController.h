//
//  FormViewController.h
//  AutoTweet
//
//  Created by 日比野 達哉 on 2013/10/24.
//  Copyright (c) 2013年 Tatsuya Hibino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FormViewController : UIViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic) NSString *tweetId;

@end
