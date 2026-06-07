// This is a generated file - do not edit.
//
// Generated from api.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use metricTypeDescriptor instead')
const MetricType$json = {
  '1': 'MetricType',
  '2': [
    {'1': 'Unknown', '2': 0},
    {'1': 'Counter', '2': 1},
    {'1': 'StaticValue', '2': 2},
    {'1': 'Histogram', '2': 3},
  ],
};

/// Descriptor for `MetricType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List metricTypeDescriptor = $convert.base64Decode(
    'CgpNZXRyaWNUeXBlEgsKB1Vua25vd24QABILCgdDb3VudGVyEAESDwoLU3RhdGljVmFsdWUQAh'
    'INCglIaXN0b2dyYW0QAw==');

@$core.Deprecated('Use getGlobalConfigsResponseDescriptor instead')
const GetGlobalConfigsResponse$json = {
  '1': 'GetGlobalConfigsResponse',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'salt', '3': 3, '4': 1, '5': 9, '10': 'salt'},
    {'1': 'api_path', '3': 4, '4': 1, '5': 9, '10': 'apiPath'},
  ],
};

/// Descriptor for `GetGlobalConfigsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGlobalConfigsResponseDescriptor = $convert.base64Decode(
    'ChhHZXRHbG9iYWxDb25maWdzUmVzcG9uc2USEgoEY29kZRgBIAEoBVIEY29kZRIYCgdtZXNzYW'
    'dlGAIgASgJUgdtZXNzYWdlEhIKBHNhbHQYAyABKAlSBHNhbHQSGQoIYXBpX3BhdGgYBCABKAlS'
    'B2FwaVBhdGg=');

@$core.Deprecated('Use loginRequestDescriptor instead')
const LoginRequest$json = {
  '1': 'LoginRequest',
  '2': [
    {'1': 'user_name', '3': 1, '4': 1, '5': 9, '10': 'userName'},
    {'1': 'passwd', '3': 2, '4': 1, '5': 9, '10': 'passwd'},
  ],
};

/// Descriptor for `LoginRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginRequestDescriptor = $convert.base64Decode(
    'CgxMb2dpblJlcXVlc3QSGwoJdXNlcl9uYW1lGAEgASgJUgh1c2VyTmFtZRIWCgZwYXNzd2QYAi'
    'ABKAlSBnBhc3N3ZA==');

@$core.Deprecated('Use loginResponseDescriptor instead')
const LoginResponse$json = {
  '1': 'LoginResponse',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'session', '3': 3, '4': 1, '5': 9, '10': 'session'},
  ],
};

/// Descriptor for `LoginResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginResponseDescriptor = $convert.base64Decode(
    'Cg1Mb2dpblJlc3BvbnNlEhIKBGNvZGUYASABKAVSBGNvZGUSGAoHbWVzc2FnZRgCIAEoCVIHbW'
    'Vzc2FnZRIYCgdzZXNzaW9uGAMgASgJUgdzZXNzaW9u');

@$core.Deprecated('Use addUserRequestDescriptor instead')
const AddUserRequest$json = {
  '1': 'AddUserRequest',
  '2': [
    {'1': 'session', '3': 1, '4': 1, '5': 9, '10': 'session'},
    {'1': 'user_name', '3': 2, '4': 1, '5': 9, '10': 'userName'},
    {'1': 'sha256', '3': 3, '4': 1, '5': 9, '10': 'sha256'},
  ],
};

/// Descriptor for `AddUserRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addUserRequestDescriptor = $convert.base64Decode(
    'Cg5BZGRVc2VyUmVxdWVzdBIYCgdzZXNzaW9uGAEgASgJUgdzZXNzaW9uEhsKCXVzZXJfbmFtZR'
    'gCIAEoCVIIdXNlck5hbWUSFgoGc2hhMjU2GAMgASgJUgZzaGEyNTY=');

@$core.Deprecated('Use addUserResponseDescriptor instead')
const AddUserResponse$json = {
  '1': 'AddUserResponse',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `AddUserResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addUserResponseDescriptor = $convert.base64Decode(
    'Cg9BZGRVc2VyUmVzcG9uc2USEgoEY29kZRgBIAEoBVIEY29kZRIYCgdtZXNzYWdlGAIgASgJUg'
    'dtZXNzYWdl');

@$core.Deprecated('Use listUserRequestDescriptor instead')
const ListUserRequest$json = {
  '1': 'ListUserRequest',
  '2': [
    {'1': 'session', '3': 1, '4': 1, '5': 9, '10': 'session'},
  ],
};

/// Descriptor for `ListUserRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listUserRequestDescriptor = $convert.base64Decode(
    'Cg9MaXN0VXNlclJlcXVlc3QSGAoHc2Vzc2lvbhgBIAEoCVIHc2Vzc2lvbg==');

@$core.Deprecated('Use userDescriptor instead')
const User$json = {
  '1': 'User',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 4, '10': 'userId'},
    {'1': 'user_name', '3': 2, '4': 1, '5': 9, '10': 'userName'},
  ],
};

