# Echo Chamber Mobile App Example

A super simple echo chamber mobile app example written in in [`Flutter`](https://flutter.dev/) to show how [Approov](https://approov.io/product) can be integrated when using the [phoenix_wings](https://pub.dev/packages/phoenix_wings) Dart package to talk with an [Elixir Phoenix Channels](https://hexdocs.pm/phoenix/channels.html) backend. This quickstart provides a step-by-step example of integrating Approov into an app using a simple `Echo Chamber` app example that performs an echo of user input based on a request to an API backend that can be protected with Approov.

## WHAT YOU WILL NEED
* Access to a trial or paid Approov account
* The `approov` command line tool [installed](https://approov.io/docs/latest/approov-installation/) with access to your account
* [Android Studio](https://developer.android.com/studio) installed (version ArticFox 2020.3.1 is used in this guide) if you will build the Android app
* [Xcode](https://developer.apple.com/xcode/) installed (version 13.0 is used in this guide) to build iOS version of application
* [Cocoapods](https://cocoapods.org) installed to support iOS building (1.11.2 used in this guide)
* [Flutter](https://flutter.dev) version 2.5.3 used in this guide with Dart 2.14.4
* The contents of this repo

## Try The Echo Chamber App Without Approov

First, clone this repo:

> git clone https://github.com/approov/quickstart-flutter-elixir-phoenix-channels.git

Next, open your IDE on the folder `src/echo-chamber-app`.

Now, use the correspondent button of your IDE to get the dependencies.

Finally, you can build and run the Flutter Echo Chamber mobile app by hitting the correspondent button in your IDE.

Alternatively, you can attach desired device and execute `flutter run` using the command line.

> NOTE: The mobile app will run against this live backend `https://unprotected.phoenix-channels.demo.approov.io`, and the code for it is in the [approov/quickstart-elixir-phoenix-channels-token-check](https://github.com/approov/quickstart-elixir-phoenix-channels-token-check/tree/master/src/unprotected-server/echo) Github repo at `src/unprotected-server/echo`.

### iOS Potential Issues

If the iOS build fails with an error related to `Pods-Runner` then navigate inside `ios` folder using `cd ios` and run `pod install`.

If the iOS build fails with a signing error, open the Xcode project located in `ios/Runner.xcworkspace`:

```
$ open ios/Runner.xcworkspace
```

and select your code signing team in the _Signing & Capabilities_ section of the project.

Also ensure you modify the app's `Bundle Identifier` so it contains a unique string (you can simply append your company name). This is to avoid Apple rejecting a duplicate `Bundle Identifier` when code signing is performed. Then return to the shell and repeat the failed build step.

Please also verify the minimum iOS supported version is set to `iOS 10` if there is a supported version mismatch error.

### Android Potential Issues
If the Android build fails with `Manifest merger failed : Attribute application@label value=([...]) from AndroidManifest.xml:11:9-46 is also present at [approov-sdk.aar] AndroidManifest.xml:12:9-41 value=(@string/app_name)`, then open `android/app/src/main/AndroidManifest.xml` in an editor and make the following changes.

- Add the schema as an attribute in the `manifest` tag:

```
    <manifest ...
        xmlns:tools="http://schemas.android.com/tools"
        ... >
```
- Add the `android:label` and `tools` attributes to the `application` tag:
```
    <application ...
        android:label="@string/app_name"
        tools:replace="label"
        ... >
```

## Adding APPROOV Support

Approov protection is provided through the `approov_service_flutter_httpclient` plugin for both, Android and iOS mobile platforms. This plugin handles all Approov related functionality, such as downloading and instalation of Approov SDK library, initialization, managing of initial and update configurations, fetching of Approov tokens, adding these to API requests as necessary, and manages certificate public key pinning. The plugin also requests all necessary network permissions.

The `Elixir Phoenix Channels` and `phoenix_wings` support are located in the [approov-flutter-packages](https://github.com/approov/approov-flutter-packages.git) repository and is automatically installed by replacing the original `pubspec.yaml` file with the modified `pubspec.yaml.approov-example`. Using the shell from the directory `quickstart-flutter-elixir-phoenix-channels/src/echo-chamber-app `:

```
cp pubspec.yaml.approov-example pubspec.yaml
```

Now you need to link the ApproovSDK to your account. This requires editing two files and replacing the originals. Edit the file `lib/http_service.dart.approov-example` by finding the line that contains:

```Dart
final approovClient = ApproovClient('<enter your config string here>');
```

The `<enter-your-config-string-here>` is a custom string that configures your Approov account access. This will have been provided in your Approov onboarding email.

Now edit the file `lib/phoenix_channel.dart.approov-example` and locate this line:

```Dart
_socket = PhoenixSocket("${HttpService.websocketUrl}/socket/websocket",
        '<enter your config string here>',
        socketOptions: socket_options);
```

The `<enter-your-config-string-here>` needs to be replaced by the string you obtained during account registration.

Now replace the files from the command line:

```Bash
cp lib/http_service.dart.approov-example lib/http_service.dart
cp lib/phoenix_channel.dart.approov-example lib/phoenix_channel.dart
```

The original files use the unmodified `phoenix_wings` and `Elixir Phoenix Channels` whereas the new ones configure and make use of Approov.

Finally, open the Echo Chamber mobile app in your IDE, from the `src/echo-chamber-app` folder, and then use the correspondent button of your IDE to fetch your new dependencies, but don't build or run the Echo Chamber mobile app yet.


### Mobile API Registration

The app will run against [this backend](https://github.com/approov/quickstart-elixir-phoenix-channels-token-check/tree/master/src/approov-protected-server/token-check/echo), that is live at `token.phoenix-channels.demo.approov.io`, thus we also need to let the Approov cloud service know the API domain for it:

```Bash
approov api -add token.phoenix-channels.demo.approov.io
```
> **NOTE:** This command only needs to be executed the first time you register an APK/IPA with Approov.

The Approov cloud service will not issue Approov tokens for your mobile app if you forget this step, even if the mobile app binary is registered and no tampering is detected with the binary on the environment is running on.

Adding the API domain also configures the [dynamic certificate pinning](https://approov.io/docs/latest/approov-usage-documentation/#approov-dynamic-pinning) setup, out of the box. Approov Dynamic Pinning secures the communication channel between your app and your API with all the benefits of traditional pinning but without the drawbacks.

> **NOTE:** By default, the pin is extracted from the public key of the leaf certificate served by the domain, as visible to the box executing the Approov CLI command and the Approov servers.

If you want to run the mobile app against a backend you have control off, then you need to follow the [deployment guide](https://github.com/approov/quickstart-elixir-phoenix-channels-token-check/blob/master/DEPLOYMENT.md) for the backend of this Echo Chamber mobile app. Remember that this backend needs to be reachable from the Internet, otherwise, the mobile app will not get Approov tokens, because the Approov cloud service will not be able to get the pins for configuring the dynamic pinning, that you get out of the box when you integrate Approov in a mobile app.

### Mobile App Binary Registration

In order to use your mobile app with Approov you need to register the mobile app binary each time you build it.

First, launch the Echo Chamber mobile app by hitting the correspondent button in your IDE.

> **IMPORTANT:** If you already have attempted to follow this guide, and have the Echo Chamber mobile app installed in your device, then you **MUST** uninstall it first, because Flutter seems to preserve state from previous attempts.

Now, you can go ahead and register the resulting binary with the Approov CLI tool. For development execute from inside the `src/echo-chamber-app` folder:

For Android:

```text
approov registration -add build/app/outputs/flutter-apk/app-debug.apk --expireAfter 1h
```

For iOS: It is necessary to build an app archive (.ipa extension) and export it to a convenient location, for example the `quickstart-flutter-elixir-phoenix-channels` directory. See detailed instruction [here](https://flutter.dev/docs/deployment/ios) Install the app's .ipa on the device in order to ensure that the installed version and the registered version are the same. Assuming you have built an app archive, signed it and exported it to `quickstart-flutter-elixir-phoenix-channels/Runner\ 2021-11-11\ 14-27-30/example.ipa`, the registration command is:

```text
approov registration -add ../../Runner\ 2021-02-04\ 14-27-30/example.ipa --expireAfter 1h
```

> **IMPORTANT:** During development always use the `--expireAfter` flag with an expiration that best suits your needs, using `h` for hours and `d` for days. By default, an app registration is permanent and will remain in the Approov cloud database until it is explicitly removed. Permanent app registrations should be used to identify apps that are being published to production.

Finally, you can now use the Echo Chamber mobile app and play with it, but you need to restart it in order for the mobile app to get a valid Approov token, because in the first launch it was not yet registered with the Approov cloud service.

> **NOTE:** To not have to restart the mobile app you can try to build the mobile app, then register it with Approov and then launch it, but this often leads to a failure in Approov not recognizing the mobile app as registered, because the way Flutter works it seems that in development it always build the mobile app when you hit the run button, even when no code changes had taken place, thus resulting in a different binary(maybe a timestamp is added in the build process), therefore not the same you had registered previously. This is also true for when using the `flutter` cli.

For a **production release** rest assured that you don't need to launch the mobile app, just build it and register it. Please read our docs at [Managing Registrations](https://approov.io/docs/latest/approov-usage-documentation/#managing-registrations) for more details in how to proceed.


#### Development Work-flow

The registration step is required for each time you change your code, even if you are just commenting out a line of code or fixing a typo in a variable.

The Flutter hot reload functionality doesn't write to the disk any changes made to the code, therefore you cannot re-register the mobile app without stopping it and start it again, thus for a better development work-flow you may want to ensure your device [always passes](https://approov.io/docs/latest/approov-usage-documentation/#adding-a-device-security-policy). This way the mobile app always get valid Approov tokens without the need to re-register it for each modification made to the code.

For example:

```Bash
approov device -add h4gubfCFzJu81j/U2BJsdg== -policy default,whitelist,all
```

The value `h4gubfCFzJu81j/U2BJsdg==` is the device id, and you can read on our docs the section [Extracting the Device ID](https://approov.io/docs/latest/approov-usage-documentation/#extracting-the-device-id) for more details how you can do it.


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

## WHAT IF I DON'T SEE ECHO OUTPUT

If you still don't get an echo from the app then there are some things you can try. Remember this may be because the device you are using has some characteristics that cause rejection for the currently set [Security Policy](https://approov.io/docs/latest/approov-usage-documentation/#security-policies) on your Approov account:

* Ensure that the version of the app you are running is exactly the one you registered with Approov.
* Look at the [`logcat`](https://developer.android.com/studio/command-line/logcat) or the MacOS `Console` application output from the device. Information about any Approov token fetched or an error is output at the `INFO` level, e.g. `ApproovService: Approov Token for token.phoenix-channels.demo.approov.io: {"exp":1636623318,"ip":"2a02:c7f:8d09:0:4994:a536:af46:b737","did":"MSoSzkRlBoco17xZ146Gow==","anno":["app-not-registered","bad-app-id-sig","bad-app-unver-sig","devicecheck-suppress","first-fetch","has-app-id-sig","has-app-unver-sig","no-custom-claim","safetynet-suppress","sigblock-suppress","true"],"arc":"N725GLOVQI","sip":"QTWg5h"}`. You can easily [check](https://approov.io/docs/latest/approov-usage-documentation/#loggable-tokens) the validity and find out any reason for a failure.
* Consider using an [Annotation Policy](https://approov.io/docs/latest/approov-usage-documentation/#annotation-policies) during initial development to directly see why the device is not being issued with a valid token.
* Use `approov metrics` to see [Live Metrics](https://approov.io/docs/latest/approov-usage-documentation/#live-metrics) of the cause of failure.
* You can use a debugger or emulator and get valid Approov tokens on a specific device by ensuring your device [always passes](https://approov.io/docs/latest/approov-usage-documentation/#adding-a-device-security-policy). As a shortcut, when you are first setting up, you can add a [device security policy](https://approov.io/docs/latest/approov-usage-documentation/#adding-a-device-security-policy) using the `latest` shortcut as discussed so that the `device ID` doesn't need to be extracted from the logs or an Approov token.
* Approov token data is logged to the console using a secure mechanism - that is, a _loggable_ version of the token is logged, rather than the _actual_ token for debug purposes. This is covered [here](https://www.approov.io/docs/latest/approov-usage-documentation/#loggable-tokens). The code which performs this is:

```Dart
const result = await ApproovService.fetchApproovToken(url);
console.log("Fetched Approov token: " + result.loggableToken);
```

and the logged token is specified in the variable `result.loggableToken`.

The Approov token format (discussed [here](https://www.approov.io/docs/latest/approov-usage-documentation/#token-format)) includes an `anno` claim which can tell you why a particular Approov token is invalid and your app is not correctly authenticated with the Approov Cloud Service. The various forms of annotations are described [here](https://www.approov.io/docs/latest/approov-usage-documentation/#annotation-results).