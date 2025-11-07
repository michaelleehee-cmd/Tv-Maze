*** Settings ***
Resource    ../resources/keywords_tvmaze.robot

*** Test Cases ***
Verify Breaking Bad Show URL Contains Show ID
    Create TVMaze Session
    ${search_response}=    Search Show    breaking bad
    Log TVMaze Response Info    ${search_response}
    Should Be Equal As Integers    ${search_response.status_code}    200

    ${show_id}=    Extract First Show Id From Search    ${search_response}

    ${details_response}=    Get Show By Id    ${show_id}
    Log TVMaze Response Info    ${details_response}
    Should Be Equal As Integers    ${details_response.status_code}    200

    Assert Show URL Contains Id    ${details_response}    ${show_id}
    Log TVMaze Response Info    ${details_response}
