# lenght of the word 5, no time limit, there is only one player playingm he has 6 guesses to find the word
require 'gosu'
ORANGE = Gosu::Color.new(255, 255, 165, 0)

class WordleGame < Gosu::Window
  def initialize
    super(900, 800)
    self.caption = 'Wordle Game'

    @target_word = "apple".upcase
    @guesses_remaining = 6
    @guessed_letters = []
    @current_row = 0
    @letters_to_draw = Array.new(30)

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
    @current_position = 0

  end

  def draw
    Gosu.draw_rect(0, 0, width, height, Gosu::Color.argb(255, 0, 0, 0))

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

    if @key_press_animation
      x = @keyboard_x + 10
      y = @keyboard_y + 10
      letter_spacing = 10

      @keyboard_rows.each do |row|
        row.each do |letter|
          if letter == @key_press_animation
            rect_x = x - 5
            rect_y = y - 5
            rect_width = @square_size + 10
            rect_height = @square_size + 10
            rect_color = Gosu::Color.argb(200, 255, 255, 255)

            Gosu.draw_rect(rect_x, rect_y, rect_width, rect_height, rect_color, z = 3)
          end

          x += @square_size + letter_spacing
        end

        x = @keyboard_x + 10
        y += @square_size + letter_spacing
      end

      @animation_frame += 1
      if @animation_frame >= 30
        @key_press_animation = nil
        @animation_frame = 0
      end
    end
  end

  def button_down(id)
    if [Gosu::KbReturn, Gosu::KbEnter].include?(id)
      submit_word
    elsif id == Gosu::KB_ESCAPE
      close
    elsif id == Gosu::KB_BACKSPACE
      delete_last_letter
    else
      letter = Gosu.button_id_to_char(id).upcase if Gosu.button_down?(id) && Gosu.button_id_to_char(id)
      if letter && @keyboard_letters.include?(letter)
        @selected_letter = letter
        animate_key_press(letter)
        update_squares(letter)
      end
    end
  end

  def needs_cursor?
    true
  end

  def button_up(id)
    if id == Gosu::MS_LEFT
      mouse_x = self.mouse_x
      mouse_y = self.mouse_y

      if within_keyboard?(mouse_x, mouse_y)
        action_or_letter = get_action_or_letter_from_mouse_coords(mouse_x, mouse_y)

        if action_or_letter == 'Enter'
          submit_word
        elsif action_or_letter == 'Supp'
          delete_last_letter
        elsif action_or_letter
          @selected_letter = action_or_letter
          animate_key_press(action_or_letter)
          update_squares(action_or_letter)
        end
      end
    end
  end

  def get_action_or_letter_from_mouse_coords(x, y)
    letter_x = @keyboard_x + 10
    letter_y = @keyboard_y + 10
    letter_spacing = 10

    @keyboard_rows.each do |row|
      row.each do |action_or_letter|
        if x >= letter_x && x <= letter_x + @square_size && y >= letter_y && y <= letter_y + @square_size
          return action_or_letter
        end

        letter_x += @square_size + letter_spacing
      end

      letter_x = @keyboard_x + 10
      letter_y += @square_size + letter_spacing
    end

    nil
  end

  def animate_key_press(letter)
    @key_pressed[letter] = true
    @key_press_animation = letter
    @animation_frame = 0
  end

  def update
    super
    @key_pressed = {} # Reset the key_pressed hash to empty after each frame
  end

  private

  def draw_title
    title_text = "Wordle"
    title_x = (width - @font_title.text_width(title_text) * 2) / 2.03
    title_y = @title_offset_y

    @font_title.draw_text(title_text, title_x, title_y, 0, scale_x = 2, scale_y = 2, Gosu::Color::WHITE)
  end

  def draw_squares
    @letters_to_draw.each_with_index do |letter, index|
      i = index / 5
      j = index % 5
      x = @start_x + j * (@square_size + 10)
      y = @start_y + i * (@square_size + 10)

      Gosu.draw_rect(x, y, @square_size, @square_size, Gosu::Color::BLACK, z = 1)
      Gosu.draw_line(x, y, Gosu::Color::WHITE, x + @square_size, y, Gosu::Color::WHITE, @line_width)
      Gosu.draw_line(x + @square_size, y, Gosu::Color::WHITE, x + @square_size, y + @square_size, Gosu::Color::WHITE, @line_width)
      Gosu.draw_line(x + @square_size, y + @square_size, Gosu::Color::WHITE, x, y + @square_size, Gosu::Color::WHITE, @line_width)
      Gosu.draw_line(x, y + @square_size, Gosu::Color::WHITE, x, y, Gosu::Color::WHITE, @line_width)

      draw_letter_in_square(letter, x, y) if letter # This will only draw the letter if it is not nil
    end
  end

  def draw_keyboard
    letter_spacing = 10
    line_spacing = 8
    row_height = @square_size + line_spacing
    max_row_width = @keyboard_rows.map { |row| row.size * (@square_size + letter_spacing) - letter_spacing }.max

    current_y = @keyboard_y + (@keyboard_height - 3 * row_height + line_spacing) / 2

    @keyboard_rows.each do |row|
      row_width = row.size * (@square_size + letter_spacing) - letter_spacing
      current_x = @keyboard_x + (max_row_width - row_width) / 2

      row.each do |letter|
        if letter == @selected_letter
          if @key_pressed[letter]
            rect_color = Gosu::Color::GRAY
            text_color = Gosu::Color::WHITE
            rect_y_offset = 4
          else
            rect_color = Gosu::Color::WHITE
            text_color = Gosu::Color::BLACK
            rect_y_offset = 0
          end
          text_x = current_x + (@square_size - @font_letters.text_width(letter)) / 2
          text_y = current_y + (@square_size - @font_letters.height) / 2 + rect_y_offset
          Gosu.draw_rect(current_x, current_y + rect_y_offset, @square_size, @square_size - rect_y_offset, rect_color, z = 2)
          @font_letters.draw_text(letter, text_x, text_y, 2, 1, 1, text_color)
        else
          Gosu.draw_rect(current_x, current_y, @square_size, @square_size, Gosu::Color::WHITE, z = 2)
          text_x = current_x + (@square_size - @font_letters.text_width(letter)) / 2
          text_y = current_y + (@square_size - @font_letters.height) / 2
          @font_letters.draw_text(letter, text_x, text_y, 2, 1, 1, Gosu::Color::BLACK)
        end

        current_x += @square_size + letter_spacing
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

    if @current_position < 5 # Only allow 5 letters per line
      @guessed_letters << letter
      @letters_to_draw[@current_row * 5 + @current_position] = letter
      @current_position += 1
    end
  end

  def needs_text_input?
    true
  end

  def is_valid_word?(word)
    word == @target_word
  end

  def submit_word
    if is_valid_word?(@guessed_letters)
      check_word
      @current_row += 1
      @guessed_letters.clear

      # Reset the letters to draw for the next row
      @letters_to_draw.fill(nil, @current_row * 5, 5)
    end
  end

  def check_word
    target_word_letters = @target_word.split("")
    @guessed_letters.each_with_index do |letter, index|
      if target_word_letters[index] == letter
        @letters_to_draw[@current_row * 5 + index] = Gosu::Color::GREEN
      elsif target_word_letters.include?(letter)
        @letters_to_draw[@current_row * 5 + index] = ORANGE
      else
        @letters_to_draw[@current_row * 5 + index] = Gosu::Color::BLACK
      end
    end
  end

  def delete_last_letter
    # Remove the last letter from the guessed_letters array
    @guessed_letters.pop

    # Remove the letter from the display
    @current_position -= 1
    @letters_to_draw[@current_row * 5 + @current_position] = nil
  end

  def draw_letter_in_square(letter, x, y)
    text_x = x + (@square_size - @font_letters.text_width(letter)) / 2
    text_y = y + (@square_size - @font_letters.height) / 2
    @font_letters.draw_text(letter, text_x, text_y, 2, 1, 1, Gosu::Color::WHITE)  # Use Gosu::Color::WHITE
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