/// Descriptor for `User`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userDescriptor = $convert.base64Decode(
    'CgRVc2VyEhcKB3VzZXJfaWQYASABKARSBnVzZXJJZBIbCgl1c2VyX25hbWUYAiABKAlSCHVzZX'
    'JOYW1l');

@$core.Deprecated('Use listUserResponseDescriptor instead')
const ListUserResponse$json = {
  '1': 'ListUserResponse',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {
      '1': 'users',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.metrics_explorer.User',
      '10': 'users'
    },
  ],
};

/// Descriptor for `ListUserResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listUserResponseDescriptor = $convert.base64Decode(
    'ChBMaXN0VXNlclJlc3BvbnNlEhIKBGNvZGUYASABKAVSBGNvZGUSGAoHbWVzc2FnZRgCIAEoCV'
    'IHbWVzc2FnZRIsCgV1c2VycxgDIAMoCzIWLm1ldHJpY3NfZXhwbG9yZXIuVXNlclIFdXNlcnM=');

@$core.Deprecated('Use removeUserRequestDescriptor instead')
const RemoveUserRequest$json = {
  '1': 'RemoveUserRequest',
  '2': [
    {'1': 'session', '3': 1, '4': 1, '5': 9, '10': 'session'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 4, '10': 'userId'},
  ],
};

/// Descriptor for `RemoveUserRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeUserRequestDescriptor = $convert.base64Decode(
    'ChFSZW1vdmVVc2VyUmVxdWVzdBIYCgdzZXNzaW9uGAEgASgJUgdzZXNzaW9uEhcKB3VzZXJfaW'
    'QYAiABKARSBnVzZXJJZA==');

@$core.Deprecated('Use removeUserResponseDescriptor instead')
const RemoveUserResponse$json = {
  '1': 'RemoveUserResponse',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `RemoveUserResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeUserResponseDescriptor = $convert.base64Decode(
    'ChJSZW1vdmVVc2VyUmVzcG9uc2USEgoEY29kZRgBIAEoBVIEY29kZRIYCgdtZXNzYWdlGAIgAS'
    'gJUgdtZXNzYWdl');

@$core.Deprecated('Use victoriaMetricsDatasourceDescriptor instead')
const VictoriaMetricsDatasource$json = {
  '1': 'VictoriaMetricsDatasource',
  '2': [
    {'1': 'vm_datasource_id', '3': 1, '4': 1, '5': 4, '10': 'vmDatasourceId'},
    {'1': 'datasource_name', '3': 2, '4': 1, '5': 9, '10': 'datasourceName'},
    {'1': 'addr', '3': 3, '4': 1, '5': 9, '10': 'addr'},
  ],
};

/// Descriptor for `VictoriaMetricsDatasource`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List victoriaMetricsDatasourceDescriptor = $convert.base64Decode(
    'ChlWaWN0b3JpYU1ldHJpY3NEYXRhc291cmNlEigKEHZtX2RhdGFzb3VyY2VfaWQYASABKARSDn'
    'ZtRGF0YXNvdXJjZUlkEicKD2RhdGFzb3VyY2VfbmFtZRgCIAEoCVIOZGF0YXNvdXJjZU5hbWUS'
    'EgoEYWRkchgDIAEoCVIEYWRkcg==');

@$core.Deprecated('Use listDatasourceRequestDescriptor instead')
const ListDatasourceRequest$json = {
  '1': 'ListDatasourceRequest',
  '2': [
    {'1': 'session', '3': 1, '4': 1, '5': 9, '10': 'session'},
  ],
};

/// Descriptor for `ListDatasourceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listDatasourceRequestDescriptor =
    $convert.base64Decode(
        'ChVMaXN0RGF0YXNvdXJjZVJlcXVlc3QSGAoHc2Vzc2lvbhgBIAEoCVIHc2Vzc2lvbg==');

@$core.Deprecated('Use listDatasourceResponseDescriptor instead')
const ListDatasourceResponse$json = {
  '1': 'ListDatasourceResponse',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {
      '1': 'datasources',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.metrics_explorer.VictoriaMetricsDatasource',
      '10': 'datasources'
    },
  ],
};

