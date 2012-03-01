notification :libnotify, :timeout => 3, :transient => true, :append => true, :sticky => false

guard 'bundler' do
  watch('Gemfile')
  watch(/^.+\.gemspec/)
end

guard 'rspec', :version => 2, :cli => "--tag focus --format Fuubar" do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
  watch('spec/support') {"spec"}
end

