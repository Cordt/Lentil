# Lentil

Lentil is a Social Media and Messaging App that runs on top of [Lens Protocol](https://www.lens.xyz) and [XMTP](https://xmtp.org). It is the only natively implemented iOS Client, fully built with SwiftUI.

* [Overview](#overview)
* [How to run the project](#how-to-run-the-project)
* [Configuration](#configuration)
* [License](#license)
* [Contribute](#contribute)

## Overview
Lentil is a native iOS Client for Lens Protocol. It does not aim to be a clone of Twitter, YouTube or others, but instead to showcase and explore the functionalitites of the protocol.
The app is built using 
* [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) as the core architecture of the app,
* [SwiftUI](https://developer.apple.com/xcode/swiftui/) to power the interface, and
* [WalletConnect v2](https://github.com/WalletConnect/WalletConnectSwiftV2) to integrate with common wallets.

The app runs on top of 
* [Lens Protocol](https://docs.lens.xyz/docs) as the backend that powers the social network, and
* [XMTP](https://github.com/xmtp/xmtp-ios) as the backend that powers the wallet based messaging.

Lentil is currently in closed Alpha, feel free to sign up on [lentilapp.xyz](https://lentilapp.xyz).

## How to run the project
The app is fully built using Swift, so we recommend to use Xcode to run it.

Once you cloned the repository and opened it in Xcode, you need to add two files:
* `Secrets-Development.xcconfig` in the *Lentil* folder
* `Secrets-Production.xcconfig` in the *Lentil* folder

These configuration files store the project's secrets. Add the following information to each of them:

```
INFURA_PROJECT_ID = 
INFURA_API_SECRET_KEY = 

WALLETCONNECT_PROJECT_ID = 

GIPHY_API_KEY = 

SENTRY_DSN_KEY_1 = 
SENTRY_DSN_KEY_2 = 
SENTRY_DSN_PROJECT_ID = 
```

You need to provide a key for each of those entries to be able to run the app.

Once this is done, you should be able to run the app and test it.
Please note that it is not necessary to have a handle to use Lentil, it works without being authenticated against the API.
It is possible though to obtain a Lens handle on Mumbai Testnet without the need for whitelisting, in case you want to test the full set of functionalities.

## Configuration
When running Lentil with the Debug configuration, it uses Mumbai Testnet for Lens and the XMTP Dev Network for Messaging.
These endpoints are already defined in `Mumbai-Development.xcconfig`.

Please note that it is currently not possible to use WalletConnect with the Simulator, meaning any authentication (Lens or XMTP) needs to be done on an actual Device.
This is not a limitation of Lentil or WalletConnect, but of the Simulator itself.

## License
Lentil is released under [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0.html).

## Contribute
In case you find any bugs or issues, please feel free to open an issue in GitHub.
While we maintain a clear focus for Lentil, we are always happy to get feedback or suggestions on it. Please reach out to us via [E-Mail](mailto:gm@lentilapp.xyz).
