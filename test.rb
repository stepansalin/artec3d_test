require 'test/unit'
require './request.rb'
require './browser.rb'
require './page.rb'

class TC_Test < Test::Unit::TestCase

  def self.startup
    @@params = YAML.load_file('./params.yml')
    puts "Started searching for pages not fitting the pattern"
    @@to_investigate = points_of_interest(@@params)
    puts "\n done \n"
    # закомментируйте строчку с определением @@to_investigate
    # и раскомментируйте строчку ниже, чтобы не ждать проверки всех страниц
    # @@to_investigate = [4, 5, 638, 666, 3395, 3471, 8543, 9999]
  end

  def setup
    @browser = setup_browser(@@params)
    @failed_pages = []
  end

  def teardown
    @browser.quit
  end

  def test_check_with_browser
    puts "Testing vor valid links\n"
    test_passed = true
    if @@to_investigate.any?
      @@to_investigate.each do |page_number|
        page = BasicPage.new(page_number,@browser,@@params,@failed_pages)
        #если хотя бы для одной страницы тест не выполнился,
        #то assert в конце теста обвалится
        test_passed = false unless page.test_successful()
        print "\r" #\r переносит каретку в начало строки (стирает строку)
                   # это сделано для удобства проверяющего,
                   # в настоящем CI только утяжелит логи
      end
      # Отбросим последний элемент из failed_pages,
      # потому что он просто "последняя" страница.
      # Это можно делать только если тест не прошел,
      # потому что иначе мы можем затронуть страницы,
      # добавленные в failed_pages другими тестами.
      @failed_pages.pop unless test_passed
      print "\r\n ...done!\n"
      assert(test_passed,"Some pages do not have valid links:\n#{@failed_pages}")
    else
      puts "Everything fits the template, no worries"
    end
  end

  def test_boundaries
    puts "\n Testing boundaries\n"
    test_passed = true
    checker = Proc.new do |page_number|
      # метод check_status описан в request.rb
      # если хоть одна страница вернет не 403,
      # то assert в конце теста обвалится
      unless check_status(@@params,page_number,'403')
        test_passed = false
        @failed_pages << {id: page_number,
          reason: "is out of boundaries, but does not invoke 403"}
      end
    end
    #проверяем от params['lowest_boundary'] до 0
    (@@params["lowest_boundary"]..0).each(&checker)
    #проверяем от последнего до его же + params['highest_boundary_margin']
    (@@to_investigate.last+1..@@to_investigate.last+@@params['highest_boundary_margin']).each(&checker)
    print "\r\n ...done!\n"
    assert(test_passed,"Boundaries check failed: #{@failed_pages} ")
  end

end
