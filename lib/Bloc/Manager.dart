import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter_windows/Bloc/States.dart';
import 'package:gms_flutter_windows/Models/AboutUsModel.dart';
import 'package:gms_flutter_windows/Models/ArticleModel.dart';
import 'package:gms_flutter_windows/Models/AttendanceModel.dart';
import 'package:gms_flutter_windows/Models/ClassModel.dart';
import 'package:gms_flutter_windows/Models/DietPlanModel.dart';
import 'package:gms_flutter_windows/Models/EventModel.dart';
import 'package:gms_flutter_windows/Models/FAQModel.dart';
import 'package:gms_flutter_windows/Models/LoginModel.dart';
import 'package:gms_flutter_windows/Models/MealModel.dart';
import 'package:gms_flutter_windows/Models/PrivateCoachModel.dart';
import 'package:gms_flutter_windows/Models/ProgramModel.dart';
import 'package:gms_flutter_windows/Models/SessionModel.dart';
import 'package:gms_flutter_windows/Models/SubscribersModel.dart';
import 'package:gms_flutter_windows/Models/SubscriptionModel.dart';
import 'package:gms_flutter_windows/Models/UserModel.dart';
import 'package:gms_flutter_windows/Models/WorkoutModel.dart';
import 'package:gms_flutter_windows/Modules/Base.dart';
import 'package:gms_flutter_windows/Modules/Login.dart';
import 'package:gms_flutter_windows/Remote/Dio_Linker.dart';
import 'package:gms_flutter_windows/Remote/End_Points.dart';
import 'package:gms_flutter_windows/Shared/Components.dart';
import 'package:gms_flutter_windows/Shared/SecureStorage.dart';
import 'package:gms_flutter_windows/main.dart';

class Manager extends Cubit<BlocStates> {
  Manager() : super(InitialState());
  final int paginationSize = 5;

  static Manager get(BuildContext context) => BlocProvider.of(context);

  void emitNewState() {
    emit(UpdateNewState());
  }

