# frozen_string_literal: true

class LokiCError < StandardError; end

class PopulationExecutionError < LokiCError; end
class CreationExecutionError < LokiCError; end
class CheckUpdatesExecutionError < LokiCError; end
class CronTabExecutionError < LokiCError; end
