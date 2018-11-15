#!/bin/bash

#-------------------------------------------------------
# Paste from developer.amazon.com below
#-------------------------------------------------------

# This is the name given to your device or mobile app in the Amazon developer portal. To look this up, navigate to https://developer.amazon.com/edw/home.html. It may be labeled Device Type ID.
ProductID=YOUR_PRODUCT_ID_HERE

# Retrieve your client ID from the web settings tab within the developer console: https://developer.amazon.com/edw/home.html
ClientID=YOUR_CLIENT_ID_HERE

# Retrieve your client secret from the web settings tab within the developer console: https://developer.amazon.com/edw/home.html
ClientSecret=YOUR_CLIENT_SECRET_HERE

#-------------------------------------------------------
# No need to change anything below this...
#-------------------------------------------------------

#-------------------------------------------------------
# Pre-populated for testing. Feel free to change.
#-------------------------------------------------------

# Your Country. Must be 2 characters!
Country='US'
# Your state. Must be 2 or more characters.
State='WA'
# Your city. Cannot be blank.
City='SEATTLE'
# Your organization name/company name. Cannot be blank.
Organization='AVS_USER'
# Your device serial number. Cannot be blank, but can be any combination of characters.
DeviceSerialNumber='123456789'
# Your KeyStorePassword. We recommend leaving this blank for testing.
KeyStorePassword=''

#-------------------------------------------------------
# Function to parse user's input.
#-------------------------------------------------------
# Arguments are: Yes-Enabled No-Enabled Quit-Enabled
YES_ANSWER=1
NO_ANSWER=2
QUIT_ANSWER=3
parse_user_input()
{
  if [ "$1" = "0" ] && [ "$2" = "0" ] && [ "$3" = "0" ]; then
    return
  fi
  while [ true ]; do
    Options="["
    if [ "$1" = "1" ]; then
      Options="${Options}y"
      if [ "$2" = "1" ] || [ "$3" = "1" ]; then
        Options="$Options/"
      fi
    fi
    if [ "$2" = "1" ]; then
      Options="${Options}n"
      if [ "$3" = "1" ]; then
        Options="$Options/"
      fi
    fi
    if [ "$3" = "1" ]; then
      Options="${Options}quit"
    fi
    Options="$Options]"
    read -p "$Options >> " USER_RESPONSE
    USER_RESPONSE=$(echo $USER_RESPONSE | awk '{print tolower($0)}')
    if [ "$USER_RESPONSE" = "y" ] && [ "$1" = "1" ]; then
      return $YES_ANSWER
    else
      if [ "$USER_RESPONSE" = "n" ] && [ "$2" = "1" ]; then
        return $NO_ANSWER
      else
        if [ "$USER_RESPONSE" = "quit" ] && [ "$3" = "1" ]; then
          printf "\nGoodbye.\n\n"
          exit
        fi
      fi
    fi
    printf "Please enter a valid response.\n"
  done
}

#----------------------------------------------------------------
# Function to select a user's preference between several options
#----------------------------------------------------------------
# Arguments are: result_var option1 option2...
select_option()
{
  local _result=$1
  local ARGS=("$@")
  if [ "$#" -gt 0 ]; then
      while [ true ]; do
         local count=1
         for option in "${ARGS[@]:1}"; do
            echo "$count) $option"
            ((count+=1))
         done
         echo ""
         local USER_RESPONSE
         read -p "Please select an option [1-$(($#-1))] " USER_RESPONSE
         case $USER_RESPONSE in
             ''|*[!0-9]*) echo "Please provide a valid number"
                          continue
                          ;;
             *) if [[ "$USER_RESPONSE" -gt 0 && $((USER_RESPONSE+1)) -le "$#" ]]; then
                    local SELECTION=${ARGS[($USER_RESPONSE)]}
                    echo "Selection: $SELECTION"
                    eval $_result=\$SELECTION
                    return
                else
                    clear
                    echo "Please select a valid option"
                fi
                ;;
         esac
      done
  fi
}

#-------------------------------------------------------
# Function to retrieve user account credentials
#-------------------------------------------------------
# Argument is: the expected length of user input
Credential=""
get_credential()
{
  Credential=""
  read -p ">> " Credential
  while [ "${#Credential}" -lt "$1" ]; do
    echo "Input has invalid length."
    echo "Please try again."
    read -p ">> " Credential
  done
}

