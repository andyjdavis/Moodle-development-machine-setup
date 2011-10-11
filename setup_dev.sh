#-----------------------------------------------------
#configuration options

#database
databaseserver='localhost'
databaseuser='yourdatabaseuser'
databasepassword='yourpassword'

#your git repository
myrepo=git@github.com:yourgitrepo/moodle.git

#code directory
moodledir=/home/yourusername/Desktop/code/moodle
moodledirdev=$moodledir/dev
moodledirint=$moodledir/int

#data directory
#Note: code and data directories cannot have the same parent
#ie /blah/moodlecode and /blah/moodledata or is_dataroot_insecure() will report that your data directory is within your code directory
#and prevent installation
datadir=/home/yourusername/Desktop/tempdata/moodledata
datadirdev=$datadir/dev
datadirint=$datadir/int

webdir=/var/www/moodle
webdirdev=$webdir/dev
webdirint=$webdir/int

#moodle config
moodlepassword=password
moodleuser=admin

#used for directory and database schema names
moodle19=moodle19stable
moodle20=moodle20stable
moodle21=moodle21stable
master=master

#a html page containing links to all of your moodles will be created
indexfilelocation='/var/www/index.php'

#-----------------------------------------------------
# and now the actual setup script
#-----------------------------------------------------
mkdir $webdir
mkdir $webdirdev
mkdir $webdirint

mkdir $moodledir
mkdir $moodledirdev
mkdir $moodledirint

mkdir $datadir
mkdir $datadirdev
mkdir $datadirdev/$moodle19
mkdir $datadirdev/$moodle20
mkdir $datadirdev/$moodle21
mkdir $datadirdev/$master

mkdir $datadirint
mkdir $datadirint/$moodle19
mkdir $datadirint/$moodle20
mkdir $datadirint/$moodle21
mkdir $datadirint/$master

echo "----------------------dev 1.9 stable----------------------"
cd $moodledirdev
mysql --user=$databaseuser --password=$databasepassword -e "create database moodle_dev_$moodle19;"
mysql --user=$databaseuser --password=$databasepassword -e "ALTER DATABASE moodle_dev_$moodle19 CHARACTER SET utf8;"
git clone $myrepo $moodle19
ln -s $moodledirdev/$moodle19 $webdirdev/$moodle19
cd $moodledirdev/$moodle19
git config core.filemode false #ignore file permission changes
git remote add upstream git://git.moodle.org/moodle.git
git checkout MOODLE_19_STABLE
git pull upstream MOODLE_19_STABLE
#command line installation not possible in 1.9. Visit http://localhost/moodle/dev/moodle19stable to complete installation
#php admin/cli/install.php --lang=en --wwwroot=$webdirdev/$moodle19 --dataroot=$datadir/dev/$moodle19 --dbtype=mysqli --dbhost=$databaseserver --dbname=$moodle19 --dbuser=$databaseuser --dbpass=$databasepassword --fullname="site fullname" --shortname="site shortname" --adminuser=$moodleuser --adminpass=$moodlepassword --non-interactive --agree-license --allow-unstable

echo "----------------------dev 2.0 stable----------------------"
cd $moodledirdev
mysql --user=$databaseuser --password=$databasepassword -e "create database moodle_dev_$moodle20;"
mysql --user=$databaseuser --password=$databasepassword -e "ALTER DATABASE moodle_dev_$moodle20 CHARACTER SET utf8;"
git clone $myrepo $moodle20
ln -s $moodledirdev/$moodle20 $webdirdev/$moodle20
cd $moodledirdev/$moodle20
git config core.filemode false #ignore file permission changes
git remote add upstream git://git.moodle.org/moodle.git
git checkout MOODLE_20_STABLE
git pull upstream MOODLE_20_STABLE
php ./admin/cli/install.php --lang=en --wwwroot=http://localhost/moodle/dev/$moodle20 --dataroot=$datadir/dev/$moodle20 --dbtype=mysqli --dbhost=$databaseserver --dbname=moodle_dev_$moodle20 --dbuser=$databaseuser --dbpass=$databasepassword --fullname="2.0 stable dev fullname" --shortname="2.0 dev" --adminuser=$moodleuser --adminpass=$moodlepassword --non-interactive --agree-license --allow-unstable

