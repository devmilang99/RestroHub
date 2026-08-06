import 'package:http_certificate_pinning/http_certificate_pinning.dart';
import 'package:restro_hub/core/utils/logger.dart';
import 'package:safe_device/safe_device.dart';

class SecurityService {
  /// Checks if the device is secure (not rooted/jailbroken, not an emulator if restricted).
  static Future<bool> isDeviceSecure() async {
    try {
      bool isJailBroken = await SafeDevice.isJailBroken;
      bool isRealDevice = await SafeDevice.isRealDevice;
      bool isTampered = await SafeDevice.isSafeDevice == false;

      // In production, we might want to block rooted devices
      if (isJailBroken || isTampered) {
        logError(
          'Security Check Failed: Rooted/Jailbroken or Tampered device detected.',
        );
        return false;
      }

      // Optional: block emulators in high-security apps
      // if (!isRealDevice) return false;

      return true;
    } catch (e) {
      logError('Security Check Error', e);
      return false; // Fail secure
    }
  }

  /// Verifies SSL certificate for a given URL.
  /// SHA-256 Fingerprint should be updated regularly.
  static Future<bool> verifyCertificate(
    String url,
    List<String> allowedFingerprints,
  ) async {
    try {
      final secureStatus = await HttpCertificatePinning.check(
        serverURL: url,
        headerHttp: {},
        sha: SHA.SHA256,
        allowedSHAFingerprints: allowedFingerprints,
        timeout: 10,
      );
      return secureStatus == "CONNECTION_SECURE";
    } catch (e) {
      logError('SSL Pinning Verification Failed', e);
      return false;
    }
  }
}
