# encoding: utf-8

require 'rabl_presenters/base'
require 'rabl_presenters/enumerable'

class ActionController::Base
  def present object, options={}
    RablPresenter::Base.present(object, self, options)
  end
end
