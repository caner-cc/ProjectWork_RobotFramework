*** Settings ***
Library   SeleniumLibrary
Library   String
Library   OperatingSystem
Library   Collections
Library   Dialogs
Library   Builtin

*** Variables ***
${questioncolor}   rgb(0, 0, 0)
${fontfamily}   "Roboto", sans-serif
@{frontnameslist}   
@{backnameslist}
${OriginalShotDir}   C:/Users/Caner/Downloads/Original
${TestShotDir}   C:/Users/Caner/Downloads/TestShot
${category_count}   ${8}
@{answerlist}

*** Test Cases ***
Opening the website and selecting a municipality
    Open browser   https://vaalikone.yle.fi/eduskuntavaali2019?lang=en-US
    Maximize browser window
    Wait until page contains   Welcome to Yle's election compass!
    Click element   xpath://*[@id="root"]/main/div[1]/section/div[2]/input
    Click element   xpath://*[@id="root"]/main/div[1]/section/div[2]/div/a[1]
    Click button   xpath://*[@id="root"]/main/div[1]/section/button

*** Test Cases ***
Checking if question number elements are same distance from left side
   ${count}=   Get element count   xpath:/html/body/div[1]/main/div[1]/div/article[*]/section[*]/div/div[1]
   ${element}=   Get webelement   xpath:/html/body/div/main/div[1]/div/article[1]/section[1]/div/div[1]
   ${expectedmargin}=    Get horizontal position    ${element}
   @{elementlist}=    Get webelements   xpath:/html/body/div/main/div[1]/div/article[*]/section[*]/div/div[1]
   
   FOR    ${INDEX}    IN    @{elementlist}
       ${margin}=    Get horizontal position    ${INDEX}    
       Should be equal   ${expectedmargin}   ${margin}
    END 
   
   #buttons aren't aligned the after the 10th box  

*** Test Cases ***
Checking the first question of each section if the text color is the same
   ${count}=   Get element count   xpath:/html/body/div/main/div[1]/div/article[*]/section[1]/div/div[2]/span
   set global variable   ${count}
   ${attribute name}=   set variable   color
   FOR   ${INDEX}   IN RANGE   1   ${count}+1
       ${element}=   Get webelement   xpath:/html/body/div/main/div[1]/div/article[${INDEX}]/section[*]/div/div[2]/span
       ${prop_val}=   Call Method   ${element}   value_of_css_property   ${attribute name}
       Should be equal   ${prop_val}   ${questioncolor}
    END
    
    ##Just to understand for later: article[*] is each section represented by a different color and section[1] is the first question in each section
    ##In the for loop i compare each 1st question of every section to see if their colors match
       
Checking the first question of each section if the font used is the same
   ${attribute name}=   set variable   font-family
   FOR   ${INDEX}   IN RANGE   1   ${count}+1
       ${element}=   Get webelement   xpath:/html/body/div/main/div[1]/div/article[${INDEX}]/section[*]/div/div[2]/span
       ${prop_val}=   Call Method   ${element}   value_of_css_property   ${attribute name}
       Should be equal   ${prop_val}   ${fontfamily}
    END
    


*** Test Cases ***
Answering all of the questions from the read file
   ${numbers}=   Get file   C:/Users/Caner/Downloads/valinnat.txt   
   @{numberlist}=   Split to lines   ${numbers}   
   @{questionorder}=   Create list   6   7   8   9   95   63   18   17   3   11   13   10   12   16   19   20   22   21   4   5   1   2   60   61   64   23   24   25   26   27
   
   ## IN ZIP allows us to loop through 2 variables together, line representing numberlist and index for questionorder
   FOR   ${line}   ${index}   IN ZIP   ${numberlist}   ${questionorder}
   Select radio button   question_${index}   ${line}   
   END
   #See results page button
   Click button   xpath:/html/body/div/main/div[1]/div/button

*** Test Cases ***
Clicking the next page and comparing all the candidates from the meet the candidate button
   
   ${count}=   Get element count   xpath:/html/body/div/main/div[1]/div/section[*]/div[1]/div[1]/h3/a
   FOR   ${INDEX}   IN RANGE   1   ${count}+1
      ${frontname}=   Get text   xpath:/html/body/div/main/div[1]/div/section[${INDEX}]/div[1]/div[1]/h3/a
      Append to list   ${frontnameslist}   ${frontname} 
   END
   
   FOR   ${INDEX2}   IN RANGE   1   ${count}+1
      Click element    xpath:/html/body/div/main/div[1]/div/section[${INDEX2}]/div[1]/div[1]/a[2]
      ${backname}=   Get text   xpath:/html/body/div/main/div[1]/div/section[1]/div[1]/div[1]/h1                                 
      Append to list   ${backnameslist}   ${backname}      
      Click element   xpath:/html/body/div/main/div[1]/header/div[1]/button
   END   
   Should be equal   ${frontnameslist}   ${backnameslist}

