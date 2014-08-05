module UsersHelper
  def button_for_option(opt, options)
    labels = {"s" => "S: звук", "p" => "K: позиция", "c" => "D: цвет", "f" => "L: форма"}
    disable = !(options.include? opt)
    button_tag labels[opt], value: opt, disabled: disable
  end
end
