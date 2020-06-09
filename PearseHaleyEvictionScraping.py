Python 3.7.3 (v3.7.3:ef4ec6ed12, Mar 25 2019, 16:52:21) 
[Clang 6.0 (clang-600.0.57)] on darwin
Type "help", "copyright", "credits" or "license()" for more information.
>>> # import modules

import pandas as pd
import glob
import os
from bs4 import BeautifulSoup
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import JavascriptException, NoSuchElementException, StaleElementReferenceException
from selenium.common.exceptions import TimeoutException, ElementClickInterceptedException
from selenium.common.exceptions import ElementNotInteractableException, ElementNotSelectableException
from selenium import webdriver
from selenium.webdriver import ActionChains
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from my_fake_useragent import UserAgent
from selenium.webdriver.common.keys import Keys
from python_anticaptcha import AnticaptchaClient, NoCaptchaTaskProxylessTask

## API_Key for page, and site_key to send to captcha solving service ##
API_KEY = '########################'
site_key = "6LfqmHkUAAAAAAKhHRHuxUy6LOMRZSG2LvSwWPO9"

tyler_login = "########"
tyler_password = "##########"

#function to create a csv from the dataframe resulting from each search#

def make_df(source, file_name, county, year, month, cases):
    # create file name based on county, month, and year
    if str(county) == "DeKalb" and str(month) != "All":
        filepath = "//Users//victorhaley//Desktop//Evictions//DeKalb//" + str(year) + "//" + str(month) + "//"
    elif str(county) == "DeKalb" and str(month) == "All":
        filepath = "//Users//victorhaley//Desktop//Evictions//DeKalb//" + str(year) + "//Missing//"
    elif str(county) == "Fulton" and str(month) != "All":
        filepath = "//Users//victorhaley//Desktop//Evictions//" + str(year) + "//" + str(month) + "//"
    elif str(county) == "Fulton" and str(month) == "All":
        filepath = "//Users//victorhaley//Desktop//Evictions//" + str(year) + "//Missing//"
    # create data frame from list of case record info
    df = pd.DataFrame(source,
                      columns=['File Date', 'Case ID', 'Plaintiff', 'Plaintiff Address', 'Plaintiff City',
                               'Defendant1 Name', 'Defendant1 Address', 'Defendant1 City', 'Defendant2 Name',
                               'Defendant2 Address', 'Defendant2 City', 'Case Status', 'Event Number', 'Event'])
    # export data frame to csv
    df.to_csv(filepath + file_name + ".csv", sep=",", index=False,
              columns=['File Date', 'Case ID', 'Plaintiff', 'Plaintiff Address', 'Plaintiff City',
                       'Defendant1 Name', 'Defendant1 Address', 'Defendant1 City', 'Defendant2 Name',
                       'Defendant2 Address', 'Defendant2 City', 'Case Status', 'Event Number', 'Event'])
    print(str(cases[-1]) + " out of " + str(df['Case ID'].nunique()))


def solve_captcha():
    driver.switch_to.frame(driver.find_elements_by_tag_name('iframe')[0])
    try:
        check = WebDriverWait(driver, 10).until(
            EC.element_to_be_clickable((By.XPATH, '//*[@id="recaptcha-anchor"]/div[1]')))
        print("check box image captcha")
    except (TimeoutException, NoSuchElementException):
        print("no check box")
    client = AnticaptchaClient(API_KEY)
    task = NoCaptchaTaskProxylessTask(page, site_key)
    job = client.createTask(task)
    print("Waiting for solution by Anticaptcha workers")
    job.join()
    # Receive response
    captcha_response = job.get_solution_response()
    print("Received solution", captcha_response)
    # Inject response in webpage
    driver.switch_to.default_content()
    driver.execute_script(
        "arguments[0].style.display='inline'",
        driver.find_element_by_xpath(
            '//*[@id="g-recaptcha-response"]'
        ),
    )
    driver.execute_script(
        'document.getElementById("g-recaptcha-response").innerHTML = "%s"'
        % captcha_response
    )
    driver.switch_to.default_content()

#function to enter search dates and case record strings
    