echo "----------------------dev 2.1 stable----------------------"
cd $moodledirdev
mysql --user=$databaseuser --password=$databasepassword -e "create database moodle_dev_$moodle21;"
mysql --user=$databaseuser --password=$databasepassword -e "ALTER DATABASE moodle_dev_$moodle21 CHARACTER SET utf8;"
git clone $myrepo $moodle21
ln -s $moodledirdev/$moodle21 $webdirdev/$moodle21
cd $moodledirdev/$moodle21
git config core.filemode false #ignore file permission changes
git remote add upstream git://git.moodle.org/moodle.git
git checkout MOODLE_21_STABLE
git pull upstream MOODLE_21_STABLE
php ./admin/cli/install.php --lang=en --wwwroot=http://localhost/moodle/dev/$moodle21 --dataroot=$datadir/dev/$moodle21 --dbtype=mysqli --dbhost=$databaseserver --dbname=moodle_dev_$moodle21 --dbuser=$databaseuser --dbpass=$databasepassword --fullname="2.1 stable dev fullname" --shortname="2.1 dev" --adminuser=$moodleuser --adminpass=$moodlepassword --non-interactive --agree-license --allow-unstable

echo "----------------------dev master---------------------------"
cd $moodledirdev
mysql --user=$databaseuser --password=$databasepassword -e "create database moodle_dev_$master;"
mysql --user=$databaseuser --password=$databasepassword -e "ALTER DATABASE moodle_dev_$master CHARACTER SET utf8;"
git clone $myrepo $master
ln -s $moodledirdev/$master $webdirdev/$master
cd $moodledirdev/$master
git config core.filemode false #ignore file permission changes
git remote add upstream git://git.moodle.org/moodle.git
git checkout master
git pull upstream master
php ./admin/cli/install.php --lang=en --wwwroot=http://localhost/moodle/dev/$master --dataroot=$datadir/dev/$master --dbtype=mysqli --dbhost=$databaseserver --dbname=moodle_dev_$master --dbuser=$databaseuser --dbpass=$databasepassword --fullname="master dev fullname" --shortname="master dev" --adminuser=$moodleuser --adminpass=$moodlepassword --non-interactive --agree-license --allow-unstable

#and now another installation of each branch for integration testing

echo "----------------------int 1.9 stable----------------------"
cd $moodledirint
mysql --user=$databaseuser --password=$databasepassword -e "create database moodle_int_$moodle19;"
mysql --user=$databaseuser --password=$databasepassword -e "ALTER DATABASE moodle_int_$moodle19 CHARACTER SET utf8;"
git clone $myrepo $moodle19
ln -s $moodledirint/$moodle19 $webdirint/$moodle19
cd $moodle19
git config core.filemode false #ignore file permission changes
git remote add integration git://git.moodle.org/integration.git
git checkout MOODLE_19_STABLE
git pull integration MOODLE_19_STABLE
#command line installation not possible in 1.9. Visit http://localhost/moodle/int/moodle19stable to complete installation
#php admin/cli/install.php --lang=en --wwwroot=$webdirint/$moodle19 --dataroot=$datadir/int/$moodle19 --dbtype=mysqli --dbhost=$databaseserver --dbname=$moodle19 --dbuser=$databaseuser --dbpass=$databasepassword --fullname="1.0 stable int fullname" --shortname="1.9 int" --adminuser=$moodleuser --adminpass=$moodlepassword --non-interactive --agree-license --allow-unstable

