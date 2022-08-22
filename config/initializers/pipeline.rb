# frozen_string_literal: true

PL_TARGET = %w[staging development test].include?(Rails.env) ? :staging : :production
