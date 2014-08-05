module UsersHelper
  def button_for_option(opt)
    labels = {"s" => "S: звук", "p" => "K: позиция", "c" => "D: цвет", "f" => "L: форма"}
    button_tag labels[opt], value: opt #"button value=#{opt} #{labels[opt]}"
  end
end
