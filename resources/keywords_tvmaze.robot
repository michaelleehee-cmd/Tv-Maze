*** Settings ***
Library    RequestsLibrary

*** Variables ***
${TVMAZE_BASE}    https://api.tvmaze.com

*** Keywords ***
Create TVMaze Session
    Create Session    tvmaze    ${TVMAZE_BASE}

Search Show
    [Arguments]    ${query}
    ${params}=    Create Dictionary    q=${query}
    ${response}=    GET On Session    tvmaze    /search/shows    params=${params}    expected_status=any
    RETURN    ${response}

Get Show By Id
    [Arguments]    ${id}
    ${response}=    GET On Session    tvmaze    /shows/${id}    expected_status=any
    RETURN    ${response}

Extract First Show Id From Search
    [Arguments]    ${response}
    ${json}=    Call Method    ${response}    json
    ${first}=    Set Variable    ${json[0]['show']['id']}
    RETURN    ${first}

Assert Show URL Contains Id
    [Arguments]    ${response}    ${id}
    ${json}=    Call Method    ${response}    json
    ${url}=     Set Variable    ${json['url']}
    ${id_as_string}=    Convert To String    ${id}
    Should Contain    ${url}    ${id_as_string}

Log TVMaze Response Info
    [Arguments]    ${response}
    ${status}=    Set Variable    ${response.status_code}
    Log To Console    \n=== TVMaze API Response ===
    Log To Console    Status Code: ${status}

    ${json}=    Call Method    ${response}    json

    # Detect whether response is list or object
    ${is_list}=    Evaluate    isinstance(${json}, list)

    Run Keyword If    ${is_list}        Log Search Result    ${json}
    Run Keyword If    not ${is_list}    Log Show Details    ${json}

    Log To Console    =================================\n

Log Search Result
    [Arguments]    ${json}
    ${count}=    Evaluate    len(${json})
    Log To Console    Result Count: ${count}
    Log To Console    First Match: ${json[0]['show']['name']}
    Log To Console    Show ID: ${json[0]['show']['id']}

Log Show Details
    [Arguments]    ${json}
    Log To Console    Show Name: ${json['name']}
    Log To Console    Page URL: ${json['url']}
    Log To Console    Show ID: ${json['id']}