#-------------------------------------------------------
# Function to confirm user credentials.
#-------------------------------------------------------
check_credentials()
{
  clear
  echo "====== AiVA-96 AVS User Credentials======"
  echo ""
  echo ""
  if [ "${#ProductID}" -eq 0 ] || [ "${#ClientID}" -eq 0 ] || [ "${#ClientSecret}" -eq 0 ]; then
    echo "At least one of the needed credentials (ProductID, ClientID or ClientSecret) is missing."
    echo ""
    echo ""
    echo "These values can be found here https://developer.amazon.com/edw/home.html, fix this now?"
    echo ""
    echo ""
    parse_user_input 1 0 1
  fi

  # Print out of variables and validate user inputs
  if [ "${#ProductID}" -ge 1 ] && [ "${#ClientID}" -ge 15 ] && [ "${#ClientSecret}" -ge 15 ]; then
    echo "ProductID >> $ProductID"
    echo "ClientID >> $ClientID"
    echo "ClientSecret >> $ClientSecret"
    echo ""
    echo ""
    echo "Is this information correct?"
    echo ""
    echo ""
    parse_user_input 1 1 0
    USER_RESPONSE=$?
    if [ "$USER_RESPONSE" = "$YES_ANSWER" ]; then
      return
    fi
  fi

  clear
  # Check ProductID
  NeedUpdate=0
  echo ""
  if [ "${#ProductID}" -eq 0 ]; then
    echo "Your ProductID is not set"
    NeedUpdate=1
  else
    echo "Your ProductID is set to: $ProductID."
    echo "Is this information correct?"
    echo ""
    parse_user_input 1 1 0
    USER_RESPONSE=$?
    if [ "$USER_RESPONSE" = "$NO_ANSWER" ]; then
      NeedUpdate=1
    fi
  fi
  if [ $NeedUpdate -eq 1 ]; then
    echo ""
    echo "This value should match your ProductID (or Device Type ID) entered at https://developer.amazon.com/edw/home.html."
    echo "The information is located under Device Type Info"
    echo "E.g.: RaspberryPi3"
    get_credential 1
    ProductID=$Credential
  fi

  echo "-------------------------------"
  echo "ProductID is set to >> $ProductID"
  echo "-------------------------------"

  # Check ClientID
  NeedUpdate=0
  echo ""
  if [ "${#ClientID}" -eq 0 ]; then
    echo "Your ClientID is not set"
    NeedUpdate=1
  else
    echo "Your ClientID is set to: $ClientID."
    echo "Is this information correct?"
    echo ""
    parse_user_input 1 1 0
    USER_RESPONSE=$?
    if [ "$USER_RESPONSE" = "$NO_ANSWER" ]; then
      NeedUpdate=1
    fi
  fi
  if [ $NeedUpdate -eq 1 ]; then
    echo ""
    echo "Please enter your ClientID."
    echo "This value should match the information at https://developer.amazon.com/edw/home.html."
    echo "The information is located under the 'Security Profile' tab."
    echo "E.g.: amzn1.application-oa2-client.xxxxxxxx"
    get_credential 28
    ClientID=$Credential
  fi

  echo "-------------------------------"
  echo "ClientID is set to >> $ClientID"
  echo "-------------------------------"

  # Check ClientSecret
  NeedUpdate=0
  echo ""
  if [ "${#ClientSecret}" -eq 0 ]; then
    echo "Your ClientSecret is not set"
    NeedUpdate=1
  else
    echo "Your ClientSecret is set to: $ClientSecret."
    echo "Is this information correct?"
    echo ""
    parse_user_input 1 1 0
    USER_RESPONSE=$?
    if [ "$USER_RESPONSE" = "$NO_ANSWER" ]; then
      NeedUpdate=1
    fi
  fi
  if [ $NeedUpdate -eq 1 ]; then
    echo ""
    echo "Please enter your ClientSecret."
    echo "This value should match the information at https://developer.amazon.com/edw/home.html."
    echo "The information is located under the 'Security Profile' tab."
    echo "E.g.: fxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxa"
    get_credential 20
    ClientSecret=$Credential
  fi

  echo "-------------------------------"
  echo "ClientSecret is set to >> $ClientSecret"
  echo "-------------------------------"

  check_credentials
}

