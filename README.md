
# Bacula Boss's Report . Diennea s.r.l. by Davide Giunchi

	   			      https://github.com/davidegiunchidiennea

1. Install
2. Various
3. Bugs
4. License


**BBoss Report - Bacula Boss's Report**

Generate a spreadsheet containing a report of what Bacula save: jobname, fileset, pre-post scripts ecc. All written in a human readable's format.

It's useful to generate periodic reports or when your boss ask for a "report of what we are saving right now": bacula's web interface may be your first thought, but an xls file it's easier to share with other managers,
 and access to the bacula's web interface may be restricted in a separated nework or similar.

LICENSE:

Copyright (c) 2016 Davide Giunchi at Diennea. https://github.com/davidegiunchidiennea


# 1 - Install

* Download the code

```
git clone https://github.com/davidegiunchidiennea/bboss-report.git
cd bboss-report
```

* Install the required Perl's module, on RedHat/Centos:
```
yum install perl-Spreadsheet-WriteExcel
```

on Debian/Ubuntu:

```
apt-get install libspreadsheet-writeexcel-perl
```

* copy the configuration file:

```
cp bboss-report.conf /etc/bacula/bboss-report.conf 
```

If your "bconsole" binary is not on /sbin/bconsole , please modify the configuration file

* copy the bboss-report program and then run it:

```
cp bboss-report.pl /etc/bacula/scripts/
/etc/bacula/scripts/bboss-report.pl /tmp/report.xls
```

The file /tmp/report.xls will contain the report.

# 2 - VARIOUS

You are encourage to contribute this program, if you have patch, suggestion or
critics please contact me.
This program has been tested with Bacula community as of version 7.4.0 and it should work even with Bacula Enterprise, not tested with BareOS.

Latest bbos-report's version can be found at:
https://github.com/davidegiunchidiennea

# 3 - BUGS

If you find a bug or you want to submit a patch, send a pull request on https://github.com/davidegiunchidiennea

# 4 - LICENSE

This program is Copyright(C) 2016 Diennea, and may be copied according to
the GNU GENERAL PUBLIC LICENSE (GPL) Version 2 or a later version.  A copy of 
this license is included with this package.  This package comes with no warranty
of any kind.
