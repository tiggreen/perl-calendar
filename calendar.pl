#!/usr/bin/perl
# Author: Tigran Hakobyan Kevin Bradley
# calendar.pl - Calendar perl client based on Google Calendar API. 


use strict;
# uses JSON CPAN module. JSON module must be installed first.
use JSON qw(decode_json);
#require JSON;


use strict; 
# Needed for escaping strings that are part of html urls
use URI::Escape;

if ( @ARGV < 1 ) {
  print "Usage: perl calendar.pl <access_token> ". "\n";
  exit;
}

# the calendarID is fixed.
my $cal_id = "vsclkrfr79js913a9oc7k52dbo\@group.calendar.google.com";

my $access_token = $ARGV[0];

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

# formatting the date
sub format_date {
	#2014-12-01T17:00:00-05:00
	my $dt = $_[0];
	my @spl = split(':', $dt);
	my @comps = split("-", $spl[0]);

	my $year = $comps[0];
	my $month = $comps[1];
	my $day =  substr $comps[2], 0, 2;
	my $hour = substr $comps[2], 3, 2;
	my $minute = $spl[1];
	return $month . "/" . $day . "/" . $year . " " . $hour . ":" . $minute;

}
# checks if the command was successful.
sub is_command_successful {
	return 1;
}

# TODO: Must be super pretty. 
sub event_pretty_print {
	my ($summary, $start_date, $end_date, $desc) = @_[0, 1, 2, 3];
	printf("%-15s %15s %15s %50s\n", $summary, $start_date, $end_date, $desc);
}

while (1) {

	my $line = <STDIN>;

	my @user_input = split(' ', $line);

	$command = $user_input[0];

	if (is_supported($command)) {

		if($command eq "list") {
			$result = `/bin/bash listevents.sh $access_token $cal_id someoutput`;

			my $json_data = `cat someoutput`;

			my $decode_json = decode_json($json_data);

			my @events = @{ $decode_json->{'items'} };

			# printing the header
			printf("%-15s %15s %15s %15s\n\n", "Event Name", "Start Date", "End Date", "Description");
			
			foreach my $e (@events) {
				
				my $event_id = $e->{"id"};

				# we can format the date to be more user friendly.
				my $start_date = $e->{"start"}{"dateTime"};
				my $end_date = $e->{"end"}{"dateTime"};
				my $summary = $e->{"summary"};
				my $desc = $e->{"description"};
				event_pretty_print($summary, format_date($start_date), format_date($end_date), $desc);
			}


		} elsif($command eq "add_event") {
			my $event_body = $user_input[1];
			$result = `/bin/bash addevent.sh $access_token $cal_id $event_body somefile`;

		} elsif($command eq "add_avent") {
			# TODO: possibly validate input?
			print "Please enter the event summary: ";
			my $sum = <STDIN>;
			print "Please enter the event location: ";
			my $loc = <STDIN>;
			print "Please enter the event date (Month Day Year?): ";
			my $day = <STDIN>;
			print "Please enter the event start time: ";
			my $st = <STDIN>;
			print "Please enter the event end time: ";
			my $et = <STDIN>;
			my $event_body = uri_escape($sum . " at " . $loc . " on " . $day . " " . $st . "-" . $et);
			$result = `addavent.sh $access_token $cal_id $event_body somefile`;
			# TODO: make sure event was confirmed when added by checking somefile, then deleting somefile

		} elsif($command eq "remove_event") {
			my $event_id = $user_input[1];
			$result = `/bin/bash remevent.sh $access_token $cal_id $event_id`;
		} elsif($command eq "exit") {
			exit;
		} else {
			help();
		}
	}

	else {
		print "Command is not supported yet.";
	}

	print "\n";
}