#-------------------------------------------------------
# Inserts user-provided values into a template file
#-------------------------------------------------------
# Arguments are: template_directory, template_name, target_name
use_template()
{
  Template_Loc=$1
  Template_Name=$2
  Target_Name=$3
  while IFS='' read -r line || [[ -n "$line" ]]; do
    while [[ "$line" =~ (\$\{[a-zA-Z_][a-zA-Z_0-9]*\}) ]]; do
      LHS=${BASH_REMATCH[1]}
      RHS="$(eval echo "\"$LHS\"")"
      line=${line//$LHS/$RHS}
    done
    echo "$line" >> "$Template_Loc/$Target_Name"
  done < "$Template_Loc/$Template_Name"
}

#-------------------------------------------------------
# Get alpn-boot.version according to the Java version
#-------------------------------------------------------
get_alpn_version()
{
  Java_Version=`java -version 2>&1 | awk 'NR==1{ gsub(/"/,""); print $3 }'`
  echo "java version: $Java_Version "
  Java_Major_Version=$(echo $Java_Version | cut -d '_' -f 1)
  Java_Minor_Version=$(echo $Java_Version | cut -d '_' -f 2)
  echo "major version: $Java_Major_Version minor version: $Java_Minor_Version"
  
  Alpn_Version=""
  if [ "$Java_Major_Version" = "1.8.0" ] && [ "$Java_Minor_Version" -gt 59 ]; then
    if [ "$Java_Minor_Version" -gt 160 ]; then
      Alpn_Version="8.1.12.v20180117"
    elif [ "$Java_Minor_Version" -gt 120 ]; then
      Alpn_Version="8.1.11.v20170118"
    elif [ "$Java_Minor_Version" -gt 111 ]; then
      Alpn_Version="8.1.10.v20161026"
    elif [ "$Java_Minor_Version" -gt 100 ]; then
      Alpn_Version="8.1.9.v20160720"
    elif [ "$Java_Version" == "1.8.0_92" ]; then
      Alpn_Version="8.1.8.v20160420"
    elif [ "$Java_Minor_Version" -gt 70 ]; then
      Alpn_Version="8.1.7.v20160121"
    elif [[ $Java_Version ==  "1.8.0_66" ]]; then
      Alpn_Version="8.1.6.v20151105"
    elif [[ $Java_Version ==  "1.8.0_65" ]]; then
      Alpn_Version="8.1.6.v20151105"
    elif [[ $Java_Version ==  "1.8.0_60" ]]; then
      Alpn_Version="8.1.5.v20150921"
    fi
  else
    echo "Unsupported or unknown java version ($Java_Version), defaulting to latest known ALPN."
    Echo "Check http://www.eclipse.org/jetty/documentation/current/alpn-chapter.html#alpn-versions to get the alpn version matching your JDK version."
    read -t 10 -p "Hit ENTER or wait ten seconds"
  fi
}

#-------------------------------------------------------
# Script to check if all is good before install script runs
#-------------------------------------------------------
clear
echo "=============================================================="
echo "        AiVA-96 AVS + cmuSphinx Licenses and Agreement"
echo "=============================================================="
echo ""
echo "This code base is dependent on several external libraries and virtual environments like cmuSphinx, cmuPocksphinx, 96BoardGPIO, libsoc, Atlas, VLC, NodeJS, npm, OpenJDK, OpenSSL, Maven & CMake."
echo ""
echo "Please read the document \"Installer_Licenses.txt\" from the sample app repository and the corresponding licenses of the above."
echo ""
echo "Do you agree to the terms and conditions of the necessary software from the third party sources and want to download the necessary software from the third party sources?"
echo ""
parse_user_input 1 0 1

#-------------------------------------------------------
# Display install script title information
#-------------------------------------------------------
echo "=============================================================="
echo " AiVA-96 for Amazon AVS Java Sample App on DragonBoard 410c"
echo " ** For getting 'Product ID, Client ID, Client Secret',"
echo "    visit https://developer.amazon.com/edw/home.html"
echo "=============================================================="

#--------------------------------------------------------------------------------------------
# Checking if script has been updated by the user with ProductID, ClientID, and ClientSecret
#--------------------------------------------------------------------------------------------
# If 'registinfo.txt' file exist, then read line 1, 3, 5 into variables
registinfo="registinfo-amazon.txt"
if [ -f $registinfo ]; then
    IFS=$'\r\n' GLOBIGNORE="*" command eval 'Line=($(cat $registinfo))'
    ProductID=${Line[1]}
    ClientID=${Line[3]}
    ClientSecret=${Line[5]}
fi

