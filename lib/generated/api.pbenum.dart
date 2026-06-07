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

import 'package:protobuf/protobuf.dart' as $pb;

class MetricType extends $pb.ProtobufEnum {
  static const MetricType Unknown =
      MetricType._(0, _omitEnumNames ? '' : 'Unknown');
  static const MetricType Counter =
      MetricType._(1, _omitEnumNames ? '' : 'Counter');
  static const MetricType StaticValue =
      MetricType._(2, _omitEnumNames ? '' : 'StaticValue');
  static const MetricType Histogram =
      MetricType._(3, _omitEnumNames ? '' : 'Histogram');

  static const $core.List<MetricType> values = <MetricType>[
    Unknown,
    Counter,
    StaticValue,
    Histogram,
  ];

  static final $core.List<MetricType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static MetricType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MetricType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
