#import "Chuzzle.h"
#define MMErrorDomain @"MMErrorDomain"
@import PreferencePanes;
#import "PromiseKit.h"
#import "YOLO.h"
#define Promise PMKPromise

enum MMErrorCode {
    MMDiagnosticFailedRed,
    MMDiagnosticFailedAmber
};

@interface MMPane : NSPreferencePane
- (void)mainViewDidLoad;
@end

@interface NSTask (MM)
- (Promise *)promise;
+ (instancetype):(id)parsable;
@end

@interface NSString (MM)
- (BOOL)exists;
+ (Promise *)stringWithContentsOfFile:(NSString *)path;
@end

@interface MMSwitchView : NSControl
- (IBAction)moveLeft:(id)sender;
- (IBAction)moveRight:(id)sender;
- (NSInteger)state;
- (void)setState:(NSInteger)newstate;
- (void)setState:(NSInteger)newstate animate:(bool)animate;
@end

@interface MMLED : NSView
- (void)check:(Promise *)diagnostic;
- (void)reset;
@end

NSString *MMBundlePath();

Promise *MMCheckMavericks();
Promise *MMCheckXcode();
Promise *MMCheckGit();
Promise *MMCheckGitHub();
Promise *MMCheckGitX();
Promise *MMCheckTextMate();

Promise *mdfind(NSString *app);
