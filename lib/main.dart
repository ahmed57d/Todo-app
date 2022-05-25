import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:todoapp/layout/home_layout.dart';
import 'package:todoapp/shared/bloc_observer.dart';

void main()
{
  BlocOverrides.runZoned(
        () {
          runApp(MyApp());
    },
    blocObserver: MyBlocObserver(),
  );

}

// Stateless
// Stateful

// class MyApp

class MyApp extends StatelessWidget
{
  // constructor
  // build

  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeLayout(),
    );
  }
}