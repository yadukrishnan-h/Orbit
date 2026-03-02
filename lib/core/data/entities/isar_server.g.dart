// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_server.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarServerCollection on Isar {
  IsarCollection<IsarServer> get isarServers => this.collection();
}

const IsarServerSchema = CollectionSchema(
  name: r'IsarServer',
  id: 8427066577884360816,
  properties: {
    r'authType': PropertySchema(
      id: 0,
      name: r'authType',
      type: IsarType.string,
      enumMap: _IsarServerauthTypeEnumValueMap,
    ),
    r'hostname': PropertySchema(
      id: 1,
      name: r'hostname',
      type: IsarType.string,
    ),
    r'hostnameInfo': PropertySchema(
      id: 2,
      name: r'hostnameInfo',
      type: IsarType.string,
    ),
    r'ipAddress': PropertySchema(
      id: 3,
      name: r'ipAddress',
      type: IsarType.string,
    ),
    r'kernelVersion': PropertySchema(
      id: 4,
      name: r'kernelVersion',
      type: IsarType.string,
    ),
    r'lastCpu': PropertySchema(
      id: 5,
      name: r'lastCpu',
      type: IsarType.double,
    ),
    r'lastDisk': PropertySchema(
      id: 6,
      name: r'lastDisk',
      type: IsarType.double,
    ),
    r'lastDiskTotal': PropertySchema(
      id: 7,
      name: r'lastDiskTotal',
      type: IsarType.long,
    ),
    r'lastDiskUsed': PropertySchema(
      id: 8,
      name: r'lastDiskUsed',
      type: IsarType.long,
    ),
    r'lastLatency': PropertySchema(
      id: 9,
      name: r'lastLatency',
      type: IsarType.long,
    ),
    r'lastRam': PropertySchema(
      id: 10,
      name: r'lastRam',
      type: IsarType.double,
    ),
    r'lastSeen': PropertySchema(
      id: 11,
      name: r'lastSeen',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(
      id: 12,
      name: r'name',
      type: IsarType.string,
    ),
    r'osDistro': PropertySchema(
      id: 13,
      name: r'osDistro',
      type: IsarType.string,
    ),
    r'password': PropertySchema(
      id: 14,
      name: r'password',
      type: IsarType.string,
    ),
    r'port': PropertySchema(
      id: 15,
      name: r'port',
      type: IsarType.long,
    ),
    r'serverLocation': PropertySchema(
      id: 16,
      name: r'serverLocation',
      type: IsarType.string,
    ),
    r'sortOrder': PropertySchema(
      id: 17,
      name: r'sortOrder',
      type: IsarType.long,
    ),
    r'status': PropertySchema(
      id: 18,
      name: r'status',
      type: IsarType.string,
      enumMap: _IsarServerstatusEnumValueMap,
    ),
    r'uptime': PropertySchema(
      id: 19,
      name: r'uptime',
      type: IsarType.string,
    ),
    r'username': PropertySchema(
      id: 20,
      name: r'username',
      type: IsarType.string,
    ),
    r'uuid': PropertySchema(
      id: 21,
      name: r'uuid',
      type: IsarType.string,
    )
  },
  estimateSize: _isarServerEstimateSize,
  serialize: _isarServerSerialize,
  deserialize: _isarServerDeserialize,
  deserializeProp: _isarServerDeserializeProp,
  idName: r'id',
  indexes: {
    r'uuid': IndexSchema(
      id: 2134397340427724972,
      name: r'uuid',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'uuid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarServerGetId,
  getLinks: _isarServerGetLinks,
  attach: _isarServerAttach,
  version: '3.1.0+1',
);

int _isarServerEstimateSize(
  IsarServer object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.authType.name.length * 3;
  bytesCount += 3 + object.hostname.length * 3;
  {
    final value = object.hostnameInfo;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.ipAddress;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.kernelVersion;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.osDistro;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.password.length * 3;
  {
    final value = object.serverLocation;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.name.length * 3;
  {
    final value = object.uptime;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.username.length * 3;
  bytesCount += 3 + object.uuid.length * 3;
  return bytesCount;
}

void _isarServerSerialize(
  IsarServer object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.authType.name);
  writer.writeString(offsets[1], object.hostname);
  writer.writeString(offsets[2], object.hostnameInfo);
  writer.writeString(offsets[3], object.ipAddress);
  writer.writeString(offsets[4], object.kernelVersion);
  writer.writeDouble(offsets[5], object.lastCpu);
  writer.writeDouble(offsets[6], object.lastDisk);
  writer.writeLong(offsets[7], object.lastDiskTotal);
  writer.writeLong(offsets[8], object.lastDiskUsed);
  writer.writeLong(offsets[9], object.lastLatency);
  writer.writeDouble(offsets[10], object.lastRam);
  writer.writeDateTime(offsets[11], object.lastSeen);
  writer.writeString(offsets[12], object.name);
  writer.writeString(offsets[13], object.osDistro);
  writer.writeString(offsets[14], object.password);
  writer.writeLong(offsets[15], object.port);
  writer.writeString(offsets[16], object.serverLocation);
  writer.writeLong(offsets[17], object.sortOrder);
  writer.writeString(offsets[18], object.status.name);
  writer.writeString(offsets[19], object.uptime);
  writer.writeString(offsets[20], object.username);
  writer.writeString(offsets[21], object.uuid);
}

IsarServer _isarServerDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarServer();
  object.authType =
      _IsarServerauthTypeValueEnumMap[reader.readStringOrNull(offsets[0])] ??
          AuthType.password;
  object.hostname = reader.readString(offsets[1]);
  object.hostnameInfo = reader.readStringOrNull(offsets[2]);
  object.id = id;
  object.ipAddress = reader.readStringOrNull(offsets[3]);
  object.kernelVersion = reader.readStringOrNull(offsets[4]);
  object.lastCpu = reader.readDoubleOrNull(offsets[5]);
  object.lastDisk = reader.readDoubleOrNull(offsets[6]);
  object.lastDiskTotal = reader.readLongOrNull(offsets[7]);
  object.lastDiskUsed = reader.readLongOrNull(offsets[8]);
  object.lastLatency = reader.readLongOrNull(offsets[9]);
  object.lastRam = reader.readDoubleOrNull(offsets[10]);
  object.lastSeen = reader.readDateTimeOrNull(offsets[11]);
  object.name = reader.readString(offsets[12]);
  object.osDistro = reader.readStringOrNull(offsets[13]);
  object.password = reader.readString(offsets[14]);
  object.port = reader.readLong(offsets[15]);
  object.serverLocation = reader.readStringOrNull(offsets[16]);
  object.sortOrder = reader.readLong(offsets[17]);
  object.status =
      _IsarServerstatusValueEnumMap[reader.readStringOrNull(offsets[18])] ??
          ServerStatus.unknown;
  object.uptime = reader.readStringOrNull(offsets[19]);
  object.username = reader.readString(offsets[20]);
  object.uuid = reader.readString(offsets[21]);
  return object;
}

P _isarServerDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_IsarServerauthTypeValueEnumMap[
              reader.readStringOrNull(offset)] ??
          AuthType.password) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    case 6:
      return (reader.readDoubleOrNull(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readDoubleOrNull(offset)) as P;
    case 11:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readLong(offset)) as P;
    case 18:
      return (_IsarServerstatusValueEnumMap[reader.readStringOrNull(offset)] ??
          ServerStatus.unknown) as P;
    case 19:
      return (reader.readStringOrNull(offset)) as P;
    case 20:
      return (reader.readString(offset)) as P;
    case 21:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _IsarServerauthTypeEnumValueMap = {
  r'password': r'password',
  r'key': r'key',
};
const _IsarServerauthTypeValueEnumMap = {
  r'password': AuthType.password,
  r'key': AuthType.key,
};
const _IsarServerstatusEnumValueMap = {
  r'unknown': r'unknown',
  r'online': r'online',
  r'offline': r'offline',
  r'error': r'error',
};
const _IsarServerstatusValueEnumMap = {
  r'unknown': ServerStatus.unknown,
  r'online': ServerStatus.online,
  r'offline': ServerStatus.offline,
  r'error': ServerStatus.error,
};

Id _isarServerGetId(IsarServer object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarServerGetLinks(IsarServer object) {
  return [];
}

void _isarServerAttach(IsarCollection<dynamic> col, Id id, IsarServer object) {
  object.id = id;
}

extension IsarServerByIndex on IsarCollection<IsarServer> {
  Future<IsarServer?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  IsarServer? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<IsarServer?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<IsarServer?> getAllByUuidSync(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uuid', values);
  }

  Future<int> deleteAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uuid', values);
  }

  int deleteAllByUuidSync(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uuid', values);
  }

  Future<Id> putByUuid(IsarServer object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(IsarServer object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<IsarServer> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(List<IsarServer> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }
}

extension IsarServerQueryWhereSort
    on QueryBuilder<IsarServer, IsarServer, QWhere> {
  QueryBuilder<IsarServer, IsarServer, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarServerQueryWhere
    on QueryBuilder<IsarServer, IsarServer, QWhereClause> {
  QueryBuilder<IsarServer, IsarServer, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<IsarServer, IsarServer, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterWhereClause> idBetween(
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

  QueryBuilder<IsarServer, IsarServer, QAfterWhereClause> uuidEqualTo(
      String uuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uuid',
        value: [uuid],
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterWhereClause> uuidNotEqualTo(
      String uuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [],
              upper: [uuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [uuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [uuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [],
              upper: [uuid],
              includeUpper: false,
            ));
      }
    });
  }
}

extension IsarServerQueryFilter
    on QueryBuilder<IsarServer, IsarServer, QFilterCondition> {
  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> authTypeEqualTo(
    AuthType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'authType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      authTypeGreaterThan(
    AuthType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'authType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> authTypeLessThan(
    AuthType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'authType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> authTypeBetween(
    AuthType lower,
    AuthType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'authType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      authTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'authType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> authTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'authType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> authTypeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'authType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> authTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'authType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      authTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'authType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      authTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'authType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> hostnameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hostname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      hostnameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hostname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> hostnameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hostname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> hostnameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hostname',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      hostnameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'hostname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> hostnameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'hostname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> hostnameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'hostname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> hostnameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'hostname',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      hostnameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hostname',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      hostnameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'hostname',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      hostnameInfoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'hostnameInfo',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      hostnameInfoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'hostnameInfo',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      hostnameInfoEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hostnameInfo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      hostnameInfoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hostnameInfo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      hostnameInfoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hostnameInfo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      hostnameInfoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hostnameInfo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      hostnameInfoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'hostnameInfo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      hostnameInfoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'hostnameInfo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      hostnameInfoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'hostnameInfo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      hostnameInfoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'hostnameInfo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      hostnameInfoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hostnameInfo',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      hostnameInfoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'hostnameInfo',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> idBetween(
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

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      ipAddressIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ipAddress',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      ipAddressIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ipAddress',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> ipAddressEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ipAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      ipAddressGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ipAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> ipAddressLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ipAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> ipAddressBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ipAddress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      ipAddressStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ipAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> ipAddressEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ipAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> ipAddressContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ipAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> ipAddressMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ipAddress',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      ipAddressIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ipAddress',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      ipAddressIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ipAddress',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      kernelVersionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'kernelVersion',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      kernelVersionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'kernelVersion',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      kernelVersionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kernelVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      kernelVersionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'kernelVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      kernelVersionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'kernelVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      kernelVersionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'kernelVersion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      kernelVersionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'kernelVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      kernelVersionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'kernelVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      kernelVersionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'kernelVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      kernelVersionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'kernelVersion',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      kernelVersionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kernelVersion',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      kernelVersionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'kernelVersion',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> lastCpuIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastCpu',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      lastCpuIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastCpu',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> lastCpuEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastCpu',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      lastCpuGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastCpu',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> lastCpuLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastCpu',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> lastCpuBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastCpu',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> lastDiskIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastDisk',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      lastDiskIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastDisk',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> lastDiskEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastDisk',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      lastDiskGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastDisk',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> lastDiskLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastDisk',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> lastDiskBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastDisk',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      lastDiskTotalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastDiskTotal',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      lastDiskTotalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastDiskTotal',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      lastDiskTotalEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastDiskTotal',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      lastDiskTotalGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastDiskTotal',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      lastDiskTotalLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastDiskTotal',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      lastDiskTotalBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastDiskTotal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      lastDiskUsedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastDiskUsed',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      lastDiskUsedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastDiskUsed',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      lastDiskUsedEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastDiskUsed',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      lastDiskUsedGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastDiskUsed',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      lastDiskUsedLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastDiskUsed',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      lastDiskUsedBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastDiskUsed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      lastLatencyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastLatency',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      lastLatencyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastLatency',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      lastLatencyEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastLatency',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      lastLatencyGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastLatency',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      lastLatencyLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastLatency',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      lastLatencyBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastLatency',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> lastRamIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastRam',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      lastRamIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastRam',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> lastRamEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastRam',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      lastRamGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastRam',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> lastRamLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastRam',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> lastRamBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastRam',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> lastSeenIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSeen',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      lastSeenIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSeen',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> lastSeenEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSeen',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      lastSeenGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSeen',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> lastSeenLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSeen',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> lastSeenBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSeen',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> osDistroIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'osDistro',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      osDistroIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'osDistro',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> osDistroEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'osDistro',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      osDistroGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'osDistro',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> osDistroLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'osDistro',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> osDistroBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'osDistro',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      osDistroStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'osDistro',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> osDistroEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'osDistro',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> osDistroContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'osDistro',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> osDistroMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'osDistro',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      osDistroIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'osDistro',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      osDistroIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'osDistro',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> passwordEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'password',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      passwordGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'password',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> passwordLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'password',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> passwordBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'password',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      passwordStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'password',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> passwordEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'password',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> passwordContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'password',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> passwordMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'password',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      passwordIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'password',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      passwordIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'password',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> portEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'port',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> portGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'port',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> portLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'port',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> portBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'port',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      serverLocationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'serverLocation',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      serverLocationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'serverLocation',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      serverLocationEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverLocation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      serverLocationGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'serverLocation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      serverLocationLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'serverLocation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      serverLocationBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'serverLocation',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      serverLocationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'serverLocation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      serverLocationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'serverLocation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      serverLocationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'serverLocation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      serverLocationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'serverLocation',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      serverLocationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverLocation',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      serverLocationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serverLocation',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> sortOrderEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      sortOrderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> sortOrderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> sortOrderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sortOrder',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> statusEqualTo(
    ServerStatus value, {
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

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> statusGreaterThan(
    ServerStatus value, {
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

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> statusLessThan(
    ServerStatus value, {
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

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> statusBetween(
    ServerStatus lower,
    ServerStatus upper, {
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

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> statusStartsWith(
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

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> statusEndsWith(
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

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> statusContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> statusMatches(
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

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> uptimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'uptime',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      uptimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'uptime',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> uptimeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uptime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> uptimeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uptime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> uptimeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uptime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> uptimeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uptime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> uptimeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uptime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> uptimeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uptime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> uptimeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uptime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> uptimeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uptime',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> uptimeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uptime',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      uptimeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uptime',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> usernameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'username',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      usernameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'username',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> usernameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'username',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> usernameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'username',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      usernameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'username',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> usernameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'username',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> usernameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'username',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> usernameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'username',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      usernameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'username',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition>
      usernameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'username',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> uuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> uuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> uuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> uuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> uuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> uuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> uuidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> uuidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterFilterCondition> uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uuid',
        value: '',
      ));
    });
  }
}

extension IsarServerQueryObject
    on QueryBuilder<IsarServer, IsarServer, QFilterCondition> {}

extension IsarServerQueryLinks
    on QueryBuilder<IsarServer, IsarServer, QFilterCondition> {}

extension IsarServerQuerySortBy
    on QueryBuilder<IsarServer, IsarServer, QSortBy> {
  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByAuthType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authType', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByAuthTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authType', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByHostname() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hostname', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByHostnameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hostname', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByHostnameInfo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hostnameInfo', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByHostnameInfoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hostnameInfo', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByIpAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ipAddress', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByIpAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ipAddress', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByKernelVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kernelVersion', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByKernelVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kernelVersion', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByLastCpu() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCpu', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByLastCpuDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCpu', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByLastDisk() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDisk', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByLastDiskDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDisk', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByLastDiskTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDiskTotal', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByLastDiskTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDiskTotal', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByLastDiskUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDiskUsed', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByLastDiskUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDiskUsed', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByLastLatency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLatency', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByLastLatencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLatency', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByLastRam() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRam', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByLastRamDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRam', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByLastSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeen', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByLastSeenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeen', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByOsDistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'osDistro', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByOsDistroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'osDistro', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByPassword() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'password', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByPasswordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'password', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByPort() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'port', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByPortDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'port', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByServerLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverLocation', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy>
      sortByServerLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverLocation', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByUptime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uptime', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByUptimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uptime', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByUsername() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'username', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByUsernameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'username', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension IsarServerQuerySortThenBy
    on QueryBuilder<IsarServer, IsarServer, QSortThenBy> {
  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByAuthType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authType', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByAuthTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authType', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByHostname() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hostname', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByHostnameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hostname', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByHostnameInfo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hostnameInfo', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByHostnameInfoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hostnameInfo', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByIpAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ipAddress', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByIpAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ipAddress', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByKernelVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kernelVersion', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByKernelVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kernelVersion', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByLastCpu() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCpu', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByLastCpuDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCpu', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByLastDisk() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDisk', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByLastDiskDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDisk', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByLastDiskTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDiskTotal', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByLastDiskTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDiskTotal', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByLastDiskUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDiskUsed', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByLastDiskUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDiskUsed', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByLastLatency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLatency', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByLastLatencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLatency', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByLastRam() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRam', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByLastRamDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRam', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByLastSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeen', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByLastSeenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeen', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByOsDistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'osDistro', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByOsDistroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'osDistro', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByPassword() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'password', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByPasswordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'password', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByPort() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'port', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByPortDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'port', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByServerLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverLocation', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy>
      thenByServerLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverLocation', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByUptime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uptime', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByUptimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uptime', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByUsername() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'username', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByUsernameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'username', Sort.desc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QAfterSortBy> thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension IsarServerQueryWhereDistinct
    on QueryBuilder<IsarServer, IsarServer, QDistinct> {
  QueryBuilder<IsarServer, IsarServer, QDistinct> distinctByAuthType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'authType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QDistinct> distinctByHostname(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hostname', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QDistinct> distinctByHostnameInfo(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hostnameInfo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QDistinct> distinctByIpAddress(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ipAddress', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QDistinct> distinctByKernelVersion(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kernelVersion',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QDistinct> distinctByLastCpu() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastCpu');
    });
  }

  QueryBuilder<IsarServer, IsarServer, QDistinct> distinctByLastDisk() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastDisk');
    });
  }

  QueryBuilder<IsarServer, IsarServer, QDistinct> distinctByLastDiskTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastDiskTotal');
    });
  }

  QueryBuilder<IsarServer, IsarServer, QDistinct> distinctByLastDiskUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastDiskUsed');
    });
  }

  QueryBuilder<IsarServer, IsarServer, QDistinct> distinctByLastLatency() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastLatency');
    });
  }

  QueryBuilder<IsarServer, IsarServer, QDistinct> distinctByLastRam() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastRam');
    });
  }

  QueryBuilder<IsarServer, IsarServer, QDistinct> distinctByLastSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSeen');
    });
  }

  QueryBuilder<IsarServer, IsarServer, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QDistinct> distinctByOsDistro(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'osDistro', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QDistinct> distinctByPassword(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'password', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QDistinct> distinctByPort() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'port');
    });
  }

  QueryBuilder<IsarServer, IsarServer, QDistinct> distinctByServerLocation(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverLocation',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QDistinct> distinctBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortOrder');
    });
  }

  QueryBuilder<IsarServer, IsarServer, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QDistinct> distinctByUptime(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uptime', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QDistinct> distinctByUsername(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'username', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarServer, IsarServer, QDistinct> distinctByUuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }
}

