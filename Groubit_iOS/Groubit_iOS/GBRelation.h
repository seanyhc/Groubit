//
//  GBRelation.h
//  Groubit_iOS
//
//  Created by Jeffrey on 1/20/12.
//  Copyright (c) 2012 UCB MIMS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GBHabit, GBUser;

@interface GBRelation : NSManagedObject {
@private
}
@property (nonatomic, retain) NSDate * createAt;
@property (nonatomic, retain) NSString * RelationID;
@property (nonatomic, retain) NSString * RelationType;
@property (nonatomic, retain) NSDate * updateAt;
@property (nonatomic, retain) NSString * RelationStatus;
@property (nonatomic, retain) GBUser *fromUser;
@property (nonatomic, retain) GBHabit *hasHabit;
@property (nonatomic, retain) GBUser *toUser;

@end
