class ShortPassword < StandardError
end

class WeakPassword < StandardError
end

class WrongPassword < StandardError
  
end

class NoMatch < StandardError
end

class NameTaken < StandardError
end

class CategoryEmpty < StandardError
end

class NameWithSpaces < StandardError
end

class NothingEntered < StandardError
end