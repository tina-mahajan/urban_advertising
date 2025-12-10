// functions/index.js

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

/**
 * 1️⃣ Trigger: New booking created in `slot_request`
 *    -> Notify all admins + all employees
 *    (You can restrict to "online" bookings using `source` field)
 */
exports.onNewBooking = functions.firestore
  .document("slot_request/{bookingId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const bookingId = context.params.bookingId;

    const customerName = data.customer_name || "New customer";
    const service = data.service || "";
    const date = data.date || "";
    const time = data.time || "";
    const source = (data.source || "online").toString().toLowerCase();

    // ✅ If you only want notifications for ONLINE bookings, keep this:
    if (source !== "online") {
      console.log("Skipping offline booking notification for", bookingId);
      return null;
    }

    const title = "🆕 New Booking Request";
    const body = `${customerName} requested ${service} on ${date} at ${time}.`;

    // Get all admins
    const adminSnap = await db.collection("admin").get();
    // Get all employees
    const employeeSnap = await db
      .collection("employee")
      .where("role", "==", "employee")
      .get();

    const tokens = [];

    adminSnap.forEach((doc) => {
      const t = doc.data().fcmToken;
      if (t) tokens.push(t);
    });

    employeeSnap.forEach((doc) => {
      const t = doc.data().fcmToken;
      if (t) tokens.push(t);
    });

    if (tokens.length === 0) {
      console.log("No tokens found for admins/employees");
      return null;
    }

    const message = {
      notification: {
        title,
        body,
      },
      data: {
        type: "new_booking",
        bookingId,
      },
    };

    await admin.messaging().sendToDevice(tokens, message);
    console.log("✅ New booking notification sent for", bookingId);
    return null;
  });

/**
 * 2️⃣ Trigger: Booking updated in `slot_request`
 *
 *    a) If status changed to "approved"  -> notify customer
 *    b) If assigned_employee_id changed  -> notify that employee
 *
 *    NOTE: This assumes:
 *    - Each booking has `customer_id` = uid of Customer collection document
 *    - You already store fcmToken in Customer/{uid} and employee/{uid}
 */
exports.onBookingStatusChange = functions.firestore
  .document("slot_request/{bookingId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const bookingId = context.params.bookingId;

    // a) STATUS CHANGED
    if (before.status !== after.status) {
      console.log(
        `Status changed for booking ${bookingId}: ${before.status} -> ${after.status}`
      );

      // If approved -> notify customer
      if (after.status === "approved") {
        const customerId = after.customer_id; // 👈 make sure you save this field when creating booking
        if (!customerId) {
          console.log("No customer_id on booking, skipping customer notify");
        } else {
          const customerDoc = await db
            .collection("Customer")
            .doc(customerId)
            .get();

          if (customerDoc.exists) {
            const token = customerDoc.data().fcmToken;
            if (token) {
              const message = {
                notification: {
                  title: "✅ Slot Confirmed",
                  body: `Your booking for ${after.service || ""} on ${
                    after.date || ""
                  } at ${after.time || ""} is approved.`,
                },
                data: {
                  type: "booking_approved",
                  bookingId,
                },
              };

              await admin.messaging().sendToDevice(token, message);
              console.log("✅ Customer approval notification sent");
            } else {
              console.log("Customer has no fcmToken");
            }
          } else {
            console.log("Customer document not found:", customerId);
          }
        }
      }
    }

    // b) EMPLOYEE ASSIGNED
    if (before.assigned_employee_id !== after.assigned_employee_id) {
      const empId = after.assigned_employee_id;
      if (empId) {
        console.log(
          `Employee assigned changed for booking ${bookingId}:`,
          empId
        );

        const empDoc = await db.collection("employee").doc(empId).get();
        if (!empDoc.exists) {
          console.log("Employee document not found:", empId);
        } else {
          const token = empDoc.data().fcmToken;
          if (token) {
            const message = {
              notification: {
                title: "🧾 New Task Assigned",
                body: `You have a new booking: ${
                  after.service || ""
                } for ${after.customer_name || ""} on ${
                  after.date || ""
                } at ${after.time || ""}.`,
              },
              data: {
                type: "task_assigned",
                bookingId,
              },
            };

            await admin.messaging().sendToDevice(token, message);
            console.log("✅ Employee task assignment notification sent");
          } else {
            console.log("Employee has no fcmToken");
          }
        }
      }
    }

    return null;
  });

/**
 * 3️⃣ Scheduled: Daily reminder for tomorrow’s bookings
 *    Runs every day at 18:00 IST
 *
 *    - Finds bookings for tomorrow
 *    - Notifies each assigned employee: how many tasks tomorrow
 *    - Notifies admins: total bookings tomorrow
 */
exports.dailyReminders = functions.pubsub
  .schedule("every day 18:00")
  .timeZone("Asia/Kolkata")
  .onRun(async (context) => {
    console.log("🔔 Running dailyReminders function...");

    const now = new Date();
    const tomorrow = new Date(
      now.getFullYear(),
      now.getMonth(),
      now.getDate() + 1
    );

    const dd = String(tomorrow.getDate()).padStart(2, "0");
    const monthNames = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    const MMM = monthNames[tomorrow.getMonth()];
    const yyyy = tomorrow.getFullYear();
    const tomorrowStr = `${dd} ${MMM} ${yyyy}`; // e.g. "16 Dec 2025"

    console.log("Looking for bookings on:", tomorrowStr);

    const bookingsSnap = await db
      .collection("slot_request")
      .where("date", "==", tomorrowStr)
      .get();

    if (bookingsSnap.empty) {
      console.log("No bookings for tomorrow");
      return null;
    }

    // Group tasks per employee
    const employeeTasks = {}; // { empId: [bookings] }

    bookingsSnap.forEach((doc) => {
      const data = doc.data();
      const empId = data.assigned_employee_id;
      if (empId) {
        if (!employeeTasks[empId]) {
          employeeTasks[empId] = [];
        }
        employeeTasks[empId].push(data);
      }
    });

    // 1) Notify employees
    for (const empId of Object.keys(employeeTasks)) {
      const empDoc = await db.collection("employee").doc(empId).get();
      if (!empDoc.exists) continue;

      const token = empDoc.data().fcmToken;
      if (!token) continue;

      const tasks = employeeTasks[empId];
      const count = tasks.length;
      const firstJob = tasks[0];

      const message = {
        notification: {
          title: "📅 Tomorrow's Schedule",
          body: `You have ${count} booking(s) tomorrow. First: ${
            firstJob.service || ""
          } for ${firstJob.customer_name || ""} at ${
            firstJob.time || ""
          }.`,
        },
        data: {
          type: "tomorrow_reminder",
        },
      };

      await admin.messaging().sendToDevice(token, message);
      console.log(`✅ Reminder sent to employee ${empId}`);
    }

    // 2) Notify admins with summary
    const adminsSnap = await db.collection("admin").get();
    const adminTokens = [];
    adminsSnap.forEach((doc) => {
      const t = doc.data().fcmToken;
      if (t) adminTokens.push(t);
    });

    if (adminTokens.length > 0) {
      const totalBookings = bookingsSnap.size;

      const message = {
        notification: {
          title: "📅 Tomorrow's Orders",
          body: `You have ${totalBookings} booking(s) scheduled for ${tomorrowStr}.`,
        },
        data: {
          type: "tomorrow_reminder_admin",
        },
      };

      await admin.messaging().sendToDevice(adminTokens, message);
      console.log("✅ Reminder sent to admins");
    } else {
      console.log("No admin tokens for reminders");
    }

    return null;
  });
