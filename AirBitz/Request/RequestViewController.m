//
//  RequestViewController.m
//
 
//  Copyright (c) 2014, Airbitz
//  All rights reserved.
//
//  Redistribution and use in source and binary forms are permitted provided that
//  the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//  3. Redistribution or use of modified source code requires the express written
//  permission of Airbitz Inc.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those
//  of the authors and should not be interpreted as representing official policies,
//  either expressed or implied, of the Airbitz Project.
//
//  See AUTHORS for contributing developers
//


#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end



#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "DDData.h"
#import "RequestViewController.h"
#import "Notifications.h"
#import "Transaction.h"
#import "CalculatorView.h"
#import "ButtonSelectorView.h"
#import "ABC.h"
#import "User.h"
#import "ShowWalletQRViewController.h"
#import "CommonTypes.h"
#import "CoreBridge.h"
#import "Util.h"
#import "ImportWalletViewController.h"
#import "InfoView.h"

#define QR_CODE_TEMP_FILENAME @"qr_request.png"
#define QR_CODE_SIZE          200.0

#define WALLET_BUTTON_WIDTH         200

#define OPERATION_CLEAR		0
#define OPERATION_BACK		1
#define OPERATION_DONE		2
#define OPERATION_DIVIDE	3
#define OPERATION_EQUAL		4
#define OPERATION_MINUS		5
#define OPERATION_MULTIPLY	6
#define OPERATION_PLUS		7
#define OPERATION_PERCENT	8

@interface RequestViewController () <UITextFieldDelegate, CalculatorViewDelegate, ButtonSelectorDelegate, 
                                     ShowWalletQRViewControllerDelegate, ImportWalletViewControllerDelegate>
{
	UITextField                 *_selectedTextField;
	int                         _selectedWalletIndex;
	ShowWalletQRViewController  *_qrViewController;
    ImportWalletViewController  *_importWalletViewController;
}

@property (nonatomic, weak) IBOutlet CalculatorView     *keypadView;
@property (nonatomic, weak) IBOutlet UILabel            *BTCLabel_TextField;
@property (nonatomic, weak) IBOutlet UITextField        *BTC_TextField;
@property (nonatomic, weak) IBOutlet UILabel            *USDLabel_TextField;
@property (nonatomic, weak) IBOutlet UITextField        *USD_TextField;
@property (nonatomic, weak) IBOutlet ButtonSelectorView *buttonSelector;
@property (nonatomic, weak) IBOutlet UILabel            *exchangeRateLabel;

@property (nonatomic, copy)   NSString *strFullName;
@property (nonatomic, copy)   NSString *strPhoneNumber;
@property (nonatomic, copy)   NSString *strEMail;
@property (nonatomic, strong) NSArray  *arrayWallets;

@end

@implementation RequestViewController

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

    // resize ourselves to fit in area
    [Util resizeView:self.view withDisplayView:nil];

	self.keypadView.delegate = self;
	self.buttonSelector.delegate = self;
	self.buttonSelector.textLabel.text = NSLocalizedString(@"Wallet:", @"Label text on Request Bitcoin screen");
    [self.buttonSelector setButtonWidth:WALLET_BUTTON_WIDTH];
}

-(void)awakeFromNib
{
	
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	[self loadWalletInfo];
	self.BTCLabel_TextField.text = [User Singleton].denominationLabel; 
	self.BTC_TextField.inputView = self.keypadView;
	self.USD_TextField.inputView = self.keypadView;
	self.BTC_TextField.delegate = self;
	self.USD_TextField.delegate = self;

	CGRect frame = self.keypadView.frame;
	frame.origin.y = frame.origin.y + frame.size.height;
	self.keypadView.frame = frame;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exchangeRateUpdate:) name:NOTIFICATION_EXCHANGE_RATE_CHANGE object:nil];
    [self exchangeRateUpdate:nil]; 
}


-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)showingQRCode
{
    return _qrViewController != nil;
}

- (void)resetViews
{
    if (_importWalletViewController)
    {
        [_importWalletViewController.view removeFromSuperview];
        _importWalletViewController = nil;
    }
    if (_qrViewController)
    {
        [_qrViewController.view removeFromSuperview];
        _qrViewController = nil;
    }
}


#pragma mark - Action Methods

- (IBAction)info
{
	[self.view endEditing:YES];
    [InfoView CreateWithHTML:@"infoRequest" forView:self.view];
}

- (IBAction)ImportWallet
{
	[self.view endEditing:YES];
    [self bringUpImportWalletView];
}

