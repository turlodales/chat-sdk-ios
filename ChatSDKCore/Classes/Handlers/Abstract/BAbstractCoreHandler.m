//
//  BAbstractCoreHandler.m
//  Pods
//
//  Created by Benjamin Smiley-andrews on 12/11/2016.
//
//

#import "BAbstractCoreHandler.h"

#import <ChatSDK/Core.h>
#import <Foundation/Foundation.h>

@implementation BAbstractCoreHandler

-(instancetype) init {
    if ((self = [super init])) {
        __weak __typeof__(self) weakSelf = self;
        [BChatSDK.hook addHook:[BHook hook:^(NSDictionary * data) {
            // Resets the view which the tab bar loads on
            __typeof__(self) strongSelf = weakSelf;
            strongSelf->_currentUser = Nil;
        }] withName:bHookDidLogout];
    }
    return self;
}

-(RXPromise *) sendMessageWithText:(NSString *)text withThreadEntityID:(NSString *)threadID withMetaData: (NSDictionary *)meta {
    
    // Set the URLs for the images and save it in CoreData
    [BChatSDK.db beginUndoGroup];
    
    id<PMessage> message = [[[[BMessageBuilder textMessage:text] meta:meta] thread:threadID] build];
    return [self sendMessage:message];
}

-(RXPromise *) sendMessageWithText:(NSString *)text withThreadEntityID:(NSString *)threadID {
    return [self sendMessageWithText:text withThreadEntityID:threadID withMetaData:nil];
}

-(RXPromise *) sendMessage: (id<PMessage>) messageModel {
    // This is an abstract method which must be overridden
    NSLog(@"sendMessage: must be overridden");
    assert(1 == 2);
}

-(NSArray *) messagesForThreadWithEntityID:(NSString *) entityID order: (NSComparisonResult) order {
    // Get the thread
    id<PThread> thread = [BChatSDK.db fetchEntityWithID:entityID withType:bThreadEntity];
    
    if (thread) {
        if (order == NSOrderedAscending) {
            return thread.messagesOrderedByDateAsc;
        }
        if (order == NSOrderedDescending) {
            return thread.messagesOrderedByDateDesc;
        }
    }
    return Nil;
}

-(NSArray *) threadsWithType:(bThreadType)type {
    return [self threadsWithType:type includeDeleted:NO];
}

-(NSArray *) threadsWithType:(bThreadType)type includeDeleted: (BOOL) includeDeleted {
    return [self threadsWithType:type includeDeleted:includeDeleted includeEmpty:BChatSDK.shared.configuration.showEmptyChats];
}

// TODO: Optimize this
-(NSArray *) threadsWithType:(bThreadType)type includeDeleted: (BOOL) includeDeleted includeEmpty: (BOOL) includeEmpty {
    
    NSMutableArray * threads = [NSMutableArray new];
    NSArray * allThreads = type & bThreadFilterPrivate ? BChatSDK.currentUser.threads : [BChatSDK.db fetchEntitiesWithName:bThreadEntity];
    
    for(id<PThread> thread in allThreads) {
        if(thread.type.intValue & bThreadFilterPrivate) {
            if(thread.type.intValue & type  && (!thread.deleted_.boolValue || includeDeleted) && (thread.hasMessages || includeEmpty)) {
                [threads addObject:thread];
            }
        }
        else if (thread.type.intValue & bThreadFilterPublic) {
            if(thread.type.intValue & type) {
                [threads addObject:thread];
            }
        }
    }
    
    [threads sortUsingComparator:^(id<PThread> t1, id<PThread> t2) {
        return [t2.orderDate compare:t1.orderDate];
    }];
    
    return threads;
}

-(void) save {
    [BChatSDK.db save];
}

-(void) saveToStore {
    [BChatSDK.db saveToStore];
}

-(void) sendLocalSystemMessageWithText:(NSString *)text withThreadEntityID:(NSString *)threadID {
    [self sendLocalSystemMessageWithText:text type:bSystemMessageTypeInfo withThreadEntityID:threadID];
}

-(void) sendLocalSystemMessageWithText:(NSString *)text type: (bSystemMessageType) type withThreadEntityID:(NSString *)threadID {
    id<PMessage> message = [[[BMessageBuilder systemMessage:text type:type] thread:threadID] build];
    [BHookNotification notificationMessageDidSend: message];
}


-(id<PUser>) userForEntityID: (NSString *) entityID {
    // Get the user and make sure it's updated
    return [BChatSDK.db fetchOrCreateEntityWithID:entityID withType:bUserEntity];
}

/**
 * @brief Update the user on the server
 */
-(RXPromise *) pushUser {
    assert(NO);
}

/**
 * @brief Return the current user data
 */
-(id<PUser>) currentUserModel {
    NSString * currentUserID = BChatSDK.auth.currentUserEntityID;
    if (!_currentUser || ![_currentUserEntityID isEqual:currentUserID]) {
        _currentUser = [BChatSDK.db fetchEntityWithID:currentUserID
                                                                   withType:bUserEntity];
        _currentUserEntityID = currentUserID;
        [_currentUser optimize];
        [self save];
    }
    return _currentUser;
}