extension IsarServerQueryProperty
    on QueryBuilder<IsarServer, IsarServer, QQueryProperty> {
  QueryBuilder<IsarServer, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarServer, AuthType, QQueryOperations> authTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'authType');
    });
  }

  QueryBuilder<IsarServer, String, QQueryOperations> hostnameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hostname');
    });
  }

  QueryBuilder<IsarServer, String?, QQueryOperations> hostnameInfoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hostnameInfo');
    });
  }

  QueryBuilder<IsarServer, String?, QQueryOperations> ipAddressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ipAddress');
    });
  }

  QueryBuilder<IsarServer, String?, QQueryOperations> kernelVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kernelVersion');
    });
  }

  QueryBuilder<IsarServer, double?, QQueryOperations> lastCpuProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastCpu');
    });
  }

  QueryBuilder<IsarServer, double?, QQueryOperations> lastDiskProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastDisk');
    });
  }

  QueryBuilder<IsarServer, int?, QQueryOperations> lastDiskTotalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastDiskTotal');
    });
  }

  QueryBuilder<IsarServer, int?, QQueryOperations> lastDiskUsedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastDiskUsed');
    });
  }

  QueryBuilder<IsarServer, int?, QQueryOperations> lastLatencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastLatency');
    });
  }

  QueryBuilder<IsarServer, double?, QQueryOperations> lastRamProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastRam');
    });
  }

  QueryBuilder<IsarServer, DateTime?, QQueryOperations> lastSeenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSeen');
    });
  }

  QueryBuilder<IsarServer, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<IsarServer, String?, QQueryOperations> osDistroProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'osDistro');
    });
  }

  QueryBuilder<IsarServer, String, QQueryOperations> passwordProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'password');
    });
  }

  QueryBuilder<IsarServer, int, QQueryOperations> portProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'port');
    });
  }

  QueryBuilder<IsarServer, String?, QQueryOperations> serverLocationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverLocation');
    });
  }

  QueryBuilder<IsarServer, int, QQueryOperations> sortOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortOrder');
    });
  }

  QueryBuilder<IsarServer, ServerStatus, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<IsarServer, String?, QQueryOperations> uptimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uptime');
    });
  }

  QueryBuilder<IsarServer, String, QQueryOperations> usernameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'username');
    });
  }

  QueryBuilder<IsarServer, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }
}
