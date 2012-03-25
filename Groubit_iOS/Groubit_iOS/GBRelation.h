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

@property (nonatomic, strong) NSDate * createAt;
@property (nonatomic, strong) NSString * RelationID;
@property (nonatomic, strong) NSString * RelationStatus;
@property (nonatomic, strong) NSString * RelationType;
@property (nonatomic, strong) NSDate * updateAt;
@property (nonatomic, strong) NSString * relationToUser;
@property (nonatomic, strong) NSString * relationFromUser;
@property (nonatomic, strong) GBUser *fromUser;
@property (nonatomic, strong) GBHabit *hasHabit;
@property (nonatomic, strong) GBUser *toUser;

@end
