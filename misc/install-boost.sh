#!/bin/bash

# Purpose: Install version of boost supplied in VERSION_NUMBER

# Set up some strings to use
VERSION_NUMBER="70"
VERSION_DECIMAL="1."${VERSION_NUMBER}
VERSION_UNDERSCORE="1_"${VERSION_NUMBER}
FOLDER_NAME="boost"${VERSION_DECIMAL}

echo "Setting up boost ${VERSION_DECIMAL}..."

# Copy Boost into a new folder
mkdir ${FOLDER_NAME}
cd ${FOLDER_NAME}
wget https://dl.bintray.com/boostorg/release/${VERSION_DECIMAL}.0/source/boost_${VERSION_UNDERSCORE}_0.tar.bz2
tar --bzip2 -xf boost_${VERSION_UNDERSCORE}_0.tar.bz2

# Prep and compile Boost
cd boost_${VERSION_UNDERSCORE}_0
sudo ./bootstrap.sh --prefix=/usr/local --with-libraries=all
sudo ./b2 install

# Add the Boost libraries path to the default Ubuntu library search path
sudo /bin/bash -c 'echo "/usr/local/lib" > /etc/ld.so.conf.d/boost.conf'
# Update the default Ubuntu library search paths
sudo ldconfig
# Return to the parent directory
cd ../../
# Inform user that Boost was successfully installed
echo "boost ${VERSION_DECIMAL} was successfully installed."
