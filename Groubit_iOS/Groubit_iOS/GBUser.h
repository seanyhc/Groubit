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
@property (nonatomic, retain) NSString * UserName;
@property (nonatomic, retain) NSString * UserPass;
@property (nonatomic, retain) NSString * UserID;
@property (nonatomic, retain) NSSet *habits;
@property (nonatomic, retain) NSSet *hasRelation;
@property (nonatomic, retain) NSSet *referencedByRelation;
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
