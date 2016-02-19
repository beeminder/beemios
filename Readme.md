# Warning! 

#### This is no longer the code for the App Store version of the Beeminder app. It's been rewritten in Swift and still has some things in it (integration keys) that we need to remove before open sourcing it. We'll publish it soon and link to it here when we do. 

Beeminder iOS App ("beemiOS" is pronounced "be my OS")

This is the [official Beeminder iOS app, available in the App Store](https://itunes.apple.com/us/app/beeminder/id551869729).

#### Dependencies

[Cocoapods](http://cocoapods.org/)

#### Setup

- `git clone https://github.com/beeminder/beemios`
- `cd beemios`
- `pod install`
- `cp Beeminder/constants.h.sample Beeminder/constants.h`
- `open Beeminder.xcworkspace`

#### Notes

The Twitter/Facebook buttons won't work on your local install (we couldn't figure out a way to do so without publishing secret keys). Log in with your Beeminder email/username and password. 
