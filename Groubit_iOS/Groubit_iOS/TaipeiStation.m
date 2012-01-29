//
//  TaipeiStation.m
//  Groubit_iOS
//
//  Created by Jeffrey on 1/20/12.
//  Copyright 2012 UCB MIMS. All rights reserved.
//

#import "TaipeiStation.h"
#import "GBDataModelManager.h"
#import "GBUser.h"
#import "GBHabit.h"
#import "GBTask.h"
#import "GBRelation.h"
#import "Parse/Parse.h"

@implementation TaipeiStation

@synthesize lastSyncDate;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    if(!dataModel){
    
        dataModel = [GBDataModelManager getDataModelManager];
    }
    
    lastSyncDate = [NSDate date];
    
    return self;
}

- (bool)syncUserData
{
    NSLog(@"TaipeiStation::syncUserData");
    
    GBUser *gbLocalUser = [dataModel getUser:dataModel.localUserName];
    
    // check if local user exist on remote
    
    PFQuery *query = [PFQuery queryWithClassName:@"GBUser"];
    [query whereKey:@"UserID" equalTo:gbLocalUser.UserID];
    NSArray *pfUsers = [query findObjects];
    
    if( pfUsers.count == 0 ){
    
        NSLog(@"User not exist on remote. Create now");
        
        PFObject *pfUser = [PFObject objectWithClassName:@"GBUser"];
        [pfUser setObject:gbLocalUser.UserName forKey:@"UserName"];
        [pfUser setObject:gbLocalUser.UserPass forKey:@"UserPass"];
        [pfUser setObject:gbLocalUser.UserID   forKey:@"UserID"];
        [pfUser save];
        
    }else{
    
        NSLog(@"User Exist. Merge now");
        
        PFObject *pfUser = [pfUsers lastObject];
        
        if(pfUser.updatedAt > gbLocalUser.updateAt){
            
            // use remote copy
            
            NSLog(@"Use Remote Copy");
            
            gbLocalUser.UserName = [pfUser objectForKey:@"UserName"];
            // TODO: we should secure the password with hash function
            gbLocalUser.UserPass = [pfUser objectForKey:@"UserPass"];
            gbLocalUser.updateAt = [NSDate date];
            
            [dataModel SyncData];
            
        }else{
        
            // use local copy
            
              NSLog(@"Use Local Copy");
            
            [pfUser setObject:gbLocalUser.UserName forKey:@"UserName"];
            [pfUser setObject:gbLocalUser.UserPass forKey:@"UserPass"];
            [pfUser saveInBackground];
            
        }
    }
        
    return true;
}



- (bool)syncRelation
{

    NSLog(@"TaipeiStation::syncRelation");
    
    // step 1 : Retrieve new relations on remote
    
    PFQuery *relationQuery = [PFQuery queryWithClassName:@"GBRelation"];
    [relationQuery whereKey:@"createAt" greaterThan:lastSyncDate] ;
    [relationQuery whereKey:@"toUser" equalTo:dataModel.localUserName];
    NSArray *newPFRelations = [relationQuery findObjects];
    
    if( newPFRelations && newPFRelations.count > 0 ){
    
        for( PFObject* pfRelation in newPFRelations){
        
            NSString *type     = [pfRelation objectForKey:@"RelationType"];
            NSString *fromUser = [pfRelation objectForKey:@"fromUser"];
//            NSString *toUser   = [pfRelation objectForKey:@"toUser"];
            
            if( [type isEqualToString:@"friend"] ){
                
                // friend request
                // TODO : prompt user 
                [dataModel createFriend:fromUser];
                
            }else if ([type isEqualToString:@"nanny"]){
            
                // nanny request
                // TODO prompt user
                
            }
            
        }
        
    }
    
    
    // step 2 : Retrieve all new relations on local
/*    
    NSArray *newGBRelation = [dataModel getRelationOrderThan:lastSyncDate];
    
    for(GBRelation *relation in newGBRelation){

            PFObject *pfRelation = [PFObject objectWithClassName:@"GBRelation"];
            [pfRelation setObject:relation.RelationID forKey:@"RelationID"];
            [pfRelation setObject:relation.RelationType forKey:@"RelationType"];
            [pfRelation setObject:relation.RelationStatus forKey:@"RelationStatus"];
        
            [pfRelation save];
            
    }
*/    
    // setp 3 : Merge relationes
    
    // get local relation ID
    
    
    return true;
}

- (bool)syncHabit
{

    return false;
}

- (bool) syncAll 
{
    NSLog(@"TaipeiStation::syncAll");
    NSLog(@"Last Sync Date: %@", lastSyncDate);   
    [self syncUserData];
    
 //   [self syncRelation];
    
 //   [self syncHabit];
    
    
    lastSyncDate = [NSDate date];
    return true;
}


- (void)dealloc{
    
    dataModel = nil;
}

@end
