#!/usr/bin/perl
#
# BBoss Report - Bacula Boss's Report
# Generate a spreadsheet containing a report of what Bacula save: jobname, fileset, pre-post scripts ecc. All written in a human readable's format
#

# LICENSE:
#
# Copyright (c) 2016 Diennea s.r.l. by Davide Giunchi. https://github.com/davidegiunchidiennea
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
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.


#
#TODO: 
# fix the "todo" around the code

# acquire the configuration
require '/etc/bacula/bboss-report.conf';

#http://search.cpan.org/~jmcnamara/Spreadsheet-WriteExcel-2.40/lib/Spreadsheet/WriteExcel/Examples.pm
use Spreadsheet::WriteExcel;

$filename=$ARGV[0];
if (!defined($filename)) {
	print "BBoss Report: Generate a report of what Bacula save\n";
	print "Error, usage: bboss-report.pl /tmp/my-report.xls\n\n";
	die;
} 
my $workbook  = Spreadsheet::WriteExcel->new($filename);
my $worksheet = $workbook->add_worksheet('Backup');

# Create a format for the headings
my $format = $workbook->add_format();

# Add a handler to store the width of the longest string written to a column.
# We use the stored width to simulate an autofit of the column widths.
# You should do this for every worksheet you want to autofit.
$worksheet->add_write_handler(qr[\w], \&store_string_widths);

$format->set_bold();

# textwrap, respect the newlines
# doc: http://search.cpan.org/~jmcnamara/Spreadsheet-WriteExcel-2.40/lib/Spreadsheet/WriteExcel/Examples.pm#Example:_textwrap.pl
my $format_a_capo = $workbook->add_format();
$format_a_capo->set_text_wrap();

%onechar_to_human = ( 'F' => 'File' , 'D' => 'Directory' );

$line_counter=0;