# If regist info is not edited, delete exist variables
if [ "$ProductID" = "YOUR_PRODUCT_ID_HERE" ]; then
    ProductID=""
fi
if [ "$ClientID" = "YOUR_CLIENT_ID_HERE" ]; then
    ClientID=""
fi
if [ "$ClientSecret" = "YOUR_CLIENT_SECRET_HERE" ]; then
    ClientSecret=""
fi

# If regist info is empty, ask user to input
while [[ -z $ProductID ]] ; do
    read -p "Product ID : " ProductID
done

while [[ -z $ClientID ]] ; do
    read -p "Client ID : " ClientID
done

while [[ -z $ClientSecret ]] ; do
    read -p "Client Secret : " ClientSecret
done

# check_credentials

# Display regist info for confirming
echo "Product ID is" $ProductID
echo "Client ID is" $ClientID
echo "Client Secret is" $ClientSecret
echo ""
parse_user_input 1 0 1

if [ ! -f $registinfo ]; then
    echo "# Product ID" | tee ./$registinfo > /dev/null
    echo "$ProductID" | tee -a ./$registinfo > /dev/null
    echo "# Web Client ID" | tee -a ./$registinfo > /dev/null
    echo "$ClientID" | tee -a ./$registinfo > /dev/null
    echo "# Web Client secret" | tee -a ./$registinfo > /dev/null
    echo "$ClientSecret" | tee -a ./$registinfo > /dev/null
fi

#-------------------------------------------------------
# Add library path
#-------------------------------------------------------
if [ "${#LD_LIBRARY_PATH}" -eq 0 ]; then
  echo "export LD_LIBRARY_PATH=/usr/lib/vlc:/usr/local/lib" | tee -a ~/.bashrc > /dev/null
  echo "export VLC_PLUGIN_PATH=/usr/lib/vlc/plugins:/usr/local/lib/pkgconfig" | tee -a ~/.bashrc > /dev/null
  echo "unset JAVA_TOOL_OPTIONS" | tee -a ~/.bashrc > /dev/null
  source ~/.bashrc
fi

# Preconfigured variables
SDKRoot=$(pwd)
OS=debian
User=$(id -un)
Group=$(id -gn)
Origin=$(pwd)
Samples_Loc=$Origin/samples
Java_Client_Loc=$Samples_Loc/javaclient
Wake_Word_Agent_Loc=$Samples_Loc/wakeWordAgent
Companion_Service_Loc=$Samples_Loc/companionService
NineSixBoardsLib_Loc=$Origin/96Boards
SphinxLib_Loc=$Origin/cmuSphinx
External_Loc=$Wake_Word_Agent_Loc/ext
Locale="en-US"
# Locale = "en-US" "en-GB" "de-DE" "en-CA" "en-IN" "ja-JP" "en-AU"
Wake_Word_Detection_Enabled="true"
# Wake_Word_Detection_Enabled = "true" or "false"

mkdir $External_Loc
mkdir $NineSixBoardsLib_Loc
mkdir $SphinxLib_Loc

echo ""
echo ""
echo "==============================="
echo "*******************************"
echo " *** STARTING INSTALLATION ***"
echo "  ** this may take a while **"
echo "   *************************"
echo "   ========================="
echo ""
echo ""

# Install dependencies
echo "========== Update Aptitude ==========="
date
sudo apt-get update
#sudo apt-get upgrade -yq

echo "========== Install package dependencies ==========="
sudo apt-get install -y git
sudo apt-get install -y build-essential
sudo apt-get install -y autoconf
sudo apt-get install -y automake
sudo apt-get install -y libtool
sudo apt-get install -y swig3.0
sudo apt-get install -y python-dev
sudo apt-get install -y nodejs-dev
sudo apt-get install -y cmake
sudo apt-get install -y pkg-config
sudo apt-get install -y libpcre3-dev
sudo apt-get install -y openjdk-8-jdk
sudo apt-get install -y vlc
sudo apt-get install -y vlc-bin # vlc-nox is deprecated
sudo apt-get install -y vlc-data
sudo apt-get install -y nano

echo "========== Installing Libraries ALSA, Atlas ==========="
sudo apt-get -y install libasound2-dev
sudo apt-get -y install libatlas-base-dev
sudo apt-get -y install pulseaudio
sudo ldconfig

echo "========== Installing Libraries for cmuSphinx ==========="
sudo apt-get -y install bison 
#sudo apt-get -y install libasound2-dev 
sudo apt-get -y install swig 
#sudo apt-get -y install autoconf 
#sudo apt-get -y install automake 
#sudo apt-get -y install libtool 
#sudo apt-get -y install python-dev

