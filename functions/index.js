const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

/**
 * Helper to send FCM multicast messages and automatically prune invalid or expired tokens.
 *
 * @param {admin.firestore.DocumentReference} userRef - Reference to the user's Firestore document.
 * @param {string[]} tokens - Array of FCM registration tokens.
 * @param {object} payload - Notification details (title, body, data).
 */
async function sendMulticastNotification(userRef, tokens, payload) {
  if (!tokens || !Array.isArray(tokens) || tokens.length === 0) {
    console.log(`No FCM tokens found for user at path: ${userRef.path}`);
    return;
  }

  // Remove empty or duplicate tokens
  const uniqueTokens = [...new Set(tokens.filter((t) => typeof t === "string" && t.trim().length > 0))];
  if (uniqueTokens.length === 0) {
    return;
  }

  const message = {
    tokens: uniqueTokens,
    notification: {
      title: payload.title,
      body: payload.body,
    },
    data: payload.data || {},
    android: {
      priority: "high",
      notification: {
        sound: "default",
        channelId: "high_importance_channel",
        clickAction: "FLUTTER_NOTIFICATION_CLICK",
      },
    },
    apns: {
      payload: {
        aps: {
          sound: "default",
          badge: 1,
        },
      },
    },
  };

  try {
    const response = await admin.messaging().sendEachForMulticast(message);
    console.log(
      `FCM multicast sent to ${userRef.path}: ${response.successCount} succeeded, ${response.failureCount} failed.`
    );

    // Prune stale / unregistered tokens
    if (response.failureCount > 0) {
      const failedTokens = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          const error = resp.error;
          if (
            error &&
            (error.code === "messaging/invalid-registration-token" ||
              error.code === "messaging/registration-token-not-registered")
          ) {
            failedTokens.push(uniqueTokens[idx]);
          }
        }
      });

      if (failedTokens.length > 0) {
        console.log(`Pruning ${failedTokens.length} invalid tokens from ${userRef.path}:`, failedTokens);
        await userRef.update({
          fcmTokens: admin.firestore.FieldValue.arrayRemove(...failedTokens),
        });
      }
    }
  } catch (err) {
    console.error(`Error sending multicast notification to ${userRef.path}:`, err);
  }
}

/**
 * Cloud Function triggered onCreate for `serviceRequests/{requestId}`.
 * Sends a push notification to the provider's stored fcmTokens saying:
 * "New service request from {seekerName}"
 */
exports.onServiceRequestCreated = onDocumentCreated(
  "serviceRequests/{requestId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const requestData = snapshot.data();
    const requestId = event.params.requestId;
    const { providerId, seekerId } = requestData;

    if (!providerId) {
      console.log(`No providerId specified in serviceRequest: ${requestId}`);
      return;
    }

    // 1. Fetch seeker's profile name
    let seekerName = "A seeker";
    if (seekerId) {
      try {
        const seekerDoc = await db.collection("users").doc(seekerId).get();
        if (seekerDoc.exists) {
          const sData = seekerDoc.data() || {};
          seekerName = sData.name || sData.username || seekerName;
        }
      } catch (err) {
        console.error(`Error fetching seeker info for ${seekerId}:`, err);
      }
    }

    // 2. Fetch provider's fcmTokens
    const providerRef = db.collection("users").doc(providerId);
    let providerDoc;
    try {
      providerDoc = await providerRef.get();
    } catch (err) {
      console.error(`Error fetching provider doc for ${providerId}:`, err);
      return;
    }

    if (!providerDoc.exists) {
      console.log(`Provider user doc does not exist for providerId: ${providerId}`);
      return;
    }

    const fcmTokens = providerDoc.data()?.fcmTokens || [];

    // 3. Send FCM notification to provider
    await sendMulticastNotification(providerRef, fcmTokens, {
      title: "New Service Request",
      body: `New service request from ${seekerName}`,
      data: {
        requestId: requestId,
        type: "new_request",
        seekerId: seekerId || "",
        seekerName: seekerName,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
    });
  }
);

/**
 * Cloud Function triggered onUpdate for `serviceRequests/{requestId}`.
 * When `status` changes from "pending" to "accepted" or "rejected", sends a notification
 * to the seeker's stored fcmTokens:
 * - "Your request was accepted!"
 * - "Your request was declined."
 */
exports.onServiceRequestUpdated = onDocumentUpdated(
  "serviceRequests/{requestId}",
  async (event) => {
    const beforeData = event.data?.before?.data();
    const afterData = event.data?.after?.data();
    if (!beforeData || !afterData) return;

    const beforeStatus = beforeData.status;
    const afterStatus = afterData.status;
    const requestId = event.params.requestId;

    // Check if status transitioned from pending -> accepted or rejected
    if (beforeStatus === "pending" && (afterStatus === "accepted" || afterStatus === "rejected")) {
      const seekerId = afterData.seekerId;
      if (!seekerId) {
        console.log(`No seekerId found in serviceRequest: ${requestId}`);
        return;
      }

      const seekerRef = db.collection("users").doc(seekerId);
      let seekerDoc;
      try {
        seekerDoc = await seekerRef.get();
      } catch (err) {
        console.error(`Error fetching seeker doc for ${seekerId}:`, err);
        return;
      }

      if (!seekerDoc.exists) {
        console.log(`Seeker user doc does not exist for seekerId: ${seekerId}`);
        return;
      }

      const fcmTokens = seekerDoc.data()?.fcmTokens || [];
      const messageBody =
        afterStatus === "accepted"
          ? "Your request was accepted!"
          : "Your request was declined.";

      await sendMulticastNotification(seekerRef, fcmTokens, {
        title: "Service Request Update",
        body: messageBody,
        data: {
          requestId: requestId,
          type: "status_update",
          status: afterStatus,
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
      });
    }
  }
);
