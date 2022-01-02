// required package imports
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:flutter_app/person_dao.dart';
import 'package:flutter_app/person_entity.dart';

/*
* Run command: 'flutter packages pub run build_runner build'
* This command will create $FloorAppDatabase and database.g.dart file.
* */
part 'database.g.dart';

@Database(version: 1, entities: [Person])
abstract class AppDatabase extends FloorDatabase {
  PersonDao get personDao;
}