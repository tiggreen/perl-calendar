#!/usr/bin/perl
# Author: Tigran Hakobyan
# calendar.pl - Calendar perl client based on Google Calendar API. 

use strict; 

if ( @ARGV < 2 ) {
  print "Usage: perl calendar.pl <calendar_id> <access_token> ". "\n";
  exit;
}


my $cal_id = $ARGV[0];
my $access_token = $ARGV[1];

my $command = "";
my $result = "";

# help
sub help {
	printf("%-30s\n\n", "Available Commands:");
	printf("%-16s %10s %-30s\n", "list", "<output_file>", "Displays all the events of the user's calendar.");
	printf("%-16s %10s %-30s\n", "add_event" ,"<event_body>", "Adds a new event to the user's calendar.");
	printf("%-16s %10s %-30s\n", "remove_event",  "<event_id>", "Remove the event from the user's calendar.");
}

# Check if the user input command is supported.
sub is_supported {
	my @all_commands = ("list", "add_event", "remove_event", "help", "exit");
	my $c = $_[0];
	for my $i (@all_commands) {
		if ($i eq $c) {
			return 1;
		} 
	}
	return 0;
}


while (1) {

	my $line = <STDIN>;

	my @user_input = split(' ', $line);

	$command = $user_input[0];

	if (is_supported($command)) {

		if($command eq "list") {
			$result = `/bin/bash listevents.sh $access_token $cal_id someoutput`;

		} elsif($command eq "add_event") {
			my $event_body = $user_input[1];
			$result = `/bin/bash addevent.sh $access_token $cal_id $event_body somefile`;

		} elsif($command eq "remove_event") {
			my $event_id = $user_input[1];
			$result = `/bin/bash remevent.sh $access_token $cal_id $event_id`;

		} elsif($command eq "exit") {
			exit;
		}
		 else {
			help();
		}
	}

	else {
			print "Command is not supported yet.";
	}

	print "\n";
}