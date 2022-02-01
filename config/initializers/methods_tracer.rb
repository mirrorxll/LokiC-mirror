# frozen_string_literal: true

# this help us to trace methods which needs attention
# https://ruby-doc.org/core-2.7.0/TracePoint.html

METHODS_TRACER = TracePoint.new(:call) do |tp|
  klass = tp.defined_class.to_s
  method = tp.callee_id.to_s

  publications_klass = klass.eql?('#<Class:MiniLokiC::Population::Publications>')
  no_loc_method = method.in?(%w[all by mm_by_state])
  if publications_klass && no_loc_method
    message = "*[ LokiC ] TRACE POINT*\n"\
              ">Someone called forbidden method *Publications::#{method}*"

    Slack::Web::Client.new.chat_postMessage(
      channel: 'U02JWAHN88M',
      text: message,
      as_user: true
    )
  end
end