def get_records(start_date, end_date, search_term, driver):

    short_timeout = 10  # give enough time for the loading element to appear
    long_timeout = 60

    # expand advanced search filter
    try:
        advanced_filter = WebDriverWait(driver, long_timeout).until(
            EC.element_to_be_clickable((By.XPATH, '//*[@id="AdvOptions"]')))
        ActionChains(driver).move_to_element(advanced_filter).click(advanced_filter).perform()
        print("advanced filter clicked")
    except ElementNotInteractableException:
        advanced_filter = WebDriverWait(driver, long_timeout).until(
            EC.element_to_be_clickable((By.XPATH, '//*[@id="AdvOptions"]')))
        ActionChains(driver).move_to_element(advanced_filter).click(advanced_filter).perform()
        print("advanced filter clicked")

    # input start and end dates and search term
    search_box = WebDriverWait(driver, long_timeout).until(
        EC.presence_of_element_located((By.XPATH, '//*[@id="caseCriteria_SearchCriteria"]')))
    search_box.clear()
    search_box.send_keys(search_term)
    print("search term entered")

    try:
        start_box = driver.find_element_by_id('caseCriteria.FileDateStart')
        start_box.clear()
        start_box.send_keys(start_date)
        print("start date entered")
    except ElementNotInteractableException:
        advanced_filter = WebDriverWait(driver, long_timeout).until(
            EC.element_to_be_clickable((By.XPATH, '//*[@id="AdvOptions"]')))
        ActionChains(driver).move_to_element(advanced_filter).click(advanced_filter).perform()
        print("start date entered")

    try:
        end_box = driver.find_element_by_id('caseCriteria.FileDateEnd')
        end_box.clear()
        end_box.send_keys(end_date)
        print("end date entered")
    except ElementNotInteractableException:
        advanced_filter = WebDriverWait(driver, long_timeout).until(
            EC.element_to_be_clickable((By.XPATH, '//*[@id="AdvOptions"]')))
        ActionChains(driver).move_to_element(advanced_filter).click(advanced_filter).perform()
        print("end date entered")
	#wait a few seconds in case page loading lags#
    driver.implicitly_wait(5)

#function for submitting search and checking for results to load
    
def submit_search(driver):
    short_timeout = 10  # give enough time for the loading element to appear
    long_timeout = 30
    driver.switch_to.default_content()
	#wait for submit button to be loaded#
    WebDriverWait(driver, long_timeout).until(
        EC.presence_of_all_elements_located((By.XPATH, '//*[@id="btnSSSubmit"]')))
    submit_button = driver.find_elements_by_xpath('//*[@id="btnSSSubmit"]')[0]
    WebDriverWait(driver, long_timeout).until(
        EC.element_to_be_clickable((By.XPATH, '//*[@id="btnSSSubmit"]')))
    ActionChains(driver).move_to_element(submit_button).click(submit_button).perform()
    #switch to loaded content#
    driver.switch_to.default_content()
    driver.implicitly_wait(10)
    #wait for grid holding search results to load#
    try:
        WebDriverWait(driver, long_timeout).until(
            EC.visibility_of_element_located((By.XPATH, '//*[@id="CasesGrid"]/table/thead/tr/th[2]/a[1]/span')))
        print("results loaded")
        driver.switch_to.default_content()
	#every once in a while selenium won't initially read the submit button, this catches that timeout, refreshes,#
        #and looks for it one more time#
    except TimeoutException:
        print("Timeout Error")
        driver.switch_to.default_content()
        driver.switch_to.window(driver.window_handles[0])
        WebDriverWait(driver, long_timeout).until(
            EC.presence_of_all_elements_located((By.XPATH, '//*[@id="btnSSSubmit"]')))
        submit_button2 = driver.find_elements_by_xpath('//*[@id="btnSSSubmit"]')[0]
        WebDriverWait(driver, long_timeout).until(
            EC.element_to_be_clickable((By.XPATH, '//*[@id="btnSSSubmit"]')))
        ActionChains(driver).move_to_element(submit_button2).click(submit_button2).perform()
        WebDriverWait(driver, long_timeout).until(
            EC.visibility_of_element_located((By.XPATH, '//*[@id="CasesGrid"]/table/thead/tr/th[2]/a[1]/span')))
        print("results loaded")
        driver.switch_to.default_content()


#function to find dropdown arrow and expand results if over 25 so that all can be clicked and looped through#

