import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:analytics_services/analytics_services.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:remote_data/remote_data.dart';
import 'package:repository/repository.dart';
import 'package:repository/src/mappers/mappers.dart';
import 'package:sqflite/sqflite.dart';
import 'package:storage/storage.dart';

part 'repository_auth.dart';
part 'repository_data_sync.dart';
part 'repository_favorites.dart';
part 'repository_preferences.dart';
part 'repository_queries.dart';
part 'repository_user_actions.dart';
part 'repository_data_sync_optimized.dart';
part 'repository_announcements.dart';
part 'repository_user_notifications.dart';
part 'repository_user_settings.dart';

/// Repository - Core functionality
///
/// Operations are organized into extensions:
/// - [RepositoryDataSync] - Data synchronization operations
/// - [RepositoryQueries] - Database query operations
/// - [RepositoryPreferences] - Preferences and settings operations
/// - [RepositoryFavorites] - Favorites management operations
/// - [RepositoryUserActions] - User action operations (reviews, feedback, reports)
/// - [RepositoryAuth] - Authentication operations
/// - [RepositoryAnnouncements] - Announcement operations
/// - [RepositoryUserNotifications] - In-app user notification APIs
/// - [RepositoryUserSettings] - User-level account settings APIs
class Repository {
  Repository(
    this._networkService,
    this._appDatabase,
    this._appPreferences,
    this._analyticsService,
    this._firebaseConfigDataSource,
  );

  final NetworkService _networkService;
  final AppDatabase _appDatabase;
  final AppPreferences _appPreferences;
  final IAnalyticsService _analyticsService;
  final FirebaseConfigDataSource _firebaseConfigDataSource;
}
