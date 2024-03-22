import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';

class InitializationHelper {
  Future<FormError?> initialize() async {
    final completer = Completer<FormError?>();

    final params = ConsentRequestParameters(
      consentDebugSettings: ConsentDebugSettings(
        debugGeography: DebugGeography.debugGeographyEea,
        // Or DebugGeography.debugGeographyNotEea to simulate outside of the EEA
      ),
    );

    ConsentInformation.instance.requestConsentInfoUpdate(params, () async {
      if (await ConsentInformation.instance.isConsentFormAvailable()) {
        await _loadConsentForm();
      } else {
        // There is no message to display,
        // so initialize the components here.
        await _initialize();
      }

      completer.complete();
    }, (error) {
      completer.complete(error);
    });

    return completer.future;
  }

  Future<FormError?> _loadConsentForm() async {
    final completer = Completer<FormError?>();

    ConsentForm.loadConsentForm((consentForm) async {
      final status = await ConsentInformation.instance.getConsentStatus();
      if (status == ConsentStatus.required) {
        consentForm.show((formError) {
          completer.complete(_loadConsentForm());
        });
      } else {
        // The user has chosen an option,
        // it's time to initialize the ads component.
        await _initialize();
        completer.complete();
      }
    }, (FormError? error) {
      completer.complete(error);
    });

    return completer.future;
  }

  Future<void> _initialize() async {
    await MobileAds.instance.initialize();
  }
}
