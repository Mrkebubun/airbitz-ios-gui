//
//  QuestionAnswerView.h
//  AirBitz
//
//  Created by Carson Whitsett on 3/22/14.
//  Copyright (c) 2014 AirBitz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MinCharTextField.h"

@protocol QuestionAnswerViewDelegate;

@interface QuestionAnswerView : UIView

@property (nonatomic, assign) id<QuestionAnswerViewDelegate> delegate;
@property (nonatomic, strong) NSArray *availableQuestions; /* these show up in the table */
@property (nonatomic, readonly) BOOL questionSelected;
@property (nonatomic, weak) IBOutlet MinCharTextField *answerField;

+ (QuestionAnswerView *)CreateInsideView:(UIView *)parentView withDelegate:(id<QuestionAnswerViewDelegate>)delegate;
-(void)closeTable;
-(NSString *)question;
-(NSString *)answer;
@end





@protocol QuestionAnswerViewDelegate <NSObject>

@required
-(void)QuestionAnswerView:(QuestionAnswerView *)view tablePresentedWithFrame:(CGRect)frame;
-(void)QuestionAnswerViewTableDismissed:(QuestionAnswerView *)view;
-(void)QuestionAnswerView:(QuestionAnswerView *)view didSelectQuestion:(NSDictionary *)question oldQuestion:(NSString *)oldQuestion; //dict contains 'question' and 'minLength'
-(void)QuestionAnswerView:(QuestionAnswerView *)view didSelectAnswerField:(UITextField *)textField;
@optional

@end