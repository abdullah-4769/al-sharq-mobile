class ApiConstants {
  static const String baseUrl = "http://138.68.104.206:3000";


  static const String sponsorBaseUrl = baseUrl;
  // Sponsor Dashboard endpoints
  static String getSponsorSessions(int sponsorId) {
    return '$sponsorBaseUrl/sponsors/sponsor/$sponsorId/sessions';
  }
// Add to your existing ApiConstants class
  static String getEventDetails(int eventId) => '$baseUrl/event/$eventId';
  static const String registrationTeam = '$baseUrl/admin/users/registrationteam';
  // Admin endpoints
  static const String participants = '$baseUrl/admin/users/participants';
  static String participantById(int id) => '$baseUrl/admin/users/$id';
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
  //............... Profile Visibility .....................//
  static String getProfileVisibility(int userId, int eventId) {
    return '$baseUrl/participant-directory-opt-in-out/$eventId/$userId';
  }

  static const String updateProfileVisibility = '$baseUrl/participant-directory-opt-in-out';


  // ------------------ Exhibitor Section ---------------------- //

  static String getExhibitorSessionsDashboard(int exhibitorId) {
    return '$baseUrl/exhibiteros/$exhibitorId/sessions';
  }


}
