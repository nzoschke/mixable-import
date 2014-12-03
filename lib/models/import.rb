class Import < Sequel::Model
  plugin :timestamps
  many_to_one :user, key: :user_uuid
end
