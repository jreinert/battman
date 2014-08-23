module Batman
  class AbstractError < RuntimeError; end
  class NotImplementedError < RuntimeError; end
  class WrongStateError < RuntimeError; end
end
