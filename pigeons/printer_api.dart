import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/infrastructure/printer/printer_api.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/app/src/main/kotlin/com/portfolio/restrohub/PrinterApi.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.portfolio.restrohub'),
  ),
)
@HostApi()
abstract class PrinterApi {
  bool isPrinterConnected();
  void printReceipt(Map<String, String> orderData);
}
