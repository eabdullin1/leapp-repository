#!/usr/bin/env bash


RHEL_MAJOR_VERSION=$(rpm --eval %rhel)
WORK_DIR="$HOME"
NEW_LEAPP_NAME='leapp-repository-almalinux'
NEW_LEAPP_DIR="$WORK_DIR/$NEW_LEAPP_NAME/"
LEAPP_PATH='/usr/share/leapp-repository/repositories/'
EXCLUDE_PATH='
/usr/share/leapp-repository/repositories/system_upgrade/el7toel8/files/bundled-rpms
/usr/share/leapp-repository/repositories/system_upgrade/el7toel8/files
/usr/share/leapp-repository/repositories/system_upgrade/el7toel8
/usr/share/leapp-repository/repositories/system_upgrade/el8toel9/files/bundled-rpms
/usr/share/leapp-repository/repositories/system_upgrade/el8toel9/files
/usr/share/leapp-repository/repositories/system_upgrade/el8toel9
/usr/share/leapp-repository/repositories/system_upgrade
/usr/share/leapp-repository/repositories/
'


echo "RHEL_MAJOR_VERSION=$RHEL_MAJOR_VERSION"
echo "WORK_DIR=$WORK_DIR"
echo "EXCLUDED_PATHS=$EXCLUDE_PATH"


echo 'Remove old files'
for dir in $(find $LEAPP_PATH -type d);
do
    skip=0
    for exclude in $(echo $EXCLUDE_PATH);
    do
        if [[ $exclude == $dir ]];then
            skip=1
            break
        fi
    done
    if [ $skip -eq 0 ];then
        rm -rf $dir
    fi
done

echo 'Download new tarball'
curl -s -L https://github.com/AlmaLinux/leapp-repository/archive/almalinux/leapp-repository-almalinux.tar.gz | tar -xz -C $WORK_DIR/

echo 'Deleting files as in spec file'
rm -rf $NEW_LEAPP_DIR/repos/common/actors/testactor
find $NEW_LEAPP_DIR/repos/common -name "test.py" -delete
rm -rf `find $NEW_LEAPP_DIR -name "tests" -type d`
find $NEW_LEAPP_DIR -name "Makefile" -delete
if [ $RHEL_MAJOR_VERSION -eq '7' ]; then
    rm -rf $NEW_LEAPP_DIR/repos/system_upgrade/el8toel9
else
    rm -rf $NEW_LEAPP_DIR/repos/system_upgrade/el7toel8
    rm -rf $NEW_LEAPP_DIR/repos/system_upgrade/cloudlinux
fi

echo 'Copy new data to system'
cp -r $NEW_LEAPP_DIR/repos/* $LEAPP_PATH

for DIRECTORY in $(find $LEAPP_PATH -mindepth 1 -maxdepth 1 -type d);
do
    REPOSITORY=$(basename $DIRECTORY)
    if ! [ -e /etc/leapp/repos.d/$REPOSITORY ];then
        echo "Enabling repository $REPOSITORY"
        ln -s $LEAPP_PATH/$REPOSITORY /etc/leapp/repos.d/$REPOSITORY
    fi
done

rm -rf $NEW_LEAPP_DIR