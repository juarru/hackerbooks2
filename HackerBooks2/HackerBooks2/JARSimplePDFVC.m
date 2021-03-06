//
//  JARSimplePDFVC.m
//  HackerBooks2
//
//  Created by Juan Arillo Ruiz on 1/10/16.
//  Copyright © 2016 Juan Arillo Ruiz. All rights reserved.
//

#import "JARSimplePDFVC.h"
#import "JARAnnotationDetailVC.h"
// Models
#import "JARBook.h"
#import "JARPdf.h"
// Others
#import "NotificationKeys.h"
#import "JARViewController+Navigation.h"

@interface JARSimplePDFVC ()

@property (nonatomic, readwrite) JARBook *book;

@end

@implementation JARSimplePDFVC

#pragma mark - Init

- (id)initWithBook:(JARBook *)aBook {
    if (self = [super init]) {
        _book = aBook;
        self.title = aBook.title;
    }
    
    return self;
}

#pragma mark - Notification

- (void)dealloc {
    [self unregisterForNotifications];
}

- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notifySelectedBookDidChange:)
                                                 name:DID_SELECT_BOOK_NOTIFICATION
                                               object:nil];
}

- (void)unregisterForNotifications {
    // Clear out _all_ observations that this object was making
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// BOOK_WAS_SELECTED_NOTIFICATION_NAME
- (void)notifySelectedBookDidChange:(NSNotification *)notification {
    
    // Get updated book
    JARBook *newBook = notification.userInfo[BOOK_KEY];
    // Update model
    self.book = newBook;
    // Update content view
    [self updateViewContent];
}

#pragma mark - View events

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UIBarButtonItem *addBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                            target:self
                                                                            action:@selector(addAnnotationToBook:)];
    self.navigationItem.rightBarButtonItem = addBtn;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Assign delegates
    self.webView.delegate = self;
    
    [self updateViewContent];
    
    // Notifications **********************
    [self registerForNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self unregisterForNotifications];   //optionally we can unregister a notification when the view disappears
}

#pragma mark - IBActions

- (void)addAnnotationToBook:(id)sender {
    JARAnnotationDetailVC *annVC = [[JARAnnotationDetailVC alloc] initAnnotation:nil forBook:self.book];
    [self presentViewController:[annVC wrappedInNavigationController] animated:YES completion:nil];
}

#pragma mark - Helpers

- (void)updateViewContent {
    
    self.title = self.book.title;
    
    [self.activityView startAnimating];
    [self.book.pdf fetchPDFDataWithCompletion:^(NSData *pdfData) {
        NSLog(@"PDF file is ready");
        // Start loading PDF
        if (pdfData) {
            [self.webView loadData:pdfData MIMEType:@"application/pdf" textEncodingName:@"UTF-8" baseURL:nil];
        } else {
            NSLog(@"We couldn't fetch the pdf file");
        }
    }];
}


#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"Start loading");
    [self.activityView startAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"Ups! Houston, we had a problem");
    [self.activityView stopAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"Loading did finish");
    [self.activityView stopAnimating];
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
