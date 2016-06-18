# Encoding: utf-8
require 'net/http'
require 'yaml'


#Задача метода - сравнивать страницы с шаблоном, покуда не упрется в ту, в теле которой упоминается, что она последняя.
#Результат выполнения - массив с номерами страниц, которые не попали под шаблон
def points_of_interest(params)
  result = []
  page_number = 1
  while true do
    print "\r Checking: #{page_number}.html  #{"Found #{result.size} unfitting" if result.size > 0}"
    expected = "<html><head/><body><a href='#{page_number+1}.html'>Next</a></body></html>"
    response = Net::HTTP.get_response URI("http://#{params['base_url']}/#{page_number}.html")
    code = response.code
    case code
    when '200'
      result << page_number unless response.body == expected
    #Необходимо предусмотреть случай, когда вместо страничек сервер начнет сыпать ошибками по той или иной причине.
    #Для того, чтобы тест когда-нибудь завершился в params.yml добавлен параметр maximum_attempts
    when '500','403','404'
      result << page_number
      break if page_number > params['maximum_attempts']
    end
    page_number+=1
    #Посчитаем наличие в html подстроки "последняя" достаточным критерием для остановки опроса сервера
    break if response.body.force_encoding('utf-8').include? 'последняя'
  end
  print "\r"
  result
end

def check_status(params,page_number,desired_status)
  print "\r Checking: #{page_number}.html  "
  response = Net::HTTP.get_response URI("http://#{params['base_url']}/#{page_number}.html")
  response.code==desired_status
end
