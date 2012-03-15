//
//  GBRelation.h
//  Groubit_iOS
//
//  Created by Jeffrey on 3/10/12.
//  Copyright (c) 2012 UCB MIMS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GBHabit, GBUser;

@interface GBRelation : NSManagedObject

@property (nonatomic, retain) NSDate * createAt;
@property (nonatomic, retain) NSString * RelationID;
@property (nonatomic, retain) NSString * RelationStatus;
@property (nonatomic, retain) NSString * RelationType;
@property (nonatomic, retain) NSDate * updateAt;
@property (nonatomic, retain) NSString * relationToUser;
@property (nonatomic, retain) NSString * relationFromUser;
@property (nonatomic, retain) GBUser *fromUser;
@property (nonatomic, retain) GBHabit *hasHabit;
@property (nonatomic, retain) GBUser *toUser;

@end