def expand_results(driver):
    short_timeout = 3  # give enough time for the loading element to appear
    long_timeout = 30
    #switch to main window, this helps get around the AJAX pagination#
    driver.switch_to.window(driver.window_handles[0])
    driver.implicitly_wait(10)
    #wait for presence of bottom of case grid and expand results#
    WebDriverWait(driver, 60).until(
       EC.presence_of_element_located((By.XPATH, '//*[@id="CasesGrid"]/table/thead/tr/th[2]/a[2]')))
    pages = driver.find_elements_by_xpath('//*[@id="CasesGrid"]/div/ul/li')
    #if less than 25 results don't click anything#
    if len(pages) == 0:
        print("Under 25 results")
    else:
        try:
            dropdown = WebDriverWait(driver, long_timeout).until(
                EC.element_to_be_clickable((By.XPATH, '//*[@id="CasesGrid"]/div/span[1]/span')))
            ActionChains(driver).move_to_element(dropdown).click(dropdown).perform()
            print("dropdown clicked")

            two_hundred = WebDriverWait(driver, long_timeout).until(
                EC.visibility_of_element_located(
                    (By.CSS_SELECTOR, 'body>div.k-animation-container.km-popup>div>ul>li:nth-child(4)')))
            ActionChains(driver).move_to_element(two_hundred).click(two_hundred).perform()
            print("results expanded")
            #sometimes the click gets intercepted or the dropdown can't be found,#
            #this code refreshes the search results and tries again#
        except (TimeoutException, ElementClickInterceptedException, JavascriptException):
            search_results = driver.find_element_by_id("tcControllerLink_1")
            ActionChains(driver).move_to_element(search_results).click(search_results).perform()
            driver.switch_to.window(driver.window_handles[0])
            dropdown = WebDriverWait(driver, long_timeout).until(
                EC.element_to_be_clickable((By.XPATH, '//*[@id="CasesGrid"]/div/span[1]/span')))
            ActionChains(driver).move_to_element(dropdown).click(dropdown).perform()
            print("dropdown clicked")
            two_hundred = WebDriverWait(driver, long_timeout).until(
                EC.visibility_of_element_located(
                    (By.CSS_SELECTOR, 'body>div.k-animation-container.km-popup>div>ul>li:nth-child(4)')))
            ActionChains(driver).move_to_element(two_hundred).click(two_hundred).perform()
            print("results expanded")

##main function that gets case links, loops through each one, uses beautifulsoup module to parse the html,##
##and stores the info for each case in a list that can be transformed to a dataframe and then exported as a csv file##

def get_data(start, year, driver, cases, master_list, errors):
    prefix1 = str(year[-2:]) + "ED"
    prefix2 = str(year[-2:]) + "DE"
    prefix3 = str(year[-2:]) + "D"
    long_timeout = 60
    ##create case list using prefix for whatever year is being scraped (2017 here) to be looped through##
    if len(driver.find_elements_by_partial_link_text(prefix1)) > 0:
        case_list = driver.find_elements_by_partial_link_text(prefix1)
    elif len(driver.find_elements_by_partial_link_text(prefix2)) > 0:
        case_list = driver.find_elements_by_partial_link_text(prefix2)
    elif len(driver.find_elements_by_partial_link_text(prefix3)) > 0:
        case_list = driver.find_elements_by_partial_link_text(prefix3)
    cases.append(len(case_list))

    for c in range(start, len(case_list)):
        try:
		#wait for case records header to load#
            WebDriverWait(driver, long_timeout).until(
                EC.element_to_be_clickable((By.XPATH, '//*[@id="CasesGrid"]/table/thead/tr/th[2]/a[2]')))
            case = case_list[c]
            case_text = case.text
            ActionChains(driver).move_to_element(case).click(case).perform()

            driver.implicitly_wait(10)
            #wait for individual case record page to load#
            WebDriverWait(driver, long_timeout).until(
                EC.element_to_be_clickable((By.XPATH, '//*[@id ="PortletSummaryROA"]/div[2]/div/div[1]/div/button')))
            #switch to default content to handle AJAX pagination#
            driver.switch_to.default_content()
            #make beautifulsoup of case record page#
            soup = BeautifulSoup(driver.page_source, 'lxml')
            #the information of interest all falls under either html div tags with classes 'col-md-4' or 'col-md-8'#
            #or li tags with the class 'list-group-item' so we collect those here#
            muted = soup.find_all('div', class_='col-md-4')
            primary = soup.find_all('div', class_='col-md-8')
            groups = soup.find_all('li', class_='list-group-item')
            #make an empty list to hold all of the case info#
            case_info = []

            #find file date, format, and add to case info#
            for m in muted:
                if "File Date" in m.get_text():
                    file_date = m.get_text()
                    file_date = file_date.replace(r'File Date', '')
                    file_date = file_date.rstrip()
                    file_date = file_date.lstrip()
                    case_info.append(file_date)

            #find case id, format, and add to case info#
            for m in muted:
                if "Case Number" in m.get_text():
                    case_id = m.get_text()
                    case_id = case_id.replace(r'Case Number', '')
                    case_id = case_id.rstrip()
                    case_id = case_id.lstrip()
                    case_info.append(case_id)

            #gets plaintiff info. because the exact position of this info on the page can vary and sometimes only some#
                    #or none of the info gets entered, we need to add conditionals and try/except error catching to make#
                    #sure we get the right info and that we add blanks if any information is missing#
            p_info = []
            pl_info = []
            #gets all plaintiff info, breaks it up into lines, and removes any extra spaces, and filters out empty list#
            #elements#
            try:
                plaintiff_info = primary[0].get_text()
                plaintiff_lines = plaintiff_info.splitlines()
                for l in plaintiff_lines:
                    p_info.append(l.lstrip().rstrip())
                p_info = list(filter(None, p_info))
                #if primary[0].get_text() throws an index error then we pass to the next step and try primary[1]#
            except IndexError:
                pass
            try:
                plaintiff_info2 = primary[1].get_text()
                pl_lines = plaintiff_info2.splitlines()
                for l in pl_lines:
                    pl_info.append(l.lstrip().rstrip())
                pl_info = list(filter(None, pl_info))
         #if primary[1].get_text() throws an index error then we pass to the next block. If the plaintiff info is missing,#
                #then blanks will be added to the case info list to make sure all list entries are equal length to fit a#
                #data frame#
            except IndexError:
                pass
        #most records just have a Plaintiff header with the plaintiff info underneath. Some, though, have separate#
        #Participant and Plaintiff headers. this block checks for each and finds the Plaintiff header or adds blanks if#
        #plaintiff info is missing#
        #plaintiff name#
            try:
                if p_info[1] == '(Participant)':
                    plaintiff = pl_info[1]
                else:
                    plaintiff = p_info[1]
            except IndexError:
                plaintiff = " "
                #plaintiff address#
            try:
                if p_info[1] == '(Participant)':
                    plaint_add = pl_info[3]
                else:
                    plaint_add = p_info[3]
            except IndexError:
                plaint_add = " "
            case_info.append(plaintiff)
            case_info.append(plaint_add)
            try:
                # plaintiff city#
                plaint_city = p_info[-1]
                case_info.append(plaint_city)
            except IndexError:
                case_info.append(" ")

