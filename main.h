@import PreferencePanes;

#define MMErrorDomain @"MMErrorDomain"

enum MMErrorCode {
    MMDiagnosticFailedRed,
    MMDiagnosticFailedAmber
};


@interface MMPane : NSPreferencePane
- (void)mainViewDidLoad;
@end



@interface NSString (MM)
- (void)exec;
- (NSString *)stdout;
- (BOOL)exitSuccess;
- (BOOL)isFile;
- (NSString *)read;
- (NSArray *)lines;
- (NSString *)strip;
- (NSString *)append:(NSString *)contents;
@end



@interface MMSwitchView : NSControl

- (IBAction)moveLeft:(id)sender;
- (IBAction)moveRight:(id)sender;

- (NSInteger)state;
- (void)setState:(NSInteger)newstate;
- (void)setState:(NSInteger)newstate animate:(bool)animate;

@end



@protocol MMDiagnostic <NSObject>
- (BOOL)execute:(NSError **)error;
@end


@interface MMMavericksDiagnostic : NSObject <MMDiagnostic>
@end

@interface MMXcodeDiagnostic : NSObject <MMDiagnostic>
@end

@interface MMGitDiagnostic : NSObject <MMDiagnostic>
@end

@interface MMGitXDiagnostic : NSObject <MMDiagnostic>
@end

@interface MMGitHubDiagnostic : NSObject <MMDiagnostic>
@end

@interface MMRubyDiagnostic : NSObject <MMDiagnostic>
@end

@interface MMCocoaPodsDiagnostic : NSObject <MMDiagnostic>
@end

@interface MMTextMateDiagnostic : NSObject <MMDiagnostic>
@end

@interface MMmmmmDiagnostic : NSObject <MMDiagnostic>
- (instancetype)initWithBundle:(NSBundle *)bundle;
- (NSString *)bashProfileSourceLine;
@end



BOOL mdfind(NSString *app);


@interface MMLED : NSView
- (void)checkWith:(id<MMDiagnostic>)diagnostic;
- (void)reset;
@end
