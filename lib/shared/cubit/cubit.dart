

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapp/shared/cubit/states.dart';

import '../../modules/archived_tasks/archived_tasks_screen.dart';
import '../../modules/done_tasks/done_tasks_screen.dart';
import '../../modules/new_tasks/new_tasks_screen.dart';

class AppCubit extends Cubit<AppStates>

{

  AppCubit(): super(AppInitialStates());
  static AppCubit get(context) => BlocProvider.of(context);
  int currentindex = 0;
  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];
  List<String> titles = [
    'Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];
void changeIndex(int index)
{
  currentindex = index;
  emit(AppChangeBottomNavBarState());
}
  late Database database;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];
  void createDatabase()  {
     openDatabase(
      'todo.db',
      version: 1,
      onCreate: (databse, version) {
        print('database created');
        databse
            .execute(
            'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT,time TEXT, status TEXT)')
            .then((value) {
          print('table created');
        }).catchError((error) {
          print('Error when creating table ${error.toString()}');
        });
      },
      onOpen: (database) {
        getDataFromDatabase(database);
        print('database opened');
      },
    ).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
     });
  }

   insertToDatabase(
      {
        required String title,
        required String time,
        required String date,
      }
      ) async
  {
     await database.transaction((txn) async {
      await txn
          .rawInsert(
          'INSERT INTO tasks(title, date, time, status) VALUES("$title","$date","$time","new")')
          .then((value) {})
          .catchError((error) {
        print('Error when creating new record ${error.toString()}');
      });
      print('$Future.value() inserted successfully');
      emit(AppInsertDatabaseState());
      getDataFromDatabase(database);
    });
  }
  void getDataFromDatabase(database)
  {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    emit(AppGetDatabaseLoadingState());
     database.rawQuery('SELECT * FROM tasks').then((value)
     {

       value.forEach((element) {
         if (element['status'] == 'new')
           newTasks.add(element);
            if (element['status'] == 'done')
           doneTasks.add(element);
            if (element['status'] == 'archive')
              archivedTasks.add(element);

       });
       emit(AppGetDatabaseState());
     });
  }

  void updateData({required String status, required int id}) async
  {
    database.rawUpdate(
        'UPDATE tasks SET status = ? WHERE id = ?',
        ['$status', id]).then((value)
    {
      getDataFromDatabase(database);
      emit(AppUpdateDatabaseState());
    });
  }

  void deleteData({required int id}) async
  {
    database.rawDelete('DELETE FROM Tasks WHERE id = ?', [id]).then((value)
    {
      getDataFromDatabase(database);
      emit(AppDeleteDatabaseState());
    });
  }

  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;

  void changeButtonSheetState(
  {
  required bool isShow,
  required IconData icon,
  }
)
  {
  isBottomSheetShown = isShow;
  fabIcon = icon;
  emit(AppChangeBottomSheetState());
  }

}
