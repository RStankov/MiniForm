[![Code Climate](https://codeclimate.com/github/RStankov/FormObject.png)](https://codeclimate.com/github/RStankov/FormObject)
[![Build Status](https://secure.travis-ci.org/RStankov/FormObject.png)](http://travis-ci.org/RStankov/FormObject)
[![Code coverage](https://coveralls.io/repos/RStankov/FormObject/badge.png?branch=master)](https://coveralls.io/r/RStankov/FormObject)

# FormObject

Helpers for dealing with form objects and nested forms.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'form_object'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install form_object

## Usage

```ruby
class ProductForm
  include FormObject

  attributes :name, :price, :description

  validates :name, :price, :description, presence: true

  attr_reader :id

  # this is called after successfull update
  def perfom
    @id = ExternalService.create(attributes)
  end
end
```

```ruby
def create
  @product = ProductForm.new

  if @product.update(product_params)
    redirect_to product_path(product.id)
  else
    render :edit
  end
end

private

def product_params
  params.require(:product).permit(:name, :price, :description)
end
```

### Nested models

### Nested validator

### Before/after callbacks

### Delegated attributes

### Methods

```ruby
.model
.attributes

#attributes=(attributes)
#attributes
#update(attributes = {})
#update!(attributes = {})
#persited?
```

+ included modules - ActiveModel::Model

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Run the tests (`rake`)
6. Create new Pull Request

## License

**[MIT License](https://github.com/RStankov/FormObject/blob/master/LICENSE.txt)**
