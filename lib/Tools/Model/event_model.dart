class EventModel {
  final String eventName;
  final String eventDescription;
  final DateTime eventDate;
  bool isChecked;

  EventModel(
      {required this.eventName,
      required this.eventDescription,
      required this.eventDate,
      this.isChecked = false});
}
