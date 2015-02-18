# Formi

Minor form object. Name is still unknow

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'formi'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install formi

## Usage

```ruby
class ProductForm
  include Formi

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

**[MIT License](https://github.com/RStankov/formi/blob/master/LICENSE.txt)**