- (IBAction)QRCodeButton
{
	[self.view endEditing:YES];

    // get the QR Code image
    NSMutableString *strRequestID = [[NSMutableString alloc] init];
    NSMutableString *strRequestAddress = [[NSMutableString alloc] init];
    NSMutableString *strRequestURI = [[NSMutableString alloc] init];
    UIImage *qrImage = [self createRequestQRImageFor:@"" withNotes:@"" storeRequestIDIn:strRequestID storeRequestURI:strRequestURI storeRequestAddressIn:strRequestAddress scaleAndSave:NO];

    // bring up the qr code view controller
    [self showQRCodeViewControllerWithQRImage:qrImage address:strRequestAddress requestURI:strRequestURI];
}

#pragma mark - Notification Handlers

- (void)exchangeRateUpdate: (NSNotification *)notification
{
    NSLog(@"Updating exchangeRateUpdate");
	[self updateTextFieldContents];
}

#pragma mark - Misc Methods

- (const char *)createReceiveRequestFor:(NSString *)strName withNotes:(NSString *)strNotes
{
	//creates a receive request.  Returns a requestID.  Caller must free this ID when done with it
	tABC_TxDetails details;
	tABC_CC result;
	double currency;
	tABC_Error error;

    Wallet *wallet = [self.arrayWallets objectAtIndex:_selectedWalletIndex];
	//first need to create a transaction details struct
    details.amountSatoshi = [CoreBridge denominationToSatoshi: self.BTC_TextField.text];
	
	//the true fee values will be set by the core
	details.amountFeesAirbitzSatoshi = 0;
	details.amountFeesMinersSatoshi = 0;
	
	result = ABC_SatoshiToCurrency([[User Singleton].name UTF8String], [[User Singleton].password UTF8String],
                                   details.amountSatoshi, &currency, wallet.currencyNum, &error);
	if (result == ABC_CC_Ok)
	{
		details.amountCurrency = currency;
	}

    details.szName = (char *) [strName UTF8String];
    details.szNotes = (char *) [strNotes UTF8String];
	details.szCategory = "";
	details.attributes = 0x0; //for our own use (not used by the core)

	char *pRequestID;

    // create the request
	result = ABC_CreateReceiveRequest([[User Singleton].name UTF8String],
                                      [[User Singleton].password UTF8String],
                                      [wallet.strUUID UTF8String],
                                      &details,
                                      &pRequestID,
                                      &error);

	if (result == ABC_CC_Ok)
	{
		return pRequestID;
	}
	else
	{
		return 0;
	}
}

- (UIImage *)dataToImage:(const unsigned char *)data withWidth:(int)width andHeight:(int)height
{
	//converts raw monochrome bitmap data (each byte is a 1 or a 0 representing a pixel) into a UIImage
	char *pixels = malloc(4 * width * width);
	char *buf = pixels;
		
	for (int y = 0; y < height; y++)
	{
		for (int x = 0; x < width; x++)
		{
			if (data[(y * width) + x] & 0x1)
			{
				//printf("%c", '*');
				*buf++ = 0;
				*buf++ = 0;
				*buf++ = 0;
				*buf++ = 255;
			}
			else
			{
				printf(" ");
				*buf++ = 255;
				*buf++ = 255;
				*buf++ = 255;
				*buf++ = 255;
			}
		}
		//printf("\n");
	}
	
	CGContextRef ctx;
	CGImageRef imageRef;
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	ctx = CGBitmapContextCreate(pixels,
								(float)width,
								(float)height,
								8,
								width * 4,
								colorSpace,
								(CGBitmapInfo)kCGImageAlphaPremultipliedLast ); //documentation says this is OK
	CGColorSpaceRelease(colorSpace);
	imageRef = CGBitmapContextCreateImage (ctx);
	UIImage* rawImage = [UIImage imageWithCGImage:imageRef];
	
	CGContextRelease(ctx);
	CGImageRelease(imageRef);
	free(pixels);
	return rawImage;
}

-(void)showQRCodeViewControllerWithQRImage:(UIImage *)image address:(NSString *)address requestURI:(NSString *)strRequestURI
{
	UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
	_qrViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"ShowWalletQRViewController"];
	
	_qrViewController.delegate = self;
	_qrViewController.qrCodeImage = image;
	_qrViewController.addressString = address;
	_qrViewController.uriString = strRequestURI;
	_qrViewController.statusString = NSLocalizedString(@"Waiting for Payment...", @"Message on receive request screen");
    _qrViewController.amountSatoshi = [CoreBridge denominationToSatoshi: self.BTC_TextField.text];
	CGRect frame = self.view.bounds;
	_qrViewController.view.frame = frame;
	[self.view addSubview:_qrViewController.view];
	_qrViewController.view.alpha = 0.0;
	
	[UIView animateWithDuration:0.35
						  delay:0.0
						options:UIViewAnimationOptionCurveEaseInOut
					 animations:^
	 {
		_qrViewController.view.alpha = 1.0;
	 }
    completion:^(BOOL finished)
    {
    }];
}

