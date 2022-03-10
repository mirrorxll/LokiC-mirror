import consumer from "./consumer"

$(document).on("turbolinks:load", function() {
  let properties = $('#storyTypePropertiesForm');
  let storyTypeId = properties.attr('story_type_id');

  consumer.subscriptions.create(
      {
        channel: "StoryTypePublicationsChannel",
        story_type_id: storyTypeId
      },
      {
        connected()    { console.log('properties connected'); },
        disconnected() { console.log('properties disconnected'); },
        received(_data) {
          console.log('123456');
          $.ajax({
            url: `${window.location.origin}/story_types/${storyTypeId}/opportunities`,
            method: 'get',
            dataType: 'script'
          });
        }
      }
  )
});
