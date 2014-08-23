#import <Chuzzle.h>
#define MMAErrorDomain @"MMAErrorDomain"
@import PreferencePanes;
#import <PromiseKit.h>
#define Promise PMKPromise
#import <YOLO.h>

enum MMAErrorCode {
    MMADiagnosticFailedRed,
    MMADiagnosticFailedAmber
};

@interface MMAPreferencePane : NSPreferencePane
- (void)mainViewDidLoad;
@end

@interface NSTask (MM)
+ (instancetype):(id)parsable;
@end

@interface NSString (MM)
+ (Promise *)pmk_stringWithContentsOfFile:(NSString *)path;
@end

@interface MMASwitchView : NSControl
- (IBAction)moveLeft:(id)sender;
- (IBAction)moveRight:(id)sender;
- (NSInteger)state;
- (void)setState:(NSInteger)newstate;
- (void)setState:(NSInteger)newstate animate:(bool)animate;
@end

@interface MMALED : NSView
- (void)check:(Promise *)diagnostic;
- (void)reset;
@end

NSString *MMABundlePath();

Promise *MMACheckMavericks();
Promise *MMACheckXcode();
Promise *MMACheckGit();
Promise *MMACheckGitHub();
Promise *MMACheckGitX();
Promise *MMACheckTextMate();

Promise *mdfind(NSString *app);


@interface NSURLConnection (MMA)
+ (Promise *)download:(NSString *)urlString;
@end

#define MMAApplicationsDirectory (@"~/Applications".stringByExpandingTildeInPath)
