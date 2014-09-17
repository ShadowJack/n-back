# Helpers for user views
module UsersHelper
  # Makes a button for particuar opt - option
  # and disables it if it is not in list of available options
  def button_for_option(opt, options)
    labels = { 's' => 'S: звук',
               'p' => 'K: позиция',
               'f' => 'D: форма',
               'c' => 'L: цвет' }
    disable = !(options.include? opt)
    button_tag labels[opt], value: opt, disabled: disable, class: 'ctrl-btn'
  end
end
