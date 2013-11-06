@import PreferencePanes;


@interface MMPane : NSPreferencePane
- (void)mainViewDidLoad;
@end


@interface MMLED : NSView
@property (nonatomic) BOOL on;
@end


@interface NSString (MM)
- (NSString *)stdout;
- (BOOL)exitSuccess;
- (BOOL)isFile;
- (NSString *)read;
- (NSArray *)lines;
- (NSString *)strip;
@end