  void login(Map<String, dynamic> data) {
    emit(LoadingState());
    Dio_Linker.postData(url: LOGIN, data: data)
        .then((value) async {
          var loginModel = LoginModel.fromJson(value.data['message']);
          // save some data
          await TokenStorage.writeFullName(
            '${loginModel.user.firstName} ${loginModel.user.lastName}',
          );
          await TokenStorage.writeAccessToken(loginModel.accessToken);
          await TokenStorage.writeRefreshToken(loginModel.refreshToken);
          emit(SuccessState());
          // navigate
          MyApp.navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(builder: (_) => AdminDashboard()),
          );
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  String handleDioError(dynamic error) {
    if (error is DioException) {
      // Timeouts
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'Request timeout, try again';
      }
      final response = error.response;
      if (response != null) {
        final data = response.data;
        // message: String
        if (data is Map && data['message'] != null) {
          return data['message'].toString();
        }
        if (data is Map) {
          return data.values.join('\n');
        }
        return 'Error code (${response.statusCode})';
      }
      // Network issue
      if (error.type == DioExceptionType.connectionError) {
        return 'No internet connection or server unreachable';
      }
    }
    return 'Unexpected error, try again later';
  }

  void logout() async {
    emit(LoadingState());
    await Dio_Linker.postData(url: LOGOUT)
        .then((value) async {
          emit(SuccessState());
          performLogout();
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void performLogout() async {
    await TokenStorage.deleteAccessToken();
    await TokenStorage.deleteRefreshToken();
    Future.delayed(Duration(milliseconds: 50), () {
      final navigator = MyApp.navigatorKey.currentState;
      if (navigator != null) {
        Components.showSnackBar(
          navigator.context,
          'Your session expired. Please log in again to continue.',
        );
        // navigate
        navigator.pushReplacement(MaterialPageRoute(builder: (_) => Login()));
      }
    });
  }

  GetUsersModel users = GetUsersModel(
    count: 0,
    totalPages: 1,
    currentPage: 0,
    items: [],
  );
  bool isLoading = false;

  void getUsers(String role, int page) {
    if (isLoading) return;
    isLoading = true;
    emit(LoadingState());
    Dio_Linker.getData(
          url: GETUSERS,
          params: {'role': role, 'page': page, 'size': paginationSize},
        )
        .then((value) {
          users = GetUsersModel.fromJson(value.data['message']);
          emit(SuccessState());
          isLoading = false;
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
          isLoading = false;
        });
  }

  Future<String> createUser(Map<String, dynamic> data) async {
    emit(LoadingState());
    return Dio_Linker.postData(url: CREATEUSER, data: data)
        .then((value) {
          emit(SuccessState());
          return value.data['message']['password'] as String;
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
          return '-';
        });
  }

  void updateUser(
    Map<String, dynamic> data,
    int userId,
    String role,
    int page,
  ) {
    emit(LoadingState());
    Dio_Linker.putData(url: UPDATEUSER + userId.toString(), data: data)
        .then((value) {
          getUsers(role, page);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'user Updated',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  GetClassesModel classes = GetClassesModel(
    count: 0,
    totalPages: 1,
    currentPage: 0,
    items: [],
  );

  Future<void> getClasses(int page) async {
    if (isLoading) return;
    isLoading = true;
    emit(LoadingState());
    return Dio_Linker.getData(
          url: GETCLASSES,
          params: {'page': page, 'size': paginationSize},
        )
        .then((value) {
          isLoading = false;
          classes = GetClassesModel.fromJson(value.data['message']);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
          isLoading = false;
        });
  }

  // reference Data (Coaches)
  GetUsersModel coaches = GetUsersModel(
    count: 0,
    totalPages: 1,
    currentPage: 0,
    items: [],
  );
  bool isBaseLoading = false;

  void getCoaches() {
    if (isBaseLoading) return;
    isBaseLoading = true;
    emit(LoadingState());
    Dio_Linker.getData(url: GETUSERS, params: {'role': 'Coach'})
        .then((value) {
          isBaseLoading = false;
          coaches = GetUsersModel.fromJson(value.data['message']);
          emit(SuccessState());
        })
        .catchError((error) {
          isBaseLoading = false;
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  GetProgramsModel allPrograms = GetProgramsModel(
    count: 0,
    totalPages: 1,
    currentPage: 0,
    items: [],
  );

  void getAllPrograms() {
    if (isBaseLoading) return;
    isBaseLoading = true;
    emit(LoadingState());
    Dio_Linker.getData(url: GETALLPROGRAMS)
        .then((value) {
          isBaseLoading = false;
          allPrograms = GetProgramsModel.fromJson(value.data['message']);
          emit(SuccessState());
        })
        .catchError((error) {
          isBaseLoading = false;
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  GetWorkoutsModel allWorkouts = GetWorkoutsModel(
    count: 0,
    totalPages: 1,
    currentPage: 0,
    items: [],
  );

  void getAllWorkouts() {
    if (isBaseLoading) return;
    isBaseLoading = true;
    emit(LoadingState());
    Dio_Linker.getData(url: GETALLWORKOUTS)
        .then((value) {
          isBaseLoading = false;
          allWorkouts = GetWorkoutsModel.fromJson(value.data['message']);
          emit(SuccessState());
        })
        .catchError((error) {
          isBaseLoading = false;
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  GetClassesModel allClasses = GetClassesModel(
    count: 0,
    totalPages: 1,
    currentPage: 0,
    items: [],
  );

  void getAllClasses() {
    if (isBaseLoading) return;
    isBaseLoading = true;
    emit(LoadingState());
    Dio_Linker.getData(url: GETCLASSES)
        .then((value) {
          isBaseLoading = false;
          allClasses = GetClassesModel.fromJson(value.data['message']);
          emit(SuccessState());
        })
        .catchError((error) {
          isBaseLoading = false;
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  GetMealsModel allMeals = GetMealsModel(
    count: 0,
    totalPages: 1,
    currentPage: 0,
    meals: [],
  );

  void getAllMeals() {
    if (isBaseLoading) return;
    isBaseLoading = true;
    emit(LoadingState());
    Dio_Linker.getData(url: GETMEALS)
        .then((value) {
          isBaseLoading = false;
          allMeals = GetMealsModel.fromJson(value.data['message']);
          emit(SuccessState());
        })
        .catchError((error) {
          isBaseLoading = false;
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  GetUsersModel allUsers = GetUsersModel(
    count: 0,
    totalPages: 1,
    currentPage: 0,
    items: [],
  );

  Future<void> getAllUsers() async {
    if (isBaseLoading) return;
    isBaseLoading = true;
    emit(LoadingState());
    return Dio_Linker.getData(url: GETUSERS, params: {'role': 'User'})
        .then((value) {
          isBaseLoading = false;
          allUsers = GetUsersModel.fromJson(value.data['message']);
          emit(SuccessState());
        })
        .catchError((error) {
          isBaseLoading = false;
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  // done

  void createClass(FormData data) async {
    emit(LoadingState());
    Dio_Linker.postData(url: CREATECLASS, data: data)
        .then((value) {
          getClasses(0);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'class created',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void updateClass(Map<String, dynamic> data, int classId, int page) {
    emit(LoadingState());
    Dio_Linker.putData(url: UPDATECLASS + classId.toString(), data: data)
        .then((value) {
          getClasses(page);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'class Updated',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void unAssignProgram(Map<String, dynamic> data, int page) {
    emit(LoadingState());
    Dio_Linker.postData(url: UNASSIGNPROGRAM, data: data)
        .then((value) {
          getClasses(page);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'program Un-Assigned',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void assignProgram(Map<String, dynamic> data, int page) {
    emit(LoadingState());
    Dio_Linker.postData(url: ASSIGNPROGRAM, data: data)
        .then((value) {
          getClasses(page);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'program Assigned',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  GetProgramsModel programs = GetProgramsModel(
    count: 0,
    totalPages: 1,
    currentPage: 0,
    items: [],
  );

  Future<void> getPrograms(int page) async {
    if (isLoading) return;
    isLoading = true;
    emit(LoadingState());
    return Dio_Linker.getData(
          url: GETALLPROGRAMS,
          params: {'page': page, 'size': paginationSize},
        )
        .then((value) {
          isLoading = false;
          programs = GetProgramsModel.fromJson(value.data['message']);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
          isLoading = false;
        });
  }

  void createProgram(Map<String, dynamic> data) async {
    emit(LoadingState());
    Dio_Linker.postData(url: CREATEPROGRAM, data: data)
        .then((value) {
          getPrograms(0);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'program created',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void updateProgram(Map<String, dynamic> data, int programId, int page) {
    emit(LoadingState());
    Dio_Linker.putData(url: UPDATEPROGRAM + programId.toString(), data: data)
        .then((value) {
          getPrograms(page);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'program Updated',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void assignWorkout(Map<String, dynamic> data) {
    emit(LoadingState());
    Dio_Linker.postData(url: ASSIGNWORKOUT, data: data)
        .then((value) {
          getPrograms(0);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'workout Assigned',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void unAssignWorkout(Map<String, dynamic> data, int page) {
    emit(LoadingState());
    Dio_Linker.postData(url: UNASSIGNWORKOUT, data: data)
        .then((value) {
          getPrograms(page);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'workout Un-Assigned',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void updateAssignedWorkout(Map<String, dynamic> data, int page) {
    emit(LoadingState());
    Dio_Linker.postData(url: UPDATEASSIGNEDWORKOUT, data: data)
        .then((value) {
          getPrograms(page);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'assigned Updated',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  GetSessionsModel sessions = GetSessionsModel(
    count: 0,
    totalPages: 1,
    currentPage: 0,
    items: [],
  );

  Future<void> getSessions(int page) async {
    if (isLoading) return;
    isLoading = true;
    emit(LoadingState());
    return Dio_Linker.getData(
          url: GETALLSESSIONS,
          params: {'page': page, 'size': paginationSize},
        )
        .then((value) {
          isLoading = false;
          sessions = GetSessionsModel.fromJson(value.data['message']);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
          isLoading = false;
        });
  }

  void createSession(Map<String, dynamic> data) async {
    emit(LoadingState());
    Dio_Linker.postData(url: CREATESESSION, data: data)
        .then((value) {
          getSessions(0);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'session created',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void updateSession(Map<String, dynamic> data, int sessionId, int page) {
    emit(LoadingState());
    Dio_Linker.putData(url: UPDATESESSION + sessionId.toString(), data: data)
        .then((value) {
          getSessions(page);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'session Updated',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  GetEventsModel events = GetEventsModel(
    count: 0,
    totalPages: 1,
    currentPage: 0,
    items: [],
  );

  void getEvents(int page) async {
    if (isLoading) return;
    isLoading = true;
    emit(LoadingState());
    Dio_Linker.getData(
          url: GETALLEVENTS,
          params: {'page': page, 'size': paginationSize},
        )
        .then((value) {
          isLoading = false;
          events = GetEventsModel.fromJson(value.data['message']);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
          isLoading = false;
        });
  }

  void createEvent(FormData data) async {
    emit(LoadingState());
    Dio_Linker.postData(url: CREATEEVENT, data: data)
        .then((value) {
          getEvents(0);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'event created',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void updateEvent(FormData data, int eventId, int page) {
    emit(LoadingState());
    Dio_Linker.putData(url: UPDATEEVENT + eventId.toString(), data: data)
        .then((value) {
          getEvents(page);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'event Updated',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void createPrize(Map<String, dynamic> data) async {
    emit(LoadingState());
    Dio_Linker.postData(url: CREATEPRIZE, data: data)
        .then((value) {
          getEvents(0);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'prize created',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void deletePrize(int id) async {
    emit(LoadingState());
    Dio_Linker.deleteData(url: DELETEPRIZE + id.toString())
        .then((value) {
          getEvents(0);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'prize deleted',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void editUserScore(Map<String, dynamic> data) async {
    emit(LoadingState());
    Dio_Linker.putData(url: EDITUSERSCORE, data: data)
        .then((value) {
          getEvents(0);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'score updated',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  GetArticlesModel articles = GetArticlesModel(
    count: 0,
    totalPages: 1,
    currentPage: 0,
    items: [],
  );

  void getArticles(int page, String wikiType) async {
    if (isLoading) return;
    isLoading = true;
    emit(LoadingState());
    Dio_Linker.getData(
          url: GETARTICLES,
          params: {'page': page, 'size': paginationSize, 'wiki': wikiType},
        )
        .then((value) {
          isLoading = false;
          articles = GetArticlesModel.fromJson(value.data['message']);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
          isLoading = false;
        });
  }

  void createArticle(Map<String, dynamic> data) async {
    emit(LoadingState());
    Dio_Linker.postData(url: CREATEARTICLE, data: data)
        .then((value) {
          getArticles(0, 'All');
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'article created',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void updateArticle(
    Map<String, dynamic> data,
    int articleId,
    int page,
    String type,
  ) {
    emit(LoadingState());
    Dio_Linker.putData(url: EDITARTICLE + articleId.toString(), data: data)
        .then((value) {
          getArticles(page, type);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'article Updated',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  GetWorkoutsModel workouts = GetWorkoutsModel(
    count: 0,
    totalPages: 1,
    currentPage: 0,
    items: [],
  );

  void getWorkouts(int page, String muscle) async {
    if (isLoading) return;
    isLoading = true;
    emit(LoadingState());
    Dio_Linker.getData(
          url: GETALLWORKOUTS,
          params: {'page': page, 'size': paginationSize, 'muscle': muscle},
        )
        .then((value) {
          isLoading = false;
          workouts = GetWorkoutsModel.fromJson(value.data['message']);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
          isLoading = false;
        });
  }

  void createWorkout(FormData data) async {
    emit(LoadingState());
    Dio_Linker.postData(url: CREATEWORKOUT, data: data)
        .then((value) {
          getWorkouts(0, 'All');
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'workout created',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void updateWorkout(FormData data, int workoutId, int page, String type) {
    emit(LoadingState());
    Dio_Linker.putData(url: UPDATEWORKOUT + workoutId.toString(), data: data)
        .then((value) {
          getWorkouts(page, type);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'workout Updated',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  GetMealsModel meals = GetMealsModel(
    count: 0,
    totalPages: 1,
    currentPage: 0,
    meals: [],
  );

  void getMeals(int page) async {
    if (isLoading) return;
    isLoading = true;
    emit(LoadingState());
    Dio_Linker.getData(
          url: GETMEALS,
          params: {'page': page, 'size': paginationSize},
        )
        .then((value) {
          isLoading = false;
          meals = GetMealsModel.fromJson(value.data['message']);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
          isLoading = false;
        });
  }

  void createMeal(FormData data) async {
    emit(LoadingState());
    Dio_Linker.postData(url: CREATEMEAL, data: data)
        .then((value) {
          getMeals(0);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'meal created',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void updateMeal(FormData data, int mealId, int page) {
    emit(LoadingState());
    Dio_Linker.putData(url: UPDATEMEAL + mealId.toString(), data: data)
        .then((value) {
          getMeals(page);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'meal Updated',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  GetDietPlansModel dietPlans = GetDietPlansModel(
    count: 0,
    totalPages: 1,
    currentPage: 0,
    items: [],
  );

  Future<void> getDietPlans(int page) async {
    if (isLoading) return;
    isLoading = true;
    emit(LoadingState());
    return Dio_Linker.getData(
          url: GETDIETPLANS,
          params: {'page': page, 'size': paginationSize},
        )
        .then((value) {
          isLoading = false;
          dietPlans = GetDietPlansModel.fromJson(value.data['message']);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
          isLoading = false;
        });
  }

  void createDietPlan(Map<String, dynamic> data) async {
    emit(LoadingState());
    Dio_Linker.postData(url: CREATEDIETPLAN, data: data)
        .then((value) {
          getDietPlans(0);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'dietPlan created',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void updateDietPlan(Map<String, dynamic> data, int dietPlan, int page) {
    emit(LoadingState());
    Dio_Linker.putData(url: UPDATEDIETPLAN + dietPlan.toString(), data: data)
        .then((value) {
          getDietPlans(page);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'dietPlan Updated',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void assignMeal(Map<String, dynamic> data, int page) {
    emit(LoadingState());
    Dio_Linker.postData(url: ASSIGNMEALTODIET, data: data)
        .then((value) {
          getDietPlans(page);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'meal Assigned',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void unAssignMeal(Map<String, dynamic> data, int page) {
    emit(LoadingState());
    Dio_Linker.deleteData(url: UNASSIGNMEALFROMDIET, data: data)
        .then((value) {
          getDietPlans(page);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'meal Un-Assigned',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void updateAssignedMeal(Map<String, dynamic> data, int page) {
    emit(LoadingState());
    Dio_Linker.postData(url: UPDATEASSIGNEDMEAL, data: data)
        .then((value) {
          getDietPlans(page);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'assigned Updated',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void assignUserToClass(Map<String, dynamic> data) {
    emit(LoadingState());
    Dio_Linker.postData(url: ASSIGNUSERTOCLASS, data: data)
        .then((value) {
          emit(SuccessState());
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'user Subscribed',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void inActiveUserInClass(Map<String, dynamic> data) {
    emit(LoadingState());
    Dio_Linker.putData(url: INACTIVEUSERINCLASS, data: data)
        .then((value) {
          emit(SuccessState());
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'user inActivated',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  SubscribersModel? subscribersModel;

  Future<void> getClassSubscribers(int classId) {
    emit(LoadingState());
    return Dio_Linker.getData(url: GETCLASSASSIGNMENT + classId.toString())
        .then((value) {
          subscribersModel = SubscribersModel.fromJson(value.data);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void assignProgramToUser(Map<String, dynamic> data) {
    emit(LoadingState());
    Dio_Linker.postData(url: ASSIGNPROGRAMTOUSER, data: data)
        .then((value) {
          emit(SuccessState());
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'program Assigned to User',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  Future<void> getProgramSubscribers(int programId) {
    emit(LoadingState());
    return Dio_Linker.getData(url: GETPROGRAMASSIGNMENT + programId.toString())
        .then((value) {
          subscribersModel = SubscribersModel.fromJson(value.data);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void unAssignProgramFromUser(Map<String, dynamic> data) {
    emit(LoadingState());
    Dio_Linker.deleteData(url: UNASSIGNPROGRAMTOUSER, data: data)
        .then((value) {
          emit(SuccessState());
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'program unAssigned from User',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  Future<void> getSessionSubscribers(int sessionId) {
    emit(LoadingState());
    return Dio_Linker.getData(url: GETSESSIONASSIGNMENT + sessionId.toString())
        .then((value) {
          subscribersModel = SubscribersModel.fromJson(value.data);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void assignSessionToUser(Map<String, dynamic> data) {
    emit(LoadingState());
    Dio_Linker.postData(url: ASSIGNSESSIONTOUSER, data: data)
        .then((value) {
          emit(SuccessState());
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'session Assigned to User',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void unAssignSessionFromUser(Map<String, dynamic> data) {
    emit(LoadingState());
    Dio_Linker.deleteData(url: UNASSIGNSESSIONTOUSER, data: data)
        .then((value) {
          emit(SuccessState());
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'session unAssigned from User',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  Future<void> getDietSubscribers(int dietId) {
    emit(LoadingState());
    return Dio_Linker.getData(url: GETDIETASSIGNMENT + dietId.toString())
        .then((value) {
          subscribersModel = SubscribersModel.fromJson(value.data);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void assignDietToUser(Map<String, dynamic> data) {
    emit(LoadingState());
    Dio_Linker.postData(url: ASSIGNDIETTOUSER, data: data)
        .then((value) {
          emit(SuccessState());
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'diet Plan Assigned to User',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void unAssignDietFromUser(Map<String, dynamic> data) {
    emit(LoadingState());
    Dio_Linker.deleteData(url: UNASSIGNDIETTOUSER, data: data)
        .then((value) {
          emit(SuccessState());
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'diet Plan unAssigned from User',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  Future<List<String>> getAllClassesForUser(int userId) async {
    emit(LoadingState());
    try {
      final value = await Dio_Linker.getData(
        url: GETUSERCLASSES + userId.toString(),
      );
      final result = (value.data as List)
          .map((e) => e['name'] as String)
          .toList();
      emit(SuccessState());
      return result;
    } catch (error) {
      final errorMessage = handleDioError(error);
      emit(ErrorState(errorMessage));
      return [];
    }
  }

  Future<List<String>> getAllSessionsForUser(int userId) async {
    emit(LoadingState());
    try {
      final value = await Dio_Linker.getData(
        url: GETUSERSESSIONS + userId.toString(),
      );
      final result = (value.data as List)
          .map((e) => e['title'] as String)
          .toList();
      emit(SuccessState());
      return result;
    } catch (error) {
      final errorMessage = handleDioError(error);
      emit(ErrorState(errorMessage));
      return [];
    }
  }

  Future<List<String>> getAllProgramsForUser(int userId) async {
    emit(LoadingState());
    try {
      final value = await Dio_Linker.getData(
        url: GETUSERPROGRAMS + userId.toString(),
      );
      final result = (value.data as List)
          .map((e) => e['name'] as String)
          .toList();
      emit(SuccessState());
      return result;
    } catch (error) {
      final errorMessage = handleDioError(error);
      emit(ErrorState(errorMessage));
      return [];
    }
  }

  Future<List<String>> getAllDietsForUser(int userId) async {
    emit(LoadingState());
    try {
      final value = await Dio_Linker.getData(
        url: GETUSERDIETS + userId.toString(),
      );
      final result = (value.data as List)
          .map((e) => e['title'] as String)
          .toList();
      emit(SuccessState());
      return result;
    } catch (error) {
      final errorMessage = handleDioError(error);
      emit(ErrorState(errorMessage));
      return [];
    }
  }

  AboutUsModel? gymInfo;

  Future<void> getAboutUs() async {
    emit(LoadingState());
    Dio_Linker.getData(url: GETABOUTUS)
        .then((value) {
          gymInfo = AboutUsModel.fromJson(value.data['message']);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  List<FAQModel> faqs = [];

  Future<void> getFaqs() async {
    emit(LoadingState());
    Dio_Linker.getData(url: GETFAQ)
        .then((value) {
          faqs = FAQModel.parseList(value.data);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  Future<void> createFaq(Map<String, dynamic> data) async {
    emit(LoadingState());
    await Dio_Linker.postData(url: CREATEFAQ, data: data)
        .then((value) {
          getFaqs();
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'FAQ added',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  Future<void> updateFaq(Map<String, dynamic> data, int faqId) async {
    emit(LoadingState());
    await Dio_Linker.putData(url: UPDATEFAQ + faqId.toString(), data: data)
        .then((value) {
          getFaqs();
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'FAQ updated',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  Future<void> deleteFaq(int faqId) async {
    emit(LoadingState());
    await Dio_Linker.postData(url: DELETEFAQ + faqId.toString())
        .then((value) {
          getFaqs();
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'FAQ deleted',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  Future<void> updateAboutUs(Map<String, dynamic> data) async {
    emit(LoadingState());
    await Dio_Linker.putData(url: UPADTEABOUTUS, data: data)
        .then((value) {
          getAboutUs();
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'About-us data updated',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void assignCoachToUser(Map<String, dynamic> data) async {
    emit(LoadingState());
    await Dio_Linker.postData(url: ASSIGNCOACHTOUSER, data: data)
        .then((value) {
          getUserCoaches(data['userId']);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'coach Assigned to user',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void unAssignCoachFromUser(Map<String, dynamic> data) async {
    emit(LoadingState());
    await Dio_Linker.postData(url: UNASSIGNCOACHFROMUSER, data: data)
        .then((value) {
          getUserCoaches(data['userId']);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'coach unAssigned from user',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  List<UserPrivateCoachModel> userPrivateCoaches = [];

  void getUserCoaches(int userId) async {
    emit(LoadingState());
    await Dio_Linker.getData(url: GETUSERCOACHES + userId.toString())
        .then((value) {
          userPrivateCoaches = UserPrivateCoachModel.parseList(
            value.data['message'],
          );
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  List<UserPrivateCoachModel> coachUsers = [];

  void getCoachUsers(int coachId) async {
    emit(LoadingState());
    await Dio_Linker.getData(url: GETCOACHUSERS + coachId.toString())
        .then((value) {
          coachUsers = UserPrivateCoachModel.parseList(value.data['message']);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  List<AttendanceModel> attendanceList = [];

  Future<void> getAllAttendance(String start, String end) async {
    emit(LoadingState());
    await Dio_Linker.getData(
          url: GETALLATTENDANCEBYRANGE,
          params: {'start': start, 'end': end},
        )
        .then((value) {
          attendanceList = AttendanceModel.listFromJson(value.data['message']);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  List<DateTime> userAttendanceDates = [];

  Future<void> getUserAttendance(int userId, String start, String end) async {
    emit(LoadingState());
    await Dio_Linker.getData(
          url: GETUSERATTENDANCEBYRANGE + userId.toString(),
          params: {'start': start, 'end': end},
        )
        .then((value) {
          userAttendanceDates = (value.data['message'] as List)
              .map((e) => DateTime.parse(e))
              .toList();
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  List<SubscriptionModel> userSubscriptions = [];

  Future<void> getUserSubscriptionsHistory(int userId) async {
    emit(LoadingState());
    await Dio_Linker.getData(url: GETUSERSUBSCRIPTIONS + userId.toString())
        .then((value) {
          userSubscriptions = SubscriptionModel.parseList(
            value.data['message'],
          );
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  Future<void> updateUserSubscription(Map<String, dynamic> data) async {
    emit(LoadingState());
    await Dio_Linker.postData(url: UPDATEUSERSUBSCRIPTION, data: data)
        .then((value) {
          getUserSubscriptionsHistory(data['userId']);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'subscription Updated',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  List<UserModel> expiredSubscriptions = [];

  Future<void> getPendingPaymentsByClassId(int classId) async {
    emit(LoadingState());
    await Dio_Linker.getData(url: GETEXPIREDSUBSCRIPTIONS + classId.toString())
        .then((value) {
          expiredSubscriptions = UserModel.parseList(value.data['message']);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  Future<void> updateWorkoutImage(
    FormData data,
    int page,
    String muscle,
  ) async {
    emit(LoadingState());
    await Dio_Linker.putData(url: UPLOADWORKOUTIMAGE, data: data)
        .then((value) {
          getWorkouts(page, muscle);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'image Updated',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  Future<void> updateMealImage(FormData data, int page) async {
    emit(LoadingState());
    await Dio_Linker.putData(url: UPLOADMEALIMAGE, data: data)
        .then((value) {
          getMeals(page);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'image Updated',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  Future<void> updateEventImage(FormData data, int page) async {
    emit(LoadingState());
    await Dio_Linker.putData(url: UPLOADEVENTIMAGE, data: data)
        .then((value) {
          getEvents(page);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'image Updated',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  Future<void> updateClassImage(FormData data, int page) async {
    emit(LoadingState());
    await Dio_Linker.putData(url: UPLOADCLASSIMAGE, data: data)
        .then((value) {
          getClasses(page);
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            Components.showSnackBar(
              navigator.context,
              'image Updated',
              color: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }
}
