class EventModel {
  int? id;
  final String eventName;
  final String eventDescription;
  final String eventDate;
  final String createdBy;
  bool isChecked;

  EventModel({
    this.id,
    required this.eventName,
    required this.eventDescription,
    required this.eventDate,
    required this.createdBy,
    this.isChecked = false,
  });

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'], // Pastikan properti id diisi dengan nilai dari map
      eventName: map['eventName'],
      eventDescription: map['eventDescription'],
      eventDate: map['eventDate'],
      createdBy: map['createdBy'],
      isChecked: map['isChecked'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventName': eventName,
      'eventDescription': eventDescription,
      'eventDate': eventDate,
      'createdBy': createdBy,
      'isChecked': isChecked ? 1 : 0,
    };
  }
}
