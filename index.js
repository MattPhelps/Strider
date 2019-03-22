const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//

// listen for Following events and then trigger a push notification

  exports.observeUserMessage = functions.database.ref('/messages/{messageId}')
    .onCreate((snapshot, context) => {

      var messageId = context.params.messageId;

      // trying to figure out fcmToken to send a push message
      return admin.database().ref('/messages/' + messageId).once('value', snapshot => {

        var message = snapshot.val();
        var fromId = message.fromId;

        return admin.database().ref('/users/' + message.toId).once('value', snapshot => {

         var receiverUser = snapshot.val();

        return admin.database().ref('/users/' + message.fromId).once('value', snapshot => {

          var senderUser = snapshot.val();

          var payload = {
             notification: {
               title: senderUser.name,
               body: message.text,
               sound: 'default'
             },
               data: {
               fromId: fromId
            }
          }

          admin.messaging().sendToDevice(receiverUser.fcmToken, payload)
            .then(response => {
              console.log("Successfully sent message:", response);
            }).catch(function(error) {
              console.log("Error sending message:", error);
            });
        })
      })
      })
    })

    exports.observeUserGotBumped = functions.database.ref('/bumps/{userId}/{bumperId}')
      .onCreate((snapshot, context) => {

        var userId = context.params.userId;
        var bumperId = context.params.bumperId;

        // trying to figure out fcmToken to send a push message


          return admin.database().ref('/users/' + userId).once('value', snapshot => {

           var receiverUser = snapshot.val();

          return admin.database().ref('/users/' + bumperId).once('value', snapshot => {

            var bumperUser = snapshot.val();

            var payload = {
               notification: {
                 title: "Bump!",
                 body: bumperUser.name + " bumped you",
                 sound: 'default'
               },
                 data: {
                 bumperId: bumperId
              }
            }

            admin.messaging().sendToDevice(receiverUser.fcmToken, payload)
              .then(response => {
                console.log("Successfully sent message:", response);
              }).catch(function(error) {
                console.log("Error sending message:", error);
              });
        })
        })
      })

          exports.observeNewUser = functions.database.ref('/users/{userId}')
              .onCreate((snapshot, context) => {

                var userId = context.params.userId;

                // trying to figure out fcmToken to send a push message
                return admin.database().ref('/users/' + userId).once('value', snapshot => {

                  var newUser = snapshot.val();

                  return admin.database().ref('/users/' + 'mrByyDLkeoPMnj48xwWN4rveMRz1').once('value', snapshot => {

                   var mattPhelps = snapshot.val();

                    var payload = {
                      notification: {
                        title: "Yipee!!!",
                        body:  newUser.name + ' joined Strider',
                        sound: 'default'
                      },
                    }

                    admin.messaging().sendToDevice(mattPhelps.fcmToken, payload)
                      .then(response => {
                        console.log("Successfully sent message:", response);
                      }).catch(function(error) {
                        console.log("Error sending message:", error);
                      });
                })
                })
              })
