# Echo Chamber Mobile App Example

A super simple echo chamber mobile app example to show how [Approov](https://approov.io/product) can be integrated when using the [phoenix_wings](https://pub.dev/packages/phoenix_wings) Dart package to talk with an [Elixir Phoenix Channels](https://hexdocs.pm/phoenix/channels.html) backend.


## Try the Echo Chamber mobile app without Approov

First, clone this repo:

> git clone https://github.com/approov/quickstart-flutter-elixir-phoenix-channels.git

Next, open your IDE on the folder `src/echo-chamber-app`.

Now, use the correspondent button of your IDE to get the dependencies.

Finally, you can build and run the Flutter Echo Chamber mobile app by hitting the correspondent button in your IDE.

> NOTE: The mobile app will run against this live backend `https://unprotected.phoenix-channels.demo.approov.io`, and the code for it is in the [approov/quickstart-elixir-phoenix-channels-token-check](https://github.com/approov/quickstart-elixir-phoenix-channels-token-check/tree/master/src/unprotected-server/echo) Github repo at `src/unprotected-server/echo`.

[TOC](/README.md#toc)


## Enable Approov in the Echo Chamber Mobile App

First, ensure you have the Approov CLI installed by typing in your terminal `approov`. If not, you can follow [these instructions](https://approov.io/docs/latest/approov-installation/) to install it.

### Approov Plugin Setup

All commands to execute from a terminal will assume that you are inside the `src/echo-chamber-app` folder, thus make sure you are inside it:

```text
cd src/echo-chamber-app
```

Now, from inside the `src/echo-chamber-app` folder, clone the Approov Flutter supporting packages into the `src/echo-chamber-app/approov` folder, by executing from `src/echo-chamber-app`:

```text
git clone https://github.com/approov/approov-flutter-packages.git approov
```

> **NOTE:** The Approov Flutter supporting packages _must_ be cloned first, then the Approov HTTP Client package or `git clone` will fail with the error: `src/app-final/approov` directory not empty.

Clone the Approov Flutter plugin into the `src/echo-chamber-app/approov` folder, by executing from `src/echo-chamber-app`:

```text
git clone https://github.com/approov/quickstart-flutter-httpclient.git approov/flutter-httpclient
```

If you want to build for Android then download the Android Approov SDK and add it to the Approov plugin, by executing from `src/echo-chamber-app` folder:

```text
approov sdk -getLibrary approov/flutter-httpclient/approov_http_client/android/approov-sdk.aar
```
> **NOTE:** The approov command is downloading the Approov SDK into the folder `src/echo-chamber-app/approov/flutter-httpclient/approov_http_client/android/approov-sdk.aar`

Instead, if you want to build for iOS execute from `src/echo-chamber-app` folder:

```text
approov sdk -getLibrary approov.zip
unzip approov.zip -d approov/flutter-httpclient/approov_http_client/ios
rm -rf approov.zip
```
> **NOTE:** The unzip command is unzipping the Approov library into `src/echo-chamber-app/approov/flutter-httpclient/approov_http_client/ios`

Next, retrieve the `approov-initial.config` and save it into `src/echo-chamber-app/approov-initial.config`. From inside the `src/echo-chamber-app` folder execute:

```text
approov sdk -getConfig approov-initial.config
```

Now, is time to enable Approov in the mobile app code by replacing three files, and we do this by executing from `src/echo-chamber-app`:

```text
cp pubspec.yaml.approov-example pubspec.yaml
cp lib/http_service.dart.approov-example lib/http_service.dart
cp lib/phoenix_channel.dart.approov-example lib/phoenix_channel.dart
```

Finally, open the Echo Chamber mobile app in your IDE, from the `src/echo-chamber-app` folder, and then use the correspondent button of your IDE to fetch your new dependencies, but don't build or run the Echo Chamber mobile app yet.


### Mobile API Registration

The app will run against [this backend](https://github.com/approov/quickstart-elixir-phoenix-channels-token-check/tree/master/src/approov-protected-server/token-check/echo), that is live at `token.phoenix-channels.demo.approov.io`, thus we also need to let the Approov cloud service know the API domain for it:

```text
approov api -add token.phoenix-channels.demo.approov.io
```
> **NOTE:** This command only needs to be executed the first time you register an APK with Approov.

The Approov cloud service will not issue Approov tokens for your mobile app if you forget this step, even if the mobile app binary is registered and no tampering is detected with the binary on the environment is running on.

Adding the API domain also configures the [dynamic certificate pinning](https://approov.io/docs/latest/approov-usage-documentation/#approov-dynamic-pinning) setup, out of the box. Approov Dynamic Pinning secures the communication channel between your app and your API with all the benefits of traditional pinning but without the drawbacks.

> **NOTE:** By default, the pin is extracted from the public key of the leaf certificate served by the domain, as visible to the box executing the Approov CLI command and the Approov servers.

If you want to run the mobile app against a backend you have control off, then you need to follow the [deployment guide](https://github.com/approov/quickstart-elixir-phoenix-channels-token-check/blob/master/DEPLOYMENT.md) for the backend of this Echo Chamber mobile app. Remember that this backend needs to be reachable from the Internet, otherwise, the mobile app will not get Approov tokens, because the Approov cloud service will not be able to get the pins for configuring the dynamic pinning, that you get out of the box when you integrate Approov in a mobile app.

### Mobile App Binary Registration

In order to use your mobile app with Approov you need to register the mobile app binary each time you build it.

First, launch the Echo Chamber mobile app by hitting the correspondent button in your IDE.

> **IMPORTANT:** If you already have attempted to follow this guide, and have the Echo Chamber mobile app installed in your device, then you **MUST** uninstall it first, because Flutter seems to preserve state from previous attempts.

Now, you can go ahead and register the resulting binary with the Approov CLI tool. For development execute from inside the `src/echo-chamber-app` folder:

```
approov registration -add build/app/outputs/flutter-apk/app-debug.apk --expireAfter 1h
```
> **IMPORTANT:** During development always use the `--expireAfter` flag with an expiration that best suits your needs, using `h` for hours and `d` for days. By default, an app registration is permanent and will remain in the Approov cloud database until it is explicitly removed. Permanent app registrations should be used to identify apps that are being published to production.

Finally, you can now use the Echo Chamber mobile app and play with it, but you need to restart it in order for the mobile app to get a valid Approov token, because in the first launch it was not yet registered with the Approov cloud service.

> **NOTE:** To not have to restart the mobile app you can try to build the mobile app, then register it with Approov and then launch it, but this often leads to a failure in Approov not recognizing the mobile app as registered, because the way Flutter works it seems that in development it always build the mobile app when you hit the run button, even when no code changes had taken place, thus resulting in a different binary(maybe a timestamp is added in the build process), therefore not the same you had registered previously. This is also true for when using the `flutter` cli.

For a **production release** be rest assured that you don't need to launch the mobile app, just build it and register it. Please read our docs at [Managing Registrations](https://approov.io/docs/latest/approov-usage-documentation/#managing-registrations) for more details in how to proceed.


#### Development Work-flow

The registration step is required for each time you change your code, even if you are just commenting out a line of code or fixing a typo in a variable.

The Flutter hot reload functionality doesn't write to the disk any changes made to the code, therefore you cannot re-register the mobile app without stopping it and start it again, thus for a better development work-flow you may want to [whitelist](https://approov.io/docs/latest/approov-usage-documentation/#adding-a-device-security-policy) your mobile device with the Approov cloud service. This way the mobile app always get valid Approov tokens without the need to re-register it for each modification made to the code.

For example:

```text
approov device -add h4gubfCFzJu81j/U2BJsdg== -policy default,whitelist,all
```

The value `h4gubfCFzJu81j/U2BJsdg==` is the device id, and you can read on our docs the section [Extracting the Device ID](https://approov.io/docs/latest/approov-usage-documentation/#extracting-the-device-id) for more details how you can do it.

[TOC](/README.md#toc)


### Approov Integration Code Difference

Lets's check what have changed to enable Approov in each file...

For `pubspec.yaml` we execute from `src/echo-chamber-app`:

```text
git diff pubspec.yaml
```

Next, lets check the `http_service.dart` file by executing from the `src/echo-chamber-app` folder:

```text
git diff lib/http_service.dart
```

Finally, lets check the `phoenix_channel.dart` file by executing from the `src/echo-chamber-app` folder:

```text
git diff lib/phoenix_channel.dart
```

The Git difference shows that adding Approov into an existing project is as simple as a few lines of code to add the dependency and then require and use it in the code.

[TOC](/README.md#toc)
