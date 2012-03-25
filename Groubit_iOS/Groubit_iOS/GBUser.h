//
//  GBUser.h
//  Groubit_iOS
//
//  Created by Jeffrey on 1/20/12.
//  Copyright (c) 2012 UCB MIMS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GBHabit, GBRelation;

@interface GBUser : NSManagedObject {
@private
}
@property (nonatomic, strong) NSDate * createAt;
@property (nonatomic, strong) NSDate * updateAt;
@property (nonatomic, strong) NSString * UserID;
@property (nonatomic, strong) NSString * UserName;
@property (nonatomic, strong) NSString * UserPass;
@property (nonatomic, strong) NSSet *habits;
@property (nonatomic, strong) NSSet *hasRelation;
@property (nonatomic, strong) NSSet *referencedByRelation;
@end

@interface GBUser (CoreDataGeneratedAccessors)

- (void)addHabitsObject:(GBHabit *)value;
- (void)removeHabitsObject:(GBHabit *)value;
- (void)addHabits:(NSSet *)values;
- (void)removeHabits:(NSSet *)values;
- (void)addHasRelationObject:(GBRelation *)value;
- (void)removeHasRelationObject:(GBRelation *)value;
- (void)addHasRelation:(NSSet *)values;
- (void)removeHasRelation:(NSSet *)values;
- (void)addReferencedByRelationObject:(GBRelation *)value;
- (void)removeReferencedByRelationObject:(GBRelation *)value;
- (void)addReferencedByRelation:(NSSet *)values;
- (void)removeReferencedByRelation:(NSSet *)values;
@end
