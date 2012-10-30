//
//  ApiEntity.h
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ApiEntity : NSManagedObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSDictionary *content;

@end
