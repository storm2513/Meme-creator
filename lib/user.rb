# User's class
require 'open-uri'
require_relative "generator"


class User
  def initialize(id)
    @id = id
  end

  def get_top_label(hash, redis, command, message)
    hash["top_label"] = message.text
    hash["user_status"] = "wanna_bottom_label"
    command.send_message("Окей, теперь укажи надпись снизу")
    redis.set(@id, hash.to_json)
  end

  def get_bottom_label(hash, redis, command, message)
    hash["bottom_label"] = message.text
    hash["user_status"] = "wanna_image"
    command.send_message("Красава, теперь пришли мне картинку :)")
    redis.set(@id, hash.to_json)
  end

  def get_image(hash, redis, command, message)
    if message.photo.last.nil?
      command.send_message("Хм, не похоже на картинку.")
      return true
    end
    file_id = message.photo.last.file_id
    uri = URI("https://api.telegram.org/bot#{TOKEN}/getFile?file_id=#{file_id}")
    response = JSON.parse(Net::HTTP.get(uri))
    file_path = response["result"]["file_path"]
    url = ("https://api.telegram.org/file/bot#{TOKEN}/#{file_path}")
    puts url
    open('images/image' + @id.to_s + '.png', 'wb') do |file|
      file << open(url).read
    end
    hash["user_status"] = "waiting_image"
    command.send_message("Хайпанём немножечко!")
    redis.set(@id, hash.to_json)
    send_image(hash, redis, command, message)
  end

  def send_image(hash, redis, command, message)
    file_name = "image#{@id.to_s}.png"
    top_label = hash["top_label"]
    bottom_label = hash["bottom_label"]
    command.send_message("Делаю мемас, немного подожди!")
    begin
      result_file_name = Generator.generate("image#{@id.to_s}.png", top_label, bottom_label)
      command.send_photo(result_file_name)
    rescue Exception => exc
      puts exc
      command.send_message("Чёт ошибка какая-то, давай по новой")
    end
    hash["user_status"] = nil
    command.send_message("Чёт ору))0)0")
    redis.set(@id, hash.to_json)
  end

  def send_random_image(hash, redis, command, message)
    images = Dir["images/random/*"]
    file_name = images.sample
    command.send_photo(file_name)
    command.send_message("Я бы безусловно вложил сюда несколько лайков, если бы смог!")
    hash["user_status"] = nil
    redis.set(@id, hash.to_json)
  end

  def check_status(hash, redis, command, message)
    case hash["user_status"]
    when "wanna_top_label" then get_top_label(hash, redis, command, message)
    when "wanna_bottom_label" then get_bottom_label(hash, redis, command, message)
    when "wanna_image" then get_image(hash, redis, command, message)
    when "waiting_image" then send_image(hash, redis, command, message)
    when "wanna_random_mem" then send_random_image(hash, redis, command, message)
    end
  end

  attr_accessor :id
  attr_accessor :status
end
