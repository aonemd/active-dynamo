class Account < ActiveDynamo::Base
  table name: 'account', partition_key: :no, sort_key: :balance
  attributes :no, :balance, :kind
end
