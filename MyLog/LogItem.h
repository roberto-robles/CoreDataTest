//
//  LogItem.h
//  
//
//  Created by Roberto Robles on 6/25/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LogItem : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * itemText;

@end
