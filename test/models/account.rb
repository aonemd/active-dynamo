class Account < ActiveDynamo::Base
  table name: 'account'
  attributes :no
end
