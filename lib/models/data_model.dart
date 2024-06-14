class Data {
  Data(
      this.no,
      this.node_id,
      this.latitude,
      this.longitude,
      this.altitude,
      this.sog,
      this.cog,
      this.temperature,
      this.humidity,
      this.roll,
      this.pitch,
      this.yaw,
      this.tank_volume,
      this.current,
      this.flow,
      this.status,
      this.created_at);
  @override
  String toString() {
    return "$node_id, $latitude, $longitude, $altitude, $sog, $cog, $temperature, $humidity, $roll, $pitch, $yaw, $tank_volume, $current, $flow";
  }

  int no;
  String node_id;
  double latitude;
  double longitude;
  double altitude;
  double sog;
  double cog;
  double temperature;
  double humidity;
  double roll;
  double pitch;
  double yaw;
  double tank_volume;
  double current;
  double flow;
  int status;
  String? created_at;

  Map<String, dynamic> toMap() {
    return {
      'node_id': node_id,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'sog': sog,
      'cog': cog,
      'temperature': temperature,
      'humidity': humidity,
      'roll': roll,
      'pitch': pitch,
      'yaw': yaw,
      'tank_volume': tank_volume,
      'current': current,
      'flow': flow,
      'status': status
    };
  }

  Map<String, dynamic> toMapUpdate() {
    return {
      'id': no,
      'node_id': node_id,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'sog': sog,
      'cog': cog,
      'temperature': temperature,
      'humidity': humidity,
      'roll': roll,
      'pitch': pitch,
      'yaw': yaw,
      'tank_volume': tank_volume,
      'current': current,
      'flow': flow,
      'status': status
    };
  }

  factory Data.fromMap(Map<String, dynamic> map) {
    return Data(
      map['id'],
      map['node_id'],
      map['latitude'],
      map['longitude'],
      map['altitude'],
      map['sog'],
      map['cog'],
      map['temperature'],
      map['humidity'],
      map['roll'],
      map['pitch'],
      map['yaw'],
      map['tank_volume'],
      map['current'],
      map['flow'],
      map['status'],
      map['created_at'],
    );
  }

  String toStringData() {
    return '''
      id: $no,
      node_id: $node_id,
      latitude: $latitude,
      longitude: $longitude,
      altitude: $altitude,
      sog: $sog,
      cog: $cog,
      temperature: $temperature,
      humidity: $humidity,
      roll: $roll,
      pitch: $pitch,
      yaw: $yaw,
      tank_volume: $tank_volume,
      current: $current,
      flow: $flow,
      status: $status,
      created_at: $created_at,
    ''';
  }
}