// TODO: Consider removing / refactoring this
/**
 * @brief Mark the user as online
 */
-(void) setUserOnline {
    if(BChatSDK.lastOnline && [BChatSDK.lastOnline respondsToSelector:@selector(setLastOnlineForUser:)]) {
        [BChatSDK.lastOnline setLastOnlineForUser:self.currentUserModel];
    }
}

/**
 * @brief Connect to the server
 */

-(void) goOffline {
    assert(NO);
}


/**
 * @brief Disconnect from the server
 */
-(void) goOnline {
    assert(NO);
}

// TODO: Consider removing / refactoring this
/**
 * @brief Subscribe to a user's updates
 */
-(void)observeUser: (NSString *)entityID {
    assert(NO);
}

/**
 * @brief This method invites adds the users provided to a a conversation thread
 * Register block to:
 * - Handle thread creation
 */
-(RXPromise *) createThreadWithUsers: (NSArray *) users
                                name: (NSString *) name
                       threadCreated: (void(^)(NSError * error, id<PThread> thread)) threadCreated {
    assert(NO);
}

-(RXPromise *) createThreadWithUsers: (NSArray *) users
                       threadCreated: (void(^)(NSError * error, id<PThread> thread)) thread {
    assert(NO);
}

/**
 * @brief Add users to a thread
 */
-(RXPromise *) addUsers: (NSArray *) users toThread: (id<PThread>) threadModel {
    assert(NO);
}

/**
 * @brief Remove users from a thread
 */
-(RXPromise *) removeUsers: (NSArray *) users fromThread: (id<PThread>) threadModel {
    assert(NO);
}

/**
 * @brief Lazy loading of messages this method will load
 * that are not already in memory
 */
-(RXPromise *) loadMoreMessagesForThread: (id<PThread>) threadModel {
    assert(NO);
}

/**
 * @brief This method deletes an existing thread. It deletes the thread from memory
 * and removes the user from the thread so the user no longer recieves notifications
 * from the thread
 */
-(RXPromise *) deleteThread: (id<PThread>) thread {
    assert(NO);
}

-(RXPromise *) leaveThread: (id<PThread>) thread {
    assert(NO);
}

-(RXPromise *) joinThread: (id<PThread>) thread {
    assert(NO);
}

- (void)setUserOffline {
    assert(NO);
}

-(id<PThread>) fetchThreadWithUsers: (NSArray *) users {
    id<PUser> currentUser = self.currentUserModel;
    
    NSMutableArray * usersToAdd = [NSMutableArray arrayWithArray:users];
    [usersToAdd removeObject:currentUser];
    [usersToAdd addObject:currentUser];
    
    // If there are only two users check to see if a thread already exists
    if (usersToAdd.count == 2) {
        
        // Check to see if we already have a chat with this user
        id<PThread> jointThread = Nil;
        
        NSSet * usersToAddSet = [NSSet setWithArray:usersToAdd];
        
        // Check to see if a thread already exists with these
        // two users
        for (id<PThread> thread in [BChatSDK.core threadsWithType:bThreadType1to1 includeDeleted:YES includeEmpty:YES]) {
            if ([thread.users isEqual:usersToAddSet]) {
                jointThread = thread;
                break;
            }
        }
        
        // Complete with the thread
        if(jointThread) {
            [jointThread setDeleted: @NO];
            return jointThread;
        }
    }
    return Nil;
}

-(id<PThread>) fetchOrCreateThreadWithUsers: (NSArray *) users name: (NSString *) name {
    id<PThread> thread = [self fetchThreadWithUsers:users];
    if (!thread) {
        thread = [self createThreadWithUsers:users name:name];
    }
    return thread;
}

-(id<PThread>) createThreadWithUsers: (NSArray *) users name: (NSString *) name {
    id<PUser> currentUser = self.currentUserModel;
    
    NSMutableArray * usersToAdd = [NSMutableArray arrayWithArray:users];
    [usersToAdd removeObject:currentUser];
    [usersToAdd addObject:currentUser];
    
    // Before we create the thread start an undo grouping
    // that means that if it fails we can undo changed to the database
    //[BChatSDK.db beginUndoGroup];
    
    id<PThread> threadModel = [BChatSDK.db createThreadEntity];
    threadModel.creationDate = [NSDate date];
    threadModel.creator = currentUser;
    threadModel.type = usersToAdd.count == 2 ? @(bThreadType1to1) : @(bThreadTypePrivateGroup);
    threadModel.name = name;
    
    for (id<PUser> user in usersToAdd) {
        [threadModel addUser:user];
    }
    
    return threadModel;
}

- (NSArray *)threadsWithUsers:(NSArray *)users type:(bThreadType)type {
    NSMutableArray * threads = [NSMutableArray new];

    NSSet * usersSet = [NSSet setWithArray:users];

    for (id<PThread> thread in [BChatSDK.core threadsWithType:type]) {
        if([usersSet isEqual:thread.users]) {
            [threads addObject:thread];
        }
    }

    return threads;
}


@end