echo "========== Getting the code for libsoc ==========="
cd $NineSixBoardsLib_Loc
if [ ! -d libsoc ]; then
    git clone https://github.com/wizeiot/libsoc.git
fi
cd libsoc
autoreconf -i
./configure --enable-python=2 --enable-board="dragonboard410c"
make && sudo make install
sudo ldconfig

echo "========== Getting the code for 96BoardsGPIO ==========="
cd $NineSixBoardsLib_Loc
if [ ! -d 96BoardsGPIO ]; then
    git clone https://github.com/wizeiot/96BoardsGPIO.git
fi
cd 96BoardsGPIO/Archive
./autogen.sh
./configure
make && sudo make install
sudo ldconfig

echo "========== Getting the code for cmuSphinxbase ==========="
cd $SphinxLib_Loc
if [ ! -d sphinxbase ]; then
    git clone https://github.com/wizeiot/sphinxbase.git
fi
cd sphinxbase
./autogen.sh
./configure --enable-fixed
make
sudo make install

echo "========== Getting the code for cmuPocketSphin AiVA DB410c ==========="
cd $SphinxLib_Loc
if [ ! -d pocketsphinx ]; then
    git clone https://github.com/wizeiot/pocketsphinx.git
fi
cd pocketsphinx
git checkout DB410c
mkdir extlib
cp ../../96Boards/96BoardsGPIO/Archive/lib/.libs/lib96BoardsGPIO.la ./extlib
cp ../../96Boards/96BoardsGPIO/Archive/lib/.libs/lib96BoardsGPIO.so ./extlib
cp ../../96Boards/libsoc/lib/.libs/libsoc.la ./extlib
cp ../../96Boards/libsoc/lib/.libs/libsoc.so ./extlib
./autogen.sh
./configure
make
sudo make install

cd $Origin

echo "========== Installing VLC and associated Environmental Variables =========="
#sudo apt-get install -y vlc vlc-nox vlc-data
# Make sure that the libraries can be found
sudo sh -c "echo \"/usr/lib/vlc\" >> /etc/ld.so.conf.d/vlc_lib.conf"
sudo sh -c "echo \"VLC_PLUGIN_PATH=\"/usr/lib/vlc/plugin\"\" >> /etc/environment"

# Create a libvlc soft link if doesn't exist
if ! ldconfig -p | grep "libvlc.so "; then
  [ -e $Java_Client_Loc/lib ] || mkdir $Java_Client_Loc/lib
  if ! [ -e $Java_Client_Loc/lib/libvlc.so ]; then
   Target_Lib=`ldconfig -p | grep libvlc.so | sort | tail -n 1 | rev | cut -d " " -f 1 | rev`
   ln -s $Target_Lib $Java_Client_Loc/lib/libvlc.so
  fi 
fi

sudo ldconfig

echo "========== Installing NodeJS =========="
sudo apt-get install -y nodejs npm build-essential
sudo ln -s /usr/bin/nodejs /usr/bin/node
node -v
sudo ldconfig

echo "========== Installing Maven =========="
sudo apt-get install -y maven
mvn -version
sudo ldconfig

echo "========== Installing OpenSSL and Generating Self-Signed Certificates =========="
sudo apt-get install -y openssl
sudo ldconfig

unset JAVA_TOOL_OPTIONS

echo "========== Generating ssl.cnf =========="
if [ -f $Java_Client_Loc/ssl.cnf ]; then
  rm $Java_Client_Loc/ssl.cnf
fi
use_template $Java_Client_Loc template_ssl_cnf ssl.cnf

echo "========== Generating generate.sh =========="
if [ -f $Java_Client_Loc/generate.sh ]; then
  rm $Java_Client_Loc/generate.sh
fi
use_template $Java_Client_Loc template_generate_sh generate.sh

echo "========== Executing generate.sh =========="
chmod +x $Java_Client_Loc/generate.sh
cd $Java_Client_Loc && bash ./generate.sh
cd $Origin

echo "========== Configuring Companion Service =========="
if [ -f $Companion_Service_Loc/config.js ]; then
  rm $Companion_Service_Loc/config.js
fi
use_template $Companion_Service_Loc template_config_js config.js

echo "========== Configuring Java Client =========="
if [ -f $Java_Client_Loc/config.json ]; then
  rm $Java_Client_Loc/config.json
