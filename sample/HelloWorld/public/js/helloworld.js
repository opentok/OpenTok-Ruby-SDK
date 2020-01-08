// Initialize an OpenTok Session object
var session = OT.initSession(apiKey, sessionId);

// Initialize a Publisher, and place it into the element with id="publisher"
var publisher = OT.initPublisher('publisher', {
    insertMode: 'append',
}, function(error) {
  if (error) {
    console.error('Failed to initialise publisher', error);
  }
});

// Attach event handlers
session.on({

  // This function runs when session.connect() asynchronously completes
  sessionConnected: function(event) {
    // Publish the publisher we initialzed earlier (this will trigger 'streamCreated' on other
    // clients)
    session.publish(publisher, function(error) {
      if (error) {
        console.error('Failed to publish', error);
      }
    });
  },

  // This function runs when another client publishes a stream (eg. session.publish())
  streamCreated: function(event) {
    // Subscribe to the stream that caused this event, and place it into the element with id="subscribers" 
    session.subscribe(event.stream, 'subscribers', {
        insertMode: 'append',
    }, function(error) {
      if (error) {
        console.error('Failed to subscribe', error);
      }
    });
  }

});

// Connect to the Session using a 'token'
session.connect(token, function(error) {
  if (error) {
    console.error('Failed to connect', error);
  }
});
