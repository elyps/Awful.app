//  AwfulSettings.h
//
//  Copyright 2012 Awful Contributors. CC BY-NC-SA 3.0 US https://github.com/Awful/Awful.app

#import <Foundation/Foundation.h>

@interface AwfulSettings : NSObject

/**
 * Returns a convenient singleton instance.
 */
+ (AwfulSettings *)settings;

- (void)registerDefaults;

- (void)migrateOldSettings;

@property (readonly, strong) NSArray *sections;

- (NSDictionary *)infoForSettingWithKey:(NSString *)key;

@property (assign, nonatomic) BOOL showAvatars;

@property (assign, nonatomic) BOOL showImages;

@property (assign, nonatomic) BOOL confirmNewPosts;

@property (assign, nonatomic) BOOL darkTheme;

@property (copy, nonatomic) NSString *username;

@property (copy, nonatomic) NSString *userID;

@property (nonatomic, readonly) NSString *pocketUsername;

@property (assign, nonatomic) BOOL canSendPrivateMessages;

@property (assign, nonatomic) BOOL showThreadTags;

@property (copy, nonatomic) NSArray *favoriteForums;

@property (copy, nonatomic) NSString *lastOfferedPasteboardURL;

@property (copy, nonatomic) NSString *customBaseURL;

@property (copy, nonatomic) NSString *instapaperUsername;

@property (copy, nonatomic) NSString *instapaperPassword;

- (NSString *)themeNameForForumID:(NSString *)forumID;

- (void)setThemeName:(NSString *)themeName forForumID:(NSString *)forumID;

- (id)objectForKeyedSubscript:(id)key;

- (void)setObject:(id)object forKeyedSubscript:(id <NSCopying>)key;

/**
 * Clear all settings.
 */
- (void)reset;

@end

/**
 * Sent to default center whenever a setting changes. The userInfo dictionary has a value for AwfulSettingsDidChangeSettingKey.
 */
extern NSString * const AwfulSettingsDidChangeNotification;

/**
 * One of the values in AwfulSettingsKeys indicating which setting changed.
 */
extern NSString * const AwfulSettingsDidChangeSettingKey;

/**
 * Possible values for AwfulSettingsDidChangeSettingKey, and keys for subscripting.
 *
 * N.B. Undocumented here are the "theme-X" keys, where X is a forum ID.
 */
extern const struct AwfulSettingsKeys {
    __unsafe_unretained NSString *showAvatars;
    __unsafe_unretained NSString *showImages;
    __unsafe_unretained NSString *confirmNewPosts;
    __unsafe_unretained NSString *darkTheme;
    __unsafe_unretained NSString *username;
    __unsafe_unretained NSString *userID;
    __unsafe_unretained NSString *canSendPrivateMessages;
    __unsafe_unretained NSString *showThreadTags;
    __unsafe_unretained NSString *favoriteForums;
    __unsafe_unretained NSString *lastOfferedPasteboardURL;
    __unsafe_unretained NSString *customBaseURL;
    __unsafe_unretained NSString *instapaperUsername;
} AwfulSettingsKeys;
