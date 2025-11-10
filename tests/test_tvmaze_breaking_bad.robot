*** Settings ***
Resource    ../resources/keywords_tvmaze.robot

*** Test Cases ***
Scenario: Verify Breaking Bad show URL contains its show ID
    Given TVMaze API Is Available
    When I Search For Show    breaking bad
    Then The Search Should Succeed
    And I Extract The First Show Id
    When I Retrieve Show Details By Id    ${show_id}
    Then The Show Details Should Succeed
    And I Log The TVMaze Response
    And The Show URL Should Contain The Show Id