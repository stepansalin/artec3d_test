require 'selenium/webdriver'

def setup_browser(params)
  Selenium::WebDriver::Chrome.driver_path = params['chromedriver_executable_path']
  browser = Selenium::WebDriver.for :chrome
  browser.manage.timeouts.implicit_wait = params['browser_wait_seconds']
  browser
end
