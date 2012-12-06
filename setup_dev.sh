#-----------------------------------------------------
# This is an imperfect but possibly useful script written by Andrew Davis (andrew@moodle.com)
# It is distributed without any sort of warranty. Use it at your own risk.
# Modify it and redistribute it however you see fit.
#
# This script should set up 3 development and 3 integration testing repositories.
# This is to allow me to:
# 1) Develop in master then cherry-pick commits into different versions.
# 2) Perform testing of newly integrated commits in all currently supported versions.
#-----------------------------------------------------
#configuration options

#database
databaseserver='localhost'
databaseuser='root'
databasepassword='password'

#your git repository
#myrepo=git@github.com:YOUR_NAME/moodle.git
# OR
myrepo=https://github.com/andyjdavis/moodle.git # Point this at your repo, not mine.

localusername=andrew #used to construct the path to your home directory

#code directory
codedir=/home/$localusername/Desktop/code
moodledir=$codedir/moodle

#data directory
#Note: code and data directories cannot have the same parent
#ie /blah/moodlecode and /blah/moodledata or is_dataroot_insecure() will report that your data directory is within your code directory
#and prevent installation
tempdir=/home/$localusername/Desktop/tempdata
datadir=$tempdir/moodledata

webdir=/var/www/moodle

#moodle config
moodleuser=admin
moodlepassword=Password1! #a password that meets Moodle's default password policy

#A html page containing links to all of your moodles will be created
indexfilelocation='/var/www/index.php'

#-----------------------------------------------------
# Check prerequisites are installed (apache and mysql including the curl php extension)
#-----------------------------------------------------

# While this checks that mysql is installed you should probably install it first beforehand
# so that you know the database login details (above).
sudo apt-get install apache2 php5-mysql libapache2-mod-php5 mysql-server mysql-workbench php5-curl
sudo /etc/init.d/mysql restart
sudo apache2ctl graceful

#-----------------------------------------------------
# and now the actual setup script
#-----------------------------------------------------
mkdir $webdir
mkdir $webdir/dev
mkdir $webdir/int

mkdir $codedir
mkdir $moodledir
mkdir $moodledir/dev
mkdir $moodledir/int

mkdir $tempdir
mkdir $datadir
mkdir $datadir/dev
mkdir $datadir/int

#Set all file permissions really permissive. This is NOT suitable for a production machine
chmod -R 777 $datadir
chmod -R 777 $moodledir

installmoodle()
{
	#$1 == 'dev' or 'int'
	#$2 == the moodle branch name ie 'MOODLE_24_STABLE' or 'master'
	#$3 == the remote repository name ie 'upstream' or 'integration'

	echo "----------------------$1 $2----------------------"
	echo 'creating directories'
	mkdir $datadir/$1/$2
	cd $moodledir/$1

    echo 'setting up mysql database'
	mysql --user=$databaseuser --password=$databasepassword -e "create database moodle_"$1"_"$2";"
	mysql --user=$databaseuser --password=$databasepassword -e "ALTER DATABASE moodle_"$1"_"$2" CHARACTER SET utf8;"

    if [ "$1$2" = "devmaster" ] ; then
        echo 'cloning the git repository for dev master'
        git clone $myrepo $2
    else
        echo "copying $moodledir/dev/master to $moodledir/$1/$2 rather than cloning"
        cp -R $moodledir/dev/master $moodledir/$1/$2
        rm $moodledir/$1/$2/config.php #delete config.php
	fi

	echo 'creating symlink to code in the web dir'
	ln -s $moodledir/$1/$2 $webdir/$1/$2
	cd $moodledir/$1/$2

    echo 'altering git config and adding the remote repository'
	git config core.filemode false #ignore file permission changes
	#we are adding the remote repos multiple times but git seems to be smart enough to ignore the extra adds
	git remote add $3 $4 #add the upstream or integration repository

    echo 'fetching from '$3' to get branch info'
    git fetch $3
    echo 'check out '$3'/'$2
	git checkout -b $2 $3/$2
	echo 'pull to make sure we have the absolute latest and greatest'
	git pull $3 $2

    # run Moodle's command line installer
	php ./admin/cli/install.php --lang=en --wwwroot=http://localhost/moodle/$1/$2 --dataroot=$datadir/$1/$2 --dbtype=mysqli --dbhost=$databaseserver --dbname=moodle_$1"_"$2 --dbuser=$databaseuser --dbpass=$databasepassword --fullname="$2 $1 fullname" --shortname="$2 $1" --adminuser=$moodleuser --adminpass=$moodlepassword --non-interactive --agree-license --allow-unstable
}

# Make sure to always do dev master first
# The other repositories will be copied from it to avoid repeated slow git clone operations
installmoodle "dev" "master" "upstream" "git://git.moodle.org/moodle.git"
installmoodle "dev" "MOODLE_24_STABLE" "upstream" "git://git.moodle.org/moodle.git"
installmoodle "dev" "MOODLE_23_STABLE" "upstream" "git://git.moodle.org/moodle.git"

installmoodle "int" "master" "integration" "git://git.moodle.org/integration.git"
installmoodle "int" "MOODLE_24_STABLE" "integration" "git://git.moodle.org/integration.git"
installmoodle "int" "MOODLE_23_STABLE" "integration" "git://git.moodle.org/integration.git"

#Set all file permissions really permissive. This is NOT suitable for a production server
chmod -R 777 $datadir
chmod -R 777 $moodledir

#write out an index file
echo '<html><body>' > $indexfilelocation

echo '<h1>dev</h1>' >> $indexfilelocation
echo "<p><a href='moodle/dev/MOODLE_23_STABLE'>MOODLE_23_STABLE</a></p>" >> $indexfilelocation
echo "<p><a href='moodle/dev/MOODLE_24_STABLE'>MOODLE_24_STABLE</a></p>" >> $indexfilelocation
echo "<p><a href='moodle/dev/master'>master</a></p>" >> $indexfilelocation

echo '<h1>integration</h1>' >> $indexfilelocation
echo "<p><a href='moodle/int/MOODLE_23_STABLE'>MOODLE_23_STABLE</a></p>" >> $indexfilelocation
echo "<p><a href='moodle/int/MOODLE_24_STABLE'>MOODLE_24_STABLE</a></p>" >> $indexfilelocation
echo "<p><a href='moodle/int/master'>master</a></p>" >> $indexfilelocation

echo '</body></html>' >> $indexfilelocation
