#!/bin/bash
flutter build linux --release
rm -rf /opt/servergreeter
mv build/linux/x64/release/bundle /opt/servergreeter
chmod -R 777 /opt/servergreeter
cd lightdm_interop
make all
cp liblightdm_interop.so /opt/servergreeter/
cd ..
