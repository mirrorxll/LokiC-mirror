(function() {
    App.cable.subscriptions.create(
        { channel: "PopulationStatusChannel", story_type_id: 1 },
        { connected: function() { console.log('connected'); },
          disconnected: function() { console.log('disconnected'); },
          received: function (data) { console.log(1); } }
    )
}).call();
