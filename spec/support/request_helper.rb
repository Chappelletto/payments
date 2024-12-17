module RequestHelper
  def parsed_body
    JSON.parse(subject.body, symbolize_names: true) # symbolize чтобы вернул ключи символы
  end
end
