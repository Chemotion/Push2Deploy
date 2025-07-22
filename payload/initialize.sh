echo "seeding persons..." && bundle exec rails runner db/seeds/development/00_persons.seed.rb
echo "not seeding devices..." # && bundle exec rails runner db/seeds/development/01_devices.seed.rb
echo "seeding datacollector..." && bundle exec rails runner db/seeds/development/02_datacollector.seed.rb
echo "seeding vessels..." && bundle exec rails runner db/seeds/development/03_vessels.seed.rb
echo "seeding computed props..." && bundle exec rails runner db/seeds/development/04_computed_props.seed.rb