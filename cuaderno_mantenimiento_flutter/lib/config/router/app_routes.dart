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

import 'package:go_router/go_router.dart';



final GoRouter appRouter = GoRouter(
  initialLocation: '/splash', // 👈 esto lanza el Splash al arrancar
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
      builder: (context, state) => const ClientManagementScreen(),
    ),
   
    GoRoute(
      path: '/admin/clients/:clientId/cars',
      name: 'car-list',
      builder: (context, state) {
        final clientId = state.pathParameters['clientId']!;
        return ClientCarsScreen(clientId: clientId);
      },
    ),
    GoRoute(
      path: '/intervention/:carId',
      name: 'interventionScreen',
      builder: (context, state) {
        final carId = state.pathParameters['carId']!;
        return InterventionManagementScreen(carId: carId);
      },
    ),
    GoRoute(
      path: '/intervention-details/:carId/:interventionId',
      name: 'interventionDetails',
      builder: (context, state) {
        final carId = state.pathParameters['carId']!;
        final interventionId = state.pathParameters['interventionId']!;
        return CreateInterventionScreen(carId: carId, interventionId: interventionId);
      },
    ),

  
  ],
);

