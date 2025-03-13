class MenuItems {
  String name;
  String quantity;
  String price;

  MenuItems({required this.name, required this.quantity, required this.price});
}

class Person {
  String name;
  List<MenuItems> listMenuItems;

  Person({required this.name, required this.listMenuItems});
}

List<Person> people = [
  Person(
    name: 'Raihan',
    listMenuItems: [
      MenuItems(name: 'NASI GORENG PEDAS', quantity: '1X', price: '13.000'),
      MenuItems(name: 'ICE LEMON TEA', quantity: '12X', price: '5.000'),
      MenuItems(name: 'NASI GORENG', quantity: '1X', price: '11.000'),
    ],
  ),
  Person(
    name: 'Hilmi',
    listMenuItems: [
      MenuItems(name: 'NASI GORENG PEDAS', quantity: '1X', price: '13.000'),
      MenuItems(name: 'ICE LEMON TEA', quantity: '1X', price: '5.000'),
      MenuItems(name: 'NASI GORENG', quantity: '1X', price: '11.000'),
    ],
  ),
];