#This block checks if the Defendant section is present, gets all the defendant info, checks if there are multiple defendants, and adds blanks for any missing elements#
            d_info = []
            for p in primary:
                if "Defendant" in p.get_text():
                    # defendant 1 name#
                    d_info.append(p.get_text())
                    def1_lines = d_info[0].splitlines()
                    def1_lines = list(map(str.strip, def1_lines))
                    def1_lines = list(filter(None, def1_lines))
                    try:
                        def1_name = def1_lines[1]
                        case_info.append(def1_name)
                    except (UnboundLocalError, IndexError):
                        def1_name = " "
                        case_info.append(def1_name)
                #defendant 1 address#
                    try:
                        addindex = def1_lines.index('Address')
                        if len(def1_lines[addindex:]) > 3:
                            def1_add = def1_lines[addindex + 1:-1]
                            def1_add = ', '.join(def1_add)
                            case_info.append(def1_add)
                        elif len(def1_lines[addindex:]) == 3:
                            def1_add = def1_lines[addindex + 1]
                            case_info.append(def1_add)
                        else:
                            def1_add = " "
                            case_info.append(def1_add)
                    except (UnboundLocalError, IndexError, ValueError):
                        def1_add = " "
                        case_info.append(def1_add)
                #defendant 1 city#
                    try:
                        def1_city = def1_lines[-1]
                        case_info.append(def1_city)
                    except (UnboundLocalError, IndexError):
                        def1_city = " "
                        case_info.append(def1_city)

#conditional to see if there is information for a second defendant#
                    if len(d_info) > 1:
                        d2_info = d_info[-1]
                        def2_lines = d2_info.splitlines()
                        def2_lines = list(map(str.strip, def2_lines))
                        def2_lines = list(filter(None, def2_lines))
                        #defendant 2 name#
                        try:
                            def2_name = def2_lines[1]
                            case_info.append(def2_name)
                        except IndexError:
                            def2_name = " "
                            case_info.append(def2_name)
                            #defendant 2 address#
                        try:
                            addindex = def2_lines.index('Address')
                            if len(def2_lines[addindex:]) > 3:
                                def2_add = def2_lines[addindex + 1:]
                                def2_add = ', '.join(def2_add)
                                case_info.append(def2_add)
                            elif len(def2_lines[addindex:]) == 3:
                                def2_add = def2_lines[addindex + 1]
                                case_info.append(def2_add)
                            else:
                                def2_add = " "
                                case_info.append(def2_add)
                        except (IndexError, ValueError):
                            def2_add = " "
                            case_info.append(def2_add)
			#defendant 2 city#
                        try:
                            def2_city = def2_lines[-1]
                            case_info.append(def2_city)
                        except IndexError:
                            def2_city = " "
                            case_info.append(def2_city)
                    elif len(d_info) <= 1:
                        def2_name = " "
                        case_info.append(def2_name)
                        def2_add = " "
                        case_info.append(def2_add)
                        def2_city = " "
                        case_info.append(def2_city)

            #gets case status, formats, and adds to case info#
            for m in muted:
                if "Case Status" in m.get_text():
                    case_stat = m.get_text()
                    case_stat = case_stat.replace(r'Case Status', '')
                    case_stat = case_stat.rstrip()
                    case_stat = case_stat.lstrip()
                    case_info.append(case_stat)

