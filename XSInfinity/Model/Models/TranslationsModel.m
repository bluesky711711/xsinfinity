//
//  TranslationsModel.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 5/27/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "TranslationsModel.h"
#import <Realm/Realm.h>
#import "Helper.h"

@implementation TranslationsModel

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static TranslationsModel *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void) saveTranslations: (NSArray *) translations{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    for (NSDictionary *translationData in translations) {
        
        Translations *translation = [[Translations alloc] init];
        translation.translationId = [[Helper sharedHelper] cleanValue:translationData[@"identifier"]];
        translation.translationKey = [[Helper sharedHelper] cleanValue:translationData[@"id"]];
        translation.localeIdentifier = [[Helper sharedHelper] cleanValue:translationData[@"localeIdentifier"]];
        translation.pluralForm = [[Helper sharedHelper] cleanValue:translationData[@"pluralForm"]];
        translation.value = [[Helper sharedHelper] cleanValue:translationData[@"value"]];
        translation.lastModified = [[Helper sharedHelper] cleanValue:translationData[@"lastModified"]];
        
        [realm beginWriteTransaction];
        [realm addOrUpdateObject:translation];
        [realm commitWriteTransaction];
        
    }
}

- (NSString *) getTranslationForKey: (NSString *) key{
//    Languages *language = [self selectedLanguage];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"translationKey == %@ AND localeIdentifier == %@", key, LANGUAGE_KEY];
    RLMResults *transRes = [Translations objectsWithPredicate:predicate];
    
    NSString *translationValue = key;
    if( transRes.count > 0 ){
        Translations *translation = [transRes firstObject];
        translationValue = translation.value;
    }
    
    return translationValue;
}
- (Translations *) getLatestTranslation{
    RLMResults *results = [[Translations allObjects] sortedResultsUsingKeyPath:@"lastModified" ascending:NO];
    return results.count > 0 ?[results firstObject] :nil;
}

@end
