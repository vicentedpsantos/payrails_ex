Payrails.HTTP.Mock.setup!()

# Exclude integration tests by default (require real credentials)
ExUnit.start(exclude: [:integration])
