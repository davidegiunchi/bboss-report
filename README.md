
# Bacula Boss's Report . Diennea s.r.l. by Davide Giunchi
https://github.com/davidegiunchidiennea


1. Install
2. Faq
3. Various
4. Bugs
5. License


**BBoss Report - Bacula Boss's Report**

Generate a spreadsheet containing a report of what Bacula save: jobname, fileset, pre-post scripts ecc. All written in a human readable's format.

It's useful to generate periodic reports or when your boss ask for a "report of what we are saving right now": bacula's web interface may be your first thought, but an xls file it's easier to share with other managers,
 and access to the bacula's web interface may be restricted in a separated nework or similar.

LICENSE:

Copyright (c) 2016 Davide Giunchi at Diennea. https://github.com/davidegiunchidiennea


# 1 - Install

* Download the code on the server that run the bacula director:

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

# 2 - Faq

* Q: why not an open format such as ODS or even CSV, which is more compatible with exploratory analysis tools?

* A: I would have preferred to generate an ODS document, but i haven't found a good perl module to write an OpenDocument Spreadsheet file.
I've discarded the CSV option, because, for this project, i prefer a file format that let me create some rich text format (bold,header,color ecc).
I've found the module "Spreadsheet-WriteExcel" that's perfect for my needs, and the xls could be easly read with LibreOffice and converted on every format you need.

# 3 - Various

You are encourage to contribute this program, if you have patch, suggestion or
critics please contact me.
This program has been tested with Bacula community as of version 7.4.0 and it should work even with Bacula Enterprise, not tested with BareOS.

Latest bbos-report's version can be found at:
https://github.com/davidegiunchidiennea

# 4 - Bugs

If you find a bug or you want to submit a patch, send a pull request on https://github.com/davidegiunchidiennea

# 5 - License

This program is Copyright(C) 2016 Diennea, and may be copied according to
the GNU GENERAL PUBLIC LICENSE (GPL) Version 2 or a later version.  A copy of 
this license is included with this package.  This package comes with no warranty
of any kind.
