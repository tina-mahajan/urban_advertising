import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

class PushNotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;


  static const Map<String, dynamic> _serviceAccount = {
      "type": "service_account",
      "project_id": "urban-advertising-application",
      "private_key_id": "3fc4ffa9017d9cb9b659af97d71a16917e9b3e5c",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCkHj4mht/KtvfS\nU4hzby1CGcZtze1JPK/FImQ3+h+dAObhVj6VSmLpW8Nm09zUkpdWJBzoqxGKm9ru\nqFyXAAvjgME+EB9Ybls8HHIhy5MdpJlDoDDR28IjGvg1MnqrqMUCmxgE/08k/R9s\nYYm49xy/IjE8oovmSUs8UwKoG2ZX++SBOSPRSj1UcTpOpefbU0QjLsEL4UWeLR8Z\no1O5KrPu+cvHU1ZEcWD1bpex8ipfc82LkX4tdERQTNFYlZYoK0PBZEWnLC+bsJL+\npBrtU6cLo3xa4EGDTnhO3pA7+3hR9akNlfym15+uuty/QHGDAC006+Hm0q9b75WP\n8N30JKb5AgMBAAECggEAE1zilAjSZ0AwS6sxlH3z0uJH3h1fPyZm7f0dYhnTaEKK\nmuAiJNq4ggQCsTNykM1lR8Ndukkxmf8CpOjt+J5HqM0gb343NoeZocVQ5WIXbrZE\nY11HWUEiXeIxEdStcqqIKOMrwa4uFCT9k7vLxAv6oyXJdZgPZal01A6OqA8Ig317\nCsZMyvx6Rum+doG8xifpJhUpul+/pnV75rKHQyLwc7aWHrGVt+3grR8/G3htiD1d\nm6npseeN2Mub9eMhEscJ7I2rF0n1mj0WokhtOPGyKrOab4t4UNzockTV4CZ7eH6C\nAjFEGQlpUIF7Y2S4PSmk62qG/4BJNYuHEb7RbBiuYQKBgQDVwQcBqdipuv37j3/b\nU5/Ouupxeb2QSHGdKjVcRJn+tz7Md3JHbq4K8GoiNr4Qmrx5eVOg0F47YgBu1LMq\nWoauGYfjTG8s0IAkC/Nj85w7L+YZM6a/hPK9X3XAT4mO+hke+pwmrrCGxtLTcDEL\nIDcwUUMEJ3xy014H8mwKt3Pe2QKBgQDEjd4gVxYWtpKZU+QIkaCicplMdApWiswH\nfUxWfxddsbOLjQYjbIlYzxtSM3OrS8PztBi60zBOeONtGP6TwH69KNYq24d5Rk45\nE4YVRNnWlEDj5TR8+ILpjOf0+g2c+pycU6+XsLZYvwYjxmemll9JLYbXds+xTxz2\nJqAY0mI1IQKBgDdmskQyG1/SgWWkCcV05SSVuZHztbghrqDHgdEKTseAAxzHkK0G\n+MEJEtkPSy/Oiy8IzS4PE31cpzQSmOVPVTzmjRvSgbYhzDSLjGfJiiKlBYReqMdW\n0/tVNJXFh6exFrW6yqIUANjNy3LVz0BM90DkrvPysASq1+JDaNFWPwfxAoGAMIIK\npdSYQPbB61FG386A5FZ/+txQiNcsT1Te+CHZdGgctX4SW7+3jdFfHsRP8aB7NbPm\nvoTMUTGIfy5B9dj17l0brewL3SQ6vd9RogIh+NERyqyQbZ8vP9BklpL3tRwsdnA4\nz6ju96v9KesXPYey8G5p7tcFnu61aRJTRIz3a8ECgYALXf4qXwc8DEZwJZpECNj0\n+9tM+fKgWd8fFnZgfXlcrGRHzW6Yfzw1/ERbVibjtSdU2UZNBLkqJWxBJ6svN4Pk\noBUG2ddX0S/rLm/kPtEY7K2+72EUhMTG8oukyeRWmtyzdIeT6ySZCKkZV9i6PW73\nwklwwYOIMuPM2jIhmsFuVg==\n-----END PRIVATE KEY-----\n",
      "client_email": "firebase-adminsdk-fbsvc@urban-advertising-application.iam.gserviceaccount.com",
      "client_id": "114794957173923942646",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40urban-advertising-application.iam.gserviceaccount.com",
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
  static Future<void> sendNotificationToAllEmployees({
    required String title,
    required String body,
  }) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("employee")
        .get();

    for (final doc in snapshot.docs) {
      final token = doc.data()["fcmToken"];

      if (token != null && token.toString().isNotEmpty) {
        await sendNotification(
          token: token,
          title: title,
          body: body,
        );
      }
    }
  }

}
