require "rubygems"
require "telegram/bot"
require "redis"
require 'pry'
require "json"
require_relative "db"
require_relative "command"
require_relative "user"
require_relative "start"
require_relative "data"

HELLO = "*Привет*. Я тебе могу помочь сделать годный мемасик про чужих мамок и вот это всё. Смотри список команд, которые я знаю:
/start - выводит приветствие и описание всех доступных команд
/create - создать мемасик
/random - получить рандомный мемасик с биржы мемов
/cancel - отменить создание мемасика".freeze

# Bot logic
class TelegramBot
  def choose_command(message, id, bot)
    case message.text
    when "/start" then Start.new(bot, message, HELLO)
    when "/create" then create_command(id)
    when "/cancel" then cancel_command(id)
    when "/random" then random_command(id, message)
    else
      @command.send_message("Сложно. Давай ещё раз")
    end
  end

  def create_command(id)
    puts "Create biatch"
    @command.send_message "Введи текст, который ты хочешь видеть вверху мемасика"
    hash = @db.get_hash(id)
    hash["user_status"] = "wanna_top_label"
    @db.set_hash(hash, id)
    puts hash
  end

  def cancel_command(id)
    @command.send_message "Отмена."
    hash = @db.get_hash(id)
    hash["user_status"] = nil
    @db.set_hash(hash, id)
  end

  def random_command(id, message)
    @command.send_message "Так, сейчас посмотрю что тут у нас интересного на бирже мемов."
    hash = @db.get_hash(id)
    hash["user_status"] = "wanna_random_mem"
    @db.set_hash(hash, id)
    @user.check_status(hash, @db.redis, @command, message)
  end

  def init_helper(message, bot)
    @user = User.new(message.chat.id)
    @db = Database.new(@user.id)
    @command = Command.new(bot, message)
    hash = @db.get_hash(@user.id)
    hash
  end

  def initialize
    Telegram::Bot::Client.run(TOKEN) do |bot|
      bot.listen do |message|
        hash = init_helper(message, bot)
        if message.text == "/cancel"
          cancel_command(@user.id) 
          next
        end
        next if @user.check_status(hash, @db.redis, @command, message)
        choose_command(message, @user.id, bot)
      end
    end
  end
end
