// This is a generated file - do not edit.
//
// Generated from api.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'api.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'api.pbenum.dart';

class GetGlobalConfigsResponse extends $pb.GeneratedMessage {
  factory GetGlobalConfigsResponse({
    $core.int? code,
    $core.String? message,
    $core.String? salt,
    $core.String? apiPath,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    if (salt != null) result.salt = salt;
    if (apiPath != null) result.apiPath = apiPath;
    return result;
  }

  GetGlobalConfigsResponse._();

  factory GetGlobalConfigsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetGlobalConfigsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetGlobalConfigsResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'salt')
    ..aOS(4, _omitFieldNames ? '' : 'apiPath')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGlobalConfigsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGlobalConfigsResponse copyWith(
          void Function(GetGlobalConfigsResponse) updates) =>
      super.copyWith((message) => updates(message as GetGlobalConfigsResponse))
          as GetGlobalConfigsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGlobalConfigsResponse create() => GetGlobalConfigsResponse._();
  @$core.override
  GetGlobalConfigsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetGlobalConfigsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetGlobalConfigsResponse>(create);
  static GetGlobalConfigsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get salt => $_getSZ(2);
  @$pb.TagNumber(3)
  set salt($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSalt() => $_has(2);
  @$pb.TagNumber(3)
  void clearSalt() => $_clearField(3);

  /// @VarName=APIPath
  @$pb.TagNumber(4)
  $core.String get apiPath => $_getSZ(3);
  @$pb.TagNumber(4)
  set apiPath($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasApiPath() => $_has(3);
  @$pb.TagNumber(4)
  void clearApiPath() => $_clearField(4);
}

class LoginRequest extends $pb.GeneratedMessage {
  factory LoginRequest({
    $core.String? userName,
    $core.String? passwd,
  }) {
    final result = create();
    if (userName != null) result.userName = userName;
    if (passwd != null) result.passwd = passwd;
    return result;
  }

  LoginRequest._();

  factory LoginRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LoginRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoginRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userName')
    ..aOS(2, _omitFieldNames ? '' : 'passwd')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoginRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoginRequest copyWith(void Function(LoginRequest) updates) =>
      super.copyWith((message) => updates(message as LoginRequest))
          as LoginRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoginRequest create() => LoginRequest._();
  @$core.override
  LoginRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LoginRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoginRequest>(create);
  static LoginRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userName => $_getSZ(0);
  @$pb.TagNumber(1)
  set userName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserName() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get passwd => $_getSZ(1);
  @$pb.TagNumber(2)
  set passwd($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPasswd() => $_has(1);
  @$pb.TagNumber(2)
  void clearPasswd() => $_clearField(2);
}

class LoginResponse extends $pb.GeneratedMessage {
  factory LoginResponse({
    $core.int? code,
    $core.String? message,
    $core.String? session,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    if (session != null) result.session = session;
    return result;
  }

  LoginResponse._();

  factory LoginResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LoginResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoginResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'session')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoginResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoginResponse copyWith(void Function(LoginResponse) updates) =>
      super.copyWith((message) => updates(message as LoginResponse))
          as LoginResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoginResponse create() => LoginResponse._();
  @$core.override
  LoginResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LoginResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoginResponse>(create);
  static LoginResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get session => $_getSZ(2);
  @$pb.TagNumber(3)
  set session($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSession() => $_has(2);
  @$pb.TagNumber(3)
  void clearSession() => $_clearField(3);
}

class AddUserRequest extends $pb.GeneratedMessage {
  factory AddUserRequest({
    $core.String? session,
    $core.String? userName,
    $core.String? sha256,
  }) {
    final result = create();
    if (session != null) result.session = session;
    if (userName != null) result.userName = userName;
    if (sha256 != null) result.sha256 = sha256;
    return result;
  }

  AddUserRequest._();

  factory AddUserRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddUserRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddUserRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'session')
    ..aOS(2, _omitFieldNames ? '' : 'userName')
    ..aOS(3, _omitFieldNames ? '' : 'sha256')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddUserRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddUserRequest copyWith(void Function(AddUserRequest) updates) =>
      super.copyWith((message) => updates(message as AddUserRequest))
          as AddUserRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddUserRequest create() => AddUserRequest._();
  @$core.override
  AddUserRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddUserRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddUserRequest>(create);
  static AddUserRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get session => $_getSZ(0);
  @$pb.TagNumber(1)
  set session($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSession() => $_has(0);
  @$pb.TagNumber(1)
  void clearSession() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userName => $_getSZ(1);
  @$pb.TagNumber(2)
  set userName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserName() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get sha256 => $_getSZ(2);
  @$pb.TagNumber(3)
  set sha256($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSha256() => $_has(2);
  @$pb.TagNumber(3)
  void clearSha256() => $_clearField(3);
}

class AddUserResponse extends $pb.GeneratedMessage {
  factory AddUserResponse({
    $core.int? code,
    $core.String? message,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    return result;
  }

  AddUserResponse._();

  factory AddUserResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddUserResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddUserResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddUserResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddUserResponse copyWith(void Function(AddUserResponse) updates) =>
      super.copyWith((message) => updates(message as AddUserResponse))
          as AddUserResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddUserResponse create() => AddUserResponse._();
  @$core.override
  AddUserResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddUserResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddUserResponse>(create);
  static AddUserResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

class ListUserRequest extends $pb.GeneratedMessage {
  factory ListUserRequest({
    $core.String? session,
  }) {
    final result = create();
    if (session != null) result.session = session;
    return result;
  }

  ListUserRequest._();

  factory ListUserRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListUserRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListUserRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'session')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUserRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUserRequest copyWith(void Function(ListUserRequest) updates) =>
      super.copyWith((message) => updates(message as ListUserRequest))
          as ListUserRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListUserRequest create() => ListUserRequest._();
  @$core.override
  ListUserRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListUserRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListUserRequest>(create);
  static ListUserRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get session => $_getSZ(0);
  @$pb.TagNumber(1)
  set session($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSession() => $_has(0);
  @$pb.TagNumber(1)
  void clearSession() => $_clearField(1);
}

class User extends $pb.GeneratedMessage {
  factory User({
    $fixnum.Int64? userId,
    $core.String? userName,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (userName != null) result.userName = userName;
    return result;
  }

  User._();

  factory User.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory User.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'User',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'userId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'userName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  User clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  User copyWith(void Function(User) updates) =>
      super.copyWith((message) => updates(message as User)) as User;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static User create() => User._();
  @$core.override
  User createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static User getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<User>(create);
  static User? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userName => $_getSZ(1);
  @$pb.TagNumber(2)
  set userName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserName() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserName() => $_clearField(2);
}

class ListUserResponse extends $pb.GeneratedMessage {
  factory ListUserResponse({
    $core.int? code,
    $core.String? message,
    $core.Iterable<User>? users,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    if (users != null) result.users.addAll(users);
    return result;
  }

  ListUserResponse._();

  factory ListUserResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListUserResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListUserResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..pPM<User>(3, _omitFieldNames ? '' : 'users', subBuilder: User.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUserResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUserResponse copyWith(void Function(ListUserResponse) updates) =>
      super.copyWith((message) => updates(message as ListUserResponse))
          as ListUserResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListUserResponse create() => ListUserResponse._();
  @$core.override
  ListUserResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListUserResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListUserResponse>(create);
  static ListUserResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<User> get users => $_getList(2);
}

class RemoveUserRequest extends $pb.GeneratedMessage {
  factory RemoveUserRequest({
    $core.String? session,
    $fixnum.Int64? userId,
  }) {
    final result = create();
    if (session != null) result.session = session;
    if (userId != null) result.userId = userId;
    return result;
  }

  RemoveUserRequest._();

  factory RemoveUserRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveUserRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveUserRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'session')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'userId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveUserRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveUserRequest copyWith(void Function(RemoveUserRequest) updates) =>
      super.copyWith((message) => updates(message as RemoveUserRequest))
          as RemoveUserRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveUserRequest create() => RemoveUserRequest._();
  @$core.override
  RemoveUserRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RemoveUserRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveUserRequest>(create);
  static RemoveUserRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get session => $_getSZ(0);
  @$pb.TagNumber(1)
  set session($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSession() => $_has(0);
  @$pb.TagNumber(1)
  void clearSession() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get userId => $_getI64(1);
  @$pb.TagNumber(2)
  set userId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);
}

class RemoveUserResponse extends $pb.GeneratedMessage {
  factory RemoveUserResponse({
    $core.int? code,
    $core.String? message,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    return result;
  }

  RemoveUserResponse._();

  factory RemoveUserResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveUserResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveUserResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveUserResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveUserResponse copyWith(void Function(RemoveUserResponse) updates) =>
      super.copyWith((message) => updates(message as RemoveUserResponse))
          as RemoveUserResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveUserResponse create() => RemoveUserResponse._();
  @$core.override
  RemoveUserResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RemoveUserResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveUserResponse>(create);
  static RemoveUserResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

class VictoriaMetricsDatasource extends $pb.GeneratedMessage {
  factory VictoriaMetricsDatasource({
    $fixnum.Int64? vmDatasourceId,
    $core.String? datasourceName,
    $core.String? addr,
  }) {
    final result = create();
    if (vmDatasourceId != null) result.vmDatasourceId = vmDatasourceId;
    if (datasourceName != null) result.datasourceName = datasourceName;
    if (addr != null) result.addr = addr;
    return result;
  }

  VictoriaMetricsDatasource._();

  factory VictoriaMetricsDatasource.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory VictoriaMetricsDatasource.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VictoriaMetricsDatasource',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'vmDatasourceId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'datasourceName')
    ..aOS(3, _omitFieldNames ? '' : 'addr')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VictoriaMetricsDatasource clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VictoriaMetricsDatasource copyWith(
          void Function(VictoriaMetricsDatasource) updates) =>
      super.copyWith((message) => updates(message as VictoriaMetricsDatasource))
          as VictoriaMetricsDatasource;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VictoriaMetricsDatasource create() => VictoriaMetricsDatasource._();
  @$core.override
  VictoriaMetricsDatasource createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static VictoriaMetricsDatasource getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VictoriaMetricsDatasource>(create);
  static VictoriaMetricsDatasource? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get vmDatasourceId => $_getI64(0);
  @$pb.TagNumber(1)
  set vmDatasourceId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVmDatasourceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearVmDatasourceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get datasourceName => $_getSZ(1);
  @$pb.TagNumber(2)
  set datasourceName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDatasourceName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDatasourceName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get addr => $_getSZ(2);
  @$pb.TagNumber(3)
  set addr($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAddr() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddr() => $_clearField(3);
}

class ListDatasourceRequest extends $pb.GeneratedMessage {
  factory ListDatasourceRequest({
    $core.String? session,
  }) {
    final result = create();
    if (session != null) result.session = session;
    return result;
  }

  ListDatasourceRequest._();

  factory ListDatasourceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListDatasourceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListDatasourceRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'session')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDatasourceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDatasourceRequest copyWith(
          void Function(ListDatasourceRequest) updates) =>
      super.copyWith((message) => updates(message as ListDatasourceRequest))
          as ListDatasourceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListDatasourceRequest create() => ListDatasourceRequest._();
  @$core.override
  ListDatasourceRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListDatasourceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListDatasourceRequest>(create);
  static ListDatasourceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get session => $_getSZ(0);
  @$pb.TagNumber(1)
  set session($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSession() => $_has(0);
  @$pb.TagNumber(1)
  void clearSession() => $_clearField(1);
}

class ListDatasourceResponse extends $pb.GeneratedMessage {
  factory ListDatasourceResponse({
    $core.int? code,
    $core.String? message,
    $core.Iterable<VictoriaMetricsDatasource>? datasources,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    if (datasources != null) result.datasources.addAll(datasources);
    return result;
  }

  ListDatasourceResponse._();

  factory ListDatasourceResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListDatasourceResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListDatasourceResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..pPM<VictoriaMetricsDatasource>(3, _omitFieldNames ? '' : 'datasources',
        subBuilder: VictoriaMetricsDatasource.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDatasourceResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDatasourceResponse copyWith(
          void Function(ListDatasourceResponse) updates) =>
      super.copyWith((message) => updates(message as ListDatasourceResponse))
          as ListDatasourceResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListDatasourceResponse create() => ListDatasourceResponse._();
  @$core.override
  ListDatasourceResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListDatasourceResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListDatasourceResponse>(create);
  static ListDatasourceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<VictoriaMetricsDatasource> get datasources => $_getList(2);
}

class AddDatasourceRequest extends $pb.GeneratedMessage {
  factory AddDatasourceRequest({
    $core.String? session,
    $core.String? datasourceName,
    $core.String? addr,
  }) {
    final result = create();
    if (session != null) result.session = session;
    if (datasourceName != null) result.datasourceName = datasourceName;
    if (addr != null) result.addr = addr;
    return result;
  }

  AddDatasourceRequest._();

  factory AddDatasourceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddDatasourceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddDatasourceRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'session')
    ..aOS(2, _omitFieldNames ? '' : 'datasourceName')
    ..aOS(3, _omitFieldNames ? '' : 'addr')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddDatasourceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddDatasourceRequest copyWith(void Function(AddDatasourceRequest) updates) =>
      super.copyWith((message) => updates(message as AddDatasourceRequest))
          as AddDatasourceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddDatasourceRequest create() => AddDatasourceRequest._();
  @$core.override
  AddDatasourceRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddDatasourceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddDatasourceRequest>(create);
  static AddDatasourceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get session => $_getSZ(0);
  @$pb.TagNumber(1)
  set session($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSession() => $_has(0);
  @$pb.TagNumber(1)
  void clearSession() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get datasourceName => $_getSZ(1);
  @$pb.TagNumber(2)
  set datasourceName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDatasourceName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDatasourceName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get addr => $_getSZ(2);
  @$pb.TagNumber(3)
  set addr($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAddr() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddr() => $_clearField(3);
}

class AddDatasourceResponse extends $pb.GeneratedMessage {
  factory AddDatasourceResponse({
    $core.int? code,
    $core.String? message,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    return result;
  }

  AddDatasourceResponse._();

  factory AddDatasourceResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddDatasourceResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddDatasourceResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddDatasourceResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddDatasourceResponse copyWith(
          void Function(AddDatasourceResponse) updates) =>
      super.copyWith((message) => updates(message as AddDatasourceResponse))
          as AddDatasourceResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddDatasourceResponse create() => AddDatasourceResponse._();
  @$core.override
  AddDatasourceResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddDatasourceResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddDatasourceResponse>(create);
  static AddDatasourceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

class RemoveDatasourceRequest extends $pb.GeneratedMessage {
  factory RemoveDatasourceRequest({
    $core.String? session,
    $fixnum.Int64? vmDatasourceId,
  }) {
    final result = create();
    if (session != null) result.session = session;
    if (vmDatasourceId != null) result.vmDatasourceId = vmDatasourceId;
    return result;
  }

  RemoveDatasourceRequest._();

  factory RemoveDatasourceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveDatasourceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveDatasourceRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'session')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'vmDatasourceId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveDatasourceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveDatasourceRequest copyWith(
          void Function(RemoveDatasourceRequest) updates) =>
      super.copyWith((message) => updates(message as RemoveDatasourceRequest))
          as RemoveDatasourceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveDatasourceRequest create() => RemoveDatasourceRequest._();
  @$core.override
  RemoveDatasourceRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RemoveDatasourceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveDatasourceRequest>(create);
  static RemoveDatasourceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get session => $_getSZ(0);
  @$pb.TagNumber(1)
  set session($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSession() => $_has(0);
  @$pb.TagNumber(1)
  void clearSession() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get vmDatasourceId => $_getI64(1);
  @$pb.TagNumber(2)
  set vmDatasourceId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVmDatasourceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearVmDatasourceId() => $_clearField(2);
}

class RemoveDatasourceResponse extends $pb.GeneratedMessage {
  factory RemoveDatasourceResponse({
    $core.int? code,
    $core.String? message,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    return result;
  }

  RemoveDatasourceResponse._();

  factory RemoveDatasourceResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveDatasourceResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveDatasourceResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveDatasourceResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveDatasourceResponse copyWith(
          void Function(RemoveDatasourceResponse) updates) =>
      super.copyWith((message) => updates(message as RemoveDatasourceResponse))
          as RemoveDatasourceResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveDatasourceResponse create() => RemoveDatasourceResponse._();
  @$core.override
  RemoveDatasourceResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RemoveDatasourceResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveDatasourceResponse>(create);
  static RemoveDatasourceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

class GetLabelsByDatasourceRequest extends $pb.GeneratedMessage {
  factory GetLabelsByDatasourceRequest({
    $core.String? session,
    $core.String? vmDatasourceName,
  }) {
    final result = create();
    if (session != null) result.session = session;
    if (vmDatasourceName != null) result.vmDatasourceName = vmDatasourceName;
    return result;
  }

  GetLabelsByDatasourceRequest._();

  factory GetLabelsByDatasourceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetLabelsByDatasourceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetLabelsByDatasourceRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'session')
    ..aOS(2, _omitFieldNames ? '' : 'vmDatasourceName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLabelsByDatasourceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLabelsByDatasourceRequest copyWith(
          void Function(GetLabelsByDatasourceRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetLabelsByDatasourceRequest))
          as GetLabelsByDatasourceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetLabelsByDatasourceRequest create() =>
      GetLabelsByDatasourceRequest._();
  @$core.override
  GetLabelsByDatasourceRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetLabelsByDatasourceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetLabelsByDatasourceRequest>(create);
  static GetLabelsByDatasourceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get session => $_getSZ(0);
  @$pb.TagNumber(1)
  set session($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSession() => $_has(0);
  @$pb.TagNumber(1)
  void clearSession() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get vmDatasourceName => $_getSZ(1);
  @$pb.TagNumber(2)
  set vmDatasourceName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVmDatasourceName() => $_has(1);
  @$pb.TagNumber(2)
  void clearVmDatasourceName() => $_clearField(2);
}

class LabelValues extends $pb.GeneratedMessage {
  factory LabelValues({
    $core.Iterable<$core.String>? values,
  }) {
    final result = create();
    if (values != null) result.values.addAll(values);
    return result;
  }

  LabelValues._();

  factory LabelValues.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LabelValues.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LabelValues',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'values')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LabelValues clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LabelValues copyWith(void Function(LabelValues) updates) =>
      super.copyWith((message) => updates(message as LabelValues))
          as LabelValues;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LabelValues create() => LabelValues._();
  @$core.override
  LabelValues createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LabelValues getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LabelValues>(create);
  static LabelValues? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get values => $_getList(0);
}

class GetLabelsByDatasourceResponse extends $pb.GeneratedMessage {
  factory GetLabelsByDatasourceResponse({
    $core.int? code,
    $core.String? message,
    $core.Iterable<$core.MapEntry<$core.String, LabelValues>>? labels,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    if (labels != null) result.labels.addEntries(labels);
    return result;
  }

  GetLabelsByDatasourceResponse._();

  factory GetLabelsByDatasourceResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetLabelsByDatasourceResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetLabelsByDatasourceResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..m<$core.String, LabelValues>(3, _omitFieldNames ? '' : 'labels',
        entryClassName: 'GetLabelsByDatasourceResponse.LabelsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: LabelValues.create,
        valueDefaultOrMaker: LabelValues.getDefault,
        packageName: const $pb.PackageName('metrics_explorer'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLabelsByDatasourceResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLabelsByDatasourceResponse copyWith(
          void Function(GetLabelsByDatasourceResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetLabelsByDatasourceResponse))
          as GetLabelsByDatasourceResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetLabelsByDatasourceResponse create() =>
      GetLabelsByDatasourceResponse._();
  @$core.override
  GetLabelsByDatasourceResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetLabelsByDatasourceResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetLabelsByDatasourceResponse>(create);
  static GetLabelsByDatasourceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbMap<$core.String, LabelValues> get labels => $_getMap(2);
}

class GetMetricNamesByDatasourceRequest extends $pb.GeneratedMessage {
  factory GetMetricNamesByDatasourceRequest({
    $core.String? session,
    $core.String? vmDatasourceName,
  }) {
    final result = create();
    if (session != null) result.session = session;
    if (vmDatasourceName != null) result.vmDatasourceName = vmDatasourceName;
    return result;
  }

  GetMetricNamesByDatasourceRequest._();

  factory GetMetricNamesByDatasourceRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMetricNamesByDatasourceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMetricNamesByDatasourceRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'session')
    ..aOS(2, _omitFieldNames ? '' : 'vmDatasourceName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMetricNamesByDatasourceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMetricNamesByDatasourceRequest copyWith(
          void Function(GetMetricNamesByDatasourceRequest) updates) =>
      super.copyWith((message) =>
              updates(message as GetMetricNamesByDatasourceRequest))
          as GetMetricNamesByDatasourceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMetricNamesByDatasourceRequest create() =>
      GetMetricNamesByDatasourceRequest._();
  @$core.override
  GetMetricNamesByDatasourceRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetMetricNamesByDatasourceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMetricNamesByDatasourceRequest>(
          create);
  static GetMetricNamesByDatasourceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get session => $_getSZ(0);
  @$pb.TagNumber(1)
  set session($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSession() => $_has(0);
  @$pb.TagNumber(1)
  void clearSession() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get vmDatasourceName => $_getSZ(1);
  @$pb.TagNumber(2)
  set vmDatasourceName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVmDatasourceName() => $_has(1);
  @$pb.TagNumber(2)
  void clearVmDatasourceName() => $_clearField(2);
}

class GetMetricNamesByDatasourceResponse extends $pb.GeneratedMessage {
  factory GetMetricNamesByDatasourceResponse({
    $core.int? code,
    $core.String? message,
    $core.Iterable<$core.String>? metricNames,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    if (metricNames != null) result.metricNames.addAll(metricNames);
    return result;
  }

  GetMetricNamesByDatasourceResponse._();

  factory GetMetricNamesByDatasourceResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMetricNamesByDatasourceResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMetricNamesByDatasourceResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..pPS(3, _omitFieldNames ? '' : 'metricNames')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMetricNamesByDatasourceResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMetricNamesByDatasourceResponse copyWith(
          void Function(GetMetricNamesByDatasourceResponse) updates) =>
      super.copyWith((message) =>
              updates(message as GetMetricNamesByDatasourceResponse))
          as GetMetricNamesByDatasourceResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMetricNamesByDatasourceResponse create() =>
      GetMetricNamesByDatasourceResponse._();
  @$core.override
  GetMetricNamesByDatasourceResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetMetricNamesByDatasourceResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMetricNamesByDatasourceResponse>(
          create);
  static GetMetricNamesByDatasourceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get metricNames => $_getList(2);
}

class GetSeriesByDatasourceRequest extends $pb.GeneratedMessage {
  factory GetSeriesByDatasourceRequest({
    $core.String? session,
    $core.String? vmDatasourceName,
    $core.String? metricName,
  }) {
    final result = create();
    if (session != null) result.session = session;
    if (vmDatasourceName != null) result.vmDatasourceName = vmDatasourceName;
    if (metricName != null) result.metricName = metricName;
    return result;
  }

  GetSeriesByDatasourceRequest._();

  factory GetSeriesByDatasourceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSeriesByDatasourceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSeriesByDatasourceRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'session')
    ..aOS(2, _omitFieldNames ? '' : 'vmDatasourceName')
    ..aOS(3, _omitFieldNames ? '' : 'metricName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSeriesByDatasourceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSeriesByDatasourceRequest copyWith(
          void Function(GetSeriesByDatasourceRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetSeriesByDatasourceRequest))
          as GetSeriesByDatasourceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSeriesByDatasourceRequest create() =>
      GetSeriesByDatasourceRequest._();
  @$core.override
  GetSeriesByDatasourceRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSeriesByDatasourceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSeriesByDatasourceRequest>(create);
  static GetSeriesByDatasourceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get session => $_getSZ(0);
  @$pb.TagNumber(1)
  set session($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSession() => $_has(0);
  @$pb.TagNumber(1)
  void clearSession() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get vmDatasourceName => $_getSZ(1);
  @$pb.TagNumber(2)
  set vmDatasourceName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVmDatasourceName() => $_has(1);
  @$pb.TagNumber(2)
  void clearVmDatasourceName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get metricName => $_getSZ(2);
  @$pb.TagNumber(3)
  set metricName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMetricName() => $_has(2);
  @$pb.TagNumber(3)
  void clearMetricName() => $_clearField(3);
}

class TagValues extends $pb.GeneratedMessage {
  factory TagValues({
    $core.Iterable<$core.String>? values,
    $core.Iterable<$core.int>? showTimes,
  }) {
    final result = create();
    if (values != null) result.values.addAll(values);
    if (showTimes != null) result.showTimes.addAll(showTimes);
    return result;
  }

  TagValues._();

  factory TagValues.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TagValues.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TagValues',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'values')
    ..p<$core.int>(2, _omitFieldNames ? '' : 'showTimes', $pb.PbFieldType.K3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TagValues clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TagValues copyWith(void Function(TagValues) updates) =>
      super.copyWith((message) => updates(message as TagValues)) as TagValues;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TagValues create() => TagValues._();
  @$core.override
  TagValues createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TagValues getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TagValues>(create);
  static TagValues? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get values => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<$core.int> get showTimes => $_getList(1);
}

class MetricTags extends $pb.GeneratedMessage {
  factory MetricTags({
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? tags,
  }) {
    final result = create();
    if (tags != null) result.tags.addEntries(tags);
    return result;
  }

  MetricTags._();

  factory MetricTags.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MetricTags.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MetricTags',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..m<$core.String, $core.String>(1, _omitFieldNames ? '' : 'tags',
        entryClassName: 'MetricTags.TagsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('metrics_explorer'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MetricTags clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MetricTags copyWith(void Function(MetricTags) updates) =>
      super.copyWith((message) => updates(message as MetricTags)) as MetricTags;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MetricTags create() => MetricTags._();
  @$core.override
  MetricTags createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MetricTags getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MetricTags>(create);
  static MetricTags? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbMap<$core.String, $core.String> get tags => $_getMap(0);
}

class GetSeriesByDatasourceResponse extends $pb.GeneratedMessage {
  factory GetSeriesByDatasourceResponse({
    $core.int? code,
    $core.String? message,
    $core.Iterable<$core.MapEntry<$core.String, TagValues>>? tags,
    $core.Iterable<MetricTags>? ts,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    if (tags != null) result.tags.addEntries(tags);
    if (ts != null) result.ts.addAll(ts);
    return result;
  }

  GetSeriesByDatasourceResponse._();

  factory GetSeriesByDatasourceResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSeriesByDatasourceResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSeriesByDatasourceResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..m<$core.String, TagValues>(4, _omitFieldNames ? '' : 'tags',
        entryClassName: 'GetSeriesByDatasourceResponse.TagsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: TagValues.create,
        valueDefaultOrMaker: TagValues.getDefault,
        packageName: const $pb.PackageName('metrics_explorer'))
    ..pPM<MetricTags>(5, _omitFieldNames ? '' : 'ts',
        subBuilder: MetricTags.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSeriesByDatasourceResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSeriesByDatasourceResponse copyWith(
          void Function(GetSeriesByDatasourceResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetSeriesByDatasourceResponse))
          as GetSeriesByDatasourceResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSeriesByDatasourceResponse create() =>
      GetSeriesByDatasourceResponse._();
  @$core.override
  GetSeriesByDatasourceResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSeriesByDatasourceResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSeriesByDatasourceResponse>(create);
  static GetSeriesByDatasourceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  /// repeated string series = 3;
  @$pb.TagNumber(4)
  $pb.PbMap<$core.String, TagValues> get tags => $_getMap(2);

  @$pb.TagNumber(5)
  $pb.PbList<MetricTags> get ts => $_getList(3);
}

class GetRangeByDatasourceRequest extends $pb.GeneratedMessage {
  factory GetRangeByDatasourceRequest({
    $core.String? session,
    $core.String? vmDatasourceName,
    $core.Iterable<$core.String>? queries,
    $core.String? start,
    $core.String? end,
    $core.String? step,
    $core.String? timeout,
  }) {
    final result = create();
    if (session != null) result.session = session;
    if (vmDatasourceName != null) result.vmDatasourceName = vmDatasourceName;
    if (queries != null) result.queries.addAll(queries);
    if (start != null) result.start = start;
    if (end != null) result.end = end;
    if (step != null) result.step = step;
    if (timeout != null) result.timeout = timeout;
    return result;
  }

  GetRangeByDatasourceRequest._();

  factory GetRangeByDatasourceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetRangeByDatasourceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetRangeByDatasourceRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'session')
    ..aOS(2, _omitFieldNames ? '' : 'vmDatasourceName')
    ..pPS(3, _omitFieldNames ? '' : 'queries')
    ..aOS(4, _omitFieldNames ? '' : 'start')
    ..aOS(5, _omitFieldNames ? '' : 'end')
    ..aOS(6, _omitFieldNames ? '' : 'step')
    ..aOS(7, _omitFieldNames ? '' : 'timeout')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRangeByDatasourceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRangeByDatasourceRequest copyWith(
          void Function(GetRangeByDatasourceRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetRangeByDatasourceRequest))
          as GetRangeByDatasourceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRangeByDatasourceRequest create() =>
      GetRangeByDatasourceRequest._();
  @$core.override
  GetRangeByDatasourceRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetRangeByDatasourceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetRangeByDatasourceRequest>(create);
  static GetRangeByDatasourceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get session => $_getSZ(0);
  @$pb.TagNumber(1)
  set session($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSession() => $_has(0);
  @$pb.TagNumber(1)
  void clearSession() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get vmDatasourceName => $_getSZ(1);
  @$pb.TagNumber(2)
  set vmDatasourceName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVmDatasourceName() => $_has(1);
  @$pb.TagNumber(2)
  void clearVmDatasourceName() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get queries => $_getList(2);

  @$pb.TagNumber(4)
  $core.String get start => $_getSZ(3);
  @$pb.TagNumber(4)
  set start($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStart() => $_has(3);
  @$pb.TagNumber(4)
  void clearStart() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get end => $_getSZ(4);
  @$pb.TagNumber(5)
  set end($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEnd() => $_has(4);
  @$pb.TagNumber(5)
  void clearEnd() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get step => $_getSZ(5);
  @$pb.TagNumber(6)
  set step($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStep() => $_has(5);
  @$pb.TagNumber(6)
  void clearStep() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get timeout => $_getSZ(6);
  @$pb.TagNumber(7)
  set timeout($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTimeout() => $_has(6);
  @$pb.TagNumber(7)
  void clearTimeout() => $_clearField(7);
}

class RangeData extends $pb.GeneratedMessage {
  factory RangeData({
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? tags,
    $core.Iterable<$core.double>? points,
    $core.double? constValue,
    MetricType? metricType,
  }) {
    final result = create();
    if (tags != null) result.tags.addEntries(tags);
    if (points != null) result.points.addAll(points);
    if (constValue != null) result.constValue = constValue;
    if (metricType != null) result.metricType = metricType;
    return result;
  }

  RangeData._();

  factory RangeData.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RangeData.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RangeData',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..m<$core.String, $core.String>(3, _omitFieldNames ? '' : 'tags',
        entryClassName: 'RangeData.TagsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('metrics_explorer'))
    ..p<$core.double>(4, _omitFieldNames ? '' : 'points', $pb.PbFieldType.KD)
    ..aD(5, _omitFieldNames ? '' : 'constValue')
    ..aE<MetricType>(6, _omitFieldNames ? '' : 'metricType',
        enumValues: MetricType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RangeData clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RangeData copyWith(void Function(RangeData) updates) =>
      super.copyWith((message) => updates(message as RangeData)) as RangeData;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RangeData create() => RangeData._();
  @$core.override
  RangeData createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RangeData getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RangeData>(create);
  static RangeData? _defaultInstance;

  @$pb.TagNumber(3)
  $pb.PbMap<$core.String, $core.String> get tags => $_getMap(0);

  @$pb.TagNumber(4)
  $pb.PbList<$core.double> get points => $_getList(1);

  @$pb.TagNumber(5)
  $core.double get constValue => $_getN(2);
  @$pb.TagNumber(5)
  set constValue($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(5)
  $core.bool hasConstValue() => $_has(2);
  @$pb.TagNumber(5)
  void clearConstValue() => $_clearField(5);

  @$pb.TagNumber(6)
  MetricType get metricType => $_getN(3);
  @$pb.TagNumber(6)
  set metricType(MetricType value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasMetricType() => $_has(3);
  @$pb.TagNumber(6)
  void clearMetricType() => $_clearField(6);
}

class QueryResult extends $pb.GeneratedMessage {
  factory QueryResult({
    $core.int? code,
    $core.String? message,
    $core.Iterable<RangeData>? datas,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    if (datas != null) result.datas.addAll(datas);
    return result;
  }

  QueryResult._();

  factory QueryResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory QueryResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'QueryResult',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..pPM<RangeData>(3, _omitFieldNames ? '' : 'datas',
        subBuilder: RangeData.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QueryResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QueryResult copyWith(void Function(QueryResult) updates) =>
      super.copyWith((message) => updates(message as QueryResult))
          as QueryResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static QueryResult create() => QueryResult._();
  @$core.override
  QueryResult createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static QueryResult getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<QueryResult>(create);
  static QueryResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<RangeData> get datas => $_getList(2);
}

class GetRangeByDatasourceResponse extends $pb.GeneratedMessage {
  factory GetRangeByDatasourceResponse({
    $core.int? code,
    $core.String? message,
    $core.Iterable<QueryResult>? queriesResult,
    $core.Iterable<$fixnum.Int64>? timestamps,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    if (queriesResult != null) result.queriesResult.addAll(queriesResult);
    if (timestamps != null) result.timestamps.addAll(timestamps);
    return result;
  }

  GetRangeByDatasourceResponse._();

  factory GetRangeByDatasourceResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetRangeByDatasourceResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetRangeByDatasourceResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..pPM<QueryResult>(3, _omitFieldNames ? '' : 'queriesResult',
        subBuilder: QueryResult.create)
    ..p<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'timestamps', $pb.PbFieldType.K6)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRangeByDatasourceResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRangeByDatasourceResponse copyWith(
          void Function(GetRangeByDatasourceResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetRangeByDatasourceResponse))
          as GetRangeByDatasourceResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRangeByDatasourceResponse create() =>
      GetRangeByDatasourceResponse._();
  @$core.override
  GetRangeByDatasourceResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetRangeByDatasourceResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetRangeByDatasourceResponse>(create);
  static GetRangeByDatasourceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<QueryResult> get queriesResult => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<$fixnum.Int64> get timestamps => $_getList(3);
}

class GetMenuListRequest extends $pb.GeneratedMessage {
  factory GetMenuListRequest({
    $core.String? session,
  }) {
    final result = create();
    if (session != null) result.session = session;
    return result;
  }

  GetMenuListRequest._();

  factory GetMenuListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMenuListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMenuListRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'session')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMenuListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMenuListRequest copyWith(void Function(GetMenuListRequest) updates) =>
      super.copyWith((message) => updates(message as GetMenuListRequest))
          as GetMenuListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMenuListRequest create() => GetMenuListRequest._();
  @$core.override
  GetMenuListRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetMenuListRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMenuListRequest>(create);
  static GetMenuListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get session => $_getSZ(0);
  @$pb.TagNumber(1)
  set session($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSession() => $_has(0);
  @$pb.TagNumber(1)
  void clearSession() => $_clearField(1);
}

class Menu extends $pb.GeneratedMessage {
  factory Menu({
    $fixnum.Int64? menuId,
    $core.String? menuName,
    $fixnum.Int64? parentId,
    $fixnum.Int64? roleId,
    $core.String? link,
    $core.String? target,
    $fixnum.Int64? bitFlags,
  }) {
    final result = create();
    if (menuId != null) result.menuId = menuId;
    if (menuName != null) result.menuName = menuName;
    if (parentId != null) result.parentId = parentId;
    if (roleId != null) result.roleId = roleId;
    if (link != null) result.link = link;
    if (target != null) result.target = target;
    if (bitFlags != null) result.bitFlags = bitFlags;
    return result;
  }

  Menu._();

  factory Menu.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Menu.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Menu',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'menuId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'menuName')
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'parentId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'roleId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(5, _omitFieldNames ? '' : 'link')
    ..aOS(6, _omitFieldNames ? '' : 'target')
    ..a<$fixnum.Int64>(
        7, _omitFieldNames ? '' : 'bitFlags', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Menu clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Menu copyWith(void Function(Menu) updates) =>
      super.copyWith((message) => updates(message as Menu)) as Menu;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Menu create() => Menu._();
  @$core.override
  Menu createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Menu getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Menu>(create);
  static Menu? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get menuId => $_getI64(0);
  @$pb.TagNumber(1)
  set menuId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMenuId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMenuId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get menuName => $_getSZ(1);
  @$pb.TagNumber(2)
  set menuName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMenuName() => $_has(1);
  @$pb.TagNumber(2)
  void clearMenuName() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get parentId => $_getI64(2);
  @$pb.TagNumber(3)
  set parentId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasParentId() => $_has(2);
  @$pb.TagNumber(3)
  void clearParentId() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get roleId => $_getI64(3);
  @$pb.TagNumber(4)
  set roleId($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRoleId() => $_has(3);
  @$pb.TagNumber(4)
  void clearRoleId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get link => $_getSZ(4);
  @$pb.TagNumber(5)
  set link($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLink() => $_has(4);
  @$pb.TagNumber(5)
  void clearLink() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get target => $_getSZ(5);
  @$pb.TagNumber(6)
  set target($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTarget() => $_has(5);
  @$pb.TagNumber(6)
  void clearTarget() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get bitFlags => $_getI64(6);
  @$pb.TagNumber(7)
  set bitFlags($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasBitFlags() => $_has(6);
  @$pb.TagNumber(7)
  void clearBitFlags() => $_clearField(7);
}

class GetMenuListResponse extends $pb.GeneratedMessage {
  factory GetMenuListResponse({
    $core.int? code,
    $core.String? message,
    $core.Iterable<Menu>? menus,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    if (menus != null) result.menus.addAll(menus);
    return result;
  }

  GetMenuListResponse._();

  factory GetMenuListResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMenuListResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMenuListResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..pPM<Menu>(3, _omitFieldNames ? '' : 'menus', subBuilder: Menu.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMenuListResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMenuListResponse copyWith(void Function(GetMenuListResponse) updates) =>
      super.copyWith((message) => updates(message as GetMenuListResponse))
          as GetMenuListResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMenuListResponse create() => GetMenuListResponse._();
  @$core.override
  GetMenuListResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetMenuListResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMenuListResponse>(create);
  static GetMenuListResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<Menu> get menus => $_getList(2);
}

class AddMenuRequest extends $pb.GeneratedMessage {
  factory AddMenuRequest({
    $core.String? session,
    Menu? menu,
  }) {
    final result = create();
    if (session != null) result.session = session;
    if (menu != null) result.menu = menu;
    return result;
  }

  AddMenuRequest._();

  factory AddMenuRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddMenuRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddMenuRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'session')
    ..aOM<Menu>(2, _omitFieldNames ? '' : 'menu', subBuilder: Menu.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddMenuRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddMenuRequest copyWith(void Function(AddMenuRequest) updates) =>
      super.copyWith((message) => updates(message as AddMenuRequest))
          as AddMenuRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddMenuRequest create() => AddMenuRequest._();
  @$core.override
  AddMenuRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddMenuRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddMenuRequest>(create);
  static AddMenuRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get session => $_getSZ(0);
  @$pb.TagNumber(1)
  set session($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSession() => $_has(0);
  @$pb.TagNumber(1)
  void clearSession() => $_clearField(1);

  @$pb.TagNumber(2)
  Menu get menu => $_getN(1);
  @$pb.TagNumber(2)
  set menu(Menu value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasMenu() => $_has(1);
  @$pb.TagNumber(2)
  void clearMenu() => $_clearField(2);
  @$pb.TagNumber(2)
  Menu ensureMenu() => $_ensure(1);
}

class AddMenuResponse extends $pb.GeneratedMessage {
  factory AddMenuResponse({
    $core.int? code,
    $core.String? message,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    return result;
  }

  AddMenuResponse._();

  factory AddMenuResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddMenuResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddMenuResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddMenuResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddMenuResponse copyWith(void Function(AddMenuResponse) updates) =>
      super.copyWith((message) => updates(message as AddMenuResponse))
          as AddMenuResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddMenuResponse create() => AddMenuResponse._();
  @$core.override
  AddMenuResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddMenuResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddMenuResponse>(create);
  static AddMenuResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

class RemoveMenuRequest extends $pb.GeneratedMessage {
  factory RemoveMenuRequest({
    $core.String? session,
    $fixnum.Int64? menuId,
  }) {
    final result = create();
    if (session != null) result.session = session;
    if (menuId != null) result.menuId = menuId;
    return result;
  }

  RemoveMenuRequest._();

  factory RemoveMenuRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveMenuRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveMenuRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'session')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'menuId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveMenuRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveMenuRequest copyWith(void Function(RemoveMenuRequest) updates) =>
      super.copyWith((message) => updates(message as RemoveMenuRequest))
          as RemoveMenuRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveMenuRequest create() => RemoveMenuRequest._();
  @$core.override
  RemoveMenuRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RemoveMenuRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveMenuRequest>(create);
  static RemoveMenuRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get session => $_getSZ(0);
  @$pb.TagNumber(1)
  set session($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSession() => $_has(0);
  @$pb.TagNumber(1)
  void clearSession() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get menuId => $_getI64(1);
  @$pb.TagNumber(2)
  set menuId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMenuId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMenuId() => $_clearField(2);
}

class RemoveMenuResponse extends $pb.GeneratedMessage {
  factory RemoveMenuResponse({
    $core.int? code,
    $core.String? message,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    return result;
  }

  RemoveMenuResponse._();

  factory RemoveMenuResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveMenuResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveMenuResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveMenuResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveMenuResponse copyWith(void Function(RemoveMenuResponse) updates) =>
      super.copyWith((message) => updates(message as RemoveMenuResponse))
          as RemoveMenuResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveMenuResponse create() => RemoveMenuResponse._();
  @$core.override
  RemoveMenuResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RemoveMenuResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveMenuResponse>(create);
  static RemoveMenuResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

class ModifyMenuRequest extends $pb.GeneratedMessage {
  factory ModifyMenuRequest({
    $core.String? session,
    Menu? menu,
  }) {
    final result = create();
    if (session != null) result.session = session;
    if (menu != null) result.menu = menu;
    return result;
  }

  ModifyMenuRequest._();

  factory ModifyMenuRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ModifyMenuRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ModifyMenuRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'session')
    ..aOM<Menu>(2, _omitFieldNames ? '' : 'menu', subBuilder: Menu.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ModifyMenuRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ModifyMenuRequest copyWith(void Function(ModifyMenuRequest) updates) =>
      super.copyWith((message) => updates(message as ModifyMenuRequest))
          as ModifyMenuRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ModifyMenuRequest create() => ModifyMenuRequest._();
  @$core.override
  ModifyMenuRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ModifyMenuRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ModifyMenuRequest>(create);
  static ModifyMenuRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get session => $_getSZ(0);
  @$pb.TagNumber(1)
  set session($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSession() => $_has(0);
  @$pb.TagNumber(1)
  void clearSession() => $_clearField(1);

  @$pb.TagNumber(2)
  Menu get menu => $_getN(1);
  @$pb.TagNumber(2)
  set menu(Menu value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasMenu() => $_has(1);
  @$pb.TagNumber(2)
  void clearMenu() => $_clearField(2);
  @$pb.TagNumber(2)
  Menu ensureMenu() => $_ensure(1);
}

class ModifyMenuResponse extends $pb.GeneratedMessage {
  factory ModifyMenuResponse({
    $core.int? code,
    $core.String? message,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    return result;
  }

  ModifyMenuResponse._();

  factory ModifyMenuResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ModifyMenuResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ModifyMenuResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ModifyMenuResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ModifyMenuResponse copyWith(void Function(ModifyMenuResponse) updates) =>
      super.copyWith((message) => updates(message as ModifyMenuResponse))
          as ModifyMenuResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ModifyMenuResponse create() => ModifyMenuResponse._();
  @$core.override
  ModifyMenuResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ModifyMenuResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ModifyMenuResponse>(create);
  static ModifyMenuResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

class LoadMenuTreeRequest extends $pb.GeneratedMessage {
  factory LoadMenuTreeRequest({
    $core.String? session,
  }) {
    final result = create();
    if (session != null) result.session = session;
    return result;
  }

  LoadMenuTreeRequest._();

  factory LoadMenuTreeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LoadMenuTreeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoadMenuTreeRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'session')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadMenuTreeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadMenuTreeRequest copyWith(void Function(LoadMenuTreeRequest) updates) =>
      super.copyWith((message) => updates(message as LoadMenuTreeRequest))
          as LoadMenuTreeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoadMenuTreeRequest create() => LoadMenuTreeRequest._();
  @$core.override
  LoadMenuTreeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LoadMenuTreeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoadMenuTreeRequest>(create);
  static LoadMenuTreeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get session => $_getSZ(0);
  @$pb.TagNumber(1)
  set session($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSession() => $_has(0);
  @$pb.TagNumber(1)
  void clearSession() => $_clearField(1);
}

class MenuTreeNode extends $pb.GeneratedMessage {
  factory MenuTreeNode({
    $fixnum.Int64? menuId,
    $core.String? menuName,
    $core.String? link,
    $core.String? target,
    $fixnum.Int64? bitFlags,
    $core.Iterable<MenuTreeNode>? children,
  }) {
    final result = create();
    if (menuId != null) result.menuId = menuId;
    if (menuName != null) result.menuName = menuName;
    if (link != null) result.link = link;
    if (target != null) result.target = target;
    if (bitFlags != null) result.bitFlags = bitFlags;
    if (children != null) result.children.addAll(children);
    return result;
  }

  MenuTreeNode._();

  factory MenuTreeNode.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MenuTreeNode.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MenuTreeNode',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'menuId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'menuName')
    ..aOS(3, _omitFieldNames ? '' : 'link')
    ..aOS(4, _omitFieldNames ? '' : 'target')
    ..a<$fixnum.Int64>(
        5, _omitFieldNames ? '' : 'bitFlags', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..pPM<MenuTreeNode>(6, _omitFieldNames ? '' : 'children',
        subBuilder: MenuTreeNode.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MenuTreeNode clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MenuTreeNode copyWith(void Function(MenuTreeNode) updates) =>
      super.copyWith((message) => updates(message as MenuTreeNode))
          as MenuTreeNode;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MenuTreeNode create() => MenuTreeNode._();
  @$core.override
  MenuTreeNode createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MenuTreeNode getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MenuTreeNode>(create);
  static MenuTreeNode? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get menuId => $_getI64(0);
  @$pb.TagNumber(1)
  set menuId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMenuId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMenuId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get menuName => $_getSZ(1);
  @$pb.TagNumber(2)
  set menuName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMenuName() => $_has(1);
  @$pb.TagNumber(2)
  void clearMenuName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get link => $_getSZ(2);
  @$pb.TagNumber(3)
  set link($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLink() => $_has(2);
  @$pb.TagNumber(3)
  void clearLink() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get target => $_getSZ(3);
  @$pb.TagNumber(4)
  set target($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTarget() => $_has(3);
  @$pb.TagNumber(4)
  void clearTarget() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get bitFlags => $_getI64(4);
  @$pb.TagNumber(5)
  set bitFlags($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBitFlags() => $_has(4);
  @$pb.TagNumber(5)
  void clearBitFlags() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<MenuTreeNode> get children => $_getList(5);
}

class LoadMenuTreeResponse extends $pb.GeneratedMessage {
  factory LoadMenuTreeResponse({
    $core.int? code,
    $core.String? message,
    MenuTreeNode? menus,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    if (menus != null) result.menus = menus;
    return result;
  }

  LoadMenuTreeResponse._();

  factory LoadMenuTreeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LoadMenuTreeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoadMenuTreeResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'metrics_explorer'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOM<MenuTreeNode>(3, _omitFieldNames ? '' : 'menus',
        subBuilder: MenuTreeNode.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadMenuTreeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadMenuTreeResponse copyWith(void Function(LoadMenuTreeResponse) updates) =>
      super.copyWith((message) => updates(message as LoadMenuTreeResponse))
          as LoadMenuTreeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoadMenuTreeResponse create() => LoadMenuTreeResponse._();
  @$core.override
  LoadMenuTreeResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LoadMenuTreeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoadMenuTreeResponse>(create);
  static LoadMenuTreeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  MenuTreeNode get menus => $_getN(2);
  @$pb.TagNumber(3)
  set menus(MenuTreeNode value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasMenus() => $_has(2);
  @$pb.TagNumber(3)
  void clearMenus() => $_clearField(3);
  @$pb.TagNumber(3)
  MenuTreeNode ensureMenus() => $_ensure(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
