active-dynamo
---

An ActiveRecord like ODM for AWS DynamoDB

## Installation

```sh
gem install active-dynamo
```

## Usage

Currently, the supported operations are as follows:

- Define a model in a way similar to ActiveRecord, calling `table_name` and
  `attributes` functions:

```ruby
class Account < ActiveDynamo::Base
  table name: 'account', partition_key: :no, sort_key: :balance
  attributes no: Integer, balance: Integer, kind: String
end
```

- Create a new record:

```ruby
account = Account.new(no: 123, balance: 2000, kind: 'current')
account.save

# or use `create`
account = Account.create(no: 123, balance: 2000, kind: 'current')
```

- Query the table using methods such as:

```ruby
Account.all

Account.where(no: 123, balance: 2000)
Account.where("no = 123 and balance >= 2000 and kind = 'current'")

Account.find(no: 123, balance: 2000)
```

- Update a record

```ruby
account = Account.first
account.update(kind: 'savings')
```

- Delete a record

```ruby
Account.destroy(no: 123, balance: 2000)
```

## License

See [LICENSE](https://github.com/aonemd/active-dynamo/blob/master/LICENSE).
