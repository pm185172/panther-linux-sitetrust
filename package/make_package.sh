#!/bin/sh

# Packager script to create proclog service

PACKAGE='sitetrust.service'
APP='sitetrust.sh'
EXE_NAME='sitetrust'
VERSION=$1
MAINTAINER='NCR'
ARCHITECTURE='all'
DESCRIPTION='NCR Security Site Trust service'
LOGFILE="/home/pcrfuel/Radiant/FastPoint/Log/${PACKAGE}.log"
ZIPFILE="SecurityService-linux-x64-selfcontained.zip"

cmd="$1"
# Clean
rm -rf ${PACKAGE}
rm -rf build

if [ "$cmd" = "clean" ]; then
    exit 0
fi

# Create package control file
mkdir -p ${PACKAGE}/DEBIAN
mkdir build
echo "Package: " $PACKAGE > ${PACKAGE}/DEBIAN/control
echo "Version: " $VERSION >> ${PACKAGE}/DEBIAN/control
echo "Maintainer: " $MAINTAINER >> ${PACKAGE}/DEBIAN/control
echo "Architecture: " $ARCHITECTURE >> ${PACKAGE}/DEBIAN/control
echo "Description: " $DESCRIPTION >> ${PACKAGE}/DEBIAN/control

# Create pre/post scripts
cat << EOF > ${PACKAGE}/DEBIAN/prerm
which systemctl > /dev/null
if [ "\$?" = "0" ]; then
   systemctl stop ${PACKAGE}
   systemctl disable ${PACKAGE}
else
    /etc/init.d/${PACKAGE} stop
fi
if [ -e /etc/rc5.d/S90${PACKAGE} ]; then
    rm /etc/rc5.d/S90${PACKAGE}
fi
EOF
chmod 755 ${PACKAGE}/DEBIAN/prerm

cat << EOF > ${PACKAGE}/DEBIAN/postinst
if ! id -u sitetrust > /dev/null 2>&1 ; then
    echo "Creating 'sitetrust' user."
    useradd --uid 712 -N -g pcrfuel -m -s /bin/sh sitetrust
fi
chmod 755 /etc/systemd/system/${PACKAGE}
chmod 755 /usr/bin/${APP}
chown root:root /usr/bin/${APP}
chown root:root /usr/bin/${EXE_NAME}

touch $LOGFILE
chown sitetrust:pcrfuel $LOGFILE
chmod 644 /etc/logrotate.d/sitetrust_service_rotate.conf
chown root:root /etc/logrotate.d/sitetrust_service_rotate.conf
which systemctl > /dev/null
if [ "\$?" = "0" ]; then
    systemctl daemon-reload
    systemctl enable ${PACKAGE}
    systemctl start ${PACKAGE}
else
    if [ -e /etc/rc5.d/S90${PACKAGE} ]; then
        rm /etc/rc5.d/S90${PACKAGE}
    fi
    ln -s /etc/init.d/${PACKAGE} /etc/rc5.d/S90${PACKAGE}
    /etc/init.d/${PACKAGE} start
fi

echo \`date "+%c"\` Installing ${PACKAGE}:  ${VERSION} >> /opt/pcr/panther2-packages-ver.log
EOF

chmod 755 ${PACKAGE}/DEBIAN/postinst

# Copy files
mkdir -p ${PACKAGE}/etc/systemd/system
cp ../${PACKAGE} ${PACKAGE}/etc/systemd/system/
mkdir -p ${PACKAGE}/usr/bin
cp ../${APP} ${PACKAGE}/usr/bin
# cp ../${EXE_NAME} ${PACKAGE}/usr/bin
mkdir -p ${PACKAGE}/home/sitetrust/SecurityService
unzip ../${ZIPFILE} ${PACKAGE}/home/sitetrust/SecurityService

mkdir -p ${PACKAGE}/etc/logrotate.d
cp ../sitetrust_service_rotate.conf ${PACKAGE}/etc/logrotate.d

# Create package
dpkg-deb --build $PACKAGE build
