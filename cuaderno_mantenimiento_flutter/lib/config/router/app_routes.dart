// lib/routes/app_routes.dart

import 'package:cuaderno_mantenimiento_flutter/infrastructure/models/person.dart';
import 'package:cuaderno_mantenimiento_flutter/screens/dashboards/dashboard_admin/dashboard_admin.dart';
import 'package:cuaderno_mantenimiento_flutter/screens/dashboards/dashboard_admin/sections/clients_managment/client_management_screen.dart';
import 'package:cuaderno_mantenimiento_flutter/screens/dashboards/dashboard_admin/sections/clients_managment/vehicles_managment/client_cars_screen.dart';
import 'package:cuaderno_mantenimiento_flutter/screens/dashboards/dashboard_admin/sections/clients_managment/vehicles_managment/intervention_managment/create_intervention_screen.dart';
import 'package:cuaderno_mantenimiento_flutter/screens/dashboards/dashboard_admin/sections/clients_managment/vehicles_managment/intervention_managment/intervention_managment_screen.dart';
import 'package:cuaderno_mantenimiento_flutter/screens/dashboards/dashboard_client/dashboard_client.dart';
import 'package:cuaderno_mantenimiento_flutter/screens/login_screen.dart';
import 'package:cuaderno_mantenimiento_flutter/screens/splash_screen.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';



final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/admin',
      name: 'adminDashboard',
      builder: (context, state) {
        final person = state.extra as Person;
        return AdminDashboard(person: person);
      },
    ),
    GoRoute(
      path: '/client',
      name: 'clientDashboard',
      builder: (context, state) {
        final person = state.extra as Person;
        return ClientDashboard(person: person);
      },
    ),
    GoRoute(
      path: '/admin/clients',
      name: 'clientManagement',
      builder: (context, state) {
        final person = state.extra as Person;
        return ClientManagementScreen(person: person);
      },
    ),

    GoRoute(
      path: '/admin/clients/:clientId/cars',
      name: 'car-list',
      builder: (context, state) {
        final clientId = state.pathParameters['clientId']!;
        final person = state.extra as Person;
        return ClientCarsScreen(clientId: clientId, person: person);
      },
    ),


    // ✅ RUTA para ver intervenciones de un coche
    GoRoute(
      path: '/intervention/:carId',
      name: 'interventionScreen',
      builder: (context, state) {
        final carId = state.pathParameters['carId']!;
        final extra = state.extra;
        if (extra == null || extra is! Map<String, dynamic> || !extra.containsKey('clientId')) {
          throw FlutterError('❌ clientId no proporcionado como extra.');
        }
        final clientId = extra['clientId'] as String;
        final person = extra['person'] as Person;

        return InterventionManagementScreen(
          carId: carId,
          clientId: clientId,
          person: person,
        );
      },
    ),

    // ✅ RUTA para crear detalles de intervención
    GoRoute(
      path: '/intervention-details/:carId/:interventionId',
      name: 'interventionDetails',
      builder: (context, state) {
        final carId = state.pathParameters['carId']!;
        final interventionId = state.pathParameters['interventionId']!;
        
        final extra = state.extra;
        if (extra == null || extra is! Map<String, dynamic>) {
          throw FlutterError('❌ Extra no proporcionado o inválido.');
        }

        if (!extra.containsKey('clientId') || !extra.containsKey('person')) {
          throw FlutterError('❌ clientId o person faltan en extra.');
        }

        final clientId = extra['clientId'] as String;
        final person = extra['person'] as Person;

        return CreateInterventionScreen(
          carId: carId,
          interventionId: interventionId,
          clientId: clientId,
          person: person,
          isEditMode: extra['isEditMode']  ?? false,
          
        );
      },
    ),

  ],
);
