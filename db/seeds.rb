# Safe to run repeatedly.
Setting.current

if Section.none?
  [ "Church Leaders", "Members — Part One", "Members — Part Two", "Members — Part Three" ]
    .each_with_index { |name, i| Section.create!(name: name, position: i) }
end

if OfferingType.none?
  OfferingType.create!(name: "Tithe", position: 0, counts_for_ldf: true)
  OfferingType.create!(name: "Offering", position: 1, counts_for_ldf: true)
end

if User.none?
  email = ENV.fetch("ADMIN_EMAIL", "admin@example.com")
  password = ENV.fetch("ADMIN_PASSWORD") { SecureRandom.alphanumeric(14) }
  User.create!(name: "Administrator", email_address: email, password: password, admin: true)
  puts "Created admin user #{email} with password: #{password}  (change it after first login)"
end
