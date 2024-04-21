# Changelog

## Version 0.2.5

* Added `main_model` (@rstankov)

## Version 0.2.4

* Rails 6+ support (@emilov)

## Version 0.2.3

* Fix handling delegated attributes prefixes in `attribute_names` (@rstankov)

## Version 0.2.2

* Bump activemodel requirements (@vestimir)

## Version 0.2.1

* Fix typo in `assignment` callbaks (@ayrton)
* Alias `assignment` to `assigment` for backwards compatibility (@ayrton)

## Version 0.2.0

* Don't expose model name on `model`. _(security fix)_

* Included `ActiveModel::Validations::Callbacks` to `MiniForm::Model`

* Added read option to `model`:

```ruby
class EditProfile
  include MiniForm::Model

  model :user, attributes: %i(email name), read:%(id)
end

profile = EditProfile.new(user: user)
profile.id
profile.id = 1 # raises NoMethodError
```


* MiniForm::Model can be inherited
* Added `assigment` callbacks, called when attributes are assigned
* Added `assign_attributes` alias to `attributes=`
* Exposed `errors` on MiniForm::InvalidForm
* Added descriptive message MiniForm::InvalidForm
* Made `.attribute_names` public

## Version 0.1.0

* Initial release
