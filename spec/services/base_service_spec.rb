require 'spec_helper'
require 'ffi-rzmq'

module Service
  describe BaseService do
    it_behaves_like "a service"
  end
end