echo "----------------------int 2.0 stable----------------------"
cd $moodledirint
mysql --user=$databaseuser --password=$databasepassword -e "create database moodle_int_$moodle20;"
mysql --user=$databaseuser --password=$databasepassword -e "ALTER DATABASE moodle_int_$moodle20 CHARACTER SET utf8;"
git clone $myrepo $moodle20
ln -s $moodledirint/$moodle20 $webdirint/$moodle20
cd $moodledirint/$moodle20
git config core.filemode false #ignore file permission changes
git remote add integration git://git.moodle.org/integration.git
git checkout MOODLE_20_STABLE
git pull integration MOODLE_20_STABLE
php ./admin/cli/install.php --lang=en --wwwroot=http://localhost/moodle/int/$moodle20 --dataroot=$datadir/int/$moodle20 --dbtype=mysqli --dbhost=$databaseserver --dbname=moodle_int_$moodle20 --dbuser=$databaseuser --dbpass=$databasepassword --fullname="2.0 stable int fullname" --shortname="2.0 int" --adminuser=$moodleuser --adminpass=$moodlepassword --non-interactive --agree-license --allow-unstable

echo "----------------------int 2.1 stable----------------------"
cd $moodledirint
mysql --user=$databaseuser --password=$databasepassword -e "create database moodle_int_$moodle21;"
mysql --user=$databaseuser --password=$databasepassword -e "ALTER DATABASE moodle_int_$moodle21 CHARACTER SET utf8;"
git clone $myrepo $moodle21
ln -s $moodledirint/$moodle21 $webdirint/$moodle21
cd $moodledirint/$moodle21
git config core.filemode false #ignore file permission changes
git remote add integration git://git.moodle.org/integration.git
git checkout MOODLE_21_STABLE
git pull integration MOODLE_21_STABLE
php ./admin/cli/install.php --lang=en --wwwroot=http://localhost/moodle/int/$moodle21 --dataroot=$datadir/int/$moodle21 --dbtype=mysqli --dbhost=$databaseserver --dbname=moodle_int_$moodle21 --dbuser=$databaseuser --dbpass=$databasepassword --fullname="2.1 stable int fullname" --shortname="2.1 int" --adminuser=$moodleuser --adminpass=$moodlepassword --non-interactive --agree-license --allow-unstable

echo "----------------------int master---------------------------"
cd $moodledirint
mysql --user=$databaseuser --password=$databasepassword -e "create database moodle_int_$master;"
mysql --user=$databaseuser --password=$databasepassword -e "ALTER DATABASE moodle_int_$master CHARACTER SET utf8;"
git clone $myrepo $master
ln -s $moodledirint/$master $webdirint/$master
cd $moodledirint/$master
git config core.filemode false #ignore file permission changes
git remote add integration git://git.moodle.org/integration.git
git checkout master
git pull integration master
php ./admin/cli/install.php --lang=en --wwwroot=http://localhost/moodle/int/$master --dataroot=$datadir/int/$master --dbtype=mysqli --dbhost=$databaseserver --dbname=moodle_int_$master --dbuser=$databaseuser --dbpass=$databasepassword --fullname="master int fullname" --shortname="master int" --adminuser=$moodleuser --adminpass=$moodlepassword --non-interactive --agree-license --allow-unstable


#finally set all file permissions really permissive. This is NOT suitable for a production machine
chmod -R 777 $datadir
chmod -R 777 $moodledir

#write out an index file
echo '<html><body>' > $indexfilelocation

echo '<h1>dev</h1>' >> $indexfilelocation
echo "<p><a href='moodle/dev/$moodle19'>$moodle19</a></p>" >> $indexfilelocation
echo "<p><a href='moodle/dev/$moodle20'>$moodle20</a></p>" >> $indexfilelocation
echo "<p><a href='moodle/dev/$moodle21'>$moodle21</a></p>" >> $indexfilelocation
echo "<p><a href='moodle/dev/$master'>$master</a></p>" >> $indexfilelocation

echo '<h1>int</h1>' >> $indexfilelocation
echo "<p><a href='moodle/int/$moodle19'>$moodle19</a></p>" >> $indexfilelocation
echo "<p><a href='moodle/int/$moodle20'>$moodle20</a></p>" >> $indexfilelocation
echo "<p><a href='moodle/int/$moodle21'>$moodle21</a></p>" >> $indexfilelocation
echo "<p><a href='moodle/int/$master'>$master</a></p>" >> $indexfilelocation

echo '</body></html>' >> $indexfilelocation

