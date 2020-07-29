# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :token

  def json_token
    token.raw.to_json
  end
end