// generates and returns a request qr image, stores request id in the given mutable string
- (UIImage *)createRequestQRImageFor:(NSString *)strName withNotes:(NSString *)strNotes storeRequestIDIn:(NSMutableString *)strRequestID storeRequestURI:(NSMutableString *)strRequestURI storeRequestAddressIn:(NSMutableString *)strRequestAddress scaleAndSave:(BOOL)bScaleAndSave
{
    UIImage *qrImage = nil;
    [strRequestID setString:@""];
    [strRequestAddress setString:@""];
    [strRequestURI setString:@""];

    unsigned int width = 0;
    unsigned char *pData = NULL;
    char *pszURI = NULL;
    tABC_Error error;

    const char *szRequestID = [self createReceiveRequestFor:strName withNotes:strNotes];

    if (szRequestID)
    {
        Wallet *wallet = [self.arrayWallets objectAtIndex:_selectedWalletIndex];
        tABC_CC result = ABC_GenerateRequestQRCode([[User Singleton].name UTF8String],
                                           [[User Singleton].password UTF8String],
                                           [wallet.strUUID UTF8String],
                                                   szRequestID,
                                                   &pszURI,
                                                   &pData,
                                                   &width,
                                                   &error);

        if (result == ABC_CC_Ok)
        {
                qrImage = [self dataToImage:pData withWidth:width andHeight:width];

            if (pszURI && strRequestURI)
            {
                [strRequestURI appendFormat:@"%s", pszURI];
                free(pszURI);
            }
            
        }
        else
        {
                [Util printABC_Error:&error];
        }
    }

    if (szRequestID)
    {
        if (strRequestID)
        {
            [strRequestID appendFormat:@"%s", szRequestID];
        }
        char *szRequestAddress = NULL;

        Wallet *wallet = [self.arrayWallets objectAtIndex:_selectedWalletIndex];
        tABC_CC result = ABC_GetRequestAddress([[User Singleton].name UTF8String],
                                               [[User Singleton].password UTF8String],
                                               [wallet.strUUID UTF8String],
                                               szRequestID,
                                               &szRequestAddress,
                                               &error);

        if (result == ABC_CC_Ok)
        {
            if (szRequestAddress && strRequestAddress)
            {
                [strRequestAddress appendFormat:@"%s", szRequestAddress];
                free(szRequestAddress);
            }
        }
        else
        {
            [Util printABC_Error:&error];
        }

        free((void*)szRequestID);
    }

    if (pData)
    {
        free(pData);
    }
    
    UIImage *qrImageFinal = qrImage;

    if (bScaleAndSave)
    {
        // scale qr image up
        UIGraphicsBeginImageContext(CGSizeMake(QR_CODE_SIZE, QR_CODE_SIZE));
        CGContextRef c = UIGraphicsGetCurrentContext();
        CGContextSetInterpolationQuality(c, kCGInterpolationNone);
        [qrImage drawInRect:CGRectMake(0, 0, QR_CODE_SIZE, QR_CODE_SIZE)];
        qrImageFinal = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        // save it to a file
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:QR_CODE_TEMP_FILENAME];
        [UIImagePNGRepresentation(qrImageFinal) writeToFile:filePath atomically:YES];
    }

    return qrImageFinal;
}

- (void)updateTextFieldContents
{
    tABC_Error error;
    Wallet *wallet = [self.arrayWallets objectAtIndex:_selectedWalletIndex];
    self.exchangeRateLabel.text = [CoreBridge conversionString:wallet];
    self.USDLabel_TextField.text = wallet.currencyAbbrev;
	if (_selectedTextField == self.BTC_TextField)
	{
		double currency;
        int64_t satoshi = [CoreBridge denominationToSatoshi: self.BTC_TextField.text];
		if (ABC_SatoshiToCurrency([[User Singleton].name UTF8String], [[User Singleton].password UTF8String],
                                  satoshi, &currency, wallet.currencyNum, &error) == ABC_CC_Ok)
            self.USD_TextField.text = [CoreBridge formatCurrency:currency
                                                 withCurrencyNum:wallet.currencyNum
                                                      withSymbol:false];
	}
	else if (_selectedTextField == self.USD_TextField)
	{
		int64_t satoshi;
		double currency = [self.USD_TextField.text doubleValue];
		if (ABC_CurrencyToSatoshi([[User Singleton].name UTF8String], [[User Singleton].password UTF8String],
                                  currency, wallet.currencyNum, &satoshi, &error) == ABC_CC_Ok)
            self.BTC_TextField.text = [CoreBridge formatSatoshi:satoshi
                                                     withSymbol:false
                                               overrideDecimals:[CoreBridge currencyDecimalPlaces]];
	}
}

