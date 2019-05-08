#include "LMARootListController.h"

@implementation LMARootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

- (void) respring {
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Respring"
	message:@"Are You Sure You Want To Respring?"
	preferredStyle:UIAlertControllerStyleActionSheet];

	UIAlertAction *respringBtn = [UIAlertAction actionWithTitle:@"Respring"
	style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
		pid_t pid;
		int status;
		const char* args[] = {"killall", "SpringBoard", NULL};
		posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char*
		const*)args, NULL);
		waitpid(pid, &status, WEXITED);
	}];

	UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"Cancel"
	style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
		//nothing lol
	}];

	[alert addAction:respringBtn];
	[alert addAction:cancelBtn];

	[self presentViewController:alert animated:YES completion:nil];
}

	- (void) reset {
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reset All Settings to Default"
	message:@"Are You Sure You Want To Reset All Settings to Default?"
	preferredStyle:UIAlertControllerStyleActionSheet];

	UIAlertAction *resetBtn = [UIAlertAction actionWithTitle:@"Reset All Settings to Default"
	style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
		for(PSSpecifier *specifier in [self specifiers]) {
                [super setPreferenceValue:[specifier propertyForKey:@"Default"] specifier:specifier];
      }
    [self reloadSpecifiers];
	}];

	UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"Cancel"
	style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
		//nothing lol
	}];

	[alert addAction:resetBtn];
	[alert addAction:cancelBtn];

	[self presentViewController:alert animated:YES completion:nil];
}
@end
