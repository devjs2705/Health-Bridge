class VideoCallData {
  final String channelName;
  final int doctorUid;
  final int patientUid;

  VideoCallData({
    required this.channelName,
    required this.doctorUid,
    required this.patientUid,
  });

  factory VideoCallData.fromJson(Map<String, dynamic> json) {
    return VideoCallData(
      channelName: json['channel_name'],
      doctorUid: json['doctor_uid'],
      patientUid: json['patient_uid'],
    );
  }
}
