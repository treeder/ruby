require 'open3'
require 'json'
require 'fileutils'

puts "treeder/ruby ARGV: #{ARGV.inspect}"
# puts "pwd: #{Dir.pwd}"
# puts "ls: #{`ls -al`}"
@volumes = "-v \"#{Dir.pwd}\":/app"

if ARGV.length < 1
  puts "No command provided."
end

def bundle(args=[])
  # nokogiri hack... ugly...
  exec("bundle config build.nokogiri --use-system-libraries")
  if args.length > 0
    # for example if user passed in bundle update
    exec("bundle #{args.join(' ')}")
  else
    exec("bundle install --standalone --clean")
  end
  exec("chmod -R a+rw .bundle")
  exec("chmod -R a+rw bundle")
end
#
# def image(args=[])
#   if args.length < 2
#     puts "treeder/ruby: image command requires image name and ruby script to run."
#     raise "treeder/ruby: image command requires image name and ruby script to run."
#   end
#   FileUtils.mkdir_p '/tmp/app'
#   exec("cp -r . /tmp/app")
#   # exec("cp /scripts/lib/Dockerfile /tmp/app")
#   File.open('/tmp/app/Dockerfile', 'w') { |file|
#     file.write("FROM iron/ruby
#     WORKDIR /app
#     COPY . /app/
#     ENTRYPOINT [\"ruby\", \"#{args[1]}\"]
#     ")
#   }
#   exec("ls -al /tmp/app")
#   FileUtils.cd('/tmp/app') do
#     exec("/usr/bin/docker version")
#     exec("/usr/bin/docker build -t #{args[0]} .")
#   end
# end

def exec(cmd, args = [])
  split = cmd.split(' ')
  puts "Exec: #{(split + args).join(' ')}"
  base = split.shift
  Open3.popen2e(base, *(split + args)) {|i,oe,t|
    pid = t.pid # pid of the started process.
    i.close # ensure this exits when it's done with output
    oe.each {|line|
      if /warning/ =~ line
        puts 'warning'
      end
      puts line
    }
    exit_status = t.value # Process::Status object returned.
    # puts "exit_status: #{exit_status}"
  }
end

cmd = ARGV.shift
case cmd
when 'bundle' || 'vendor'
  bundle(ARGV)
when 'image'
  image(ARGV)
else
  puts "treeder/ruby: Invalid command, see https://github.com/treeder/dockers/tree/master/go for reference."
end
