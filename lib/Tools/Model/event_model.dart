class EventModel {
  int? id;
  final String eventName;
  final String eventDescription;
  final String eventDate;
  final String createdBy;
  bool isChecked;

  EventModel({
    required this.eventName,
    required this.eventDescription,
    required this.eventDate,
    required this.createdBy,
    this.isChecked = false,
  });

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
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
