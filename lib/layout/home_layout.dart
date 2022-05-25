import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapp/components/components.dart';
import 'package:todoapp/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:todoapp/modules/done_tasks/done_tasks_screen.dart';
import 'package:todoapp/modules/new_tasks/new_tasks_screen.dart';
import 'package:todoapp/shared/cubit/states.dart';
import 'package:bloc/bloc.dart';
import '../components/constants.dart';
import '../shared/cubit/cubit.dart';

class HomeLayout extends StatelessWidget  {


  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formkey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (BuildContext context, AppStates state){
          if (state is AppInsertDatabaseState)
          {
            Navigator.pop(context);
          }
        },
        builder: (BuildContext context, AppStates state){
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            title: Text(
              cubit.titles[cubit.currentindex],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (cubit.isBottomSheetShown) {
                if(formkey.currentState!.validate())
                {
                  cubit.insertToDatabase(title: titleController.text, time: timeController.text, date: dateController.text);
                  /*insertToDatabase(
                    title: titleController.text,
                    date: dateController.text,
                    time: timeController.text,
                  ).then((value)
                  {
                    getDataFromDatabase(database).then((value)
                    {
                      Navigator.pop(context);
                      // setState(() {
                      //   isBottomSheetShown = false;
                      //   fabIcon = Icons.edit;
                      //   tasks = value;
                      // });

                    });
                  }
                  );*/

                }

              }

              else {
                scaffoldKey.currentState?.showBottomSheet((context) => Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(10.0),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Form(
                      key: formkey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          defaultFormField(
                              onTap: (){},
                              controller: titleController,
                              type: TextInputType.text,
                              validate: (String value) {
                                if (value.isEmpty) {
                                  return 'title cannot be empty';
                                }
                                return null;
                              },
                              Label: 'Task title',
                              prefix: Icons.title),
                          SizedBox(
                            height: 15.0,
                          ),
                          defaultFormField(
                              controller: timeController,
                              type: TextInputType.datetime,
                              onTap: ()
                              {
                                showTimePicker(context: context,
                                    initialTime: TimeOfDay.now()
                                ).then((value) {
                                  timeController.text = value!.format(context).toString();
                                  print(value.format(context));
                                });

                              },
                              validate: (String value) {
                                if (value.isEmpty) {
                                  return 'Time cannot be empty';
                                }
                                return null;
                              },
                              Label: 'Task Time',
                              prefix: Icons.watch_later_outlined),
                          SizedBox(
                            height: 15.0,
                          ),
                          defaultFormField(
                              controller: dateController,
                              type: TextInputType.datetime,
                              onTap: ()
                              {
                                showDatePicker(context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.parse('2090-06-01'),
                                ).then((value)
                                {
                                  print(DateFormat.yMMMd().format(value!));
                                  dateController.text = DateFormat.yMMMd().format(value);
                                });

                              },
                              validate: (String value) {
                                if (value.isEmpty) {
                                  return 'Date cannot be empty';
                                }
                                return null;
                              },
                              Label: 'Task Date',
                              prefix: Icons.calendar_today)
                        ],
                      ),
                    ),
                  ),
                ),
                  elevation: 30.0,
                ).closed.then((value) {
                  cubit.changeButtonSheetState(isShow: false, icon: Icons.edit);
                }
                );
                cubit.changeButtonSheetState(isShow: true, icon: Icons.add);

              }
            },
            child: Icon(cubit.fabIcon),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: cubit.currentindex,
            onTap: (index) {
              cubit.changeIndex(index);

            },
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Tasks'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.check_circle_outline), label: 'Done'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.archive_outlined), label: 'Archived'),
            ],
          ),
          body: ConditionalBuilder(
            condition: state is! AppGetDatabaseLoadingState,
            builder: (context) => cubit.screens[cubit.currentindex] ,
            fallback: (context) => Center(child: CircularProgressIndicator()),
          ),
        );
          },
      ),
    );
  }

  /*Future<String> getName() async {
    return 'Ahmed Ali';
  }*/


}