/// Descriptor for `ListDatasourceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listDatasourceResponseDescriptor = $convert.base64Decode(
    'ChZMaXN0RGF0YXNvdXJjZVJlc3BvbnNlEhIKBGNvZGUYASABKAVSBGNvZGUSGAoHbWVzc2FnZR'
    'gCIAEoCVIHbWVzc2FnZRJNCgtkYXRhc291cmNlcxgDIAMoCzIrLm1ldHJpY3NfZXhwbG9yZXIu'
    'VmljdG9yaWFNZXRyaWNzRGF0YXNvdXJjZVILZGF0YXNvdXJjZXM=');

@$core.Deprecated('Use addDatasourceRequestDescriptor instead')
const AddDatasourceRequest$json = {
  '1': 'AddDatasourceRequest',
  '2': [
    {'1': 'session', '3': 1, '4': 1, '5': 9, '10': 'session'},
    {'1': 'datasource_name', '3': 2, '4': 1, '5': 9, '10': 'datasourceName'},
    {'1': 'addr', '3': 3, '4': 1, '5': 9, '10': 'addr'},
  ],
};

/// Descriptor for `AddDatasourceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addDatasourceRequestDescriptor = $convert.base64Decode(
    'ChRBZGREYXRhc291cmNlUmVxdWVzdBIYCgdzZXNzaW9uGAEgASgJUgdzZXNzaW9uEicKD2RhdG'
    'Fzb3VyY2VfbmFtZRgCIAEoCVIOZGF0YXNvdXJjZU5hbWUSEgoEYWRkchgDIAEoCVIEYWRkcg==');

