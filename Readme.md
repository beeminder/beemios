Beeminder iOS App ("beemiOS" is pronounced "be my OS")

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