#gets all case events, loops through them, and adds the plaintiff, defendant, date, case id, and status info to each#
                    #to create a separate row for each event#
            event_info = []
            events = []
            for g in range(len(groups)):
                event_info.append(groups[g].get_text().lstrip().rstrip().split('  '))
            event_info = list(filter(None, event_info))
            for e in event_info:
                event = list(filter(None, e))
                event = event[0:2]
                events.append(' '.join(event))
            for e in range(len(events)):
                event_desc = list(filter(None, events[e].splitlines()))
                case_row = case_info + [e + 1, ' '.join(event_desc)]
                master_list.append(case_row)
                print(case_row)
                del case_row

            # delete local lists and print statement to show progress through loop#
            print(str(c+1) + " out of " + str(len(case_list)))
            del case_info
            del soup
            del muted
            del primary
            del groups

            #return to results#
            WebDriverWait(driver, long_timeout).until(EC.presence_of_element_located((By.ID, "tcControllerLink_1")))
            results_button = driver.find_element_by_id("tcControllerLink_1")
            ActionChains(driver).move_to_element(results_button).click(results_button).perform()
            driver.switch_to.default_content()
#catches frequent error exceptions adds the error term to a list and continues through the loop to prevent breaking#
        except (TimeoutException, StaleElementReferenceException, JavascriptException, ElementClickInterceptedException):
            print("Error at " + str(c) + " " + case_text)
            # return to results
            errors.append(case_text)
            driver.switch_to.default_content()
            WebDriverWait(driver, long_timeout).until(EC.presence_of_element_located((By.ID, "tcControllerLink_1")))
            results_button = driver.find_element_by_id("tcControllerLink_1")
            ActionChains(driver).move_to_element(results_button).click(results_button).perform()
            driver.switch_to.default_content()
            continue
        
#set chromedriver options including headless mode, max window size, and sending a random user agent, which helps get a simpler captcha"
def set_options():
    chrome_options = webdriver.ChromeOptions()
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-setuid-sandbox")
    chrome_options.add_argument("--headless")
    chrome_options.add_argument("--window-size=1920x1080")
    ua = UserAgent(family='chrome')
    randomua = ua.random()
    chrome_options.add_argument(f'user-agent={randomua}')
    print(randomua)
    return chrome_options

#create selenium webdriver#
def make_driver(county, options):
    long_timeout = 30
    path = '//Users//victorhaley//Desktop//chromedriver-1'
    page = 'https://publicrecordsaccess.fultoncountyga.gov/Portal/Home/Dashboard/29#'
    # load webdriver
    driver = webdriver.Chrome(executable_path=path, options=chrome_options)
    # get page
    driver.get(page)
    WebDriverWait(driver, long_timeout).until(
        EC.element_to_be_clickable((By.XPATH, '//*[@id="btnSSSubmit"]'))
    )
    return driver

#quit driver#
def close_driver(driver):
    # close driver
    driver.close()
    # quit driver
    driver.quit()

#function to sign in to Tyler#
def sign_in(driver):
    login_button = driver.find_elements_by_id("dropdownMenu1")
    try:
        ActionChains(driver).move_to_element(login_button[0]).click(login_button[0]).perform()
    except ElementNotInteractableException:
        ActionChains(driver).move_to_element(login_button[1]).click(login_button[1]).perform()
    sign_in = driver.find_elements_by_xpath('//*[@id="navbar"]/div/ul/li[2]/a')
    try:
        ActionChains(driver).move_to_element(sign_in[0]).click(sign_in[0]).perform()
    except ElementNotInteractableException:
        ActionChains(driver).move_to_element(sign_in[1]).click(sign_in[1]).perform()
    email_field = driver.find_element_by_xpath('//*[@id="UserName"]')
    email_field.send_keys(tyler_login)
    password_field = driver.find_element_by_xpath('//*[@id="Password"]')
    password_field.send_keys(tyler_password)
    sign_in_button = driver.find_element_by_xpath('/html/body/div/form/div[4]/div/div/div/button')
    ActionChains(driver).move_to_element(sign_in_button).click(sign_in_button).perform()
    smart_search = driver.find_element_by_xpath('//*[@id="portlet-29"]/a')
    ActionChains(driver).move_to_element(smart_search).click(smart_search).perform()

