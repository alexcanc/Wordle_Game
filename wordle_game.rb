# lenght of the word 5, no time limit, there is only one player playingm he has 6 guesses to find the word
require 'gosu'

class WordleGame < Gosu::Window
  def initialize
    super(900, 800)
    self.caption = 'Wordle Game'

    @target_word = "apple"
    @guesses_remaining = 6
    @guessed_letters = []

    font_path = 'ClearSans-Bold.ttf'  # Replace with the actual file path of the "Clear Sans" font

    @font_title = Gosu::Font.new(self, font_path, 40)
    @font_letters = Gosu::Font.new(self, font_path, 30)
    @font_text = Gosu::Font.new(self, font_path, 20)

    @title_offset_y = 15
    @squares_offset_y = 50

    @keyboard_letters = ("A".."Z").to_a
    @keyboard_rows = [
      %w(Q W E R T Y U I O P),
      %w(A S D F G H J K L),
      %w(Enter Z X C V B N M Supp)
    ]

    @keyboard_width = 800
    @keyboard_height = 200
    @keyboard_x = (width - @keyboard_width) / 2
    @keyboard_y = height - @keyboard_height - 50

    @square_size = 50
    @line_width = 5
    @start_x = (width - 5 * (@square_size + 10)) / 2
    @start_y = @title_offset_y + @font_title.height + @squares_offset_y

    @selected_letter = nil
  end

  def draw
    Gosu.draw_rect(0, 0, width, height, Gosu::Color::BLACK)

    draw_title
    draw_squares

    keyboard_width = (@square_size + 10) * @keyboard_rows[0].size + 10
    keyboard_height = 3 * (@square_size + 8) + 2 * 5

    squares_width = 5 * (@square_size + 10) - 10
    x_offset = (width - squares_width) / 2

    keyboard_x = x_offset + (squares_width - keyboard_width) / 2.45
    keyboard_y = @start_y + 6 * (@square_size + 10) + 30

    @keyboard_x = keyboard_x
    @keyboard_y = keyboard_y
    @keyboard_width = keyboard_width
    @keyboard_height = keyboard_height

    draw_keyboard

    display_guesses_remaining(width - 200, @start_y + 6 * (@square_size + 10) + 20)
    display_guessed_letters(width - 200, @start_y + 6 * (@square_size + 10) + 50)
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

  def needs_cursor?
    true
  end

  def mouse_down(x, y)
    if within_keyboard?(x, y)
      letter = get_letter_from_mouse_coords(x, y)
      if letter
        @selected_letter = letter
        update_squares(letter)
      end
    end
  end

  private

  def draw_title
    title_text = "Wordle"
    title_x = (width - @font_title.text_width(title_text) * 2) / 2.03
    title_y = @title_offset_y

    @font_title.draw_text(title_text, title_x, title_y, 0, scale_x = 2, scale_y = 2, Gosu::Color::WHITE)
  end

  def draw_squares
    6.times do |i|
      5.times do |j|
        x = @start_x + j * (@square_size + 10)
        y = @start_y + i * (@square_size + 10)

        Gosu.draw_rect(x, y, @square_size, @square_size, Gosu::Color::BLACK, z = 1)
        Gosu.draw_line(x, y, Gosu::Color::WHITE, x + @square_size, y, Gosu::Color::WHITE, @line_width)
        Gosu.draw_line(x + @square_size, y, Gosu::Color::WHITE, x + @square_size, y + @square_size, Gosu::Color::WHITE, @line_width)
        Gosu.draw_line(x + @square_size, y + @square_size, Gosu::Color::WHITE, x, y + @square_size, Gosu::Color::WHITE, @line_width)
        Gosu.draw_line(x, y + @square_size, Gosu::Color::WHITE, x, y, Gosu::Color::WHITE, @line_width)
      end
    end
  end

  def draw_keyboard
    letter_spacing = 5
    line_spacing = 8
    row_height = @square_size + line_spacing
    max_row_width = @keyboard_rows.map { |row| row.size * (@square_size + letter_spacing) - letter_spacing }.max

    current_y = @keyboard_y + (@keyboard_height - 3 * row_height + line_spacing) / 2

    @keyboard_rows.each do |row|
      row_width = row.size * (@square_size + letter_spacing) - letter_spacing
      current_x = @keyboard_x + (max_row_width - row_width) / 2

      row.each do |letter|
        if letter == @selected_letter
          if letter == 'Enter' || letter == 'Supp'
            Gosu.draw_rect(current_x, current_y, 2 * @square_size + letter_spacing, @square_size, Gosu::Color::GRAY, z = 2)
          else
            Gosu.draw_rect(current_x, current_y, @square_size, @square_size, Gosu::Color::GRAY, z = 2)
          end
          @font_letters.draw_text(letter, current_x + (@square_size - @font_letters.text_width(letter)) / 2, current_y + (@square_size - @font_letters.height) / 2, 2)
        else
          if letter == 'Enter' || letter == 'Supp'
            Gosu.draw_rect(current_x, current_y, 2 * @square_size + letter_spacing, @square_size, Gosu::Color::WHITE, z = 2)
          else
            Gosu.draw_rect(current_x, current_y, @square_size, @square_size, Gosu::Color::WHITE, z = 2)
          end
          @font_letters.draw_text(letter, current_x + (@square_size - @font_letters.text_width(letter)) / 2, current_y + (@square_size - @font_letters.height) / 2, 2, 1, 1, Gosu::Color::BLACK)
        end

        current_x += letter == 'Enter' || letter == 'Supp' ? 2 * @square_size + letter_spacing : @square_size + letter_spacing
      end

      current_y += row_height
    end
  end


  def within_keyboard?(x, y)
    x >= @keyboard_x && x <= @keyboard_x + @keyboard_width &&
      y >= @keyboard_y && y <= @keyboard_y + @keyboard_height
  end

  def get_letter_from_mouse_coords(x, y)
    letter_x = @keyboard_x + 10
    letter_y = @keyboard_y + 10
    letter_spacing = 10

    @keyboard_rows.each do |row|
      row.each do |letter|
        if x >= letter_x && x <= letter_x + @square_size && y >= letter_y && y <= letter_y + @square_size
          return letter
        end

        letter_x += @square_size + letter_spacing
      end

      letter_x = @keyboard_x + 10
      letter_y += @square_size + letter_spacing
    end

    nil
  end

  def update_squares(letter)
    return unless letter

    @guessed_letters << letter
    # Implement your logic to update the squares based on the guessed letter
    # This could involve comparing the guessed letters with the target word
    # and updating the squares accordingly

    # For demonstration purposes, let's randomly fill in the squares
    6.times do |i|
      5.times do |j|
        x = @start_x + j * (@square_size + 10)
        y = @start_y + i * (@square_size + 10)

        if rand(2).zero?
          Gosu.draw_rect(x, y, @square_size, @square_size, Gosu::Color::WHITE, z = 1)
        else
          Gosu.draw_rect(x, y, @square_size, @square_size, Gosu::Color::BLACK, z = 1)
        end
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
