#!/bin/bash
if [ ! -d "nmrium-react-wrapper" ]; then
    git clone https://github.com/NFDI4Chem/nmrium-react-wrapper.git nmrium-react-wrapper
else
    cd nmrium-react-wrapper && git pull origin main && cd ..
fi
mkdir -p toPackage
wget https://raw.githubusercontent.com/Chemotion/Push2Deploy/nmrium/payload/useWhiteList.ts
wget https://raw.githubusercontent.com/Chemotion/Push2Deploy/nmrium/payload/Dockerfile.v1.release
wget https://raw.githubusercontent.com/Chemotion/Push2Deploy/nmrium/payload/Dockerfile.v2.release
cd nmrium-react-wrapper
for release in v0.1.0 v0.2.0 v0.3.0 v0.4.0 v0.5.0 v0.6.0 v0.7.0 v0.8.0 v0.9.0 v1.0.0; do
    if [ -d "../toPackage/$release" ]; then
        echo "Directory $release already exists, skipping..."
        continue
    fi
    git checkout $release
    # if file exists, replace it
    if [ -f "src/hooks/useWhiteList.ts" ]; then
        cp ../useWhiteList.ts ./src/hooks/useWhiteList.ts
    fi
    # version is less than 0.9.0, use Dockerfile v1
    if [[ "$release" < "v0.9.0" ]]; then
        cp ../Dockerfile.v1.release ./Dockerfile.release
    else
        cp ../Dockerfile.v2.release ./Dockerfile.release
        # increase the memory limit for node
        sed -i 's/NODE_OPTIONS=--max_old_space_size=4096//g' package.json
    fi
    rm -rf build dist # remove old build directory if any is committed to the repository
    docker build --no-cache --output $release --build-arg RELEASE=$release -f Dockerfile.release . && echo "Built release $release"
    # if build was successful, move the release to toPackage directory
    if [ $? -eq 0 ]; then
        mv $release ../toPackage/.
    fi
    git reset --hard
done
cd ..
echo "Cleaning up..."
rm -rf useWhiteList.ts Dockerfile.v1.release Dockerfile.v2.release nmrium-react-wrapper releases nginx.conf
# rearrange the directory structure
cp -r toPackage/$release releases && mv toPackage/* releases/. && rm -r toPackage
wget https://raw.githubusercontent.com/Chemotion/Push2Deploy/nmrium/payload/nginx.conf
echo "Done."