#function to create long form table of monthly records where each case event is one line#
def makelongtable(county, year, month):
    if str(county) == "DeKalb":
        filepath = "//Users//victorhaley//Desktop//Evictions//DeKalb//" + str(year) + "//" + str(month) + "//"
        outfile = "//Users//victorhaley//Desktop//Evictions//DeKalb//" + str(year) + "//Long//" + str(month) + ".csv"
    elif str(county) == "Fulton":
        filepath = "//Users//victorhaley//Desktop//Evictions//" + str(year) + "//" + str(month) + "//"
        outfile = "//Users//victorhaley//Desktop//Evictions//" + str(year) + "//Long//" + str(month) + ".csv"
    # filepath = "//Users//victorhaley//Desktop//Evictions//2018//" + str(month) + "//"
    all_files = glob.glob(os.path.join(filepath, "*.csv"))
    file_df = pd.concat((pd.read_csv(f) for f in all_files))
    # file_df = file_df.drop(columns=["Event Number", "Event"])
    # file_df = file_df.drop_duplicates()
    file_df['Address'] = file_df['Defendant1 Address'] + ", " + file_df['Defendant1 City']
    pd.DataFrame.to_csv(file_df, outfile, sep=",", index=False,
              columns=['File Date', 'Case ID', 'Plaintiff', 'Plaintiff Address', 'Plaintiff City',
                       'Defendant1 Name', 'Defendant1 Address', 'Defendant1 City', 'Defendant2 Name',
                       'Defendant2 Address', 'Defendant2 City', 'Case Status', 'Event Number',
                       'Event', 'Address'])

#function to filter out judgments from all filings based on keywords in case events#
def getjudgments(county, year, month):
    if str(county) == "DeKalb":
        filepath = "//Users//victorhaley//Desktop//Evictions//DeKalb//" + str(year) + "//" + str(month) + "//"
        judgmentText = "Writ|Judgment|Default|Ejected|Possession|Vacated"
        outpath = "//Users//victorhaley//Desktop//Evictions//DeKalb//Judgments//"
    elif str(county) == "Fulton":
        filepath = "//Users//victorhaley//Desktop//Evictions//" + str(year) + "//" + str(month) + "//"
        judgmentText = "WRIT|JUDGMENT|DEFAULT|EJECTED|POSSESSION|VACATED"
        outpath = "//Users//victorhaley//Desktop//Evictions//2018//Judgments//"
    # filepath = "//Users//victorhaley//Desktop//Evictions//2020//" + str(month) + "//"
    # path = "//Users//victorhaley//Desktop//Permits//Geocoding//"
    allfiles = glob.glob(os.path.join(filepath, "*.csv"))
    filedf = pd.concat((pd.read_csv(f) for f in allfiles))
    # jdf = filedf[filedf["Event"].str.contains("Writ|Judgment|Default|Ejected|Possession|Vacated", na=False)]
    # jdf = filedf[filedf["Event"].str.contains("WRIT|JUDGMENT|DEFAULT|EJECTED|POSSESSION|VACATED", na=False)]
    jdf = filedf[filedf["Event"].str.contains(judgmentText, na=False)]
    jdf['Address'] = jdf['Defendant1 Address'] + ", " + jdf['Defendant1 City']
    # jdf2 = jdf.drop(columns=["Event Number", "Event", "Address"])
    # jdf2 = jdf2.drop_duplicates(subset=['Case ID'], keep=False)
    # jdf2 = jdf2.drop_duplicates()
    jdf2 = jdf.drop_duplicates(subset=['Case ID'], keep="last")
    jdf2[['Event Date', 'Event Type']] = jdf2['Event'].str.split(n=1, expand=True)
    jdf2 = jdf2.drop(columns=["Event Number", "Event"])
    pd.DataFrame.to_csv(jdf2, str(outpath) + str(county) + str(month) + str(year) + "finaljudgments.csv",
                        sep=",", index=False,
                        columns=['File Date', 'Case ID', 'Plaintiff', 'Plaintiff Address', 'Plaintiff City',
                                 'Defendant1 Name', 'Defendant1 Address', 'Defendant1 City', 'Defendant2 Name',
                                 'Defendant2 Address', 'Defendant2 City', 'Case Status', 'Address', 'Event Date',
                                 'Event Type'])

