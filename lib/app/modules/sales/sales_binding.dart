import 'package:get/get.dart';
import 'sales_controller.dart';

class SalesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SalesController>(() => SalesController());
  }
}
