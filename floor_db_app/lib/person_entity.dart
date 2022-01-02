import 'package:floor/floor.dart';

@entity
class Person {
  @PrimaryKey(autoGenerate: true)
  int? id;
  String name;
  String age;

  Person(this.id, this.name, this.age);
}
