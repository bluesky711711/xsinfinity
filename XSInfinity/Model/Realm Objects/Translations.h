//
//  Translations.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 5/26/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import <Realm/Realm.h>

@interface Translations : RLMObject
@property NSString *translationId;
@property NSString *translationKey;
@property NSString *localeIdentifier;
@property NSString *pluralForm;
@property NSString *value;
@property NSString *lastModified;
@end
