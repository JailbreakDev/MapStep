@interface SBMediaController : NSObject
+(id)sharedInstance;
-(BOOL)pause;
-(BOOL)isPaused;
-(BOOL)isPlaying;
-(BOOL)play;
@end

@interface NSDistributedNotificationCenter : NSNotificationCenter
+ (id)defaultCenter;
- (void)postNotificationName:(id)arg1 object:(id)arg2;
- (void)removeObserver:(id)arg1 name:(id)arg2 object:(id)arg3;
- (void)addObserver:(id)arg1 selector:(SEL)arg2 name:(id)arg3 object:(id)arg4;
@end

#define SRMediaController ((SBMediaController *)[%c(SBMediaController) sharedInstance])
#define SRPlayNotification @"com.sharedroutine.mapstep.play.notification"
#define SRPauseNotification @"com.sharedroutine.mapstep.pause.notification"
#define Post_Notification(name) [[NSDistributedNotificationCenter defaultCenter] postNotificationName:name object:nil]

%group MapStep
%hook MNVoiceController

-(void)_speak:(id)speech {
	Post_Notification(SRPauseNotification); //notification to pause playing send to springboard
	%orig;
}

-(void)speechSynthesizer:(id)synthesizer didFinishSpeaking:(BOOL)finish withError:(NSError *)error {
	Post_Notification(SRPlayNotification);
	%orig;
}

-(void)dealloc {
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
	%orig;
}

%end
%end

@interface SRMapStep : NSObject
-(void)notificationReceived:(NSNotification *)notification;
@end

@implementation SRMapStep

-(void)notificationReceived:(NSNotification *)notification {

	if ([notification.name isEqualToString:SRPauseNotification]) {

		if ([SRMediaController isPlaying]) {
			[SRMediaController pause];
		}

	}

	if ([notification.name isEqualToString:SRPlayNotification]) {

		if ([SRMediaController isPaused]) {
			[SRMediaController play];
		}

	}

}

@end

%ctor {

	NSString *bundleID = [[NSBundle mainBundle].bundleIdentifier;
	if (bundleID && [bundleID isEqualToString:@"com.apple.springboard"]) {
		SRMapStep *mapStep = [[SRMapStep alloc] init]; //it is running all the time to receive our notifications
		[[NSDistributedNotificationCenter defaultCenter] addObserver:mapStep selector:@selector(notificationReceived:) name:nil object:nil];
	} else if (bundleID && [bundleID isEqualToString:@"com.apple.Maps"]) {
		%init(MapStep);
	}
}