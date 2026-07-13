// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_capture.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetInboxCaptureCollection on Isar {
  IsarCollection<InboxCapture> get inboxCaptures => this.collection();
}

const InboxCaptureSchema = CollectionSchema(
  name: r'InboxCapture',
  id: 6533183035628840319,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'errorMessage': PropertySchema(
      id: 1,
      name: r'errorMessage',
      type: IsarType.string,
    ),
    r'parsedJson': PropertySchema(
      id: 2,
      name: r'parsedJson',
      type: IsarType.string,
    ),
    r'parsedType': PropertySchema(
      id: 3,
      name: r'parsedType',
      type: IsarType.string,
    ),
    r'rawText': PropertySchema(
      id: 4,
      name: r'rawText',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 5,
      name: r'status',
      type: IsarType.string,
    )
  },
  estimateSize: _inboxCaptureEstimateSize,
  serialize: _inboxCaptureSerialize,
  deserialize: _inboxCaptureDeserialize,
  deserializeProp: _inboxCaptureDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _inboxCaptureGetId,
  getLinks: _inboxCaptureGetLinks,
  attach: _inboxCaptureAttach,
  version: '3.1.0+1',
);

int _inboxCaptureEstimateSize(
  InboxCapture object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.errorMessage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.parsedJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.parsedType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.rawText.length * 3;
  bytesCount += 3 + object.status.length * 3;
  return bytesCount;
}

void _inboxCaptureSerialize(
  InboxCapture object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.errorMessage);
  writer.writeString(offsets[2], object.parsedJson);
  writer.writeString(offsets[3], object.parsedType);
  writer.writeString(offsets[4], object.rawText);
  writer.writeString(offsets[5], object.status);
}

InboxCapture _inboxCaptureDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = InboxCapture();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.errorMessage = reader.readStringOrNull(offsets[1]);
  object.id = id;
  object.parsedJson = reader.readStringOrNull(offsets[2]);
  object.parsedType = reader.readStringOrNull(offsets[3]);
  object.rawText = reader.readString(offsets[4]);
  object.status = reader.readString(offsets[5]);
  return object;
}

P _inboxCaptureDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _inboxCaptureGetId(InboxCapture object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _inboxCaptureGetLinks(InboxCapture object) {
  return [];
}

void _inboxCaptureAttach(
    IsarCollection<dynamic> col, Id id, InboxCapture object) {
  object.id = id;
}

extension InboxCaptureQueryWhereSort
    on QueryBuilder<InboxCapture, InboxCapture, QWhere> {
  QueryBuilder<InboxCapture, InboxCapture, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension InboxCaptureQueryWhere
    on QueryBuilder<InboxCapture, InboxCapture, QWhereClause> {
  QueryBuilder<InboxCapture, InboxCapture, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension InboxCaptureQueryFilter
    on QueryBuilder<InboxCapture, InboxCapture, QFilterCondition> {
  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      errorMessageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'errorMessage',
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      errorMessageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'errorMessage',
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      errorMessageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      errorMessageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      errorMessageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      errorMessageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'errorMessage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      errorMessageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      errorMessageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      errorMessageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      errorMessageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'errorMessage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      errorMessageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      errorMessageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'errorMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      parsedJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'parsedJson',
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      parsedJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'parsedJson',
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      parsedJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parsedJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      parsedJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'parsedJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      parsedJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'parsedJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      parsedJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'parsedJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      parsedJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'parsedJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      parsedJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'parsedJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      parsedJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'parsedJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      parsedJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'parsedJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      parsedJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parsedJson',
        value: '',
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      parsedJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'parsedJson',
        value: '',
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      parsedTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'parsedType',
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      parsedTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'parsedType',
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      parsedTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parsedType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      parsedTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'parsedType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      parsedTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'parsedType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      parsedTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'parsedType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      parsedTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'parsedType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      parsedTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'parsedType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      parsedTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'parsedType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      parsedTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'parsedType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      parsedTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parsedType',
        value: '',
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      parsedTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'parsedType',
        value: '',
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      rawTextEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rawText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      rawTextGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rawText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      rawTextLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rawText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      rawTextBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rawText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      rawTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rawText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      rawTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rawText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      rawTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rawText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      rawTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rawText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      rawTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rawText',
        value: '',
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      rawTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rawText',
        value: '',
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition> statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition> statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition> statusMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }
}

extension InboxCaptureQueryObject
    on QueryBuilder<InboxCapture, InboxCapture, QFilterCondition> {}

extension InboxCaptureQueryLinks
    on QueryBuilder<InboxCapture, InboxCapture, QFilterCondition> {}

extension InboxCaptureQuerySortBy
    on QueryBuilder<InboxCapture, InboxCapture, QSortBy> {
  QueryBuilder<InboxCapture, InboxCapture, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterSortBy> sortByErrorMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.asc);
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterSortBy>
      sortByErrorMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.desc);
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterSortBy> sortByParsedJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedJson', Sort.asc);
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterSortBy>
      sortByParsedJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedJson', Sort.desc);
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterSortBy> sortByParsedType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedType', Sort.asc);
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterSortBy>
      sortByParsedTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedType', Sort.desc);
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterSortBy> sortByRawText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawText', Sort.asc);
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterSortBy> sortByRawTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawText', Sort.desc);
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension InboxCaptureQuerySortThenBy
    on QueryBuilder<InboxCapture, InboxCapture, QSortThenBy> {
  QueryBuilder<InboxCapture, InboxCapture, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterSortBy> thenByErrorMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.asc);
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterSortBy>
      thenByErrorMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.desc);
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterSortBy> thenByParsedJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedJson', Sort.asc);
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterSortBy>
      thenByParsedJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedJson', Sort.desc);
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterSortBy> thenByParsedType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedType', Sort.asc);
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterSortBy>
      thenByParsedTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedType', Sort.desc);
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterSortBy> thenByRawText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawText', Sort.asc);
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterSortBy> thenByRawTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawText', Sort.desc);
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension InboxCaptureQueryWhereDistinct
    on QueryBuilder<InboxCapture, InboxCapture, QDistinct> {
  QueryBuilder<InboxCapture, InboxCapture, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QDistinct> distinctByErrorMessage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'errorMessage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QDistinct> distinctByParsedJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parsedJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QDistinct> distinctByParsedType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parsedType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QDistinct> distinctByRawText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rawText', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InboxCapture, InboxCapture, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }
}

extension InboxCaptureQueryProperty
    on QueryBuilder<InboxCapture, InboxCapture, QQueryProperty> {
  QueryBuilder<InboxCapture, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<InboxCapture, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<InboxCapture, String?, QQueryOperations> errorMessageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'errorMessage');
    });
  }

  QueryBuilder<InboxCapture, String?, QQueryOperations> parsedJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parsedJson');
    });
  }

  QueryBuilder<InboxCapture, String?, QQueryOperations> parsedTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parsedType');
    });
  }

  QueryBuilder<InboxCapture, String, QQueryOperations> rawTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rawText');
    });
  }

  QueryBuilder<InboxCapture, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }
}