#function to combine individual search records into one csv file with an address column to feed into a geocoding service#
def prepGeocode(county, year, month):
    if str(county) == "DeKalb":
        path = "//Users//victorhaley//Desktop//Evictions//DeKalb//" + str(year) + "//"
    elif str(county) == "Fulton":
        path = "//Users//victorhaley//Desktop//Evictions//" + str(year) + "//"
    # path = "//Users//victorhaley//Desktop//Permits//Geocoding//"
    all_files = glob.glob(os.path.join(path + str(month) + "//", "*.csv"))
    file_df = pd.concat((pd.read_csv(f) for f in all_files))
    file_df = file_df.drop(columns=["Event Number", "Event"])
    file_df = file_df.drop_duplicates()
    file_df['Address'] = file_df['Defendant1 Address'] + ", " + file_df['Defendant1 City']
    pd.DataFrame.to_csv(file_df, path + "Geocoding//" + str(month) + ".csv", sep=",",
                        index=False,
                        columns=['File Date', 'Case ID', 'Plaintiff', 'Plaintiff Address', 'Plaintiff City',
                                 'Defendant1 Name', 'Defendant1 Address', 'Defendant1 City', 'Defendant2 Name',
                                 'Defendant2 Address', 'Defendant2 City', 'Case Status', 'Address'])

#function to identify case ids that could not be succesfully geocoded and save them to a csv file to be fixed later#
def missinggeocodes(county, year):
    if str(county) == "DeKalb":
        path = "//Users//victorhaley//Desktop//Evictions//DeKalb//" + str(year) + "//GIS//"
    elif str(county) == "Fulton":
        path = "//Users//victorhaley//Desktop//Evictions//" + str(year) + "//GIS//"
    # path = "//Users//victorhaley//Desktop//Evictions//DeKalb//" + str(year) + "//GIS//"
    all_files = glob.glob(os.path.join(path, "*.csv"))
    file_df = pd.concat((pd.read_csv(f) for f in all_files))
    geocode_errors = file_df[file_df['lon'].isnull()]
    pd.DataFrame.to_csv(geocode_errors, "//Users//victorhaley//Desktop//Evictions//Geocoding//missing//" + str(county) +
                        str(year) + "geocodeerrors.csv", sep=",", index=False,
                        columns=['File.Date', 'Case.ID', 'Plaintiff', 'Plaintiff.Address', 'Plaintiff.City',
                                 'Defendant1.Name', 'Defendant1.Address', 'Defendant1.City', 'Defendant2.Name',
                                 'Defendant2.Address', 'Defendant2.City', 'Case.Status', 'Address', 'lon', 'lat'])

#function that identifies missing case ids using the sequential numbering structure and saves them to a csv file#
def missingcases(county, year, prefix):
    if str(county) == "DeKalb":
        path = "//Users//victorhaley//Desktop//Evictions//DeKalb//" + str(year) + "//Errors//"
        errorpath = "//Users//victorhaley//Desktop//Evictions//DeKalb//" + str(year) + "//Errors//"
        site = 'https://ody.dekalbcountyga.gov/portal/'
        page = 'https://ody.dekalbcountyga.gov/portal/Home/Dashboard/29'
    elif str(county) == "Fulton":
        path = "//Users//victorhaley//Desktop//Evictions//" + str(year) + "//Errors//"
        errorpath = "//Users//victorhaley//Desktop//Evictions//" + str(year) + "//Errors//"
        site = 'https://publicrecordsaccess.fultoncountyga.gov/Portal/'
        page = 'https://publicrecordsaccess.fultoncountyga.gov/Portal/Home/Dashboard/29#'
    all_files = glob.glob(os.path.join(path, "*.csv"))
    file_df = pd.concat((pd.read_csv(f) for f in all_files))
    # dataset = pd.read_csv(path + "december.csv")
    # df = pd.DataFrame(dataset)
    case_list = file_df.iloc[:, 0].tolist()
    case_nums = []
    for c in case_list:
        if str(county) == "Fulton":
            print(int(c[4:]))
            case_nums.append(int(c[4:]))
        elif str(county) == "DeKalb":
            print(int(c[3:]))
            case_nums.append(int(c[3:]))
    sorted_cases = sorted(case_nums)
    # missing_list = find_missing(sorted_cases)
    missing_list = [x for x in range(sorted_cases[0], sorted_cases[-1]+1)
                               if x not in sorted_cases]
    missing_cases = []
    for m in missing_list:
        missing_cases.append(str(prefix) + str(m))
    case_df = pd.DataFrame(missing_cases, columns=['Case ID'])
    pd.DataFrame.to_csv(case_df,
                        "//Users//victorhaley//Desktop//Evictions//ScrapingErrors//" + str(county) +
                        "//" + str(county) + str(year) + "Errors.csv",
                        sep=",", index=False, columns=['Case ID'])
    search_errors = []
    chrome_options = set_options()
    driver = make_driver(str(county))
    sign_in()
    for i in range(0, len(missing_cases)):
        master_list = []
        errors = []
        term = missing_cases[i]
        get_records("1/01/2016", "12/31/2020", term)
        try:
            submit_search()
            expand_results()
        except (TimeoutException, StaleElementReferenceException):
            if driver.current_url == site:
                search_page = WebDriverWait(driver, 30).until(
                    EC.element_to_be_clickable((By.XPATH, '//*[@id="portlet-29"]/a')))
                # advanced_filter.click()
                ActionChains(driver).move_to_element(search_page).click(search_page).perform()
                submit_search()
                expand_results()
            else:
                search_errors.append(term)
                close_driver()
                continue
        try:
            # driver.switch_to.window(driver.window_handles[0])
            # driver.switch_to.default_content()
            get_data(0, year)
        except (TimeoutException, StaleElementReferenceException):
            search_errors.append(term)
            driver.back()
            driver.switch_to.default_content()
            continue
        make_df(master_list, str(county) + "_MissingEvictions_" + str(year) + str(year) + str(i), county, year, "All")
        if len(errors) > 0:
            df = pd.DataFrame(errors, columns=['Errors'])
            df.to_csv(errorpath + str(county) + str(year) + "errors" + str(i) + ".csv", sep=",", index=False, columns=['Errors'])
        driver.get(page)
    close_driver()