@$core.Deprecated('Use addDatasourceResponseDescriptor instead')
const AddDatasourceResponse$json = {
  '1': 'AddDatasourceResponse',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `AddDatasourceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addDatasourceResponseDescriptor = $convert.base64Decode(
    'ChVBZGREYXRhc291cmNlUmVzcG9uc2USEgoEY29kZRgBIAEoBVIEY29kZRIYCgdtZXNzYWdlGA'
    'IgASgJUgdtZXNzYWdl');

@$core.Deprecated('Use removeDatasourceRequestDescriptor instead')
const RemoveDatasourceRequest$json = {
  '1': 'RemoveDatasourceRequest',
  '2': [
    {'1': 'session', '3': 1, '4': 1, '5': 9, '10': 'session'},
    {'1': 'vm_datasource_id', '3': 2, '4': 1, '5': 4, '10': 'vmDatasourceId'},
  ],
};

/// Descriptor for `RemoveDatasourceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeDatasourceRequestDescriptor =
    $convert.base64Decode(
        'ChdSZW1vdmVEYXRhc291cmNlUmVxdWVzdBIYCgdzZXNzaW9uGAEgASgJUgdzZXNzaW9uEigKEH'
        'ZtX2RhdGFzb3VyY2VfaWQYAiABKARSDnZtRGF0YXNvdXJjZUlk');

@$core.Deprecated('Use removeDatasourceResponseDescriptor instead')
const RemoveDatasourceResponse$json = {
  '1': 'RemoveDatasourceResponse',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `RemoveDatasourceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeDatasourceResponseDescriptor =
    $convert.base64Decode(
        'ChhSZW1vdmVEYXRhc291cmNlUmVzcG9uc2USEgoEY29kZRgBIAEoBVIEY29kZRIYCgdtZXNzYW'
        'dlGAIgASgJUgdtZXNzYWdl');

@$core.Deprecated('Use getLabelsByDatasourceRequestDescriptor instead')
const GetLabelsByDatasourceRequest$json = {
  '1': 'GetLabelsByDatasourceRequest',
  '2': [
    {'1': 'session', '3': 1, '4': 1, '5': 9, '10': 'session'},
    {
      '1': 'vm_datasource_name',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'vmDatasourceName'
    },
  ],
};

/// Descriptor for `GetLabelsByDatasourceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getLabelsByDatasourceRequestDescriptor =
    $convert.base64Decode(
        'ChxHZXRMYWJlbHNCeURhdGFzb3VyY2VSZXF1ZXN0EhgKB3Nlc3Npb24YASABKAlSB3Nlc3Npb2'
        '4SLAoSdm1fZGF0YXNvdXJjZV9uYW1lGAIgASgJUhB2bURhdGFzb3VyY2VOYW1l');

@$core.Deprecated('Use labelValuesDescriptor instead')
const LabelValues$json = {
  '1': 'LabelValues',
  '2': [
    {'1': 'values', '3': 1, '4': 3, '5': 9, '10': 'values'},
  ],
};

/// Descriptor for `LabelValues`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List labelValuesDescriptor = $convert
    .base64Decode('CgtMYWJlbFZhbHVlcxIWCgZ2YWx1ZXMYASADKAlSBnZhbHVlcw==');

@$core.Deprecated('Use getLabelsByDatasourceResponseDescriptor instead')
const GetLabelsByDatasourceResponse$json = {
  '1': 'GetLabelsByDatasourceResponse',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {
      '1': 'labels',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.metrics_explorer.GetLabelsByDatasourceResponse.LabelsEntry',
      '10': 'labels'
    },
  ],
  '3': [GetLabelsByDatasourceResponse_LabelsEntry$json],
};

@$core.Deprecated('Use getLabelsByDatasourceResponseDescriptor instead')
const GetLabelsByDatasourceResponse_LabelsEntry$json = {
  '1': 'LabelsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.metrics_explorer.LabelValues',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

/// Descriptor for `GetLabelsByDatasourceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getLabelsByDatasourceResponseDescriptor = $convert.base64Decode(
    'Ch1HZXRMYWJlbHNCeURhdGFzb3VyY2VSZXNwb25zZRISCgRjb2RlGAEgASgFUgRjb2RlEhgKB2'
    '1lc3NhZ2UYAiABKAlSB21lc3NhZ2USUwoGbGFiZWxzGAMgAygLMjsubWV0cmljc19leHBsb3Jl'
    'ci5HZXRMYWJlbHNCeURhdGFzb3VyY2VSZXNwb25zZS5MYWJlbHNFbnRyeVIGbGFiZWxzGlgKC0'
    'xhYmVsc0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EjMKBXZhbHVlGAIgASgLMh0ubWV0cmljc19l'
    'eHBsb3Jlci5MYWJlbFZhbHVlc1IFdmFsdWU6AjgB');

@$core.Deprecated('Use getMetricNamesByDatasourceRequestDescriptor instead')
const GetMetricNamesByDatasourceRequest$json = {
  '1': 'GetMetricNamesByDatasourceRequest',
  '2': [
    {'1': 'session', '3': 1, '4': 1, '5': 9, '10': 'session'},
    {
      '1': 'vm_datasource_name',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'vmDatasourceName'
    },
  ],
};

/// Descriptor for `GetMetricNamesByDatasourceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMetricNamesByDatasourceRequestDescriptor =
    $convert.base64Decode(
        'CiFHZXRNZXRyaWNOYW1lc0J5RGF0YXNvdXJjZVJlcXVlc3QSGAoHc2Vzc2lvbhgBIAEoCVIHc2'
        'Vzc2lvbhIsChJ2bV9kYXRhc291cmNlX25hbWUYAiABKAlSEHZtRGF0YXNvdXJjZU5hbWU=');

@$core.Deprecated('Use getMetricNamesByDatasourceResponseDescriptor instead')
const GetMetricNamesByDatasourceResponse$json = {
  '1': 'GetMetricNamesByDatasourceResponse',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'metric_names', '3': 3, '4': 3, '5': 9, '10': 'metricNames'},
  ],
};

/// Descriptor for `GetMetricNamesByDatasourceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMetricNamesByDatasourceResponseDescriptor =
    $convert.base64Decode(
        'CiJHZXRNZXRyaWNOYW1lc0J5RGF0YXNvdXJjZVJlc3BvbnNlEhIKBGNvZGUYASABKAVSBGNvZG'
        'USGAoHbWVzc2FnZRgCIAEoCVIHbWVzc2FnZRIhCgxtZXRyaWNfbmFtZXMYAyADKAlSC21ldHJp'
        'Y05hbWVz');

@$core.Deprecated('Use getSeriesByDatasourceRequestDescriptor instead')
const GetSeriesByDatasourceRequest$json = {
  '1': 'GetSeriesByDatasourceRequest',
  '2': [
    {'1': 'session', '3': 1, '4': 1, '5': 9, '10': 'session'},
    {
      '1': 'vm_datasource_name',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'vmDatasourceName'
    },
    {'1': 'metric_name', '3': 3, '4': 1, '5': 9, '10': 'metricName'},
  ],
};

/// Descriptor for `GetSeriesByDatasourceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSeriesByDatasourceRequestDescriptor =
    $convert.base64Decode(
        'ChxHZXRTZXJpZXNCeURhdGFzb3VyY2VSZXF1ZXN0EhgKB3Nlc3Npb24YASABKAlSB3Nlc3Npb2'
        '4SLAoSdm1fZGF0YXNvdXJjZV9uYW1lGAIgASgJUhB2bURhdGFzb3VyY2VOYW1lEh8KC21ldHJp'
        'Y19uYW1lGAMgASgJUgptZXRyaWNOYW1l');