- (void)loadWalletInfo
{
    // load all the non-archive wallets
    NSMutableArray *arrayWallets = [[NSMutableArray alloc] init];
    [CoreBridge loadWallets:arrayWallets archived:nil];

    // create the array of wallet names
    _selectedWalletIndex = 0;
    NSMutableArray *arrayWalletNames = [[NSMutableArray alloc] initWithCapacity:[arrayWallets count]];
    for (int i = 0; i < [arrayWallets count]; i++)
    {
        Wallet *wallet = [arrayWallets objectAtIndex:i];
 
        [arrayWalletNames addObject:[NSString stringWithFormat:@"%@ (%@)", wallet.strName, [CoreBridge formatSatoshi:wallet.balance]]];
 
        if ([_walletUUID isEqualToString: wallet.strUUID])
            _selectedWalletIndex = i;
    }
    
    if (_selectedWalletIndex < [arrayWallets count])
    {
        Wallet *wallet = [arrayWallets objectAtIndex:_selectedWalletIndex];
        self.keypadView.currencyNum = wallet.currencyNum;

        self.buttonSelector.arrayItemsToSelect = [arrayWalletNames copy];
        [self.buttonSelector.button setTitle:wallet.strName forState:UIControlStateNormal];
        self.buttonSelector.selectedItemIndex = (int) _selectedWalletIndex;
    }
    self.arrayWallets = arrayWallets;
}

- (void)bringUpImportWalletView
{
    {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
        _importWalletViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"ImportWalletViewController"];

        _importWalletViewController.delegate = self;

        CGRect frame = self.view.bounds;
        frame.origin.x = frame.size.width;
        _importWalletViewController.view.frame = frame;
        [self.view addSubview:_importWalletViewController.view];

        [UIView animateWithDuration:0.35
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^
         {
             _importWalletViewController.view.frame = self.view.bounds;
         }
                         completion:^(BOOL finished)
         {

         }];
    }
}

#pragma mark - Calculator delegates

- (void)CalculatorDone:(CalculatorView *)calculator
{
	[self.BTC_TextField resignFirstResponder];
	[self.USD_TextField resignFirstResponder];
}

- (void)CalculatorValueChanged:(CalculatorView *)calculator
{
	[self updateTextFieldContents];
}


#pragma mark - ButtonSelectorView delegates

- (void)ButtonSelector:(ButtonSelectorView *)view selectedItem:(int)itemIndex
{
    _selectedWalletIndex = itemIndex;

    // Update wallet UUID
    Wallet *wallet = [self.arrayWallets objectAtIndex:_selectedWalletIndex];
    [self.buttonSelector.button setTitle:wallet.strName forState:UIControlStateNormal];
    self.buttonSelector.selectedItemIndex = _selectedWalletIndex;
    
    _walletUUID = wallet.strUUID;

    self.keypadView.currencyNum = wallet.currencyNum;
    [self updateTextFieldContents];
}

#pragma mark - ShowWalletQRViewController delegates

- (void)ShowWalletQRViewControllerDone:(ShowWalletQRViewController *)controller
{
	[controller.view removeFromSuperview];
	_qrViewController = nil;
}

#pragma mark - Textfield delegates

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	_selectedTextField = textField;
    if (_selectedTextField == self.BTC_TextField)
        self.keypadView.calcMode = CALC_MODE_COIN;
    else if (_selectedTextField == self.USD_TextField)
        self.keypadView.calcMode = CALC_MODE_FIAT;

	self.keypadView.textField = textField;
	self.BTC_TextField.text = @"";
	self.USD_TextField.text = @"";
}

#pragma mark - Import Wallet Delegates

- (void)importWalletViewControllerDidFinish:(ImportWalletViewController *)controller
{
	[controller.view removeFromSuperview];
	_importWalletViewController = nil;
}


@end
