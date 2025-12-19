import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

class PushNotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// ----------------------------------------------------------
  /// 🔐 SERVICE ACCOUNT JSON (Paste Your Full JSON Here)
  /// ----------------------------------------------------------
  static const Map<String, dynamic> _serviceAccount = {
    "type": "service_account",
    "project_id": "urban-advertising-application",
    "private_key_id": "d821e7f0561c4eee1a168b7946d9dc2ff65b521d",
    "private_key":
    "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDXvsCTSPeogq+5\nL78wufQ5bCeAlO0mjFO+ko9maVnv5yGpB00XQ55DwU0ShiByVTLtkqA4RIUAkMDJ\nAn7VtmxZn3577gwmaMGwn7o98jpmaZ5+1pMUQHaXwCGsMGDy+WDN2BuDzXews2ax\n+RqXxAT2EouYHKOk3491SDL/Djo+CXjzUgIHffQF+EetYajFaAz3ksGV6tukZXmx\nk58M5g+K9ojPA4UbgsJ3o9EtSVf7yNzwkl4D5wIRozkCHmDCPXX2+LcG6uqvbKNE\nMjXYtWxEIpgVw7UkwSGg2/lB/C0540D/3IfGDEDCisJp/bqrCxwQQYk6umR66ZNC\nPQLJnsnfAgMBAAECggEAHsopX5u1RIZKH8qxpXmUYjGOPaqDYdH7DaKK9pmobTV2\nN1JEbUKILrFCl5cuwEJqfz9CwGT++kKuUMGbalKbifraKUOi1kRzCArzoG2WahE+\nvmlPGj/M7QFNjO5ml6aBaz8hRiEnqL8hs9qSMgCWmKuy4mWL8Ta6mYlRRdc49qtO\nKTwicY3Ci/n7iySZxB5awOrToSvusvmV0po6uJK2xeXWUFNJUFsllim4NfnRzc1N\nUuwS46aY5Dw7U4IzEak9+iGVh8cVcaEFlTN9K4C6x3fa/j3x1PoEpJ+PnQ3bZ0Bb\n+wAUq6sIH4QjXv99rtGadrQOucVjq9lGovPw4gaP2QKBgQD8PVDKVkoI1BFuliyi\nA2MIf/xNNT3bv66ECzX2xIPvwaYNDAxWV8NwcpTu+I3GV+eMrqypj78ct10DEmX4\nYnxpu/1vu0kRpP5qF0WSMNeK8WRryGY+p4suTScRs8jEBtoLpL5Obsc+wtIfkETX\nPwxpRzZHGg9Bu4nMX5wD6Emg6wKBgQDa9idvpZeLyYWjxMoXPiuyLsro3kP0IGAe\nBE0k02NfrkFXb5rQ1mbU9CJxjkMWl0lfzEYOPOF0q9YOh4hGHAesshyZH+BwYd4q\nHYo7El6gCcg0nsuS7fuiLp0O197ShQSvlaKnRPBv/NARluLiUYv6ribIHONe7fz7\nZ1ynrWzd3QKBgAlZSG5HZnUPTxoXLM5Qa9I71CEUcRd88j3ooHZl8DHprnrbUHW+\nyPqY9JYq1i5cwbNAIhwivMWWsjbT7r2XAN92XT1P5rRlthw+gpCZiNOYgM1R3yBB\nW3I639DTJgTF8DzwPTFw/6d+1wTedv63UoFwZz2ZZKleBwxxGro2WMxDAoGAd7MH\nXgaFcTqqnxuuasRm+NKRxHn1Zhjo0qABWDdjZOQK/nSZir8amiIYTkG6NThhOUif\np5rqmXBy5aB8A+/A1kzMS31cobMu05EwhxiEuDKAyxtgKKOG42NeIsYqHqXvKNnB\ngHW0h1QKnwMAZz6zKkhYFR+NwNCTcxBPW674C9UCgYEAu3nAmcTevJHgSbWc1lwH\niYw/YSfQL6VAPF7cFVf7ACN+Pczq2KlUWboyW/6tj4C9K5gIBJLLxIAB9fU1y6bK\nF0JOp9XYwoNrZm6w+/J5OkOwH6+E7ZE/0fu9H+J/AYAaimzhUHAAC6Pr3LTq66sD\nYfPbiZuaG/btoiak2VURM5w=\n-----END PRIVATE KEY-----\n",
    "client_email":
    "firebase-adminsdk-fbsvc@urban-advertising-application.iam.gserviceaccount.com",
    "client_id": "114794957173923942646",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url":
    "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url":
    "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40urban-advertising-application.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com"
  };

  /// ----------------------------------------------------------
  /// 🔥 SAVE TOKEN ON LOGIN
  /// ----------------------------------------------------------
  static Future<void> initAndSaveToken({
    required String uid,
    required String role,
  }) async {
    await _fcm.requestPermission();
    final token = await _fcm.getToken();
    if (token == null) return;

    print("🔥 FCM Token saved for $role → $token");

    final collection = role == "admin"
        ? "admin"
        : role == "employee"
        ? "employee"
        : "Customer";

    await FirebaseFirestore.instance.collection(collection).doc(uid).update({
      "fcmToken": token,
    });
  }

  /// ----------------------------------------------------------
  /// 🔐 FCM V1: Fetch OAuth Access Token from Google
  /// ----------------------------------------------------------
  static Future<String> _getAccessToken() async {
    final creds = ServiceAccountCredentials.fromJson(_serviceAccount);
    const scopes = ["https://www.googleapis.com/auth/firebase.messaging"];

    final client = await clientViaServiceAccount(creds, scopes);
    final accessToken = client.credentials.accessToken.data;

    client.close();
    return accessToken;
  }

  /// ----------------------------------------------------------
  /// 📩 Send Notification (FCM V1 API)
  /// ----------------------------------------------------------
  static Future<void> sendNotification({
    required String token,
    required String title,
    required String body,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      final projectId = _serviceAccount["project_id"];

      final url = Uri.parse(
          "https://fcm.googleapis.com/v1/projects/$projectId/messages:send");

      final message = {
        "message": {
          "token": token,
          "notification": {
            "title": title,
            "body": body,
          }
        }
      };

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
        body: jsonEncode(message),
      );

      print("📨 FCM Response: ${response.body}");
    } catch (e) {
      print("❌ Error sending notification: $e");
    }
  }
}
