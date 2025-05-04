import 'package:get/get.dart';
import 'package:strukin/controller/splitpage_controller.dart';
import 'package:strukin/model/struk_from_api.dart';

class EditPageController extends GetxController {
  Rx<StrukFromApi?> transaksi = Rx<StrukFromApi?>(null);
  var splitController = Get.put(SplitpageController());
  @override
  void onInit() {
    transaksi.value = splitController.processedText.value!.deepCopy();
    super.onInit();
  }

  void addMenu(Item item) {
    transaksi.value?.items!.add(item);
  }

  void resetStruk() {
    transaksi.value = splitController.processedTextBackup;
  }

  void total(int index) {
    transaksi.value!.items![index].price =
        transaksi.value!.items![index].unitPrice ??
        0 * transaksi.value!.items![index].quantity!;
    int total = 0;

    for (var item in transaksi.value!.items!) {
      total += item.price!;
    }
    transaksi.value!.total = total + transaksi.value!.tax!;

    transaksi.value!.subtotal = total;
  }

  void updateTax(int tax) {
    transaksi.value!.tax = tax;

    var subTotal = transaksi.value!.subtotal;
    transaksi.value!.total = subTotal! + tax;
  }

  void updateTotal() {
    int total = 0;
    for (var i = 0; i < transaksi.value!.items!.length; i++) {
      total += transaksi.value!.items![i].price!;
    }
    transaksi.value!.total = total;
  }
}
