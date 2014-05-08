# Airbitz iOS

## Setup your environment

    REPO_DIR=$HOME/airbitz
    mkdir -p $REPO_DIR
    cd $REPO_DIR

Set your `$REPO_DIR` to whatever you want.

## Setting up airbitz walletcore

    cd $REPO_DIR
    git clone git@github.com:Airbitz/airbitz-walletcore.git
    cd airbitz-walletcore
    WALLET_CORE=`pwd`
    cd deps
    make

    DITTY_PATH=/Projects/Ditty\ Labs/Clients/AirBitz/Project/AirBitz/AirBitz/ABC
    sudo mkdir -p $DITTY_PATH
    sudo cp prefix/arm/armv7/lib/*.a $DITTY_PATH

## Build Airbitz iOS in xcode

    cd $REPO_DIR
    git clone git@github.com:Airbitz/airbitz-ios-gui.git

    # copy headers 
    mkdir airbitz-ios-gui/AirBiz/ABC
    cp $WALLET_CORE/src/*.h airbitz-ios-gui/AirBiz/ABC

    # Fire up in xcode
    open airbitz-ios-gui/AirBitz.xcodeproj

Once in xcode you can run Command-R to run it in an emulator.