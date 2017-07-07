# Generates text on image
require 'RMagick'
require 'pry'
include Magick
class Generator
  def self.generate(file_name, top_label, bottom_label)
    labels = [top_label, bottom_label]
    img = ImageList.new("images/#{file_name}")
    txt = Draw.new
    width = img.columns
    height = img.rows
    top = true
    for label in labels
      size = label.size
      size = 8 if label.size < 8
      font_size = width / 12.0 * (22.0 / size)
      margin = height / 45.0
      img.annotate(txt, 0, 0, 0, margin, label) do
        txt.gravity = if top
                        top = false
                        Magick::NorthGravity
                      else
                        Magick::SouthGravity
                      end
        txt.font = "lib/impact.ttf"
        txt.pointsize = font_size
        txt.stroke = '#000000'
        txt.fill = '#ffffff'
        txt.font_weight = Magick::BoldWeight
      end
    end

    img.format = 'png'
    result_file_name = "images/result" + file_name
    img.write(result_file_name)
    result_file_name
  end
end