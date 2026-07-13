const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.onSiagaStatusUpdate = functions.firestore
  .document('siaga_status/current')
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const prevData = change.before.data();

    if (newData.level === prevData.level) return;

    const levelLabels = {
      1: 'Normal',
      2: 'Waspada',
      3: 'Siaga',
      4: 'Awas',
    };

    const iconMap = {
      1: '\u2705',
      2: '\u26A0\uFE0F',
      3: '\uD83D\uDEE1\uFE0F',
      4: '\u26D4',
    };

    const level = newData.level;
    const label = newData.levelLabel || levelLabels[level] || 'Tidak Diketahui';
    const description = newData.description || '';
    const icon = iconMap[level] || '';

    const title = `Level Siaga: ${label} ${icon}`;
    const body = description || `Status siaga Gunung Merapi berubah ke level ${label}.`;

    const payload = {
      notification: {
        title,
        body,
      },
      data: {
        screen: 'home',
        level: String(level),
        label,
      },
      topic: 'siaga_merapi',
    };

    try {
      await admin.messaging().send(payload);
      functions.logger.info(`Notification sent for level ${level}`);
    } catch (error) {
      functions.logger.error('Error sending notification:', error);
    }
  });