@$core.Deprecated('Use tagValuesDescriptor instead')
const TagValues$json = {
  '1': 'TagValues',
  '2': [
    {'1': 'values', '3': 1, '4': 3, '5': 9, '10': 'values'},
    {'1': 'show_times', '3': 2, '4': 3, '5': 5, '10': 'showTimes'},
  ],
};

/// Descriptor for `TagValues`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tagValuesDescriptor = $convert.base64Decode(
    'CglUYWdWYWx1ZXMSFgoGdmFsdWVzGAEgAygJUgZ2YWx1ZXMSHQoKc2hvd190aW1lcxgCIAMoBV'
    'IJc2hvd1RpbWVz');

@$core.Deprecated('Use metricTagsDescriptor instead')
const MetricTags$json = {
  '1': 'MetricTags',
  '2': [
    {
      '1': 'tags',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.metrics_explorer.MetricTags.TagsEntry',
      '10': 'tags'
    },
  ],
  '3': [MetricTags_TagsEntry$json],
};

@$core.Deprecated('Use metricTagsDescriptor instead')
const MetricTags_TagsEntry$json = {
  '1': 'TagsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `MetricTags`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List metricTagsDescriptor = $convert.base64Decode(
    'CgpNZXRyaWNUYWdzEjoKBHRhZ3MYASADKAsyJi5tZXRyaWNzX2V4cGxvcmVyLk1ldHJpY1RhZ3'
    'MuVGFnc0VudHJ5UgR0YWdzGjcKCVRhZ3NFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1'
    'ZRgCIAEoCVIFdmFsdWU6AjgB');

@$core.Deprecated('Use getSeriesByDatasourceResponseDescriptor instead')
const GetSeriesByDatasourceResponse$json = {
  '1': 'GetSeriesByDatasourceResponse',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {
      '1': 'tags',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.metrics_explorer.GetSeriesByDatasourceResponse.TagsEntry',
      '10': 'tags'
    },
    {
      '1': 'ts',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.metrics_explorer.MetricTags',
      '10': 'ts'
    },
  ],
  '3': [GetSeriesByDatasourceResponse_TagsEntry$json],
};

@$core.Deprecated('Use getSeriesByDatasourceResponseDescriptor instead')
const GetSeriesByDatasourceResponse_TagsEntry$json = {
  '1': 'TagsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.metrics_explorer.TagValues',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

/// Descriptor for `GetSeriesByDatasourceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSeriesByDatasourceResponseDescriptor = $convert.base64Decode(
    'Ch1HZXRTZXJpZXNCeURhdGFzb3VyY2VSZXNwb25zZRISCgRjb2RlGAEgASgFUgRjb2RlEhgKB2'
    '1lc3NhZ2UYAiABKAlSB21lc3NhZ2USTQoEdGFncxgEIAMoCzI5Lm1ldHJpY3NfZXhwbG9yZXIu'
    'R2V0U2VyaWVzQnlEYXRhc291cmNlUmVzcG9uc2UuVGFnc0VudHJ5UgR0YWdzEiwKAnRzGAUgAy'
    'gLMhwubWV0cmljc19leHBsb3Jlci5NZXRyaWNUYWdzUgJ0cxpUCglUYWdzRW50cnkSEAoDa2V5'
    'GAEgASgJUgNrZXkSMQoFdmFsdWUYAiABKAsyGy5tZXRyaWNzX2V4cGxvcmVyLlRhZ1ZhbHVlc1'
    'IFdmFsdWU6AjgB');

@$core.Deprecated('Use getRangeByDatasourceRequestDescriptor instead')
const GetRangeByDatasourceRequest$json = {
  '1': 'GetRangeByDatasourceRequest',
  '2': [
    {'1': 'session', '3': 1, '4': 1, '5': 9, '10': 'session'},
    {
      '1': 'vm_datasource_name',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'vmDatasourceName'
    },
    {'1': 'queries', '3': 3, '4': 3, '5': 9, '10': 'queries'},
    {'1': 'start', '3': 4, '4': 1, '5': 9, '10': 'start'},
    {'1': 'end', '3': 5, '4': 1, '5': 9, '10': 'end'},
    {'1': 'step', '3': 6, '4': 1, '5': 9, '10': 'step'},
    {'1': 'timeout', '3': 7, '4': 1, '5': 9, '10': 'timeout'},
  ],
};

