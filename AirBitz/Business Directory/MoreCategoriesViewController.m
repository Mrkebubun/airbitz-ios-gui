//
//  MoreCategoriesViewController.m
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

#import "MoreCategoriesViewController.h"
#import "DL_URLServer.h"
#import "categoryCell.h"
#import "CJSONDeserializer.h"
#import "Server.h"

#define MODE_NAME	0
#define MODE_LEVEL	1

@interface MoreCategoriesViewController () <UITableViewDataSource, UITableViewDelegate, DL_URLRequestDelegate>
{
	BOOL mode;
	NSMutableArray *categoriesArray;
}
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *modeButton;

@end

@implementation MoreCategoriesViewController

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
	mode = MODE_LEVEL;
	// Do any additional setup after loading the view.
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	categoriesArray = [[NSMutableArray alloc] init];
	[self assignNameCategoryButtonText];
	[self loadCategories];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadCategories
{
	NSString *serverQuery;
	
	[categoriesArray removeAllObjects];
	if(mode == MODE_NAME)
	{
		serverQuery = [NSString stringWithFormat:@"%@/categories/?sort=name", SERVER_API];
	}
	else
	{
		serverQuery = [NSString stringWithFormat:@"%@/categories/?sort=level", SERVER_API];
	}
	 
	[[DL_URLServer controller] issueRequestURL:serverQuery
									withParams:nil
									withObject:nil
								  withDelegate:self
							acceptableCacheAge:60 * 60
								   cacheResult:YES];
}

-(void)pruneFirstThreeLevelsFromCategories
{
	NSDictionary *category;
	
	for(int i=0; i<categoriesArray.count; i++)
	{
		category = [categoriesArray objectAtIndex:i];
		NSNumber *num = [category objectForKey:@"level"];
		if(num && num != (id)[NSNull null])
		{
			if([num intValue] < 4)
			{
				[categoriesArray removeObject:category];
				i--;
			}
		}
		else
		{
			//prune null categories
			[categoriesArray removeObject:category];
			i--;
		}
	}
	
	//NSLog(@"New categories: %@", categoriesArray);
}

-(IBAction)back
{
	[[DL_URLServer controller] cancelAllRequestsForDelegate:self];
	
	[self.delegate moreCategoriesViewControllerDone:self withCategory:nil];
}

-(void)assignNameCategoryButtonText
{
	if(mode == MODE_NAME)
	{
		[self.modeButton setTitle:NSLocalizedString(@"Name", nil) forState:UIControlStateNormal];
	}
	else
	{
		[self.modeButton setTitle:NSLocalizedString(@"Level", nil) forState:UIControlStateNormal];
	}
}

-(IBAction)Mode
{
	[self.activityView startAnimating];
	if(mode == MODE_NAME)
	{
		mode = MODE_LEVEL;
	}
	else
	{
		mode = MODE_NAME;
	}
	[self assignNameCategoryButtonText];
	[self loadCategories];
}

#pragma mark Table View delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return categoriesArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger row = [indexPath row];
	categoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"categoryCell"];
	if (nil == cell)
	{
		cell = [[categoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"categoryCell"];
	}

	if((row == 0) && (row == [tableView numberOfRowsInSection:indexPath.section] - 1))
	{
		cell.bkgImage.image = [UIImage imageNamed:@"bd_cell_single"];
	}
	else
	{
		if(row == 0)
		{
			cell.bkgImage.image = [UIImage imageNamed:@"bd_cell_top"];
		}
		else
			if(row == [tableView numberOfRowsInSection:indexPath.section] - 1)
			{
				cell.bkgImage.image = [UIImage imageNamed:@"bd_cell_bottom"];
			}
			else
			{
				cell.bkgImage.image = [UIImage imageNamed:@"bd_cell_middle"];
			}
	}
	NSDictionary *dict = [categoriesArray objectAtIndex:indexPath.row];
	if(mode == MODE_NAME)
	{
		cell.categoryLabel.text = [dict objectForKey:@"name"];
	}
	else
	{
		cell.categoryLabel.text = [dict objectForKey:@"name"];
	}
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 44.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *dict = [categoriesArray objectAtIndex:indexPath.row];
	[self.delegate moreCategoriesViewControllerDone:self withCategory:[dict objectForKey:@"name"]];
}

#pragma mark - DLURLServer Callbacks

- (void)onDL_URLRequestCompleteWithStatus:(tDL_URLRequestStatus)status resultData:(NSData *)data resultObj:(id)object
{
	NSString *jsonString = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
	NSData *jsonData = [jsonString dataUsingEncoding:NSUTF32BigEndianStringEncoding];
	NSError *myError;
	NSDictionary *dictFromServer = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&myError];
	
	
	[categoriesArray addObjectsFromArray:[dictFromServer objectForKey:@"results"]];
	
	NSString *nextQuery = [dictFromServer objectForKey:@"next"];
	if(nextQuery && (nextQuery != (id)[NSNull null]))
	{
		//NSLog(@"Loading next: %@", nextQuery);
		//NSString *serverQuery = [NSString stringWithFormat:@"%@/categories/?sort=level", SERVER_API];
	
		[[DL_URLServer controller] issueRequestURL:nextQuery
										withParams:nil
										withObject:nil
									  withDelegate:self
								acceptableCacheAge:60 * 60
									   cacheResult:YES];
				
	}
	else
	{
		//NSLog(@"Results: %@", categoriesArray);
		[self pruneFirstThreeLevelsFromCategories];
		[self.activityView stopAnimating];
		[self.tableView reloadData];
	}
}

@end
