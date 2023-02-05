#!/bin/bash

source=https://pub-c7a32e5b5d834ec9aeef400105452a42.r2.dev/Muse_Hub.deb
target=Muse_Hub.deb

if ! sha1sum -c --quiet Muse_Hub.deb.sha1sum; then
    echo Downloading Muse Hub now
    wget $source -O $target
fi

if ! sha1sum -c --quiet Muse_Hub.deb.sha1sum; then
    echo "Muse Hub file checksum changed, aborting"
    exit 1
else
    echo "Muse Hub already downloaded, skipping"
fi

if ! compgen -G *.rpm > /dev/null; then
    echo Converting Debian package to Fedora package
    sudo alien --to-rpm --scripts $target
else
    echo "Skipping Debian package conversion as the rpm file already exists"
fi

echo Searching built rpm
rpm_file=$(ls muse*.rpm)

echo Fixing package $rpm_file
rpmrebuild -pe $rpm_file

if [ $? -ne 0 ]; then
    echo "rpmrebuild failed, aborting script"
    echo "You can install the rpm shipped with the repository"
fi

fixed_rpm_file=$(ls ~/rpmbuild/RPMS/x86_64/muse-hub-*.x86_64.rpm)

echo Installing $rpm_file
sudo rpm -i --nodeps $rpm_file