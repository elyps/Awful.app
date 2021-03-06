//  AwfulManagedObject.h
//
//  Copyright 2013 Awful Contributors. CC BY-NC-SA 3.0 US https://github.com/Awful/Awful.app

#import <CoreData/CoreData.h>

/**
 * An AwfulManagedObject is marginally more convenient than an NSManagedObject.
 */
@interface AwfulManagedObject : NSManagedObject

/**
 * Returns the name of the entity represented by the class. The default implementation returns the name of the class.
 */
+ (NSString *)entityName;

/**
 * Returns a new object of the class's entity inserted into a managed object context.
 */
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

/**
 * Returns all objects of the class's entity.
 */
+ (NSArray *)fetchAllInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

/**
 * Returns all objects of the class's entity that match a predicate.
 */
+ (NSArray *)fetchAllInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                    matchingPredicateFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(2, 3);

/**
 * Returns YES if there are any objects of the class's entity that match a predicate.
 */
+ (BOOL)anyInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
          matchingPredicateFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(2, 3);

/**
 * Returns an arbitrary object of the class's entity that matches a predicate.
 */
+ (instancetype)fetchArbitraryInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                             matchingPredicateFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(2, 3);

/**
 * Deletes all objects of the class's entity that match a predicate.
 *
 * @return YES if deletion succeeded, otherwise NO.
 */
+ (BOOL)deleteAllInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                matchingPredicateFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(2, 3);

@end
