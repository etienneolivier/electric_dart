import 'package:electricsql/src/util/types.dart';
import 'package:equatable/equatable.dart';

const kSubscriptionDelivered = 'subscription_delivered';
const kSubscriptionError = 'subscription_error';

typedef SubscriptionId = String;

typedef SubscriptionDeliveredCallback = void Function(SubscriptionData data);
typedef SubscriptionErrorCallback = void Function(SubscriptionErrorData error);

class SubscriptionErrorData {
  final SubscriptionId? subscriptionId;
  final SatelliteException error;

  SubscriptionErrorData({
    required this.subscriptionId,
    required this.error,
  });
}

class SubscribeResponse {
  final SubscriptionId subscriptionId;
  final SatelliteException? error;

  SubscribeResponse({
    required this.subscriptionId,
    required this.error,
  });
}

class UnsubscribeResponse with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class ClientShapeDefinition with EquatableMixin {
  final List<ShapeSelect> selects;

  ClientShapeDefinition({
    required this.selects,
  });

  @override
  List<Object?> get props => [selects];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'selects': selects.map((x) => x.toMap()).toList(),
    };
  }

  factory ClientShapeDefinition.fromMap(Map<String, dynamic> map) {
    return ClientShapeDefinition(
      selects: List<ShapeSelect>.from(
        (map['selects'] as List<dynamic>).map<ShapeSelect>(
          (x) => ShapeSelect.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }
}

sealed class ShapeRequestOrDefinition with EquatableMixin {
  final ClientShapeDefinition definition;

  ShapeRequestOrDefinition({
    required this.definition,
  });

  @override
  List<Object?> get props => [definition];
}

class ShapeRequest extends ShapeRequestOrDefinition {
  final String requestId;

  ShapeRequest({
    required this.requestId,
    required super.definition,
  });

  @override
  List<Object?> get props => [...super.props, requestId];
}

class ShapeDefinition extends ShapeRequestOrDefinition {
  final String uuid;

  ShapeDefinition({
    required this.uuid,
    required super.definition,
  });

  @override
  List<Object?> get props => [...super.props, uuid];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'definition': definition.toMap(),
      'uuid': uuid,
    };
  }

  factory ShapeDefinition.fromMap(Map<String, dynamic> map) {
    return ShapeDefinition(
      uuid: map['uuid'] as String,
      definition: ClientShapeDefinition.fromMap(
        map['definition'] as Map<String, dynamic>,
      ),
    );
  }
}

class ShapeSelect with EquatableMixin {
  final String tablename;

  ShapeSelect({
    required this.tablename,
  });

  @override
  List<Object?> get props => [tablename];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tablename': tablename,
    };
  }

  factory ShapeSelect.fromMap(Map<String, dynamic> map) {
    return ShapeSelect(
      tablename: map['tablename'] as String,
    );
  }
}

class SubscriptionData {
  final SubscriptionId subscriptionId;
  final List<int> lsn;
  final List<InitialDataChange> data;
  final Map<String, String> shapeReqToUuid;

  SubscriptionData({
    required this.subscriptionId,
    required this.lsn,
    required this.data,
    required this.shapeReqToUuid,
  });
}

class InitialDataChange {
  final Relation relation;
  final Record record;
  final List<Tag> tags;

  InitialDataChange({
    required this.relation,
    required this.record,
    required this.tags,
  });
}
