import 'package:floor/floor.dart';
import 'package:flutter_app/person_entity.dart';

@dao
abstract class PersonDao {
  @Query('SELECT * FROM Person')
  Future<List<Person>> getAllPeople();

  @insert
  Future<void> insertPerson(Person person);

  @Query('DELETE FROM Person WHERE id = :id')
  Future<void> deleteOnePerson(int id);

  @Query('DELETE FROM Person')
  Future<void> deleteAllPerson();

  @Query('UPDATE Person SET name = :name, age = :age WHERE id = :id')
  Future<void> updatePerson(int id, String name, String age);
}