Given(/numbers api is available/) do
  stub_request(:get, "http://numbersapi.com/random").
    to_return(:status => 200, :body => json_response("fact_response"), :headers => {})
end

Given(/^the (.+) service is enabled$/) do |service|
  EDI.register_services service.to_sym
end

When(/^someone sends the message "(.+)"$/) do |message|
  EDI.websocket.send_message message
  sleep 2
end

Then(/^EDI will respond with a random fact$/) do
    expect(@slack).to have_message "115 is the atomic number of an element temporarily called ununpentium."
end
