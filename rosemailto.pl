#!/usr/bin/perl
#############################################################################
# Mailto.pl v1.0 A web form emailing script which does not require sendmail
# 9/15/2003
# Copyright (c) 2003 Jim Roberts
# www.jim.roberts.net
# ###########################################################################
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# A copy of the GNU public license can be found at: 
# http://www.gnu.org/licenses/gpl.html
#
##############################################################################

use strict;
use CGI qw(:standard);
use Net::SMTP;

my($query,$mailhost,$mail_from,$subject,$confirmation_email_to,$confirmation_email_from,$confirmation_subject,$thankyou_url,$smtp,$f,$r,$confirmation_body);
my @mail_to;
my @field_order;
my @required_fields;
my %fields;


$query = new CGI;

############################################################################
# 
# User Settings - customize these per email form
# 
############################################################################

# Which Server should we send email through?  Note: this server must be set up 
# as an SMTP gateway for your site.  Try "localhost" first.
$mailhost = "smtp.1and1.com";

#
# Form results email settings 
#

# It's recommended the "from" field is an internal address - not the one submitted by the form poster. 
$mail_from = 'jbkorver@yahoo.com';
# Who gets the email in your organization
@mail_to = ('jbkorver@yahoo.com');
# Subject of the posted message
$subject = "La Vie en Rose Registration";


#
# Confirmation email settings  (Sending a confirmation back to the customer) 
#

# Where to send the confirmation email - if this is empty, no confirmation email will be sent.
$confirmation_email_to = $query->param("EMAIL");
# Who sends the email back to the customer?
$confirmation_email_from = 'jbkorver@yahoo.com';
# The subject of the confirmation message
$confirmation_subject = "Thank you from julianakorver.net";
# The body of the confirmation message.
$confirmation_body = "\nI have received your registration, when Denny receives the paypal notice and confirms
your registration with me, I will add your name to the list of confirmed players at http://julianakorver.net/rose \n\nThank you and I look forward to seeing you in February!\n\nJuliana\njulianakorver.net\n\n";


#
# Fields output - It's important to list all the fields in your form below.
# Follow the instructions so the output is customized as you wish.
#

#Order in which fields should be shown in the email - list all fields here - this is CASE SENSITIVE
@field_order = ("NAME","DIVISION","EMAIL","ADDRESS","CITY","STATE","PDGA","PHONE","COMMENTS");
#You can check required fields at the form using Javascript, or list them here for simple checking.
@required_fields = ("NAME","EMAIL","PDGA", "DIVISION");

#Fields output - These give human readable labels to the output fields.  Again, there should be one for each field.
$fields{"NAME"} = "Name";
$fields{"EMAIL"} = "Email Address";
$fields{"DIVISION"} = "Division";
$fields{"EMAIL"} = "Email Address";
$fields{"ADDRESS"} = "Address";
$fields{"CITY"} = "City";
$fields{"STATE"} = "State";
$fields{"PDGA"} = "PDGA #";
$fields{"PHONE"} = "Phone";
$fields{"COMMENTS"} = "Comments";

#Thank you page - This is the page the user is redirected to.
$thankyou_url = "http://julianakorver.net/rose/paypal.html";


##############################################################################
##############################################################################
# 
# DO NOT MODIFY BELOW THIS POINT (Unless you know what you are doing!)
#
##############################################################################
##############################################################################
print $query->header;

#Check required Fields
my $field;

foreach $field (@required_fields) {
  if(!$query->param($field)) {
    print "<script>
      alert(\"Please supply the following information: $fields{$field}\"); 
		history.back();</script>";
    exit;
  }	
}

#Send out the email

    $smtp = Net::SMTP->new($mailhost);

    $smtp->mail($ENV{USER});
	foreach $r (@mail_to) {
    		$smtp->to($r);
	}
    $smtp->data();
    $smtp->datasend("From: $mail_from\n");
    $smtp->datasend("To: ".join(",",@mail_to)."\n");
    $smtp->datasend("Subject: $subject\n");
    $smtp->datasend("\n");
    $smtp->datasend("The following was submitted:\n\n");
    my $outline;
    foreach $f (@field_order) {
	$outline = sprintf("%30s: %s",$fields{$f},$query->param($f));
	$smtp->datasend($outline."\n");
    }
    $smtp->dataend();

    $smtp->quit;


#Send out a Confirmation email

if($confirmation_email_to =~ /\@/) {

    my $smtp = Net::SMTP->new($mailhost);

    $smtp->mail($ENV{USER});
    $smtp->to("$confirmation_email_to");

    $smtp->data();
    $smtp->datasend("From: $confirmation_email_from\n");
    $smtp->datasend("To: $confirmation_email_to\n");
    $smtp->datasend("Subject: $confirmation_subject\n");
    $smtp->datasend("\n");
    $smtp->datasend("$confirmation_body\n");
    $smtp->dataend();

    $smtp->quit;

}


print "<META HTTP-EQUIV=refresh content=\"0;URL=$thankyou_url\">\n";