open (JOBS,"echo 'show jobs'\|$bconsole |");
while (<JOBS>) {

	# exclude unnecessary informations
	unless ( ($_ =~ /^Connecting to Director/) or ($_ =~ /^1000 OK:/) or ($_ =~ /^Enter a period/) or ($_ =~ /^show jobs/) or ($_ =~ /^You have messages/)) {

		#Job: name=name-of-job JobType=66 level= Priority=10 Enabled=1
		if ( $_ =~ /^Job: name=(.+) JobType=(\d+) .+ Enabled=(\d)$/) {

			### it's a new job, so write the previous report ###
			if ($jobname) {
				$worksheet->write($line_counter, 0, "$jobname");
				$worksheet->write($line_counter, 1, "$jobtype");
				# remove the last, useless, newline "\n"
				chomp($fileset_decoded);
				$worksheet->write($line_counter, 2, "$fileset_decoded",$format_a_capo);
				chomp($script_pre);
				$worksheet->write($line_counter, 3, "$script_pre",$format_a_capo);
				chomp($script_post);
				$worksheet->write($line_counter, 4, "$script_post",$format_a_capo);
				$worksheet->write($line_counter, 5, "$enabled");
			} else {
				# it's the first line, generate column's name
				#JOBNAME;JOBTYPE;FILESET;PRESCRIPT;POSTSCRIPT;DISABLE
				$worksheet->write(0, 0, 'JobName', $format);
				$worksheet->write(0, 1, 'JobType', $format);
				$worksheet->write(0, 2, 'FileSet', $format);
				$worksheet->write(0, 3, 'Script Pre Backup', $format);
				$worksheet->write(0, 4, 'Script Post Backup', $format);
				$worksheet->write(0, 5, 'Disable', $format);
			}
			$line_counter++;

			$jobname = $1;
			$jobtype = $2;
			$enabled = $3;
			if ($enabled == 1) {
				# don't write anything if it's enabled: it makes only noise
				$enabled = '';
			} else {
				$enabled = 'Disabled';
			}

			if ($jobtype == 66) {
				$jobtype = 'Backup';	
			} elsif ($jobtype == 82) {
				$jobtype = 'Restore';	
			} elsif ($jobtype == 99) {
				$jobtype = 'Copy';	
			} elsif ($jobtype == 86) {
				$jobtype = 'Verify';	
			}

			# zeroing the fileset, to get the various O N I only after the true fileset
			($fileset_name,$fileset_decoded,$options,$include,$exclude,$script_pre,$script_post,$script)='';

		} elsif ( $_ =~ /^  --> FileSet: name=(.+)$/) {
			$fileset_name = $1;
		} elsif ( $_ =~ /^      N$/) {
			#Separator
			$fileset_decoded .= "\n";
			# zeroing, even the include-exclude are finished
			($include,$exclude)='';

		} elsif ( $_ =~ /^      O (.+)$/) {
			#Options
			$options = $1;
			$fileset_decoded .= "Options: ";
			if ( $options =~ /e/) {
				$fileset_decoded .= "Exclude ";
			} elsif ( $options =~ /o/) {
				$fileset_decoded .= "OneFS ";
			}

		} elsif ( $_ =~ /^      I (.+)$/) {
			#DIR/FILE to include
			$include_tmp=$1;
			#TODO: use something better than a regexp
			# se e' la prima volta
			if ( $include =~ /^$/) {
				$include = $include_tmp;
				$fileset_decoded .= "- Include: $include_tmp , ";
			} else {
				$include = $include_tmp;
				$fileset_decoded .= "$include_tmp , ";
			}
		#} elsif ( $_ =~ /^      R (.+)$/) {
		} elsif ( $_ =~ /^      R(D|F)* (.+)$/) {
			$fileset_decoded .= "RegExp" . $onechar_to_human{$1} . ": $2 ";
			#$fileset_decoded .= "RegExp $1: $2 ";
			# regexp
		} elsif ( $_ =~ /^      W(D|F)* (.+)$/) {
			#$fileset_decoded .= "Wild $1: $2 ";
			$fileset_decoded .= "Wild" . $onechar_to_human{$1} . ": $2 ";
			# regexp
		} elsif ( $_ =~ /^      E (.+)$/) {
			# exclude
			$exclude_tmp=$1;
			#TODO: use something better than a regexp
			# if it's the first time
			if ( $exclude =~ /^$/) {
				$exclude = $exclude_tmp;
				$fileset_decoded .= "Exclude $exclude , ";
			} else {
				$exclude = $exclude_tmp;
				$fileset_decoded .= "$exclude , ";
			}



		### PRE/POST SCRIPT ###
		} elsif ( $_ =~ /^  --> Command=(.+)$/) {
			$script=$1;
		} elsif ( $_ =~ /^  --> RunWhen=(\d)$/) {
			#2 is pre, 1 is post
			if ($1 == 2) {
				$script_pre.=$script . "\n";
			} else {
				$script_post.=$script . "\n";
			}
		}



	}
}

# http://search.cpan.org/~jmcnamara/Spreadsheet-WriteExcel-2.40/lib/Spreadsheet/WriteExcel/Examples.pm#Example:_autofit.pl
# Run the autofit after you have finished writing strings to the workbook.
autofit_columns($worksheet);

###############################################################################
#
# Adjust the column widths to fit the longest string in the column.
#
sub autofit_columns {
    
   my $worksheet = shift;
   my $col       = 0;
    
   for my $width (@{$worksheet->{__col_widths}}) {
   	$worksheet->set_column($col, $col, $width) if $width;
       	$col++;
   }
}

sub store_string_widths {
    
        my $worksheet = shift;
        my $col       = $_[1];
        my $token     = $_[2];

        return if not defined $token;       # Ignore undefs.
        return if $token eq '';             # Ignore blank cells.
        return if ref $token eq 'ARRAY';    # Ignore array refs.
        return if $token =~ /^=/;           # Ignore formula

       return if $token =~ /^([+-]?)(?=\d|\.\d)\d*(\.\d*)?([Ee]([+-]?\d+))?$/;

        return if $token =~ m{^[fh]tt?ps?://};
        return if $token =~ m{^mailto:};
        return if $token =~ m{^(?:in|ex)ternal:};

        my $old_width    = $worksheet->{__col_widths}->[$col];
        my $string_width = string_width($token);
    
        if (not defined $old_width or $string_width > $old_width) {

            $worksheet->{__col_widths}->[$col] = $string_width;
        }
    
        return undef;
}    

sub string_width {
        return 0.9 * length $_[0];
}