/// Descriptor for `GetRangeByDatasourceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRangeByDatasourceRequestDescriptor = $convert.base64Decode(
    'ChtHZXRSYW5nZUJ5RGF0YXNvdXJjZVJlcXVlc3QSGAoHc2Vzc2lvbhgBIAEoCVIHc2Vzc2lvbh'
    'IsChJ2bV9kYXRhc291cmNlX25hbWUYAiABKAlSEHZtRGF0YXNvdXJjZU5hbWUSGAoHcXVlcmll'
    'cxgDIAMoCVIHcXVlcmllcxIUCgVzdGFydBgEIAEoCVIFc3RhcnQSEAoDZW5kGAUgASgJUgNlbm'
    'QSEgoEc3RlcBgGIAEoCVIEc3RlcBIYCgd0aW1lb3V0GAcgASgJUgd0aW1lb3V0');

@$core.Deprecated('Use rangeDataDescriptor instead')
const RangeData$json = {
  '1': 'RangeData',
  '2': [
    {
      '1': 'tags',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.metrics_explorer.RangeData.TagsEntry',
      '10': 'tags'
    },
    {'1': 'points', '3': 4, '4': 3, '5': 1, '10': 'points'},
    {'1': 'const_value', '3': 5, '4': 1, '5': 1, '10': 'constValue'},
    {
      '1': 'metric_type',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.metrics_explorer.MetricType',
      '10': 'metricType'
    },
  ],
  '3': [RangeData_TagsEntry$json],
};

@$core.Deprecated('Use rangeDataDescriptor instead')
const RangeData_TagsEntry$json = {
  '1': 'TagsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `RangeData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rangeDataDescriptor = $convert.base64Decode(
    'CglSYW5nZURhdGESOQoEdGFncxgDIAMoCzIlLm1ldHJpY3NfZXhwbG9yZXIuUmFuZ2VEYXRhLl'
    'RhZ3NFbnRyeVIEdGFncxIWCgZwb2ludHMYBCADKAFSBnBvaW50cxIfCgtjb25zdF92YWx1ZRgF'
    'IAEoAVIKY29uc3RWYWx1ZRI9CgttZXRyaWNfdHlwZRgGIAEoDjIcLm1ldHJpY3NfZXhwbG9yZX'
    'IuTWV0cmljVHlwZVIKbWV0cmljVHlwZRo3CglUYWdzRW50cnkSEAoDa2V5GAEgASgJUgNrZXkS'
    'FAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use queryResultDescriptor instead')
const QueryResult$json = {
  '1': 'QueryResult',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {
      '1': 'datas',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.metrics_explorer.RangeData',
      '10': 'datas'
    },
  ],
};

/// Descriptor for `QueryResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryResultDescriptor = $convert.base64Decode(
    'CgtRdWVyeVJlc3VsdBISCgRjb2RlGAEgASgFUgRjb2RlEhgKB21lc3NhZ2UYAiABKAlSB21lc3'
    'NhZ2USMQoFZGF0YXMYAyADKAsyGy5tZXRyaWNzX2V4cGxvcmVyLlJhbmdlRGF0YVIFZGF0YXM=');

@$core.Deprecated('Use getRangeByDatasourceResponseDescriptor instead')
const GetRangeByDatasourceResponse$json = {
  '1': 'GetRangeByDatasourceResponse',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {
      '1': 'queries_result',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.metrics_explorer.QueryResult',
      '10': 'queriesResult'
    },
    {'1': 'timestamps', '3': 4, '4': 3, '5': 3, '10': 'timestamps'},
  ],
};

/// Descriptor for `GetRangeByDatasourceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRangeByDatasourceResponseDescriptor = $convert.base64Decode(
    'ChxHZXRSYW5nZUJ5RGF0YXNvdXJjZVJlc3BvbnNlEhIKBGNvZGUYASABKAVSBGNvZGUSGAoHbW'
    'Vzc2FnZRgCIAEoCVIHbWVzc2FnZRJECg5xdWVyaWVzX3Jlc3VsdBgDIAMoCzIdLm1ldHJpY3Nf'
    'ZXhwbG9yZXIuUXVlcnlSZXN1bHRSDXF1ZXJpZXNSZXN1bHQSHgoKdGltZXN0YW1wcxgEIAMoA1'
    'IKdGltZXN0YW1wcw==');

@$core.Deprecated('Use getMenuListRequestDescriptor instead')
const GetMenuListRequest$json = {
  '1': 'GetMenuListRequest',
  '2': [
    {'1': 'session', '3': 1, '4': 1, '5': 9, '10': 'session'},
  ],
};

/// Descriptor for `GetMenuListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMenuListRequestDescriptor =
    $convert.base64Decode(
        'ChJHZXRNZW51TGlzdFJlcXVlc3QSGAoHc2Vzc2lvbhgBIAEoCVIHc2Vzc2lvbg==');

