//The MIT License (MIT)
//
//Copyright (c) 2013 Alterplay
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of
//this software and associated documentation files (the "Software"), to deal in
//the Software without restriction, including without limitation the rights to
//use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//the Software, and to permit persons to whom the Software is furnished to do so,
//subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <UIKit/UIKit.h>

#define kDefinedPINCount 4

@protocol APPINViewDelegate;
@interface APPINView : UIView

//PIN image
@property (nonatomic, strong) UIImage *normalPINImage;
@property (nonatomic, strong) UIImage *selectedPINImage;

//Getter/Setter for PIN code NSString
@property (nonatomic, strong) NSString *PINCode;

//Delegate
@property (nonatomic, weak) id <APPINViewDelegate> delegate;
@end

@protocol APPINViewDelegate <NSObject>
@required
- (void)PINCodeView:(APPINView *)view didEnterPIN:(NSString *)PINCode;
@end