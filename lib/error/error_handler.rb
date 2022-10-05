module Error
  module ErrorHandler
    def self.included(clazz)
      clazz.class_eval do
        rescue_from StandardError,                with: :standard_error
        rescue_from ActiveRecord::RecordNotFound, with: :not_found
        rescue_from ActiveRecord::RecordInvalid,
                    ActiveRecord::RecordNotSaved, with: :unprocessable_entity
      end
    end

    private

    def not_found(exception)
      @exception = exception
      backtrace  = exception.backtrace.second

      current_account.exception_records.create(name: exception.class.name,
                                               description: exception,
                                               backtrace: backtrace,
                                               requested_params: params.to_unsafe_hash)

      render 'errors/not_found'
    end

    def standard_error(exception)
      @exception = exception
      @backtrace = exception.backtrace.first

      current_account.exception_records.create(name: exception.class.name,
                                               description: exception,
                                               backtrace: @backtrace,
                                               requested_params: params.to_unsafe_hash)

      render 'errors/standard_error'
    end

    def unprocessable_entity(exception)
      @exception = exception

      current_account.exception_records.create(name: exception.class.name,
                                               description: exception,
                                               requested_params: params.to_unsafe_hash)

      render 'errors/unprocessable_entity'
    end
  end
end