fi
use_template $Java_Client_Loc template_config_json config.json

echo "========== Configuring ALSA Devices =========="
if [ -f /home/$User/.asoundrc ]; then
  rm /home/$User/.asoundrc
fi
printf "pcm.!default {\n  type asym\n   playback.pcm {\n     type plug\n     slave.pcm \"hw:0,0\"\n   }\n   capture.pcm {\n     type plug\n     slave.pcm \"hw:1,0\"\n   }\n}" >> /home/$User/.asoundrc

echo "========== Installing CMake =========="
#sudo apt-get install -y cmake
sudo ldconfig

echo "========== Installing Java Client =========="
if [ -f $Java_Client_Loc/pom.xml ]; then
  rm $Java_Client_Loc/pom.xml
fi

get_alpn_version

cp $Java_Client_Loc/pom_pi.xml $Java_Client_Loc/pom.xml

sed -i "s/The latest version of alpn-boot that supports .*/The latest version of alpn-boot that supports JDK $Java_Version -->/" $Java_Client_Loc/pom.xml
sed -i "s:<alpn-boot.version>.*</alpn-boot.version>:<alpn-boot.version>$Alpn_Version</alpn-boot.version>:" $Java_Client_Loc/pom.xml

cd $Java_Client_Loc && mvn validate && mvn install && cd $Origin

echo "========== Installing Companion Service =========="
cd $Companion_Service_Loc && npm install && cd $Origin

if [ "$Wake_Word_Detection_Enabled" = "true" ]; then
  echo "========== Preparing External dependencies for Wake Word Agent =========="
  mkdir $External_Loc/include
  mkdir $External_Loc/lib
  mkdir $External_Loc/resources

  cp $NineSixBoardsLib_Loc/libsoc/lib/include/*.h $External_Loc/include/
  cp $NineSixBoardsLib_Loc/libsoc/lib/.libs/libsoc.a $External_Loc/lib/libsoc.a

  cp $NineSixBoardsLib_Loc/96BoardsGPIO/Archive/lib/gpio.h $cp $External_Loc/include/
  cp $NineSixBoardsLib_Loc/96BoardsGPIO/Archive/lib/.libs/lib96BoardsGPIO.a $External_Loc/lib/lib96BoardsGPIO.a

  echo "========== Compiling Wake Word Agent =========="
  cd $Wake_Word_Agent_Loc/src && cmake . && make -j4
 #cd $Wake_Word_Agent_Loc/tst && cmake . && make -j4
fi

chown -R $User:$Group $Origin
chown -R $User:$Group /home/$User/.asoundrc

cd $Origin

#-------------------------------------------------------
# Finished
#-------------------------------------------------------
echo "=============================================================="
echo " Installation Finished. Run sample application,"
echo " '$ bash ./alexa_avs_sample.sh'" 
echo " ** You need to get an authentication once. "

# build running script for sample app and wake engine
echo "#!/bin/bash" | tee ./alexa_avs_sample.sh > /dev/null
echo "cd $Companion_Service_Loc" | tee -a ./alexa_avs_sample.sh > /dev/null
echo "xterm -e 'npm start' &" | tee -a ./alexa_avs_sample.sh > /dev/null
echo "cd $Java_Client_Loc" | tee -a ./alexa_avs_sample.sh > /dev/null
echo "xterm -e 'mvn exec:exec' &" | tee -a ./alexa_avs_sample.sh > /dev/null

if [ "$Wake_Word_Detection_Enabled" = "true" ]; then
  echo "#!/bin/bash" | tee ./wake_word_agent.sh > /dev/null
  echo "cd $Wake_Word_Agent_Loc" | tee -a ./wake_word_agent.sh > /dev/null
  echo "xterm -e 'sudo ./wakeWordAgent gpio' &" | tee -a ./wake_word_agent.sh > /dev/null
  echo "cd $Origin" | tee -a ./wake_word_agent.sh > /dev/null
  echo "xterm -e './run_sphinx_no_log.sh' &" | tee -a ./wake_word_agent.sh > /dev/null

  echo "=============================================================="
  echo " Run wake word agent, after get an alexa app authentication."
  echo " '$ bash ./wake_word_agent.sh'"
fi

#chmod +x run_sphinx*
#chmod +x sphinx_test.sh
chmod +x *.sh

echo "=============================================================="
echo " Please reboot system before running sample applications."
echo "=============================================================="