@$core.Deprecated('Use menuDescriptor instead')
const Menu$json = {
  '1': 'Menu',
  '2': [
    {'1': 'menu_id', '3': 1, '4': 1, '5': 4, '10': 'menuId'},
    {'1': 'menu_name', '3': 2, '4': 1, '5': 9, '10': 'menuName'},
    {'1': 'parent_id', '3': 3, '4': 1, '5': 4, '10': 'parentId'},
    {'1': 'role_id', '3': 4, '4': 1, '5': 4, '10': 'roleId'},
    {'1': 'link', '3': 5, '4': 1, '5': 9, '10': 'link'},
    {'1': 'target', '3': 6, '4': 1, '5': 9, '10': 'target'},
    {'1': 'bit_flags', '3': 7, '4': 1, '5': 4, '10': 'bitFlags'},
  ],
};

/// Descriptor for `Menu`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List menuDescriptor = $convert.base64Decode(
    'CgRNZW51EhcKB21lbnVfaWQYASABKARSBm1lbnVJZBIbCgltZW51X25hbWUYAiABKAlSCG1lbn'
    'VOYW1lEhsKCXBhcmVudF9pZBgDIAEoBFIIcGFyZW50SWQSFwoHcm9sZV9pZBgEIAEoBFIGcm9s'
    'ZUlkEhIKBGxpbmsYBSABKAlSBGxpbmsSFgoGdGFyZ2V0GAYgASgJUgZ0YXJnZXQSGwoJYml0X2'
    'ZsYWdzGAcgASgEUghiaXRGbGFncw==');

@$core.Deprecated('Use getMenuListResponseDescriptor instead')
const GetMenuListResponse$json = {
  '1': 'GetMenuListResponse',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {
      '1': 'menus',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.metrics_explorer.Menu',
      '10': 'menus'
    },
  ],
};

/// Descriptor for `GetMenuListResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMenuListResponseDescriptor = $convert.base64Decode(
    'ChNHZXRNZW51TGlzdFJlc3BvbnNlEhIKBGNvZGUYASABKAVSBGNvZGUSGAoHbWVzc2FnZRgCIA'
    'EoCVIHbWVzc2FnZRIsCgVtZW51cxgDIAMoCzIWLm1ldHJpY3NfZXhwbG9yZXIuTWVudVIFbWVu'
    'dXM=');

@$core.Deprecated('Use addMenuRequestDescriptor instead')
const AddMenuRequest$json = {
  '1': 'AddMenuRequest',
  '2': [
    {'1': 'session', '3': 1, '4': 1, '5': 9, '10': 'session'},
    {
      '1': 'menu',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.metrics_explorer.Menu',
      '10': 'menu'
    },
  ],
};

/// Descriptor for `AddMenuRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addMenuRequestDescriptor = $convert.base64Decode(
    'Cg5BZGRNZW51UmVxdWVzdBIYCgdzZXNzaW9uGAEgASgJUgdzZXNzaW9uEioKBG1lbnUYAiABKA'
    'syFi5tZXRyaWNzX2V4cGxvcmVyLk1lbnVSBG1lbnU=');