#master function that combines most of the above functions to scrape and save all case records for#
    #a specific county, year, and month. Also requires start and end date for search, list of search terms,#
    #and starting index for the list of cases#
def scrapeRecords(start, end, county, year, month, terms, index):
    if str(county) == "DeKalb":
        errorpath = "//Users//victorhaley//Desktop//Evictions//DeKalb//" + str(year) + "//Errors//"
        site = 'https://ody.dekalbcountyga.gov/portal/'
        page = "https://ody.dekalbcountyga.gov/portal/Home/Dashboard/29"
    elif str(county) == "Fulton":
        errorpath = "//Users//victorhaley//Desktop//Evictions//" + str(year) + "//Errors//"
        site = 'https://publicrecordsaccess.fultoncountyga.gov/Portal/'
        page = 'https://publicrecordsaccess.fultoncountyga.gov/Portal/Home/Dashboard/29#'
    search_errors = []
    chrome_options = set_options()
    driver = make_driver(str(county), chrome_options)
    sign_in(driver)
    for i in range(index, len(terms)):
        master_list = []
        cases = []
        errors = []
        term = terms[i]
        get_records(start, end, term, driver)
        try:
            submit_search(driver)
            expand_results(driver)
        except (TimeoutException, StaleElementReferenceException):
            if driver.current_url == site:
                search_page = WebDriverWait(driver, 30).until(
                    EC.element_to_be_clickable((By.XPATH, '//*[@id="portlet-29"]/a')))
                # advanced_filter.click()
                ActionChains(driver).move_to_element(search_page).click(search_page).perform()
                submit_search(driver)
                expand_results(driver)
            else:
                search_errors.append(term)
                close_driver(driver)
                continue
        try:
            # driver.switch_to.window(driver.window_handles[0])
            # driver.switch_to.default_content()
            get_data(0, year, driver, cases, master_list, errors)
        except (TimeoutException, StaleElementReferenceException):
            search_errors.append(term)
            driver.back()
            driver.switch_to.default_content()
            continue
        make_df(master_list, str(county) + "_evictions_" + str(month) + str(year) + str(i), county, year, month, cases)
        if len(errors) > 0:
            df = pd.DataFrame(errors, columns=['Errors'])
            df.to_csv(errorpath + str(month) + "errors" + str(i) + ".csv", sep=",", index=False, columns=['Errors'])
        driver.get(page)
    # make_df(master_list, "fulton_evictions_oct19" + str(i) + ".csv")
    close_driver(driver)

#create list of search terms to feed scrapeRecords function#
may17searchtermsdekalb = []
prefix = "17D1"
suffixes = list(range(17, 44))
for s in suffixes:
    may17searchtermsdekalb.append(prefix + str(s) + '*')

scrapeRecords("5/01/2017", "5/31/2017", "DeKalb", "2017", "May", may17searchtermsdekalb, 0)


#example of how to loop through monthly data and create judgment tables, prepare data for geocoding, and make#
#long tables#
months = ["January", "February", "March", "April", "May", "June", "July", "August", "September",
          "October", "November", "December"]

for m in months:
    getjudgments("DeKalb", 2017, m)
    prepGeocode("DeKalb", 2017, m)
    makelongtable("DeKalb", 2017, m)



