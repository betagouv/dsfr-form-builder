#!/usr/bin/env ruby

match_data = ARGV[0].match(/([0-9]+\.[0-9]+\.[0-9]+)/)
raise ArgumentError, "misformed version, should look like '0.0.13' (no v)" unless match_data

version = match_data[1]

current_git_branch = `git rev-parse --abbrev-ref HEAD`.strip
raise StandardError, "you need to be on main branch" if current_git_branch != "main"

raise StandardError, "your branch needs to be clean, no changes" unless `git status --porcelain`.empty?


commands = <<~BASH.split("\n")
  sed -E -i '' "s/[0-9]+.[0-9]+.[0-9]+/#{version}/" dsfr-form_builder.gemspec
  bundle
  git add dsfr-form_builder.gemspec Gemfile.lock
  git commit -m "release version #{version}"
  gem build dsfr-view-components.gemspec
  git tag -a "#{version}" -m "release version #{version}"
  git push
  git push origin "#{version}"
  gh release create "#{version}" --verify-tag --generate-notes
BASH

commands.each do |command|
  puts command
  res = system(command)
  raise Exception, "command failed!" unless res

  puts
end

puts "\n🚀 Almost done!"
puts "last step is to run this command with a valid 2FA OTP token for your rubygems account:"
puts "gem push dsfr-form_builder-#{version}.gem --otp 123456"
