# Push Notification Setup (Admin Broadcast)

This app now does the following:

- Registers for APNs permissions.
- Retrieves an FCM token.
- Subscribes every device to topic `all-users`.
- Shows an Admin Broadcast form in the Profile tab only for admin emails.

## 1) Configure Admin Emails in Xcode

In the `FBLA CONNECT` target Build Settings, set:

- `ADMIN_EMAILS` to a comma-separated list, for example:
  - `you@school.org,advisor@school.org`
- `PUSH_BROADCAST_ENDPOINT` to your HTTPS Cloud Function URL (set after deploy).

## 2) Enable Apple + Firebase Push

In Apple Developer and Xcode:

- Enable `Push Notifications` capability for the app bundle.
- Add `Background Modes` and check `Remote notifications` (recommended).

In Firebase Console:

- Open Project Settings -> Cloud Messaging.
- Upload your APNs Auth Key (`.p8`) or certificates for iOS.

## 3) Deploy Admin-Only Broadcast Function

Use Firebase Functions with this endpoint (Node.js):

```javascript
const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();

const adminEmails = [
  "you@school.org",
  "advisor@school.org",
];

exports.sendBroadcastNotification = onRequest(async (req, res) => {
  if (req.method !== "POST") {
    res.status(405).json({error: "Method not allowed"});
    return;
  }

  const authHeader = req.headers.authorization || "";
  const token = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : "";
  if (!token) {
    res.status(401).json({error: "Missing auth token"});
    return;
  }

  let decoded;
  try {
    decoded = await admin.auth().verifyIdToken(token);
  } catch (error) {
    res.status(401).json({error: "Invalid auth token"});
    return;
  }

  const callerEmail = (decoded.email || "").toLowerCase();
  if (!adminEmails.includes(callerEmail)) {
    res.status(403).json({error: "Admin access required"});
    return;
  }

  const title = String(req.body?.title || "").trim();
  const body = String(req.body?.body || "").trim();
  if (!title || !body) {
    res.status(400).json({error: "title and body are required"});
    return;
  }

  try {
    await admin.messaging().send({
      topic: "all-users",
      notification: {title, body},
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    });

    res.status(200).json({ok: true});
  } catch (error) {
    logger.error("Broadcast failed", error);
    res.status(500).json({error: "Failed to send broadcast"});
  }
});
```

Then deploy:

```bash
firebase deploy --only functions:sendBroadcastNotification
```

## 4) Connect App to Function

- Copy deployed HTTPS URL for `sendBroadcastNotification`.
- Paste it into `PUSH_BROADCAST_ENDPOINT` build setting.

## 5) Send to Everyone

1. Sign in with an email listed in `ADMIN_EMAILS`.
2. Open Profile tab.
3. Use `Admin Broadcast` section.
4. Enter title and message.
5. Tap `Send Push Notification`.

All devices subscribed to `all-users` receive the push.
