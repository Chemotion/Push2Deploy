#!/bin/bash
if [ ! -d "nmrium-react-wrapper" ]; then
    git clone https://github.com/NFDI4Chem/nmrium-react-wrapper.git nmrium-react-wrapper
else
    cd nmrium-react-wrapper
    git pull origin main
    cd ..
fi
mkdir -p releases
wget https://github.com/Chemotion/Push2Deploy/raw/refs/heads/nmrium/payload/useWhiteList.ts
wget https://github.com/Chemotion/Push2Deploy/raw/refs/heads/nmrium/payload/Dockerfile.v1.release
wget https://github.com/Chemotion/Push2Deploy/raw/refs/heads/nmrium/payload/Dockerfile.v2.release
cd nmrium-react-wrapper
for release in v0.1.0 v0.2.0 v0.3.0 v0.4.0 v0.5.0 v0.6.0 v0.7.0 v0.8.0 v0.9.0 v1.0.0; do
    if [ -d "../releases/$release" ]; then
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
    # set the release version in the Dockerfile
    mkdir -p ../releases/${release}
    docker build --output ../releases/${release} --build-arg RELEASE=$release -f Dockerfile.release . && echo "Built release $release"
    git clean -fdx
done
cd ..
echo "Cleaning up..."
rm useWhiteList.ts Dockerfile.v1.release Dockerfile.v2.release