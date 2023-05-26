# lenght of the word 5, no time limit, there is only one player playingm he has 6 guesses to find the word
require 'gosu'

class WordleGame < Gosu::Window
  def initialize
    super(800, 600)
    self.caption = 'Wordle Game'

    @target_word = "apple"
    @guesses_remaining = 6
    @guessed_letters = []

    font_path = 'ClearSans-Bold.ttf' # Replace with the actual file path of the "Clear Sans" font

    @font_title = Gosu::Font.new(self, font_path, 40)
    @font_letters = Gosu::Font.new(self, font_path, 30)
    @font_text = Gosu::Font.new(self, font_path, 20)
  end

  def draw
    Gosu.draw_rect(0, 0, width, height, Gosu::Color::BLACK)

    center_x = width / 2
    center_y = height / 2

    title_text = "Wordle"
    title_x = center_x - (@font_title.text_width(title_text, scale_x = 2) / 2)
    title_y = center_y - 200

    @font_title.draw_text(title_text, title_x, title_y, 0, scale_x = 2, scale_y = 2, Gosu::Color::WHITE)

    start_x = center_x - 2.5 * 50 - 2 * 10
    start_y = title_y + @font_title.height + 40

    draw_guess_lines(start_x, start_y)

    display_guesses_remaining(center_x - 70, center_y + 150)

    display_guessed_letters(center_x - 70, center_y + 180)
  end

  def button_down(id)
    case id
    when Gosu::KB_ESCAPE
      close
    end
  end

  def update
    # Add game logic here if needed
  end

  private

  def draw_guess_lines(start_x, start_y)
    square_size = 50
    line_width = 5

    6.times do |i|
      5.times do |j|
        x = start_x + j * (square_size + 10)
        y = start_y + i * (square_size + 10)

        Gosu.draw_rect(x, y, square_size, square_size, Gosu::Color::BLACK, z = 1)
        Gosu.draw_line(x, y, Gosu::Color::WHITE, x + square_size, y, Gosu::Color::WHITE, line_width)
        Gosu.draw_line(x + square_size, y, Gosu::Color::WHITE, x + square_size, y + square_size, Gosu::Color::WHITE, line_width)
        Gosu.draw_line(x + square_size, y + square_size, Gosu::Color::WHITE, x, y + square_size, Gosu::Color::WHITE, line_width)
        Gosu.draw_line(x, y + square_size, Gosu::Color::WHITE, x, y, Gosu::Color::WHITE, line_width)
      end
    end
  end

  def display_guesses_remaining(x, y)
    text = "Guesses Remaining: #{@guesses_remaining}"
    @font_text.draw_text(text, x, y, 0, 1, 1, Gosu::Color::BLACK)
  end

  def display_guessed_letters(x, y)
    guessed_letters_display = "Guessed Letters: " + @guessed_letters.join(", ")
    @font_text.draw_text(guessed_letters_display, x, y, 0, 1, 1, Gosu::Color::BLACK)
  end
end

WordleGame.new.show if __FILE__ == $0
