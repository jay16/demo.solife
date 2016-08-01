# encoding: utf-8
module API
  # api base controller
  class ApplicationController < ::ApplicationController

    get '/single_quota' do
      hash = {
        one: "问: '云散水枯，汝归何处？'",
        two: "反问: '何为云水？'",
        three: "答: '心似白云常自在，意如流水任东西。'"
      }

      respond_with_json(hash)
    end
  end
end
