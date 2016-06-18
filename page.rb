class BasicPage

  def initialize(page_number,browser,params,failed_pages)
    print "\r Testing #{page_number}.html"
    @page_number = page_number
    @browser = browser
    @params = params
    @failed_pages = failed_pages
  end

  def test_successful()
    @browser.get "http://#{@params['base_url']}/#{@page_number}.html"

    #сначала нужно найти ссылку на следующую страницу.
    # Лучше всего искать ее по атрибуту href
    link = @browser.find_element(:xpath,"//*[@href='#{@page_number+1}.html']")

    #вызовем событие mouseover для ссылки, мало ли что там
    @browser.action.move_to(link).perform
    link.click

    if @browser.current_url != "http://#{@params['base_url']}/#{@page_number+1}.html"
      #так же сделаем проверку на то, что ссылка вела на следующую страницу.
      #С одной стороны, это гарантируется атрибутом href,
      #с другой - не возьмусь утверждать, что при помощи JavaScript браузер нельзя перехитрить.
      @failed_pages << {id: @page_number, reason: "Link led somewhere else"}
      return false
    else
      return true
    end

  rescue Selenium::WebDriver::Error::NoSuchElementError
    #если браузер не нашел ссылку, можно считать тест проваленным
    @failed_pages << {id: @page_number, reason: "No link present"}
    return false
  rescue Selenium::WebDriver::Error::ElementNotVisibleError
    #наличие ссылки в DOM недостаточно. Она еще должна быть видна.
    @failed_pages << {id: @page_number, reason: "Link not visible"}
    return false
  end

end
