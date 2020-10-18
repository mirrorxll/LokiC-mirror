# frozen_string_literal: true

class Week < SecondaryRecord # :nodoc:

  def to_s
    if self.begin.month == self.end.month
      "#{self.begin.strftime("%d")}-#{self.end.strftime("%d")}.#{self.begin.strftime("%m")}"
    else
      "#{self.begin.strftime("%d")}.#{self.begin.strftime("%m")}-#{self.end.strftime("%d")}.#{self.end.strftime("%m")}"
    end
  end
end
