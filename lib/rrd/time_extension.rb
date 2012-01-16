# -*- coding: UTF-8 -*-
require 'active_support/version'

if ActiveSupport::VERSION::MAJOR >= 3
  require 'active_support/core_ext/date/calculations'
  require 'active_support/core_ext/numeric/time'
  require 'active_support/core_ext/integer/time'
else
  require 'active_support/duration'
  require 'active_support/core_ext/numeric/time'
  require 'active_support/core_ext/integer/time'

  class Numeric
    include ActiveSupport::CoreExtensions::Numeric::Time
  end

  class Integer
    include ActiveSupport::CoreExtensions::Integer::Time
  end
end
