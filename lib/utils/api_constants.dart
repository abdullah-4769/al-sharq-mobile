class ApiConstants {
  static const String baseUrl = "http://138.68.104.206:3000";



  static String getConnectedUsers(int userId) {
    return '$baseUrl/connections/all?userId=$userId';
  }

  static String getPendingConnections(int userId) {
    return '$baseUrl/connections/pending?userId=$userId';
  }

  // In ApiConstants class
  static String handleConnectionRequest(int requestId) {
    return '$baseUrl/connections/$requestId/status';
  }


  static String getSponsorDetails(int sponsorId) {
    return '$baseUrl/sponsors/$sponsorId/details';
  }

  static String getExhibitorDetails(int exhibitorId) {
    return '$baseUrl/exhibiteros/$exhibitorId/details';
  }


  static String getSponsorsAndExhibitors(int eventId) {
    return '$baseUrl/event/eventsrelatedsponsers/$eventId';
  }
  // Auth endpoints
  static const String signup = "$baseUrl/auth/register";
  static const String login = "$baseUrl/auth/login";

  // -------------------- SESSION DETAILS --------------------
  static String sessionDetails(int sessionId) => '$baseUrl/sessions/detail/$sessionId';


  // -------------------- Speaker in Participant DETAILS --------------------
  static const String speakerShortDetails = '/speakers/event';

  // -------------------- Boolmark DETAILS --------------------
  static const String bookmarkSession = '/participants/agenda';
   static const String bookmarkedSessions = '/participants/bookmarked-sessions';


  // Event Sessions API
  static String getEventSessions(int eventId) => "$baseUrl/event/event-sessions/$eventId";
}
