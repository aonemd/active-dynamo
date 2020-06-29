class Account < ActiveDynamo::Base
  table name: 'accounts'
  attributes :no
end
