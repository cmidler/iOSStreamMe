//
//  MainTableViewController.h
//  genesis
//
//  Created by Chase Midler on 9/3/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainTableViewCell.h"
#import "AppDelegate.h"
#import "MainDatabase.h"
#import "MeViewController.h"
#import "CustomPickerViewController.h"
#import "ViewStreamCollectionViewController.h"
#import "SelectStreamsTableViewController.h"
#import "MainTutorialContentViewController.h"
#import "Stream.h"

#include "REMenu.h"
#define STREAMS_PER_PAGE 50
#define SHARES_PER_PAGE 10
#define LOADING_CELL_TAG 1337
#define STREAM_CELL_TAG 1234
#define END_LOADING_SHARE_TAG 1111
#define BEGINNING_LOADING_SHARE_TAG 8888
#define SHARE_CELL_TAG 1000
#define MAX_TITLE_CHARS 32
#define MAX_CAPTION_CHARS 140
#define TABLE_VIEW_BAR_HEIGHT 66
#define HEADER_HEIGHT 66
#define FIRST_HEADER_HEIGHT 10
#define TOOLBAR_HEIGHT 44
#define PICTURE_SIZE 100
#define TABLE_VIEW_X_ORIGIN 16
#define COLLECTION_VIEW_WIDTH 262.5 //260 for width and 2.5 for spacing between cells

@interface MainTableViewController : UITableViewController <UITextFieldDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIPageViewControllerDataSource>
{
    NSArray* showStreamsArray;
}
- (IBAction)addStreamAction:(id)sender;
//-(void) updateMethod;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) IBOutlet UITableView *streamsTableView;
@property (weak, nonatomic) IBOutlet UISwitch *switchButton;
//- (IBAction)switchToggleAction:(id)sender;
@property (nonatomic, readwrite) NSInteger selectedCellIndex;
@property (nonatomic, readwrite) NSInteger selectedSectionIndex;
@property (strong, nonatomic) PFObject* selectedStream;
@property (strong, nonatomic) CBCentralInterface* central;
@property (nonatomic) UIImagePickerControllerCameraFlashMode flashMode;
@property (strong, nonatomic) CustomPickerViewController *customPicker;
@property (strong, nonatomic) UIImageView *cameraOverlayView;
@property (strong, nonatomic) UIToolbar* toolBar;
@property (strong, nonatomic) UIBarButtonItem *flashButton;
@property (strong, nonatomic) UIBarButtonItem *streamLengthButton;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) UILabel* timeLabel;
@property (nonatomic, readwrite) bool finishedDownload;
@property (nonatomic, readwrite) bool isReloading;
@property (nonatomic, readwrite) dispatch_queue_t queue;
@property (nonatomic, readwrite) int currentPage;
@property (nonatomic, readwrite) int totalPages;
@property (nonatomic, readwrite) bool tableFirstLoad;
@property (strong, nonatomic) NSString* streamName;
@property (strong, nonatomic) NSData* imageData;
@property (nonatomic, readwrite) CGPoint originalCenter;
@property (strong, nonatomic) UITextView* caption;
@property (nonatomic, readwrite) bool creatingStream;
@property (nonatomic, readwrite) bool isTakingPicture;
@property (nonatomic, readwrite) float expirationTime;
@property (strong, nonatomic) NSString* hours;
@property (strong, nonatomic) NSString* mins;
@property (nonatomic, readwrite) bool openedWithShake;
@property (nonatomic, readwrite) bool pickerShown;
@property (nonatomic, readwrite) bool imagePickerOpen;
@property (strong, nonatomic) UIActivityIndicatorView* activityIndicator;
@property (nonatomic, readwrite) int totalValidStreams;
@property (nonatomic, readwrite) bool downloadingStreams;
@property (nonatomic, readwrite) bool loadingTableView;
@property (nonatomic, readwrite) bool isPoppingBack;
@property (nonatomic, readwrite) int sortBy;
@property (strong, nonatomic) REMenu* menu;
@property (nonatomic, readwrite) bool menuOpened;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;
@property (nonatomic, readwrite) bool showingAnywhere;
@property (nonatomic, readwrite) bool loadingViral;
@end