@$core.Deprecated('Use addMenuResponseDescriptor instead')
const AddMenuResponse$json = {
  '1': 'AddMenuResponse',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `AddMenuResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addMenuResponseDescriptor = $convert.base64Decode(
    'Cg9BZGRNZW51UmVzcG9uc2USEgoEY29kZRgBIAEoBVIEY29kZRIYCgdtZXNzYWdlGAIgASgJUg'
    'dtZXNzYWdl');

@$core.Deprecated('Use removeMenuRequestDescriptor instead')
const RemoveMenuRequest$json = {
  '1': 'RemoveMenuRequest',
  '2': [
    {'1': 'session', '3': 1, '4': 1, '5': 9, '10': 'session'},
    {'1': 'menu_id', '3': 2, '4': 1, '5': 4, '10': 'menuId'},
  ],
};

/// Descriptor for `RemoveMenuRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeMenuRequestDescriptor = $convert.base64Decode(
    'ChFSZW1vdmVNZW51UmVxdWVzdBIYCgdzZXNzaW9uGAEgASgJUgdzZXNzaW9uEhcKB21lbnVfaW'
    'QYAiABKARSBm1lbnVJZA==');

@$core.Deprecated('Use removeMenuResponseDescriptor instead')
const RemoveMenuResponse$json = {
  '1': 'RemoveMenuResponse',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `RemoveMenuResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeMenuResponseDescriptor = $convert.base64Decode(
    'ChJSZW1vdmVNZW51UmVzcG9uc2USEgoEY29kZRgBIAEoBVIEY29kZRIYCgdtZXNzYWdlGAIgAS'
    'gJUgdtZXNzYWdl');

@$core.Deprecated('Use modifyMenuRequestDescriptor instead')
const ModifyMenuRequest$json = {
  '1': 'ModifyMenuRequest',
  '2': [
    {'1': 'session', '3': 1, '4': 1, '5': 9, '10': 'session'},
    {
      '1': 'menu',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.metrics_explorer.Menu',
      '10': 'menu'
    },
  ],
};

/// Descriptor for `ModifyMenuRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List modifyMenuRequestDescriptor = $convert.base64Decode(
    'ChFNb2RpZnlNZW51UmVxdWVzdBIYCgdzZXNzaW9uGAEgASgJUgdzZXNzaW9uEioKBG1lbnUYAi'
    'ABKAsyFi5tZXRyaWNzX2V4cGxvcmVyLk1lbnVSBG1lbnU=');

@$core.Deprecated('Use modifyMenuResponseDescriptor instead')
const ModifyMenuResponse$json = {
  '1': 'ModifyMenuResponse',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `ModifyMenuResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List modifyMenuResponseDescriptor = $convert.base64Decode(
    'ChJNb2RpZnlNZW51UmVzcG9uc2USEgoEY29kZRgBIAEoBVIEY29kZRIYCgdtZXNzYWdlGAIgAS'
    'gJUgdtZXNzYWdl');

@$core.Deprecated('Use loadMenuTreeRequestDescriptor instead')
const LoadMenuTreeRequest$json = {
  '1': 'LoadMenuTreeRequest',
  '2': [
    {'1': 'session', '3': 1, '4': 1, '5': 9, '10': 'session'},
  ],
};

/// Descriptor for `LoadMenuTreeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loadMenuTreeRequestDescriptor =
    $convert.base64Decode(
        'ChNMb2FkTWVudVRyZWVSZXF1ZXN0EhgKB3Nlc3Npb24YASABKAlSB3Nlc3Npb24=');

@$core.Deprecated('Use menuTreeNodeDescriptor instead')
const MenuTreeNode$json = {
  '1': 'MenuTreeNode',
  '2': [
    {'1': 'menu_id', '3': 1, '4': 1, '5': 4, '10': 'menuId'},
    {'1': 'menu_name', '3': 2, '4': 1, '5': 9, '10': 'menuName'},
    {'1': 'link', '3': 3, '4': 1, '5': 9, '10': 'link'},
    {'1': 'target', '3': 4, '4': 1, '5': 9, '10': 'target'},
    {'1': 'bit_flags', '3': 5, '4': 1, '5': 4, '10': 'bitFlags'},
    {
      '1': 'children',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.metrics_explorer.MenuTreeNode',
      '10': 'children'
    },
  ],
};

/// Descriptor for `MenuTreeNode`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List menuTreeNodeDescriptor = $convert.base64Decode(
    'CgxNZW51VHJlZU5vZGUSFwoHbWVudV9pZBgBIAEoBFIGbWVudUlkEhsKCW1lbnVfbmFtZRgCIA'
    'EoCVIIbWVudU5hbWUSEgoEbGluaxgDIAEoCVIEbGluaxIWCgZ0YXJnZXQYBCABKAlSBnRhcmdl'
    'dBIbCgliaXRfZmxhZ3MYBSABKARSCGJpdEZsYWdzEjoKCGNoaWxkcmVuGAYgAygLMh4ubWV0cm'
    'ljc19leHBsb3Jlci5NZW51VHJlZU5vZGVSCGNoaWxkcmVu');

@$core.Deprecated('Use loadMenuTreeResponseDescriptor instead')
const LoadMenuTreeResponse$json = {
  '1': 'LoadMenuTreeResponse',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {
      '1': 'menus',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.metrics_explorer.MenuTreeNode',
      '10': 'menus'
    },
  ],
};

/// Descriptor for `LoadMenuTreeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loadMenuTreeResponseDescriptor = $convert.base64Decode(
    'ChRMb2FkTWVudVRyZWVSZXNwb25zZRISCgRjb2RlGAEgASgFUgRjb2RlEhgKB21lc3NhZ2UYAi'
    'ABKAlSB21lc3NhZ2USNAoFbWVudXMYAyABKAsyHi5tZXRyaWNzX2V4cGxvcmVyLk1lbnVUcmVl'
    'Tm9kZVIFbWVudXM=');
