# Approov Quickstart: Flutter Elixir Phoenix Channels

[Approov](https://approov.io) is an API security solution used to verify that requests received by your backend services originate from trusted versions of your mobile apps.

This is an Approov integration quickstart example for a mobile app built with Flutter and using a backend with [Elixir Phoenix Channels](https://hexdocs.pm/phoenix/channels.html). If you are looking for another mobile app integration you can check our list of [quickstarts](https://approov.io/docs/latest/approov-integration-examples/mobile-app/), and if you don't find what you are looking for, then please let us know [here](https://approov.io/contact). This quickstart provides the basic steps for integrating Approov into your app. A more detailed step-by-step guide using a [Echo Chamber App](https://github.com/approov/quickstart-flutter-elixir-phoenix-channels/blob/master/ECHO-CHAMBER-EXAMPLE.md) is also available.


## ADDING Approov Enabled Elixir Phoenix Channels

The Approov Enabled Elixir Phoenix Channels is available via [`Github`](https://github.com/approov/quickstart-flutter-elixir-phoenix-channels.git) package. This allows inclusion into the project by simply specifying a dependency in the `pubspec.yaml` files for the app. In the `dependencies:` section of `pubspec.yaml` file add the following package reference:

```yaml
phoenix_wings:
  git:
    url: https://github.com/approov/approov-flutter-packages.git
    path: phoenix_wings
approov_web_socket:
  git:
    url: https://github.com/approov/approov-flutter-packages.git
    path: approov_web_socket
approov_service_flutter_httpclient:
  git: https://github.com/approov/approov-service-flutter-httpclient.git
```

The `phoenix_wings` package uses a predefined header to forward the Approov Token and also forwards the Approov SDK initialization string to the `approov_web_socket` package. The `approov_web_socket` package interacts with the `approov_service_flutter_httpclient` by means of an `ApproovHttpClient` object.

The `approov_service_flutter_httpclient` package is actually an open source wrapper layer that allows you to easily use Approov with `Flutter`. This has a further dependency to the closed source [Android Approov SDK](https://github.com/approov/approov-android-sdk) and [iOS Approov SDK](https://github.com/approov/approov-ios-sdk) packages. Those are automatically added as dependencies for the platform specific targets.

The `approov_service_flutter_httpclient` package declares four classes:

1. ApproovService and TokenFetchResult provide the SDK native binding
2. ApproovHttpClient which is a drop-in replacement for the Dart IO library's HttpClient and calls the ApproovService
3. ApproovClient which is a drop-in replacement for Client from the Flutter http package (https://pub.dev/packages/http)
    and uses internally an ApproovHttpClient object


### ANDROID

The `approov_service_flutter_httpclient` adds an additional repository to the `build.gradle` project file:

```gradle
maven { url 'https://jitpack.io' }
```

and two implementation dependencies:

```gradle
dependencies {
    implementation 'com.squareup.okhttp3:okhttp:4.9.3'
    implementation 'com.github.approov:approov-android-sdk:2.9.0'
}
```

### ANDROID MANIFEST CHANGES

The following app permissions need to be available in the manifest of your application to be able to use Approov:

```xml
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.INTERNET" />
```

Note that the minimum SDK version you can use with the Approov package is 21 (Android 5.0). 

Please [read this](https://approov.io/docs/latest/approov-usage-documentation/#targetting-android-11-and-above) section of the reference documentation if targetting Android 11 (API level 30) or above.

### IOS

The `approov_service_flutter_httpclient` generates a [Cocoapods](https://cocoapods.org) dependency file which must be installed by executing:

```Bash
pod install
```

in the directory containing the ios project files.

## Initializing and Using the Phoenix Channels Package

You need to instantiate the `PhoenixSocket` with an additional parameter and use it to `connect()`:

```Dart
_socket = PhoenixSocket("${HttpService.websocketUrl}/socket/websocket",
        '<enter your config string here>',
        socketOptions: socket_options);
```

The `<enter-your-config-string-here>` is a custom string that configures your Approov account access. This will have been provided in your Approov onboarding email.


### Approov Http Client

The last step is to use the Approov Http Client in your code. This is a drop in replacement for the Flutter native Http Client.

So, wherever you have your HttpClient defined, you should replace it with the drop-in Approov HttpClient:

```dart
import 'package:approov_service_flutter_httpclient/approov_service_flutter_httpclient.dart';

//static final httpClient = new http.Client();
http.Client client = ApproovClient('<enter-your-config-string-here>');
```

Full example code for a Phoenix Channels mobile app:

```dart
import 'package:approov_service_flutter_httpclient/approov_service_flutter_httpclient.dart';

class PinnedHttp {
  static String apiBaseUrl = 'YOUR_API_SERVER_BASE_URL_HERE';

  http.Client client = ApproovClient('<enter-your-config-string-here>');
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

## Checking it Works

Initially you won't have set which API domains to protect, so the interceptor will not add anything. It will have called Approov though and made contact with the Approov cloud service. You will see logging from Approov saying `UNKNOWN_URL`.

Your Approov onboarding email should contain a link allowing you to access [Live Metrics Graphs](https://approov.io/docs/latest/approov-usage-documentation/#metrics-graphs). After you've run your app with Approov integration you should be able to see the results in the live metrics within a minute or so. At this stage you could even release your app to get details of your app population and the attributes of the devices they are running upon.

However, to actually protect your APIs there are some further steps you can learn about in [Next Steps](https://github.com/approov/quickstart-flutter-httpclient/blob/master/NEXT-STEPS.md).


