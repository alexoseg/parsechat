//
//  ChatViewController.m
//  ParseChat
//
//  Created by Alex Oseguera on 7/6/20.
//  Copyright © 2020 Alex Oseguera. All rights reserved.
//

#import "ChatViewController.h"
#import <Parse/Parse.h>
#import "ChatCell.h"

@interface ChatViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *messages;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshFeed) userInfo:nil repeats:true];
}

-(void)refreshFeed{
    PFQuery *query = [PFQuery queryWithClassName:@"Message_fbu2019"];
    [query includeKey:@"user"]; 
    [query orderByDescending:@"createdAt"];
    
    typeof(self) __weak weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(error != nil){
            NSLog(@"%@", [error localizedDescription]);
        } else {
            weakSelf.messages = objects;
            [weakSelf.tableView reloadData];
        }
    }];
}

- (IBAction)sendMessage:(id)sender {
    PFObject *const chatMessage = [PFObject objectWithClassName:@"Message_fbu2019"];
    chatMessage[@"text"] = self.messageTextField.text;
    chatMessage[@"user"] = PFUser.currentUser;
    [chatMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded){
            NSLog(@"The message was saved!");
        } else {
            NSLog(@"Problem saving the message %@", error.localizedDescription);
        }
    }];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell"];
    PFObject *object = self.messages[indexPath.row];
    PFUser *user = object[@"user"];
    
    if(user != nil){
        cell.usernameLabel.text = user.username;
    } else {
        cell.usernameLabel.text = @"🤖";
    }
    cell.messageLabel.text = object[@"text"];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
