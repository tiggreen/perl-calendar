perl-calendar
=============

A console based calendar in Perl based on Google Calendar API.

Program requires the following perl modules to be installed in the machine before it can run.

1. JSON
2. Data::Format::Pretty::Console

To run the program:
>>> perl calendar.pl accesstoken

In order to generate an access token:

1. Go to: https://developers.google.com/oauthplayground/
2. Select Calendar API v3 -> https://www.googleapis.com/auth/calendar
3. Hit 'Authorize APIs'
4. Hit 'Exchange authroization code for tokens'
5. Copy the access token from the 'access token' field that was created.  This is the access token which should be passed to our script.

Usage:

To display all the events in the calendar run:
>>> list 

To create a new event run:
>>> add_event

To edit en existing event run: (Note: the program will ask for an event number which is the number on top of each event if you run list.)
>>> edit_event 

To remove an event run:
>>> remove_event

To exit the program run:
>>> exit

To show the help run:
>>> help
