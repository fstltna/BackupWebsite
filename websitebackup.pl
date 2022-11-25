#!/usr/bin/perl

# Set these for your situation
my $WEBDIR = "/var/www";
my $BACKUPDIR = "/root/backups";
my $SQLDUMPDIR = "$BACKUPDIR/sqldump/";
my $TARCMD = "/bin/tar czf";
my $VERSION = "1.0";

# Init file data
my $MySettings = "$ENV{'HOME'}/.webbackuprc";
my $BACKUPUSER = "";
my $BACKUPPASS = "";
my $BACKUPSERVER = "";
my $BACKUPPATH = "";
my $DEBUG_MODE = "off";

#-------------------
# No changes below here...
#-------------------

sub ReadConfigFile
{
	# Check for config file
	if (-f $MySettings)
	{
		# Read in settings
		open (my $FH, "<", $MySettings) or die "Could not read default file '$MySettings' $!";
		while (<$FH>)
		{
			chop();
			my ($Command, $Setting) = split(/=/, $_);
			if ($Command eq "backupuser")
			{
				$BACKUPUSER = $Setting;
			}
			if ($Command eq "backuppass")
			{
				$BACKUPPASS = $Setting;
			}
			if ($Command eq "backupserver")
			{
				$BACKUPSERVER = $Setting;
			}
			if ($Command eq "backuppath")
			{
				$BACKUPPATH = $Setting;
			}
			if ($Command eq "debugmode")
			{
				$DEBUG_MODE = $Setting;
			}
		}
		close($FH);
	}
	else
	{
		# Store defaults
		open (my $FH, ">", $MySettings) or die "Could not create default file '$MySettings' $!";
		print $FH "backupuser=\n";
		print $FH "backuppass=\n";
		print $FH "backupserver=\n";
		print $FH "backuppath=\n";
		print $FH "debugmode=off\n";
		close($FH);
	}
}

sub PrintDebugCommand
{
	if ($DEBUG_MODE eq "off")
	{
		return;
	}
	my $PassedString = shift;
	print "About to run:\n$PassedString\n";
	print "Press Enter To Run This:";
	my $entered = <STDIN>;
}

ReadConfigFile();

print "WebsiteBackup - back up your website - version $VERSION\n";
print "======================================================\n";

if (! -d $BACKUPDIR)
{
	print "Backup dir $BACKUPDIR not found, creating...\n";
	system("mkdir -p $BACKUPDIR");
}
print "Moving existing backups: ";

if (-f "$BACKUPDIR/webbackup-5.tgz")
{
	unlink("$BACKUPDIR/webbackup-5.tgz")  or warn "Could not unlink $BACKUPDIR/webbackup-5.tgz: $!";
}
if (-f "$BACKUPDIR/webbackup-4.tgz")
{
	rename("$BACKUPDIR/webbackup-4.tgz", "$BACKUPDIR/webbackup-5.tgz");
}
if (-f "$BACKUPDIR/webbackup-3.tgz")
{
	rename("$BACKUPDIR/webbackup-3.tgz", "$BACKUPDIR/webbackup-4.tgz");
}
if (-f "$BACKUPDIR/webbackup-2.tgz")
{
	rename("$BACKUPDIR/webbackup-2.tgz", "$BACKUPDIR/webbackup-3.tgz");
}
if (-f "$BACKUPDIR/webbackup-1.tgz")
{
	rename("$BACKUPDIR/webbackup-1.tgz", "$BACKUPDIR/webbackup-2.tgz");
}
print "Done\nCreating Backup: ";
system("$TARCMD $BACKUPDIR/webbackup-1.tgz  $WEBDIR");
if ($BACKUPSERVER ne "")
{
	print "Offsite backup requested\n";
	print "Copying $BACKUPDIR/webbackup-1.tgz to $BACKUPSERVER:$BACKUPPORT\n";
	PrintDebugCommand("rsync -avz -e ssh $BACKUPDIR/webbackup-1.tgz $BACKUPUSER\@$BACKUPSERVER:$BACKUPPATH\n");
	system ("rsync -avz -e ssh $BACKUPDIR/webbackup-1.tgz $BACKUPUSER\@$BACKUPSERVER:$BACKUPPATH");
}

print("Done!\nMoving Existing MySQL data: ");
if (-f "$SQLDUMPDIR/yourls.sql-5.gz")
{
        unlink("$SQLDUMPDIR/yourls.sql-5.gz")  or warn "Could not unlink $SQLDUMPDIR/yourls.sql-5.gz: $!";
}
if (-f "$SQLDUMPDIR/yourls.sql-4.gz")
{
        rename("$SQLDUMPDIR/yourls.sql-4.gz", "$SQLDUMPDIR/yourls.sql-5.gz");
}
if (-f "$SQLDUMPDIR/yourls.sql-3.gz")
{
        rename("$SQLDUMPDIR/yourls.sql-3.gz", "$SQLDUMPDIR/yourls.sql-4.gz");
}
if (-f "$SQLDUMPDIR/yourls.sql-2.gz")
{
        rename("$SQLDUMPDIR/yourls.sql-2.gz", "$SQLDUMPDIR/yourls.sql-3.gz");
}
if (-f "$SQLDUMPDIR/yourls.sql-1.gz")
{
        rename("$SQLDUMPDIR/yourls.sql-1.gz", "$SQLDUMPDIR/yourls.sql-2.gz");
}
if (-f "$SQLDUMPDIR/yourls.sql.gz")
{
        rename("$SQLDUMPDIR/yourls.sql.gz", "$SQLDUMPDIR/yourls.sql-1.gz");
}
print("Done!\n");
exit 0;
