# Simple command that sends messages
class Command
  def initialize(bot, message)
    @bot = bot
    @message = message
  end

  def send_message(send_text)
    @bot.api.send_message(chat_id: @message.chat.id, parse_mode: "Markdown", text: send_text)
  end

  def send_photo(file_name)
  	@bot.api.send_photo(chat_id: @message.chat.id, photo: Faraday::UploadIO.new(file_name, 'image/png'))
  end
end