*** Test Cases ***
Navigating to the candidate Harri Aalto 
   Click element    xpath:/html/body/div/div/div[1]/div/a[2]
   Click element   xpath:/html/body/div/main/div[1]/section/a   
   Input text   xpath:/html/body/div/main/div[1]/div/div[1]/input   Harri Aalto
Getting the screenshot of the candidate Harri Aalto
   Set screenshot directory   ${OriginalShotDir}
   Empty Directory   ${OriginalShotDir}
   Capture element screenshot   CSS:html body div#root main div.constituencyroute__MainWrapper-sc-1cmvtcm-0.bBopNv div.candidatespage__Container-lc4j1t-1.gbJZop div div div.ReactVirtualized__Grid.ReactVirtualized__List div.ReactVirtualized__Grid__innerScrollContainer div section.ResultCard-b3imyv-4.dWctTj.card__Card-jgylk6-1.kZXFax div.ResultCard__InfoRow-b3imyv-1.gXVvhG img.CandidateImage-sc-50x8nr-0.jXMapJ
Comparing and reporting the differences
   ${diffvalue}=   Run and return rc and output   magick ${OriginalShotDir}/selenium-element-screenshot-1.png ${testShotDir}/selenium-element-screenshot-1.png -metric RMSE -compare -format "%[distortion]" info:
   ${diffvalue}=   Set variable   ${diffvalue}[1]
   Run keyword if   ${diffvalue}>0   Run   magick ${OriginalShotDir}/selenium-element-screenshot-1.png ${testShotDir}/selenium-element-screenshot-1.png -metric RMSE -compare ${testShotDir}difference.png

*** Test Cases ***
Extra test 1: Checking if there are always the same amount of categories which is 8

   ${count}=   Get element count   xpath:/html/body/div[1]/main/div[1]/div/article[*]/section[1]/div/div[1]
   Should be equal   ${count}   ${category_count}

*** Test Cases ***
Extra test 2: Checking if every section has the correct labels displaying.
   @{correct_answerlist}=   Create list   Completely disagree   I don't know   Completely agree   Completely disagree   I don't know   Completely agree   Completely disagree   I don't know   Completely agree   Completely disagree   I don't know   Completely agree   Completely disagree   I don't know   Completely agree   Completely disagree   I don't know   Completely agree   Completely disagree   I don't know   Completely agree   Completely disagree   I don't know   Completely agree
   ${count}=   Get element count   xpath:/html/body/div/main/div[1]/div/article[*]/section[1]/div/div[3]/div[1]/label  
   
   FOR   ${INDEX}   IN RANGE   1   ${count}+1
   ${cdisagree}=   Get text   xpath:/html/body/div/main/div[1]/div/article[${INDEX}]/section[1]/div/div[3]/div[1]/label      
   ${idontknow}=   Get text   xpath:/html/body/div/main/div[1]/div/article[${INDEX}]/section[1]/div/div[3]/div[3]/label
   ${cagree}=   Get text   xpath:/html/body/div/main/div[1]/div/article[${INDEX}]/section[1]/div/div[3]/div[5]/label    
   Append to list   ${answerlist}   ${cdisagree}
   Append to list   ${answerlist}   ${idontknow}
   Append to list   ${answerlist}   ${cagree}
   END
   
   Should be equal   ${answerlist}   ${correct_answerlist}
 

*** Test Cases ***
Extra test 3: Screenshotting our top 2 candidates
   Capture element screenshot   CSS:html body div#root main div.constituencyroute__MainWrapper-sc-1cmvtcm-0.bBopNv div.resultpage__Container-juvi7r-1.cJntQT section.ResultCard-b3imyv-4.dWctTj.card__Card-jgylk6-1.kmYdWT
   Capture element screenshot   CSS:html body div#root main div.constituencyroute__MainWrapper-sc-1cmvtcm-0.bBopNv div.resultpage__Container-juvi7r-1.cJntQT section.ResultCard-b3imyv-4.dWctTj.card__Card-jgylk6-1.kZXFax

*** Test Cases ***
Extra test 4: Checking if our top candidate is from Liike Nyt.
  ${liike}=   Set variable  Liike Nyt
  Click element   xpath:/html/body/div/main/div[1]/div/section[1]/div[1]/div[1]/a[1]
  ${element}=   Get text   xpath:/html/body/div/main/div[1]/div/section[1]/div[2]/div[1]/h3
  Should be equal  ${liike}   ${element}

*** Test Cases ***
Extra test 5: Comparing my answers to others my age
  Click button   xpath:/html/body/div/main/div[1]/div/section[10]/button
  Input text   xpath:/html/body/div/main/div[1]/div/section[10]/div/div/div[2]/div/form/div[1]/input   25
  Click element   xpath:/html/body/div/main/div[1]/div/section[10]/div/div/div[2]/div/form/div[2]/select/option[2]
  Click button   xpath:/html/body/div/main/div[1]/div/section[10]/div/div/div[2]/div/div[2]/button


