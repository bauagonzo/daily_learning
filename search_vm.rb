require 'rbvmomi'
require 'rbvmomi/trollop'
require 'awesome_print'
require 'pry'

opts = Trollop.options do
  banner <<-EOS
Search for a VM.

Usage:
    search_vm.rb [options] VM name

VIM connection options:
  EOS

  rbvmomi_connection_opts

  text <<-EOS

Other options:
  EOS
end

Trollop.die("must specify host") unless opts[:host]
vm_name = ARGV[0] or abort "must specify VM name"

def search_vms folder, pattern
  folder.childEntity.each do |x|
    case x
    when RbVmomi::VIM::Folder
      search_vms(x, pattern)
    when RbVmomi::VIM::VirtualMachine
      puts x.name if Regexp.new(pattern) =~ x.name
    end
  end
end



vim = RbVmomi::VIM.connect opts

datacenters = vim.serviceInstance.content.rootFolder.childEntity
datacenters.each do |dc|
  # binding.pry # can be useful for interactive queries or debugging
  search_vms(dc.vmFolder, vm_name)
end
