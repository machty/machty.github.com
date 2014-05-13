---
layout: post
title: "Daily Journal"
date: 2014-05-13 13:15
comments: true
categories: 
- Active Admin
---

## Sharing ignored blank password fields in ActiveAdmin

I use ActiveAdmin for some stuff, and often you want to update 
some resource while leaving its password the same, but if you have
a password field on the form, the form will POST with empty password
and empty confirmation you'll get a validation error from an empty
password. You can override this with a `controller` block in your
ActiveAdmin resource config via:

    controller do
      def update
        param_obj = params['admin_user']
        if param_obj[:password].blank?
          param_obj.delete("password")
          param_obj.delete("password_confirmation")
        end
        super
      end
    end

But if you have multiple Devise-esque resources with passwords, it'd be
nice to share this with multiple resources. It's a bit tricky to solve
this with idiomatic Ruby since you're already in ActiveAdmin's DSL land,
but the following works:

`/lib/admin/ignore_blank_password.rb`:

```ruby
module Admin
  module IgnoreBlankPassword
    def self.ignore(dsl)
      dsl.instance_eval do
        controller do
          def update
            param_key = resource.class.model_name.param_key.to_sym
            param_obj = params[param_key]
            if param_obj[:password].blank?
              param_obj.delete("password")
              param_obj.delete("password_confirmation")
            end
            super
          end
        end
      end
    end
  end
end
```

`/app/admin/admin_user.rb`:

```ruby
require 'admin/ignore_blank_password'
ActiveAdmin.register AdminUser do
  Admin::IgnoreBlankPassword.ignore(self)
  
  ...
end
```



