echo 'Initializing installation of Metasploit Framework from Github.' &> ~/LOGFILE.txt
echo "Installation started from $USER at $HOSTNAME at " &>> ~/LOGFILE.txt
date &>> ~/LOGFILE.txt


echo '***********************************************************'
echo '* Metasploit  Framework  Git  Installer  for  Arch  Linux *' 
echo '* brought to you by teravice. Distributed under GPLv3  ****'
echo '* teravice[at]gmail.com , teravice[at]protonmail.ch *******'
echo '* www.teravice.com ****************************************' 
echo '* PGP Key : http://pgp.teravice.com ***********************'
echo '***********************************************************'
echo ''

echo '***********************************************************'
echo '* Checking if system is up to date, updating(if necessary)*' 
echo '* and installing dependancies... **************************' 
echo '***********************************************************'
echo ''
sudo pacman -Syyu --noconfirm &>> ~/LOGFILE.txt


sudo pacman -S --needed --noconfirm wget git gcc patch curl zlib readline autoconf automake diffutils make libtool bison subversion gnupg postgresql &>> ~/LOGFILE.txt

echo '***********************************************************'
echo '* Downloading,compiling & installing Ruby 2.1.5 from AUR. *' 
echo '***********************************************************'
echo ''

wget -P /tmp https://aur.archlinux.org/packages/ru/ruby-2.1/ruby-2.1.tar.gz  &>> ~/LOGFILE.txt

cd /tmp

tar -xvf ruby-2.1.tar.gz  &>> ~/LOGFILE.txt

cd ruby-2.1

makepkg -s  &>> ~/LOGFILE.txt

sudo pacman -U ruby*.pkg.tar.xz 

su root

echo 'PATH="$(ruby -e "print Gem.user_dir")/bin:$PATH"' >> /etc/profile

echo 'export PATH' >> /etc/profile

exit

source /etc/profile

echo '***********************************************************'
echo '* Installing basic gems that we will need. ****************' 
echo '* wirble **************************************************' 
echo '* sqlite3 *************************************************'
echo '* bundler *************************************************' 
echo '***********************************************************'
echo ''

gem install wirble sqlite3 bundler &>> ~/LOGFILE.txt

echo '***********************************************************'
echo '* Creating installation directory /opt/development ********' 
echo '* and proceeding with the svn download and installation ***' 
echo '* of nmap. ************************************************'
echo '***********************************************************'
echo ''

sudo mkdir /opt/development

sudo chown -R $USERNAME:$USERNAME /opt/development

cd /opt/development

svn co https://svn.nmap.org/nmap &>> ~/LOGFILE.txt

cd nmap

./configure &>> ~/LOGFILE.txt

make &>> ~/LOGFILE.txt

sudo make install &>> ~/LOGFILE.txt

make clean &>> ~/LOGFILE.txt


echo '***********************************************************'
echo '* We are  now goint to check whether  en_US.UTF8  locale  *' 
echo '* is set. We are going to  use  nano  again.  If  needed  *' 
echo '* the file /etc/locale.gen will be opened. You have  to   *'
echo '* remove the # that are  in  front  of  en_US.UTF-8 UTF-8 *' 
echo '* and en_US ISO-8859-1. Then hit Ctrl+O and Ctrl+X        *'
echo '***********************************************************'
echo ''

read -p "* Press [Enter] key to continue...*************************"

if ! ( locale -a | grep "en_US.utf8" ) ; then
	echo "* Locales not found. Generating...*************************"
	sudo nano /etc/locale.gen
	sudo locale-gen &>> ~/LOGFILE.txt
	else
	echo "* Locales found. Nothing to do here. **********************"
fi

echo '***********************************************************'
echo '* Setting up postgresql. Starting, enabling and creating **' 
echo '* the user msf and the database msf.***********************' 
echo '***********************************************************'
echo ''

sudo systemctl start postgresql &>> ~/LOGFILE.txt

sudo systemctl enable postgresql &>> ~/LOGFILE.txt

sudo -u postgres createuser msf -P -S -R -D &>> ~/LOGFILE.txt

sudo -u postgres createdb -O msf msf &>> ~/LOGFILE.txt

cd /opt/development

echo '***********************************************************'
echo '* Cloning Metasploit Framework from Github. ***************' 
echo '* After cloning is complete,bundle install will be run so *' 
echo '* all the required gems will be installed directly. *******'
echo '***********************************************************'
echo ''
git clone https://github.com/rapid7/metasploit-framework.git &>> ~/LOGFILE.txt

cd metasploit-framework

bundle install &>> ~/LOGFILE.txt

sudo chmod a+r /usr/lib/ruby/gems/2.1.0/gems/robots-0.10.1/lib/robots.rb

echo '***********************************************************'
echo '* Creating simlinks for msf executables at /usr/local/bin *' 
echo '* Creating database.yml file with all the settings so that*' 
echo '* msfconsole can connect to postgres automatically. *******'
echo '***********************************************************'
echo ''

sudo bash -c 'for MSF in $(ls msf*); do ln -s $PWD/$MSF /usr/local/bin/$MSF;done' &>> ~/LOGFILE.txt

sudo echo -e 'production:\n adapter: postgresql\n database: msf\n username: msf\n password: \n host: 127.0.0.1\n port: 5432\n pool: 75\n timeout: 5\n' > /opt/development/metasploit-framework/config/database.yml &>> ~/LOGFILE.txt

sudo sh -c "echo export MSF_DATABASE_CONFIG=/opt/development/metasploit-framework/config/database.yml >> /etc/profile" &>> ~/LOGFILE.txt

source /etc/profile


echo '***********************************************************'
echo '* Downloading the latest version of Armitage. *************' 
echo '* After  the   download  is  complete  armitage  will  be *' 
echo '* installed and linked properly.*'
echo '***********************************************************'
echo ''


curl -# -o /tmp/armitage.tgz http://www.fastandeasyhacking.com/download/armitage-latest.tgz &>> ~/LOGFILE.txt

sudo tar -xvzf /tmp/armitage.tgz -C /opt/development &>> ~/LOGFILE.txt

sudo ln -s /opt/development/armitage/armitage /usr/local/bin/armitage &>> ~/LOGFILE.txt

sudo ln -s /opt/development/armitage/teamserver /usr/local/bin/teamserver &>> ~/LOGFILE.txt

sudo sh -c "echo java -jar /opt/development/armitage/armitage.jar \$\* > /opt/development/armitage/armitage" &>> ~/LOGFILE.txt

sudo perl -pi -e 's/armitage.jar/\/opt\/development\/armitage\/armitage.jar/g' /opt/development/armitage/teamserver &>> ~/LOGFILE.txt


echo '***********************************************************'
echo '* Congratulations! Setup is complete. If something is not *' 
echo '* working properly check ~/LOGFILE.txt for errors and post*' 
echo '* them to https://github.com/teravice/MSF-ArchInstaller   *'
echo '* This is a new project so every help provided is much    *' 
echo '* appreciated.                                            *'
echo '***********************************************************'
echo ''
echo ''

echo '***********************************************************'                                                  
echo ' #    # ###  #####   #####  '
echo ' #   #   #  #     # #     # '
echo ' #  #    #  #       #       '
echo ' ###     #   #####   #####  '
echo ' #  #    #        #       # '
echo ' #   #   #  #     # #     # '
echo ' #    # ###  #####   #####  '
echo '***********************************************************'