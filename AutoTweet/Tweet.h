//
//  Tweet.h
//  AutoTweet
//
//  Created by 日比野 達哉 on 2013/11/15.
//  Copyright (c) 2013年 Tatsuya Hibino. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tweet : NSObject

@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *hour;
@property (nonatomic, strong) NSString *tweet_id;

@end
