#!/usr/bin/perl
# Author: Tigran Hakobyan Kevin Bradley
# calendar.pl - Calendar perl client based on Google Calendar API. 

use strict;
# Uses JSON CPAN module. JSON module must be installed first.
use JSON qw(decode_json);
# Needed for date and time manipulation.
use DateTime;
# Needed for pretty print. 
# Required Data::Format::Pretty::Console module from CPAN.
use Data::Format::Pretty::Console qw(format_pretty);
# Needed for escaping strings that are part of html urls
use URI::Escape;

if ( @ARGV < 1 ) {
  print "Usage: perl calendar.pl <access_token> ". "\n";
  exit;
}

# The calendarID is fixed. We work with this calendar.
my $cal_id = "vsclkrfr79js913a9oc7k52dbo\@group.calendar.google.com";

# Access token is passed as an argument.
my $access_token = $ARGV[0];

my $command = "";
my $result = "";

# Contains (EventNumber, EventFields) key,value pairs.
my %id_lookup_table = {};

# HELP.
sub help {
	printf("%-30s\n\n", "Available Commands:");
	printf("%-16s %10s %-30s\n", "list", "", "Display all the events.");
	printf("%-16s %10s %-30s\n", "add_event", "", "Add a new event.");
	printf("%-16s %10s %-30s\n", "edit_event", "", "Edit an event.");
	printf("%-16s %10s %-30s\n", "remove_event",  "", "Remove an event.");
}

# Check if the user input command is supported.
sub is_supported {
	my @all_commands = ("list", "add_event", "remove_event", "edit_event", "help", "exit");
	my $c = $_[0];
	for my $i (@all_commands) {
		if ($i eq $c) {
			return 1;
		} 
	}
	return 0;
}

# Trimthe a string.
sub  trim {
	my $st = shift;
	$st =~ s/^\s+|\s+$//g;
	return $st
};

# Populate the lookup hashtable
sub populate_the_event_list {

	$result = `/bin/bash listevents.sh $access_token $cal_id list-events.tmp`;
	my $json_data = `cat list-events.tmp`;
	if ($json_data eq "") {
		print "The current access_token is expired or there is no event in the calendar.\n";
		exit;
	}
	my $decode_json = decode_json($json_data);
	my @events = @{ $decode_json->{'items'} };
	my @event_list;
	my $enum = 1;

	foreach my $e (@events) {
		my $event_id = $e->{"id"};
		my $start_date = $e->{"start"}{"dateTime"};
		my $end_date = $e->{"end"}{"dateTime"};
		my $summary = $e->{"summary"};
		my $desc = $e->{"description"};
		my $loc = $e->{"location"};
		if ($start_date && $end_date) {
			push(@event_list, [$enum, $summary, create_date($start_date),
				 create_date($end_date), $desc, $loc]);

			# Adding a new tuple into our lookup hashtable.
			$id_lookup_table{$enum} = [$event_id, $summary, $start_date,
				 					   $end_date, $desc, $loc];
			$enum += 1;
		} 
	}
	return @event_list;
}

# Add a new event to the calendar.
sub add_new_event {

	print "Please enter the event summary: ";
	my $sum = <STDIN>;
	print "Please enter the event location: ";
	my $loc = <STDIN>;
	# Note see writeup, the Google api accepts various formats
	print "Please enter the event date (Month Day Year?): ";
	my $day = <STDIN>;
	my $st = "";
	while (1) {
		print "Please enter the event start time (ie 10:35am): ";
		$st = <STDIN>;
		# Make sure that the start time format is valid.
		$st = `echo "$st" | awk 'tolower(\$0) ~ /^(0?[[:digit:]]|1[0-2]):[0-5][[:digit:]](am|pm)\$/ {print tolower(\$0)}'`;
		if ($st ne "") {
			last;
		}
	}
	my $et = "";
	while (1) {
		print "Please enter the event end time (ie 10:55am): ";
		$et = <STDIN>;
		$et = `echo "$et" | awk 'tolower(\$0) ~ /^(0?[[:digit:]]|1[0-2]):[0-5][[:digit:]](am|pm)\$/ {print tolower(\$0)}'`;
		if ($et ne "") {
			last;
		}
	}
	# Creating en event body for attaching to our REST URL as a parameter.
	my $event_body = uri_escape($sum . " at " . $loc . " on " . $day . " " . $st . "-" . $et);
	$result = `/bin/bash addevent.sh $access_token $cal_id $event_body add-event.tmp`;
	my $json_result = `cat add-event.tmp`;
	# Checking if add operation was successful.
	if (is_command_successful($json_result)) {
		return 1;
	} else {
		return 0;
	}
}

# Remove an event from the calendar.
sub remove_event {
	print "Please enter the event number you want to remove (ie 1): ";
	my $ev_num = <STDIN> + 0;
	# Making sure that the event number exists in our hashtable..
	if (exists($id_lookup_table{$ev_num})) {
		my @event = $id_lookup_table{$ev_num};
		# Getting the event id.
		my $event_id = $event[0][0];

		$result = `/bin/bash remevent.sh $access_token $cal_id $event_id`;
		# Note remove event receives no http response file 204-no content
		print "The event was successfully removed from the calendar.";
		# Removing all the temp created files from the remove command.
		my $clean_rem = `rm ??????????????????????????`;
		return 1;
	} else {
	    print "The event number is invalid.";
	    return 0;
	}
}

