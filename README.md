# Approov Quickstart: Flutter Elixir Phoenix Channels

[Approov](https://approov.io) is an API security solution used to verify that requests received by your backend services originate from trusted versions of your mobile apps.

This is an Approov integration quickstart example for a mobile app built with Flutter and using a backend with Elixir Phoenix Channels. If you are looking for another mobile app integration you can check our list of [quickstarts](https://approov.io/docs/latest/approov-integration-examples/mobile-app/), and if you don't find what you are looking for, then please let us know [here](https://approov.io/contact).


## TOC

* [Overview](#overview)
    + [What you will need](#what-you-will-need)
    + [What you will learn](#what-you-will-learn)
* [Approov Integration Quickstart](#approov-integration-quickstart-in-your-app)
    + [Approov Plugin Setup](#approov-plugin-setup)
    + [Approov Http Client](#approov-http-client)
    + [Mobile API Registration](#mobile-api-registration)
    + [Mobile App Binary Registration](#mobile-app-binary-registration)
* [Echo Chamber Mobile App Example](/src/echo-chamber-app/README.md)
* [Next Steps](#next-steps)


## Overview

### What You Will Need

* Access to either the demo account ([request access here](https://info.approov.io/demo-token)) or a trial/paid Approov account
* The `approov` command line tool [installed](https://approov.io/docs/latest/approov-installation/) with `APPROOV_MANAGEMENT_TOKEN` set with your account access token
* Flutter installed. This quickstart uses version:

  ```text
  flutter --version
  Flutter 1.22.2 • channel stable • https://github.com/flutter/flutter.git
  Framework • revision 84f3d28555 (3 weeks ago) • 2020-10-15 16:26:19 -0700
  Engine • revision b8752bbfff
  Tools • Dart 2.10.2
  ```

[TOC](#toc)

### What You Will Learn

* How to integrate Approov into a real app in a step by step fashion
* How to register your app to get valid tokens from Approov
* A solid understanding of how to integrate Approov into your own app that uses Flutter with Elixir Phoenix Channels
* Some pointers to other Approov features

[TOC](#toc)


## Approov Integration Quickstart in your App

This quickstart is for any developer looking to integrate Approov in their own mobile app. For an hands-on ready mobile app example you can follow the [guide](/src/echo-chamber-app/README.md) for the Echo Chamber app example included in this repo.

### Approov Plugin Setup

At the root of your project create a folder named `approov`:

```text
mkdir approov
```

Clone the Approov Flutter plugin into the `approov` folder:

```text
git clone https://github.com/approov/quickstart-flutter-httpclient.git approov
```
> **NOTE:** The Approov Flutter plugin will be located at `your-project/approov` folder

Download the Android Approov SDK and add it to the Approov plugin:

If you want to build for Android then download the Android Approov SDK and add it to the Approov plugin, by executing from the root of your project:

```text
approov sdk -getLibrary approov/flutter-httpclient/approov_http_client/android/approov-sdk.aar
```
> **NOTE:** The approov command is downloading the Approov SDK into the folder `your-project/approov/flutter-httpclient/approov_http_client/android/approov-sdk.aar`

Instead, if you want to build for iOS execute from the root of your project:

```text
approov sdk -getLibrary approov.zip
unzip approov.zip -d approov/flutter-httpclient/approov_http_client/ios
rm -rf approov.zip
```
> **NOTE:** The unzip command is unzipping the Approov library into `your-project/approov/flutter-httpclient/approov_http_client/ios`

Retrieve the `approov-initial.config` file and save it to the root of your project:

```
approov sdk -getConfig approov-initial.config
```
> **NOTE:** The Approov initial config will be located at `your-project/approov-initial.config`

Edit your `pubspec.yaml` and add the Approov SDK and the `approov-initial.config` to it:

```yml
dependencies:
  approov_http_client:
    path: ./approov/flutter-httpclient/approov_http_client

flutter:
  assets:
    - ./approov-initial.config
```

[TOC](#toc)


### Approov Http Client

The last step is to use the Approov Http Client in your code. This is a drop in replacement for the Flutter native Http Client.

So, wherever you have your HttpClient defined, you should replace it with the drop-in Approov HttpClient:

```dart
import 'package:approov_http_client/approov_http_client.dart';

//static final httpClient = new http.Client();
static final httpClient = ApproovClient();
```

Full example code for a Phoenix Channels mobile app:

```dart
import 'package:approov_http_client/approov_http_client.dart';

class PinnedHttp {
  static String apiBaseUrl = 'YOUR_API_SERVER_BASE_URL_HERE';

  static final httpClient = ApproovClient();
}
```

Usage example for protecting the user register/login requests with Approov:

```dart
class UserAuth {
  final http = PinnedHttp.httpClient;

  // code omitted for brevity

  Response response = await http
    .post(
      "${PinnedHttp.apiBaseUrl}/auth/login",
      headers: {"content-type": "application/json"},
      body: jsonEncode(credentials),
    )
    .catchError((onError) {
      print(onError);
      return null;
    });

  // code omitted for brevity

}
```

[TOC](#toc)


### Mobile API Registration

Approov needs to know the domain name of the API for which it will issue tokens.

Add it with:

```text
approov api -add your.api.domain.com
```

> **NOTE:** This only needs to be done one time per each API, not for every time you register a mobile app binary.

The Approov cloud service will not issue Approov tokens for your mobile app if you forget this step, even if the mobile app binary is registered and no tampering is detected with the binary or the environment is running on.

Adding the API domain also configures the [dynamic certificate pinning](https://approov.io/docs/latest/approov-usage-documentation/#approov-dynamic-pinning) setup, out of the box. Approov Dynamic Pinning secures the communication channel between your app and your API with all the benefits of traditional pinning but without the drawbacks.

> **NOTE:** By default, the pin is extracted from the public key of the leaf certificate served by the domain, as visible to the box executing the Approov CLI command and the Approov servers.

[TOC](#toc)

### Mobile App Binary Registration

In order to use your mobile app with Approov you need to register the mobile app binary each time you build it.

First, build the mobile app by hitting the correspondent button in your IDE.

After the build is finished you can then register the resulting binary with the Approov CLI tool.

#### For Development:

From the root of your project execute:

```
approov registration -add build/app/outputs/flutter-apk/app-debug.apk --expireAfter 1h
```

> **IMPORTANT:** During development always use the `--expireAfter` flag with an expiration that best suits your needs, using `h` for hours and `d` for days. By default, an app registration is permanent and will remain in the Approov cloud database until it is explicitly removed. Permanent app registrations should be used to identify apps that are being published to production. Read more in our docs at [Managing Registrations](https://approov.io/docs/latest/approov-usage-documentation/#managing-registrations).

This registration step is required for each time you change your code, even if you are just commenting out a line of code or fixing a typo in a variable.

The Flutter hot reload functionality doesn't write to the disk any changes made to the code, therefore you cannot re-register the mobile app without stopping it and start it again, thus for a better development work-flow you may want to [whitelist](https://approov.io/docs/latest/approov-usage-documentation/#adding-a-device-security-policy) your mobile device with the Approov cloud service. This way the mobile app always get valid Approov tokens without the need to re-register it for each modification made to the code.

For example:

```text
approov device -add h4gubfCFzJu81j/U2BJsdg== -policy default,whitelist,all
```

The value `h4gubfCFzJu81j/U2BJsdg==` is the device id, and you can read on our docs the section [Extracting the Device ID](https://approov.io/docs/latest/approov-usage-documentation/#extracting-the-device-id) for more details how you can do it.

#### For Production

For a production release, you can refer to the [Managing Registration](https://approov.io/docs/latest/approov-usage-documentation/#managing-registrations) section of our docs for instructions on the several methods that can be used for Android and iOS.


[TOC](#toc)


## Next Steps

This quick start guide has shown you how to integrate Approov with your existing app. Now you might want to explore some other Approov features:

* Managing your app [registrations](https://approov.io/docs/latest/approov-usage-documentation/#managing-registrations)
* Manage the [pins](https://approov.io/docs/latest/approov-usage-documentation/#public-key-pinning-configuration) on the API domains to ensure that no Man-in-the-Middle attacks on your app's communication are possible.
* Update your [Security Policy](https://approov.io/docs/latest/approov-usage-documentation/#security-policies) that determines the conditions under which an app will be given a valid Approov token.
* Learn how to [Manage Devices](https://approov.io/docs/latest/approov-usage-documentation/#managing-devices) that allows you to change the policies on specific devices.
* Understand how to issue and revoke your own [Management Tokens](https://approov.io/docs/latest/approov-usage-documentation/#management-tokens) to control access to your Approov account.
* Use the [Metrics Graphs](https://approov.io/docs/latest/approov-usage-documentation/#metrics-graphs) to see live and accumulated metrics of devices using your account and any reasons for devices being rejected and not being provided with valid Approov tokens. You can also see your billing usage which is based on the total number of unique devices using your account each month.
* Use [Service Monitoring](https://approov.io/docs/latest/approov-usage-documentation/#service-monitoring) emails to receive monthly (or, optionally, daily) summaries of your Approov usage.
* Consider using [Token Binding](https://approov.io/docs/latest/approov-usage-documentation/#token-binding). The method `<AppClass>.approovService!!.setBindingHeader` takes the name of the header holding the value to be bound. This only needs to be called once but the header needs to be present on all API requests using Approov.
* Investigate other advanced features, such as [Offline Security Mode](https://approov.io/docs/latest/approov-usage-documentation/#offline-security-mode), [DeviceCheck Integration](https://approov.io/docs/latest/approov-usage-documentation/#apple-devicecheck-integration) and [Android Automated Launch Detection](https://approov.io/docs/latest/approov-usage-documentation/#android-automated-launch-detection).

[TOC](#toc)

