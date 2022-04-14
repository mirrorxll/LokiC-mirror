# frozen_string_literal: true

PL_TARGET = %w[development test].include?(Rails.env) ? :staging : :production
