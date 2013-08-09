//
//  JHIntroGraphicViewController.m
//  tubedj
//
//  Created by Jordan Hamill on 09/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHIntroGraphicViewController.h"
#import "JHDiscalimerViewController.h"

@interface JHIntroGraphicViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation JHIntroGraphicViewController {
	BOOL _pageControlUsed;
	UIBarButtonItem *doneBarButton;
}

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
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"gradient-bg"]];
	self.navigationItem.hidesBackButton = YES;
	self.scrollView.delegate = self;
	
	UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
	[doneButton setTitle:@"done" forState:UIControlStateNormal];
	[doneButton setTitleColor:[UIColor app_blue] forState:UIControlStateNormal];
	[doneButton addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	
	doneBarButton = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
	
	NSNumber *remainingHeight;
	
	if(IS_IPHONE5) {
		remainingHeight = [NSNumber numberWithFloat:548-44];
	} else {
		remainingHeight = [NSNumber numberWithFloat:460-44];
	}

    
	UIImageView	*imageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"startup-1"]];
	UIImageView	*imageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"startup-2"]];
	UIImageView	*imageView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"startup-3"]];
	UIImageView	*imageView4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"startup-4"]];
	
	imageView1.translatesAutoresizingMaskIntoConstraints = NO;
	imageView2.translatesAutoresizingMaskIntoConstraints = NO;
	imageView3.translatesAutoresizingMaskIntoConstraints = NO;
	imageView4.translatesAutoresizingMaskIntoConstraints = NO;
	
	[self.scrollView addSubview:imageView1];
	[self.scrollView addSubview:imageView2];
	[self.scrollView addSubview:imageView3];
	[self.scrollView addSubview:imageView4];
	
	[self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView1(320)][imageView2(320)][imageView3(320)][imageView4(320)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView1,imageView2,imageView3,imageView4)]];
	[self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView1(remainingHeight)]|" options:0 metrics:NSDictionaryOfVariableBindings(remainingHeight) views:NSDictionaryOfVariableBindings(imageView1)]];
	[self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView2(remainingHeight)]|" options:0 metrics:NSDictionaryOfVariableBindings(remainingHeight) views:NSDictionaryOfVariableBindings(imageView2)]];
	[self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView3(remainingHeight)]|" options:0 metrics:NSDictionaryOfVariableBindings(remainingHeight) views:NSDictionaryOfVariableBindings(imageView3)]];
	[self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView4(remainingHeight)]|" options:0 metrics:NSDictionaryOfVariableBindings(remainingHeight) views:NSDictionaryOfVariableBindings(imageView4)]];
	
	[self.scrollView updateConstraints];
	[self.scrollView layoutIfNeeded];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doneButtonPressed:(id)sender
{
	JHDiscalimerViewController *nextPage = [GeneralUI loadController:[JHDiscalimerViewController class]];
	[self.navigationController pushViewController:nextPage animated:YES];
}

- (IBAction)changePage:(id)sender {
    _pageControlUsed = YES;
    CGFloat pageWidth = _scrollView.contentSize.width /_pageControl.numberOfPages;
    CGFloat x = _pageControl.currentPage * pageWidth;
    [_scrollView scrollRectToVisible:CGRectMake(x, 0, pageWidth, _scrollView.frame.size.height) animated:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    _pageControlUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	
	int page = lround(_scrollView.contentOffset.x /
					  (_scrollView.contentSize.width / _pageControl.numberOfPages));
	
	if(page == 3) {
		self.navigationController.visibleViewController.navigationItem.rightBarButtonItem = doneBarButton;
	} else
		self.navigationController.visibleViewController.navigationItem.rightBarButtonItem = nil;
	
    if (!_pageControlUsed)
		_pageControl.currentPage = page;
}
@end
