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
  include FormObject::Model

  attributes :id, :name, :price, :description

  validates :name, :price, :description, presence: true

  # called after successful validations in update
  def perform
    @id = ExternalService.create(attributes)
  end
end
```

```ruby
class ProductsController < ApplicationController
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
end
```

### Delegated attributes

Attributes can be delegated to a sub object.

```ruby
class SignUpForm
  include FormObject::Model

  attr_reader :account, :user

  attributes :name, :email, delegate: :user
  attributes :company_name, :plan, delegate: :account

  validates :name, :email, :company_name, :plan, presence: true

  def initialize
    @account = Account.new
    @user    = User.new account: @account
  end

  def perform
    user.save!
    account.save!
  end
end
```

```ruby
form = SignUpForm.new
form.name = 'name' # => form.user.name = 'name'
form.name          # => form.user.name
form.plan = 'free' # => form.account.plan = 'free'
form.plan          # => form.account.plan
```

### Nested validator

`form_object/nested` validator runs validations on the given model and copies errors to the form object.

```ruby
class SignUpForm
  include FormObject::Model

  attr_reader :account, :user

  attributes :name, :email, delegate: :user
  attributes :company_name, :plan, delegate: :account

  validates :account, :user, 'form_object/nested' => true

  def initialize
    @account = Account.new
    @user    = User.new account: @account
  end

  def perform
    account.save!
    user.save!
  end
end
```

### Nested models

Combines delegated attributes and nested validation into a single call.

```ruby
class SignUpForm
  include FormObject::Model

  modal :user, attributes: %i(name email)
  model :account, attributes: %i(company_name plan)

  def initialize
    @account = Account.new
    @user    = User.new account: @account
  end

  def perform
    account.save!
    user.save!
  end
end
```

### Auto saving nested models

In most of the time `perform` is just calling `save!`.

```ruby
class SignUpForm
  include FormObject::Model

  modal :user, attributes: %i(name email), save: true
  model :account, attributes: %i(company_name plan), save: true

  def initialize
    @account = Account.new
    @user    = User.new account: @account
  end
end
```

### Before/after callbacks

```ruby
class SignUpForm
  include FormObject::Model

  # ... code

  before_update :run_before_update
  after_update :run_after_update

  private

  def run_before_update
    # ...
  end

  def run_after_update
    # ...
  end

  # alternatively you can overwrite "before_update"
  def before_update
  end

  # alternatively you can overwrite "after_update"
  def after_update
  end
end
```

### Methods

<table>
  <tr>
    <th>Method</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>.model</td>
    <td>Defines a sub object for the form</td>
  </tr>
  <tr>
    <td>.attributes</td>
    <td>Defines an attribute, it can delegate to sub object</td>
  </tr>
  <tr>
    <td>#initialize</td>
    <td>Meant to be overwritten. By defaults calls `attributes=`</td>
  </tr>
  <tr>
    <td>#attributes=</td>
    <td>Sets values of all attributes</td>
  </tr>
  <tr>
    <td>#attributes</td>
    <td>Returns all attributes of the form</td>
  </tr>
  <tr>
    <td>#update</td>
    <td>Sets attributes, calls validations, saves models and `perform`</td>
  </tr>
  <tr>
    <td>#update!</td>
    <td>Calls `update`. If validation fails, it raises an error</td>
  </tr>
  <tr>
    <td>#perform</td>
    <td>Meant to be overwritten. Doesn't do anything by default</td>
  </tr>
  <tr>
    <td>#before_update</td>
    <td>Meant to be overwritten.</td>
  </tr>
  <tr>
    <td>#after_update</td>
    <td>Meant to be overwritten.</td>
  </tr>
  <tr>
    <td>#transaction</td>
    <td>If ActiveRecord is available, wraps `perform` in transaction.</td>
  </tr>
</table>

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Run the tests (`rake`)
6. Create new Pull Request

## License

**[MIT License](https://github.com/RStankov/FormObject/blob/master/LICENSE.txt)**
