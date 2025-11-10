*** Settings ***
Library    RequestsLibrary
Library    OperatingSystem
Library    Collections

*** Variables ***
${TVMAZE_BASE}    https://api.tvmaze.com

*** Keywords ***
# BDD style keywords
Given TVMaze API Is Available
    Create TVMaze Session

When I Search For Show
    [Arguments]    ${query}
    ${response}=    Search Show    ${query}
    Set Test Variable    ${response}

When I Retrieve Show Details By Id
    [Arguments]    ${id}
    ${response}=    Get Show By Id    ${id}
    Set Test Variable    ${response}

Then The Search Should Succeed
    Should Be Equal As Integers    ${response.status_code}    200

Then The Show Details Should Succeed
    Should Be Equal As Integers    ${response.status_code}    200

And I Extract The First Show Id
    ${show_id}=    Extract First Show Id From Search    ${response}
    Set Test Variable    ${show_id}

And The Show URL Should Contain The Show Id
    Assert Show URL Contains Id    ${response}    ${show_id}

And I Log The TVMaze Response
    Log TVMaze Response Info    ${response}


#Technical keywords
Create TVMaze Session
    Create Session    tvmaze    ${TVMAZE_BASE}  verify=false  disable_warnings=True
    Disable TLS Warning
    Log To Console    \n─────────────────────────────────────────────

Search Show
    [Arguments]    ${query}
    ${params}=    Create Dictionary    q=${query}
    ${response}=    GET On Session    tvmaze    /search/shows    params=${params}    expected_status=any
    Response Time Should Be Below    ${response}    0.6      Search Show
    RETURN    ${response}

Get Show By Id
    [Arguments]    ${id}
    ${response}=    GET On Session    tvmaze    /shows/${id}    expected_status=any
    Response Time Should Be Below    ${response}    0.3     Get Show By Id
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

Response Time Should Be Below
    [Arguments]    ${response}    ${max_time}=0.5    ${label}=API Call
    ${elapsed}=    Call Method    ${response.elapsed}    total_seconds
    Log To Console    \n--- PERFORMANCE (${label}) ---
    Log To Console    Response Time: ${elapsed}s
    Log To Console    Limit: ${max_time}s
    Log To Console    -------------------------------------
    Should Be True    ${elapsed} < ${max_time}    Performance failure: ${label} took ${elapsed}s (limit ${max_time}s)


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

Disable TLS Warning
    Set Environment Variable    PYTHONWARNINGS    ignore:InsecureRequestWarning

