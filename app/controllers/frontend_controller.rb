# frozen_string_literal: true

class FrontendController < ApplicationController

  layout false

  def index
    skip_authorization

    index_file = Rails.env.test? ? 'index-test' : 'index'
    render file: Rails.root.join("public/frontend-#{index_file}.html")
  end

  private

  def frontend_file
    index_name = 'index'

    if Rails.env.test? && File.exist?(file_path('index-test'))
      index_name = 'index-test'
    end

    file_path(index_name)
  end

  def file_path(index_name)
    Rails.root.join("public/frontend-#{index_name}.html")
  end
end
