@vcr
Feature: Fact Service


  Scenario: Request a Fact
    Given the fact service is enabled
    When someone sends the message "EDI, fact"
    Then EDI will respond with a random fact