# Edit an event.
sub edit_event {

	print "Please enter the event number you want to edit (ie 1): ";
	my $ev_num = <STDIN> + 0;

	if (exists($id_lookup_table{$ev_num})) {
		my @event = $id_lookup_table{$ev_num};

		# Getting the event id.
		my $event_id = $event[0][0];

		# Storing current event fields. 
		my $event_summary = $event[0][1];
		my $event_start = $event[0][2];
		my $event_end =  $event[0][3];
		my $event_desc = $event[0][4];
		my $event_loc = $event[0][5];


		print "Please enter the event summary ($event_summary): ";
		my $sum = <STDIN>;
		if(trim($sum) eq "") {
			$sum = $event_summary;
		}
		print "Please enter the event location ($event_loc): ";
		my $loc = <STDIN>;
		if(trim($loc) eq "") {
			$loc = $event_loc;
		}
		print "Please enter the event date (Month Day Year?): ";
		my $day = <STDIN>;
		my $st = "";
		while (1) {
			print "Please enter the event start time (ie 10:35am): ";
			$st = <STDIN>;
			$st = `echo "$st" | awk 'tolower(\$0) ~ /^(0?[[:digit:]]|1[0-2]):[0-5][[:digit:]](am|pm)\$/ {print tolower(\$0)}'`;
			if ($st ne "") {
				last;
			}
		}
		my $et = "";
		while (1) {
			print "Please enter the event end time (ie 10:55am): ";
			$et = <STDIN>;
			$et = `echo "$et" | awk 'tolower(\$0) ~ /^(0?[[:digit:]]|1[0-2]):[0-5][[:digit:]](am|pm)\$/ {print tolower(\$0)}'`;
			if ($et ne "") {
				last;
			}
		}
		my $event_body = uri_escape($sum . " at " . $loc . " on " . $day . " " . $st . "-" . $et);
		$result = `/bin/bash addevent.sh $access_token $cal_id $event_body add-event.tmp`;
		my $json_result = `cat add-event.tmp`;

		# Checking if add operation was successful.
		if (is_command_successful($json_result)) {
			$result = `/bin/bash remevent.sh $access_token $cal_id $event_id`;
			return 1;
		} else {
			return 0;
		}

	} else {
	    print "The event number is invalid.";
	    return 0;
	}
}
# Changing the date to a user friendly format.
sub format_date {
	# Getting the Date object.
	my $dt = $_[0];
	return $dt->month . "/" . $dt->day . "/" . $dt->year . " " . $dt->hour . ":" . $dt->minute;

}

# The incoming date format looks like 2014-11-19T22:20:20.935Z. 
sub create_date {
	
	my $dt = $_[0];
	my @spl = split(':', $dt);
	my @comps = split("-", $spl[0]);
	my $year = $comps[0];
	my $month = $comps[1];
	my $day =  substr $comps[2], 0, 2;
	my $hour = substr $comps[2], 3, 2;
	my $minute = $spl[1];

	# Creating the date object
	my $dt = DateTime->new(
	    year       => $year,
	    month      => $month,
	    day        => $day,
	    hour       => $hour,
	    minute     => $minute,
	    time_zone  => 'local',
	);
	return $dt;

}

# Check if add/edit event commands were successful.
# The operation is successful if its status is "confirmed".
sub is_command_successful {

	# The response is JSON. 
	my $event_json = $_[0];
	my $event = decode_json($event_json);
	# Status of the event. Possible values are:
	# "confirmed" - The event is confirmed. This is the default status.
	# "tentative" - The event is tentatively confirmed.
	# "cancelled" - The event is cancelled.
	return $event->{"status"} eq "confirmed";
}

populate_the_event_list();

while (1) {

	print ">>> ";
	my $line = <STDIN>;
	my @user_input = split(' ', $line);
	$command = $user_input[0];

	if (is_supported($command)) {

		# Listing all the events in the calendar.
		if($command eq "list") {
			my @event_list = populate_the_event_list();
			# Sorting events by their start date.
			@event_list=sort { $a->[2] <=> $b->[2] } @event_list;
			foreach my $tple (@event_list) {
			my $header = "Event ". $tple->[0];
			print format_pretty({
				$header => [
				{
					Summary     => $tple->[1],
					Start   => format_date($tple->[2]),
					End     => format_date($tple->[3]),
					Description => $tple->[4],
					Location => $tple->[5]
				}
					] 
				}
				);
			}

		# Adding a new event to the calendar.
		} elsif($command eq "add_event") {

			if(add_new_event()) {
				print "The event was successfully added.";
				my $unused = `rm add-event.tmp`;
				populate_the_event_list();
			} else {
				print "Something went wrong.";
			}

		# Removing an event from the calendar.
		} elsif($command eq "remove_event") {
			if(remove_event()) {
				populate_the_event_list();
			}
		}
		# Editing an event from the calendar.
		elsif($command eq "edit_event") {
			if(edit_event()) {
				print "The event was successfully edited.";
				my $unused = `rm add-event.tmp`;
				my $clean_rem = `rm ??????????????????????????`;
				populate_the_event_list();
			}

		}
		# Exiting the program.
		elsif($command eq "exit") {
			exit;

		}
		elsif($command eq "help") {
			help();
		}
		else {
		}
	}
	else {
		print "Invalid command.";
	}
	print "\n";
}
