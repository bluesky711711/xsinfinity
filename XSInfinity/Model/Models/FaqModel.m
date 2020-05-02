//
//  FaqModel.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 8/9/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "FaqModel.h"
#import <Realm/Realm.h>
#import "Helper.h"
#import "FaqCategory.h"
#import "Faq.h"

@implementation FaqModel

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static FaqModel *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void)saveFaqCategories:(NSArray *)json{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    for (NSDictionary *category in json) {
        FaqCategory *obj = [FaqCategory new];
        obj.identifier = [[Helper sharedHelper] cleanValue:category[@"identifier"]];
        
        NSString *title = [[Helper sharedHelper] cleanValue:category[@"title"]];
        
        obj.title = title;
        
        [realm beginWriteTransaction];
        [realm addOrUpdateObject:obj];
        [realm commitWriteTransaction];
        
        [self saveFaqs:category[@"faqs"] withCategory:obj];
    }
    
}

- (NSArray *)getAllFaqCategories{
    RLMResults *res = [FaqCategory allObjects];
    
    NSMutableArray *result = [NSMutableArray array];
    for (RLMObject *object in res) {
        [result addObject:object];
    }
    
    return [result mutableCopy];
}

- (void)saveFaqs:(NSArray *)json withCategory:(FaqCategory *)category{
    RLMRealm *realm = [RLMRealm defaultRealm];
    for (NSDictionary *faq in json){
        Faq *obj = [Faq new];
        obj.identifier = [[Helper sharedHelper] cleanValue:faq[@"identifier"]];
        obj.title = [[Helper sharedHelper] cleanValue:faq[@"title"]];
        obj.answer = [[Helper sharedHelper] cleanValue:faq[@"answer"]];
        obj.categoryIdentifier = category.identifier;
        obj.categoryTitle = category.title;
        
        [realm beginWriteTransaction];
        [realm addOrUpdateObject:obj];
        [realm commitWriteTransaction];
    }
    
}

- (NSArray *)getAllFaqsByCategory:(NSString *)categoryId{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryIdentifier = %@", categoryId];
    RLMResults *res = [Faq objectsWithPredicate:predicate];
    
    NSMutableArray *result = [NSMutableArray array];
    for (RLMObject *object in res) {
        [result addObject:object];
    }
    
    return [result mutableCopy];
}

- (NSArray *)searchFaqsByTitle:(NSString *)faqTitle{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@", faqTitle];
    RLMResults *res = [Faq objectsWithPredicate:predicate];
    
    NSMutableArray *result = [NSMutableArray array];
    for (RLMObject *object in res) {
        [result addObject:object];
    }
    
    return [result mutableCopy];
}

@end
