//
//  FCDeckCollectionViewController.m
//  Flashcard
//
//  Created by Sean Fitzgerald on 10/4/13.
//  Copyright (c) 2013 Sean T Fitzgerald. All rights reserved.
//

#import "FCDeckCollectionViewController.h"
#import "Deck.h"

@interface FCDeckCollectionViewController ()

@property (strong, nonatomic) NSArray *decks;

@end

@implementation FCDeckCollectionViewController

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
	
	//pull card decks from core data database
	/***** REMEMBER THIS IS NOT PERFORMED IN THE MAIN THREAD. DON'T EXPECT THERE TO BE ANY DECKS READY AFTER THIS METHOD *****/
	//also, this method draws a UIActivityIndicator on top of the view. It also gets rid of it afterward.
	[self pullCoreData];
	
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)pullCoreData {
	
	//start the activity indicator
#warning activity indicator
	
	//get the bundle documents URL
	NSURL * documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
	
	//create a managed document from the douments URl and the appended the model's name
	UIManagedDocument * databaseDocument = [[UIManagedDocument alloc] initWithFileURL:[documentsURL URLByAppendingPathComponent:FLASHCARD_DATA_MODEL_NAME]];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:[documentsURL path]])
	{
		[databaseDocument openWithCompletionHandler:^(BOOL success) {
			
			//turn off the activity indicator
#warning activity indicator

			if (success)
			{
				//pull the data from the document
				[self documentIsReady:databaseDocument];
			}
			else [[[UIAlertView alloc] initWithTitle:@"Storage Error"
																			 message:nil
																			delegate:self
														 cancelButtonTitle:nil
														 otherButtonTitles: nil] show];
		}];
	}
	else
	{
		[databaseDocument saveToURL:documentsURL
										forSaveOperation:UIDocumentSaveForCreating
									 completionHandler:^(BOOL success){
										 
										 //turn off the activity indicator
#warning activity indicator

										 if (success)
										 {
											 //pull the data from the document
											 [self documentIsReady:databaseDocument];

											 //Put in a filler Deck because this is the first time the user has opened the app
											 [self firstTimeDeckInsert];
										 }
										 else [[[UIAlertView alloc] initWithTitle:@"Storage Error"
																											message:nil
																										 delegate:self
																						cancelButtonTitle:nil
																						otherButtonTitles: nil] show];
									 }];
	}

	
}

-(void)documentIsReady:(UIManagedDocument *)databaseDocument
{
	NSManagedObjectContext * databaseContext = databaseDocument.managedObjectContext;
	
	NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:DECK_ENTITY_NAME];
	// fetch the decks, store them to array
	
	NSError * error;
	NSArray * savedPhotoObjectsArray = [self.databaseContext executeFetchRequest:request error:&error];
	
	NSMutableArray * tempImageArray = [[NSMutableArray alloc] init];
	
	for (TDMPhoto * photoObject in savedPhotoObjectsArray)
	{
    [tempImageArray addObject:photoObject];
	}
	self.imageArray = [tempImageArray copy];
	[self.collectionView reloadData];
}

-(void)firstTimeDeckInsert
{
	//Put in a filler Deck because this is the first time the user has opened the app
	
	UIImage * capturedimage = [UIImage imageNamed:@"fillerImage.png"];
	
	capturedimage = [self fixOrientation:capturedimage];
	
	NSData *imageData = UIImagePNGRepresentation(capturedimage);
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"image%d.png",[self.imageArray count]+1]];
	
	//	NSLog((@"pre writing to file"));
	if (![imageData writeToFile:imagePath atomically:NO])
	{
		//    NSLog((@"Failed to cache image data to disk"));
	}
	else
	{
		//    NSLog(@"the cachedImagedPath is %@",imagePath);
		TDMPhoto* photo = [self savePhotoWithPath:imagePath];
		NSMutableArray* tempImageArray = [self.imageArray mutableCopy];
		[tempImageArray  addObject:photo];
		self.imageArray = [tempImageArray copy];
		
	}
	
	[self.collectionView reloadData];
	
}



@end
