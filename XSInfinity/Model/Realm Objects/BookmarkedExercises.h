//
//  BookmarkedExercises.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 8/10/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import <Realm/Realm.h>

@interface BookmarkedExercises : RLMObject
@property NSString *bookmarkId;
@property NSString *exerciseId;

@end
